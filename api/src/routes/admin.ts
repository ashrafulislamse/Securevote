// Admin routes: dashboard stats, voter registry, KYC queue, fraud alerts,
// organizations, and audit log. Admin + verifier roles.

import { Hono } from "hono";
import { zValidator } from "@hono/zod-validator";
import { auth, requireRole, type AppContext, type AuthUser } from "../middleware/auth";
import { audit, computeEntryHash, GENESIS_HASH } from "../middleware/audit";
import {
  createOrganizationSchema,
  updateOrganizationSchema,
  createAlertSchema,
  resolveAlertSchema,
  bulkVoterStatusSchema,
  notifyVotersSchema,
  updateVoterSchema,
  importVotersSchema,
} from "../schemas";
import { uuid, now } from "../lib/utils";
import { hashPassword } from "../lib/password";

export const adminRoutes = new Hono<AppContext>()
  .use(auth())
  .use(requireRole("admin", "verifier"));

// ---------------------------------------------------------------------------
// GET /admin/stats — dashboard KPIs.
// ---------------------------------------------------------------------------
adminRoutes.get("/stats", async (c) => {
  const [elections, voters, boosted, votes] = await Promise.all([
    c.env.DB.prepare("SELECT COUNT(*) AS n FROM elections").first(),
    c.env.DB.prepare("SELECT COUNT(*) AS n FROM users").first(),
    c.env.DB.prepare("SELECT COUNT(*) AS n FROM users WHERE kyc_status = 'approved'").first(),
    c.env.DB.prepare("SELECT COUNT(*) AS n FROM votes").first(),
  ]);

  const byStatus = await c.env.DB.prepare(
    "SELECT status, COUNT(*) AS n FROM elections GROUP BY status",
  ).all();

  return c.json({
    stats: {
      totalElections: elections?.n ?? 0,
      totalVoters: voters?.n ?? 0,
      approvedVoters: boosted?.n ?? 0,
      totalVotes: votes?.n ?? 0,
    },
    electionStatus: byStatus.results,
  });
});

// ---------------------------------------------------------------------------
// GET /admin/voters — voter registry with search + status filter.
// ---------------------------------------------------------------------------
adminRoutes.get("/voters", async (c) => {
  const { q, status, kycStatus, limit = "50", offset = "0" } = c.req.query();
  let sql =
    "SELECT id, email, full_name, phone, role, kyc_status, status, created_at FROM users WHERE role = 'voter'";
  const params: unknown[] = [];
  if (q) {
    sql += " AND (email LIKE ? OR full_name LIKE ?)";
    params.push(`%${q}%`, `%${q}%`);
  }
  if (status) {
    sql += " AND status = ?";
    params.push(status);
  }
  if (kycStatus) {
    sql += " AND kyc_status = ?";
    params.push(kycStatus);
  }
  sql += " ORDER BY created_at DESC LIMIT ? OFFSET ?";
  params.push(parseInt(limit, 10), parseInt(offset, 10));

  const { results } = await c.env.DB.prepare(sql).bind(...params).all();
  return c.json({
    voters: results.map((r: any) => ({
      id: r.id,
      email: r.email,
      fullName: r.full_name,
      phone: r.phone,
      role: r.role,
      kycStatus: r.kyc_status,
      status: r.status,
      createdAt: r.created_at,
    })),
  });
});

// ---------------------------------------------------------------------------
// GET /admin/voters/:id — single voter detail.
// ---------------------------------------------------------------------------
adminRoutes.get("/voters/:id", async (c) => {
  const id = c.req.param("id");
  const voter = await c.env.DB.prepare(
    `SELECT u.id, u.email, u.full_name, u.phone, u.role, u.kyc_status, u.status,
            u.notes, u.created_at,
            (SELECT COUNT(*) FROM votes v WHERE v.user_id = u.id) AS vote_count
     FROM users u WHERE u.id = ?`,
  )
    .bind(id)
    .first();
  if (!voter) return c.json({ error: "voter not found" }, 404);

  const votes = await c.env.DB.prepare(
    `SELECT v.id, v.receipt_id, v.created_at, e.title AS election_title
     FROM votes v JOIN elections e ON e.id = v.election_id
     WHERE v.user_id = ? ORDER BY v.created_at DESC`,
  )
    .bind(id)
    .all();

  return c.json({
    voter: {
      id: voter.id,
      email: voter.email,
      fullName: voter.full_name,
      phone: voter.phone,
      role: voter.role,
      kycStatus: voter.kyc_status,
      status: voter.status,
      notes: voter.notes,
      createdAt: voter.created_at,
      vote_count: voter.vote_count,
    },
    votes: votes.results.map((v: any) => ({
      id: v.id,
      receiptId: v.receipt_id,
      createdAt: v.created_at,
      election_title: v.election_title,
    })),
  });
});

// ---------------------------------------------------------------------------
// GET /admin/audit-log — recent audit entries (now with hash chain fields).
// Optional ?verify=true runs a full chain check (cached in KV for 60s).
// ---------------------------------------------------------------------------
adminRoutes.get("/audit-log", async (c) => {
  const { limit = "100", action, verify } = c.req.query();
  let sql = "SELECT * FROM audit_log";
  const params: unknown[] = [];
  if (action) {
    sql += " WHERE action = ?";
    params.push(action);
  }
  sql += " ORDER BY created_at DESC LIMIT ?";
  params.push(parseInt(limit, 10));
  const { results } = await c.env.DB.prepare(sql).bind(...params).all();

  const payload: Record<string, unknown> = { logs: results };

  if (verify === "true") {
    payload.chain = await cachedVerify(c);
  }

  return c.json(payload);
});

// ---------------------------------------------------------------------------
// GET /admin/audit-log/verify — walk the chain and report integrity.
// ---------------------------------------------------------------------------
adminRoutes.get("/audit-log/verify", async (c) => {
  return c.json(await computeChainStatus(c.env.DB));
});

/** Walk the audit log in chronological order and recompute each entry_hash. */
async function computeChainStatus(db: D1Database): Promise<{
  ok: boolean;
  totalEntries: number;
  firstEntryAt: number | null;
  lastEntryAt: number | null;
  brokenAt: string | null;
  reason: string | null;
}> {
  // Pull every row ordered chronologically. D1 pages internally; for the
  // expected volume (audit events) a single page is fine.
  const { results } = await db
    .prepare(
      "SELECT id, actor_id, action, target_type, target_id, metadata, " +
        "ip_address, created_at, prev_hash, entry_hash " +
        "FROM audit_log ORDER BY created_at ASC, id ASC",
    )
    .all<{
      id: string;
      actor_id: string | null;
      action: string;
      target_type: string | null;
      target_id: string | null;
      metadata: string | null;
      ip_address: string | null;
      created_at: number;
      prev_hash: string;
      entry_hash: string;
    }>();

  const rows = results ?? [];
  if (rows.length === 0) {
    return {
      ok: true,
      totalEntries: 0,
      firstEntryAt: null,
      lastEntryAt: null,
      brokenAt: null,
      reason: null,
    };
  }

  let expectedPrev = GENESIS_HASH;
  for (const row of rows) {
    if (row.prev_hash !== expectedPrev) {
      return {
        ok: false,
        totalEntries: rows.length,
        firstEntryAt: rows[0]!.created_at,
        lastEntryAt: rows[rows.length - 1]!.created_at,
        brokenAt: row.id,
        reason: `prev_hash mismatch at ${row.id}: expected ${expectedPrev.slice(0, 12)}..., got ${row.prev_hash.slice(0, 12)}...`,
      };
    }
    const recomputed = await computeEntryHash({
      prevHash: row.prev_hash,
      action: row.action,
      actorId: row.actor_id,
      targetType: row.target_type,
      targetId: row.target_id,
      metadata: row.metadata,
      ip: row.ip_address,
      createdAt: row.created_at,
    });
    if (recomputed !== row.entry_hash) {
      return {
        ok: false,
        totalEntries: rows.length,
        firstEntryAt: rows[0]!.created_at,
        lastEntryAt: rows[rows.length - 1]!.created_at,
        brokenAt: row.id,
        reason: `entry_hash mismatch at ${row.id}: stored ${row.entry_hash.slice(0, 12)}..., recomputed ${recomputed.slice(0, 12)}...`,
      };
    }
    expectedPrev = row.entry_hash;
  }

  return {
    ok: true,
    totalEntries: rows.length,
    firstEntryAt: rows[0]!.created_at,
    lastEntryAt: rows[rows.length - 1]!.created_at,
    brokenAt: null,
    reason: null,
  };
}

/** Cache the verify result in KV for 60s so the badge stays snappy. */
async function cachedVerify(
  c: { env: { DB: D1Database; SESSIONS?: KVNamespace } },
): Promise<Awaited<ReturnType<typeof computeChainStatus>>> {
  const kv = c.env.SESSIONS;
  if (kv) {
    const cached = await kv.get("audit-chain:status", "json");
    if (cached) {
      return cached as Awaited<ReturnType<typeof computeChainStatus>>;
    }
  }
  const status = await computeChainStatus(c.env.DB);
  if (kv) {
    await kv.put("audit-chain:status", JSON.stringify(status), {
      expirationTtl: 60,
    });
  }
  return status;
}

// ---------------------------------------------------------------------------
// GET /admin/alerts — anomaly/fraud alerts.
// Reads from the persisted `alerts` table. If the table is empty, falls back
// to synthesising rows from the sessions heuristic (preserves prior behavior).
// ---------------------------------------------------------------------------
adminRoutes.get("/alerts", async (c) => {
  const { status } = c.req.query();
  let sql = "SELECT id, type, severity, target, title, body, status, assigned_to, metadata, created_at, resolved_at FROM alerts";
  const params: unknown[] = [];
  if (status) {
    sql += " WHERE status = ?";
    params.push(status);
  }
  sql += " ORDER BY created_at DESC LIMIT 100";
  const { results } = await c.env.DB.prepare(sql).bind(...params).all<Record<string, unknown>>();

  type AlertRow = {
    id: unknown;
    type: unknown;
    severity: unknown;
    target: unknown;
    title?: unknown;
    body?: unknown;
    status?: unknown;
    assignedTo?: unknown;
    metadata?: unknown;
    count?: unknown;
    createdAt: unknown;
    resolvedAt?: unknown;
  };

  let alerts: AlertRow[] = results.map((r) => ({
    id: r.id,
    type: r.type,
    severity: r.severity,
    target: r.target,
    title: r.title,
    body: r.body,
    status: r.status,
    assignedTo: r.assigned_to,
    metadata: r.metadata ? JSON.parse(r.metadata as string) : null,
    createdAt: r.created_at,
    resolvedAt: r.resolved_at,
  }));

  // Fallback: synthesise from the sessions heuristic if no persisted alerts.
  if (alerts.length === 0) {
    const duplicates = await c.env.DB.prepare(
      "SELECT user_id, COUNT(*) AS n FROM sessions WHERE revoked_at IS NULL GROUP BY user_id ORDER BY n DESC LIMIT 5",
    ).all();
    alerts = duplicates.results
      .filter((r: Record<string, unknown>) => (r.n as number) > 3)
      .map((r: Record<string, unknown>) => ({
        id: `alert_${r.user_id}`,
        type: "MULTIPLE_SESSIONS",
        severity: "medium",
        target: r.user_id,
        count: r.n,
        createdAt: Date.now(),
      }));
  }

  return c.json({ alerts });
});

// ---------------------------------------------------------------------------
// GET /admin/recent-elections — for the dashboard table.
// ---------------------------------------------------------------------------
adminRoutes.get("/recent-elections", async (c) => {
  const { results } = await c.env.DB.prepare(
    `SELECT e.*, (SELECT COUNT(*) FROM votes v WHERE v.election_id = e.id) AS vote_count
     FROM elections e ORDER BY e.created_at DESC LIMIT 10`,
  ).all();
  return c.json({ elections: results });
});

// ---------------------------------------------------------------------------
// Organizations CRUD — backs the admin Organizations page.
// ---------------------------------------------------------------------------

function orgFromRow(r: Record<string, unknown>) {
  return {
    id: r.id,
    name: r.name,
    plan: r.plan,
    members: r.members,
    status: r.status,
    createdAt: r.created_at,
  };
}

adminRoutes.get("/organizations", async (c) => {
  const { results } = await c.env.DB.prepare(
    "SELECT * FROM organizations ORDER BY created_at DESC",
  ).all<Record<string, unknown>>();
  return c.json({ organizations: results.map(orgFromRow) });
});

adminRoutes.post(
  "/organizations",
  zValidator("json", createOrganizationSchema),
  async (c) => {
    const data = c.req.valid("json");
    const admin = c.get("user") as AuthUser;
    const id = uuid();

    await c.env.DB.prepare(
      `INSERT INTO organizations (id, name, plan, members, status, created_at)
       VALUES (?, ?, ?, ?, ?, ?)`,
    )
      .bind(id, data.name, data.plan, data.members ?? 0, data.status, now())
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: "organization.create",
      targetType: "organization",
      targetId: id,
      metadata: { name: data.name, plan: data.plan },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true, organization: { id, name: data.name, plan: data.plan, members: data.members ?? 0, status: data.status } }, 201);
  },
);

adminRoutes.patch(
  "/organizations/:id",
  zValidator("json", updateOrganizationSchema),
  async (c) => {
    const id = c.req.param("id");
    const data = c.req.valid("json");
    const admin = c.get("user") as AuthUser;

    const row = await c.env.DB.prepare("SELECT id FROM organizations WHERE id = ?")
      .bind(id)
      .first();
    if (!row) return c.json({ error: "organization not found" }, 404);

    const fields: Record<string, unknown> = {
      name: data.name,
      plan: data.plan,
      members: data.members,
      status: data.status,
    };
    const sets: string[] = [];
    const params: unknown[] = [];
    for (const [col, val] of Object.entries(fields)) {
      if (val !== undefined) {
        sets.push(`${col} = ?`);
        params.push(val);
      }
    }
    if (sets.length === 0) return c.json({ error: "no fields to update" }, 400);
    params.push(id);

    await c.env.DB.prepare(`UPDATE organizations SET ${sets.join(", ")} WHERE id = ?`)
      .bind(...params)
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: "organization.update",
      targetType: "organization",
      targetId: id,
      metadata: { fields: Object.keys(data) },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true });
  },
);

adminRoutes.delete("/organizations/:id", async (c) => {
  const id = c.req.param("id");
  const admin = c.get("user") as AuthUser;

  const row = await c.env.DB.prepare("SELECT id FROM organizations WHERE id = ?")
    .bind(id)
    .first();
  if (!row) return c.json({ error: "organization not found" }, 404);

  await c.env.DB.prepare("DELETE FROM organizations WHERE id = ?").bind(id).run();

  await audit(c.env, {
    actorId: admin.id,
    action: "organization.delete",
    targetType: "organization",
    targetId: id,
    ip: c.req.header("cf-connecting-ip"),
  });

  return c.json({ ok: true });
});

// ---------------------------------------------------------------------------
// Alerts — create (simulate), resolve, assign. Admin + verifier.
// ---------------------------------------------------------------------------

adminRoutes.post(
  "/alerts",
  zValidator("json", createAlertSchema),
  async (c) => {
    const data = c.req.valid("json");
    const admin = c.get("user") as AuthUser;
    const id = uuid();

    await c.env.DB.prepare(
      `INSERT INTO alerts (id, type, severity, target, title, body, status, metadata, created_at)
       VALUES (?, ?, ?, ?, ?, ?, 'open', ?, ?)`,
    )
      .bind(
        id,
        data.type,
        data.severity,
        data.target ?? null,
        data.title,
        data.body ?? null,
        data.metadata ? JSON.stringify(data.metadata) : null,
        now(),
      )
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: "alert.create",
      targetType: "alert",
      targetId: id,
      metadata: { type: data.type, severity: data.severity },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true, alert: { id, type: data.type, title: data.title, severity: data.severity, status: "open" } }, 201);
  },
);

adminRoutes.post(
  "/alerts/:id/resolve",
  zValidator("json", resolveAlertSchema),
  async (c) => {
    const id = c.req.param("id");
    const data = c.req.valid("json");
    const admin = c.get("user") as AuthUser;

    const row = await c.env.DB.prepare("SELECT id FROM alerts WHERE id = ?")
      .bind(id)
      .first();
    if (!row) return c.json({ error: "alert not found" }, 404);

    const resolvedAt = data.status === "resolved" ? now() : null;
    await c.env.DB.prepare(
      "UPDATE alerts SET status = ?, assigned_to = COALESCE(?, assigned_to), resolved_at = COALESCE(?, resolved_at) WHERE id = ?",
    )
      .bind(data.status, data.assignedTo ?? null, resolvedAt, id)
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: "alert.resolve",
      targetType: "alert",
      targetId: id,
      metadata: { status: data.status, assignedTo: data.assignedTo },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true, status: data.status });
  },
);

adminRoutes.post("/alerts/:id/assign", async (c) => {
  const id = c.req.param("id");
  const admin = c.get("user") as AuthUser;

  const row = await c.env.DB.prepare("SELECT id FROM alerts WHERE id = ?")
    .bind(id)
    .first();
  if (!row) return c.json({ error: "alert not found" }, 404);

  // Assign to the current admin and move to investigating.
  await c.env.DB.prepare(
    "UPDATE alerts SET status = 'investigating', assigned_to = ? WHERE id = ?",
  )
    .bind(admin.email, id)
    .run();

  await audit(c.env, {
    actorId: admin.id,
    action: "alert.assign",
    targetType: "alert",
    targetId: id,
    metadata: { assignedTo: admin.email },
    ip: c.req.header("cf-connecting-ip"),
  });

  return c.json({ ok: true, status: "investigating", assignedTo: admin.email });
});

// ---------------------------------------------------------------------------
// POST /admin/voters/bulk-status — update KYC status for a batch of voters.
// ---------------------------------------------------------------------------

adminRoutes.post(
  "/voters/bulk-status",
  zValidator("json", bulkVoterStatusSchema),
  async (c) => {
    const { ids, kycStatus } = c.req.valid("json");
    const admin = c.get("user") as AuthUser;

    // D1 prepared statements bind one set of values per call. For a bounded
    // batch (max 500 per schema) we run a per-id UPDATE — each is cheap.
    let updated = 0;
    for (const voterId of ids) {
      const res = await c.env.DB.prepare(
        "UPDATE users SET kyc_status = ?, updated_at = ? WHERE id = ? AND role = 'voter'",
      )
        .bind(kycStatus, now(), voterId)
        .run();
      updated += res.meta?.changes ?? 0;
    }

    await audit(c.env, {
      actorId: admin.id,
      action: "voter.bulk-status",
      targetType: "user",
      metadata: { ids, kycStatus, updated },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true, updated });
  },
);

// ---------------------------------------------------------------------------
// POST /admin/voters/notify — send an in-app notification to selected voters.
// ---------------------------------------------------------------------------

adminRoutes.post(
  "/voters/notify",
  zValidator("json", notifyVotersSchema),
  async (c) => {
    const { ids, title, body } = c.req.valid("json");
    const admin = c.get("user") as AuthUser;

    let inserted = 0;
    for (const voterId of ids) {
      const notifId = uuid();
      await c.env.DB.prepare(
        `INSERT INTO notifications (id, user_id, title, body, type, read, created_at)
         VALUES (?, ?, ?, ?, 'admin', 0, ?)`,
      )
        .bind(notifId, voterId, title, body ?? null, now())
        .run();
      inserted++;
    }

    await audit(c.env, {
      actorId: admin.id,
      action: "voter.notify",
      targetType: "notification",
      metadata: { ids, title, inserted },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true, inserted });
  },
);

// ---------------------------------------------------------------------------
// PATCH /admin/voters/:id — update a voter (suspend/reinstate, edit profile,
// notes). Admin only (verifier role can read but not mutate voter records).
// ---------------------------------------------------------------------------

adminRoutes.patch(
  "/voters/:id",
  requireRole("admin"),
  zValidator("json", updateVoterSchema),
  async (c) => {
    const id = c.req.param("id");
    const data = c.req.valid("json");
    const admin = c.get("user") as AuthUser;

    const row = await c.env.DB.prepare("SELECT id FROM users WHERE id = ? AND role = 'voter'")
      .bind(id)
      .first();
    if (!row) return c.json({ error: "voter not found" }, 404);

    const fields: Record<string, unknown> = {
      full_name: data.fullName,
      phone: data.phone,
      status: data.status,
      notes: data.notes,
    };
    const sets: string[] = [];
    const params: unknown[] = [];
    for (const [col, val] of Object.entries(fields)) {
      if (val !== undefined) {
        sets.push(`${col} = ?`);
        params.push(val);
      }
    }
    if (sets.length === 0) return c.json({ error: "no fields to update" }, 400);
    sets.push("updated_at = ?");
    params.push(now(), id);

    await c.env.DB.prepare(`UPDATE users SET ${sets.join(", ")} WHERE id = ?`)
      .bind(...params)
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: "voter.update",
      targetType: "user",
      targetId: id,
      metadata: { fields: Object.keys(data) },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true });
  },
);

// ---------------------------------------------------------------------------
// POST /admin/voters/import — bulk-create voter accounts from parsed CSV data.
// Each voter gets a random password (they can reset via forgot-password).
// Returns the count created + any emails that already existed (skipped).
// ---------------------------------------------------------------------------

adminRoutes.post(
  "/voters/import",
  requireRole("admin"),
  zValidator("json", importVotersSchema),
  async (c) => {
    const { voters } = c.req.valid("json");
    const admin = c.get("user") as AuthUser;

    let created = 0;
    const skipped: string[] = [];

    for (const v of voters) {
      // Check for existing email — skip if present.
      const existing = await c.env.DB.prepare("SELECT id FROM users WHERE email = ?")
        .bind(v.email)
        .first();
      if (existing) {
        skipped.push(v.email);
        continue;
      }

      const id = uuid();
      // Random password the voter can reset later.
      const randomPassword = uuid() + uuid();
      const passwordHash = await hashPassword(randomPassword);

      await c.env.DB.prepare(
        `INSERT INTO users (id, email, password_hash, full_name, phone, role, kyc_status, status, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, 'voter', 'pending', 'active', ?, ?)`,
      )
        .bind(id, v.email, passwordHash, v.fullName, v.phone ?? null, now(), now())
        .run();
      created++;
    }

    await audit(c.env, {
      actorId: admin.id,
      action: "voter.import",
      targetType: "user",
      metadata: { requested: voters.length, created, skipped: skipped.length },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true, created, skipped });
  },
);
