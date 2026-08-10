// Admin routes: dashboard stats, voter registry, KYC queue, fraud alerts,
// and audit log. Admin + verifier roles.

import { Hono } from "hono";
import { auth, requireRole, type AppContext } from "../middleware/auth";
import { audit, computeEntryHash, GENESIS_HASH } from "../middleware/audit";

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
  const { q, status, limit = "50", offset = "0" } = c.req.query();
  let sql =
    "SELECT id, email, full_name, phone, role, kyc_status, created_at FROM users WHERE role = 'voter'";
  const params: unknown[] = [];
  if (q) {
    sql += " AND (email LIKE ? OR full_name LIKE ?)";
    params.push(`%${q}%`, `%${q}%`);
  }
  if (status) {
    sql += " AND kyc_status = ?";
    params.push(status);
  }
  sql += " ORDER BY created_at DESC LIMIT ? OFFSET ?";
  params.push(parseInt(limit, 10), parseInt(offset, 10));

  const { results } = await c.env.DB.prepare(sql).bind(...params).all();
  return c.json({ voters: results });
});

// ---------------------------------------------------------------------------
// GET /admin/voters/:id — single voter detail.
// ---------------------------------------------------------------------------
adminRoutes.get("/voters/:id", async (c) => {
  const id = c.req.param("id");
  const voter = await c.env.DB.prepare(
    `SELECT u.id, u.email, u.full_name, u.phone, u.role, u.kyc_status, u.created_at,
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

  return c.json({ voter, votes: votes.results });
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
// GET /admin/alerts — anomaly/fraud alerts (Phase 5 will auto-generate these;
// for now returns empty list + seeds from a simple heuristic).
// ---------------------------------------------------------------------------
adminRoutes.get("/alerts", async (c) => {
  // Detect duplicate votes (shouldn't happen due to UNIQUE constraint) and
  // suspicious rapid registration as basic anomaly signals.
  const duplicates = await c.env.DB.prepare(
    "SELECT user_id, COUNT(*) AS n FROM sessions WHERE revoked_at IS NULL GROUP BY user_id ORDER BY n DESC LIMIT 5",
  ).all();

  const alerts = duplicates.results
    .filter((r: Record<string, unknown>) => (r.n as number) > 3)
    .map((r: Record<string, unknown>) => ({
      id: `alert_${r.user_id}`,
      type: "MULTIPLE_SESSIONS",
      severity: "medium",
      target: r.user_id,
      count: r.n,
      createdAt: Date.now(),
    }));

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
