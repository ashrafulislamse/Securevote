// Election routes: CRUD + candidates + results + publishing.
// Public reads are available to any authenticated voter; admin writes use RBAC.

import { Hono } from "hono";
import { zValidator } from "@hono/zod-validator";
import { z } from "zod";
import type { Env, ElectionStatus } from "../types";
import {
  createElectionSchema,
  updateElectionSchema,
  createCandidateSchema,
  updateCandidateSchema,
  createBallotBlockSchema,
  updateBallotBlockSchema,
  publishElectionSchema,
} from "../schemas";
import { uuid, now } from "../lib/utils";
import { auth, requireRole, type AuthUser, type AppContext } from "../middleware/auth";
import { audit } from "../middleware/audit";
import {
  isChainConfigured,
  createElectionOnChain,
  finalizeOnChain,
  getOnChainVoteCount,
  ChainNotConfiguredError,
} from "../lib/blockchain";
import { merkleTreeWithProofs } from "../lib/merkle";

export const electionsRoutes = new Hono<AppContext>();

// Validate that an election exists and return its row.
async function getElectionRow(
  env: Env,
  id: string,
): Promise<Record<string, unknown> | null> {
  return env.DB.prepare("SELECT * FROM elections WHERE id = ?")
    .bind(id)
    .first();
}

function electionFromRow(row: Record<string, unknown>) {
  return {
    id: row.id,
    title: row.title,
    description: row.description,
    organization: row.organization,
    type: row.type,
    status: row.status,
    startsAt: row.starts_at,
    endsAt: row.ends_at,
    canVote: (row.status as string) === "active",
    candidateCount: row.candidate_count ?? 0,
    merkleRoot: row.merkle_root ?? null,
    onchainTxHash: row.onchain_tx_hash ?? null,
    finalizedAt: row.finalized_at ?? null,
  };
}

// ---------------------------------------------------------------------------
// GET /elections — list elections the current user can see.
// Public with optional auth (voters browsing). Admin sees all.
// ---------------------------------------------------------------------------
electionsRoutes.get("/", async (c) => {
  const { status, q } = c.req.query();
  let sql =
    "SELECT e.*, (SELECT COUNT(*) FROM candidates c WHERE c.election_id = e.id) AS candidate_count FROM elections e";
  const params: unknown[] = [];
  const where: string[] = [];

  if (status) {
    where.push("e.status = ?");
    params.push(status);
  }
  if (q) {
    where.push("(e.title LIKE ? OR e.organization LIKE ?)");
    params.push(`%${q}%`, `%${q}%`);
  }
  if (where.length) sql += " WHERE " + where.join(" AND ");
  sql += " ORDER BY e.created_at DESC";

  const { results } = await c.env.DB.prepare(sql).bind(...params).all<
    Record<string, unknown>
  >();
  return c.json({ elections: results.map(electionFromRow) });
});

// ---------------------------------------------------------------------------
// POST /elections — create (admin only)
// ---------------------------------------------------------------------------
electionsRoutes.post(
  "/",
  auth(),
  requireRole("admin"),
  zValidator("json", createElectionSchema),
  async (c) => {
    const data = c.req.valid("json");
    const admin = c.get("user") as AuthUser;
    const id = uuid();
    const ts = now();

    await c.env.DB.prepare(
      `INSERT INTO elections (id, title, description, organization, type, status, starts_at, ends_at, created_by, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, 'draft', ?, ?, ?, ?, ?)`,
    )
      .bind(
        id,
        data.title,
        data.description ?? null,
        data.organization ?? null,
        data.type,
        data.startsAt,
        data.endsAt,
        admin.id,
        ts,
        ts,
      )
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: "election.create",
      targetType: "election",
      targetId: id,
      metadata: { title: data.title },
      ip: c.req.header("cf-connecting-ip"),
    });

    // -----------------------------------------------------------------------
    // Phase 6: anchor the new election on Polygon Amoy (best-effort).
    // If the contract is configured, call `createElection(id, startsAt,
    // endsAt)`. Store the tx hash on the row + audit. If it fails, the
    // election still exists in D1 and the cron listener can retry.
    // -----------------------------------------------------------------------
    let onchainTxHash: string | null = null;
    if (isChainConfigured(c.env)) {
      try {
        const receipt = await createElectionOnChain(
          c.env,
          id,
          data.startsAt,
          data.endsAt,
        );
        onchainTxHash = receipt.txHash;
        await c.env.DB.prepare(
          "UPDATE elections SET onchain_tx_hash = ? WHERE id = ?",
        )
          .bind(onchainTxHash, id)
          .run();
        await audit(c.env, {
          actorId: admin.id,
          action: "election.create.onchain",
          targetType: "election",
          targetId: id,
          metadata: { txHash: onchainTxHash, blockNumber: receipt.blockNumber },
          ip: c.req.header("cf-connecting-ip"),
        });
      } catch (e) {
        const msg =
          e instanceof ChainNotConfiguredError
            ? e.message
            : e instanceof Error
              ? e.message
              : String(e);
        await audit(c.env, {
          actorId: admin.id,
          action: "election.create.onchain.failed",
          targetType: "election",
          targetId: id,
          metadata: { error: msg },
          ip: c.req.header("cf-connecting-ip"),
        });
        console.error("createElection on-chain failed", msg);
      }
    } else {
      await audit(c.env, {
        actorId: admin.id,
        action: "election.create.onchain.skipped",
        targetType: "election",
        targetId: id,
        metadata: { reason: "chain not configured" },
        ip: c.req.header("cf-connecting-ip"),
      });
    }

    return c.json(
      {
        ok: true,
        election: {
          id,
          title: data.title,
          status: "draft",
          onchainTxHash,
        },
      },
      201,
    );
  },
);

// ---------------------------------------------------------------------------
// GET /elections/:id — single election + its candidates.
// ---------------------------------------------------------------------------
electionsRoutes.get("/:id", async (c) => {
  const id = c.req.param("id");
  const row = await getElectionRow(c.env, id);
  if (!row) return c.json({ error: "election not found" }, 404);

  const candidates = await c.env.DB.prepare(
    "SELECT * FROM candidates WHERE election_id = ? ORDER BY ballot_order ASC",
  )
    .bind(id)
    .all<Record<string, unknown>>();

  return c.json({
    election: electionFromRow(row),
    candidates: candidates.results.map((r) => ({
      id: r.id,
      electionId: r.election_id,
      name: r.name,
      party: r.party,
      bio: r.bio,
      manifesto: r.manifesto,
      photoUrl: r.photo_url,
      ballotOrder: r.ballot_order,
      visible: r.visible === null ? true : Boolean(r.visible),
      verified: Boolean(r.verified),
    })),
  });
});

// ---------------------------------------------------------------------------
// PATCH /elections/:id — update (admin only)
// ---------------------------------------------------------------------------
electionsRoutes.patch(
  "/:id",
  auth(),
  requireRole("admin"),
  zValidator("json", updateElectionSchema),
  async (c) => {
    const id = c.req.param("id");
    const data = c.req.valid("json");
    const admin = c.get("user") as AuthUser;
    const existing = await getElectionRow(c.env, id);
    if (!existing) return c.json({ error: "election not found" }, 404);

    const sets: string[] = [];
    const params: unknown[] = [];
    const fields: Record<string, unknown> = {
      title: data.title,
      description: data.description,
      organization: data.organization,
      type: data.type,
      starts_at: data.startsAt,
      ends_at: data.endsAt,
    };
    for (const [col, val] of Object.entries(fields)) {
      if (val !== undefined) {
        sets.push(`${col} = ?`);
        params.push(val);
      }
    }
    sets.push("updated_at = ?");
    params.push(now(), id);

    await c.env.DB.prepare(
      `UPDATE elections SET ${sets.join(", ")} WHERE id = ?`,
    )
      .bind(...params)
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: "election.update",
      targetType: "election",
      targetId: id,
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true });
  },
);

// ---------------------------------------------------------------------------
// POST /elections/:id/status — transition status (admin only)
// draft -> scheduled -> active -> closed -> published
//
// On transition to "closed" we compute the merkle root over all vote
// hashes, store per-vote merkle proofs, then call `finalize(electionId,
// merkleRoot)` on the Voting contract. This is the "real" anchoring step.
// ---------------------------------------------------------------------------
electionsRoutes.post(
  "/:id/status",
  auth(),
  requireRole("admin"),
  zValidator(
    "json",
    z.object({ status: z.enum(["draft", "scheduled", "active", "closed", "published"]) }),
  ),
  async (c) => {
    const id = c.req.param("id");
    const { status } = c.req.valid("json");
    const admin = c.get("user") as AuthUser;
    const existing = await getElectionRow(c.env, id);
    if (!existing) return c.json({ error: "election not found" }, 404);

    // -----------------------------------------------------------------------
    // If we're closing the election, compute the merkle root + proofs first
    // and store them on the votes table. Then call finalize on-chain.
    // -----------------------------------------------------------------------
    let merkleRootVal: string | null = null;
    let onchainFinalizeTx: string | null = null;
    if (status === "closed") {
      const { results: voteRows } = await c.env.DB.prepare(
        "SELECT id, vote_hash FROM votes WHERE election_id = ? AND vote_hash IS NOT NULL",
      )
        .bind(id)
        .all<Record<string, unknown>>();

      const leaves = voteRows
        .map((r) => r.vote_hash as string | null)
        .filter((h): h is string => Boolean(h));

      if (leaves.length > 0) {
        const { root, proofs } = await merkleTreeWithProofs(leaves);
        merkleRootVal = root;
        // Persist each vote's proof JSON.
        for (const r of voteRows) {
          const vh = r.vote_hash as string | null;
          if (!vh) continue;
          const key = "0x" + (vh.startsWith("0x") ? vh.slice(2).toLowerCase() : vh.toLowerCase());
          const proof = proofs[key] ?? [];
          await c.env.DB.prepare(
            "UPDATE votes SET merkle_proof = ? WHERE id = ?",
          )
            .bind(JSON.stringify(proof), r.id as string)
            .run();
        }
      } else {
        merkleRootVal = "0x" + "00".repeat(32);
      }

      // Persist merkle root + finalized_at on the election row.
      await c.env.DB.prepare(
        "UPDATE elections SET merkle_root = ?, finalized_at = ? WHERE id = ?",
      )
        .bind(merkleRootVal, now(), id)
        .run();

      // On-chain finalize (best-effort).
      if (isChainConfigured(c.env) && merkleRootVal) {
        try {
          const receipt = await finalizeOnChain(c.env, id, merkleRootVal);
          onchainFinalizeTx = receipt.txHash;
          await c.env.DB.prepare(
            "UPDATE elections SET onchain_tx_hash = ? WHERE id = ?",
          )
            .bind(onchainFinalizeTx, id)
            .run();
          await audit(c.env, {
            actorId: admin.id,
            action: "election.finalize.onchain",
            targetType: "election",
            targetId: id,
            metadata: {
              txHash: onchainFinalizeTx,
              blockNumber: receipt.blockNumber,
              merkleRoot: merkleRootVal,
            },
            ip: c.req.header("cf-connecting-ip"),
          });
        } catch (e) {
          const msg =
            e instanceof ChainNotConfiguredError
              ? e.message
              : e instanceof Error
                ? e.message
                : String(e);
          await audit(c.env, {
            actorId: admin.id,
            action: "election.finalize.onchain.failed",
            targetType: "election",
            targetId: id,
            metadata: { error: msg, merkleRoot: merkleRootVal },
            ip: c.req.header("cf-connecting-ip"),
          });
          console.error("finalize on-chain failed", msg);
        }
      } else {
        await audit(c.env, {
          actorId: admin.id,
          action: "election.finalize.onchain.skipped",
          targetType: "election",
          targetId: id,
          metadata: { reason: "chain not configured", merkleRoot: merkleRootVal },
          ip: c.req.header("cf-connecting-ip"),
        });
      }
    }

    await c.env.DB.prepare("UPDATE elections SET status = ?, updated_at = ? WHERE id = ?")
      .bind(status, now(), id)
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: `election.status.${status}`,
      targetType: "election",
      targetId: id,
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({
      ok: true,
      status,
      merkleRoot: merkleRootVal,
      onchainFinalizeTx,
    });
  },
);

// ---------------------------------------------------------------------------
// POST /elections/:id/candidates — add candidate (admin only)
// ---------------------------------------------------------------------------
electionsRoutes.post(
  "/:id/candidates",
  auth(),
  requireRole("admin"),
  zValidator("json", createCandidateSchema),
  async (c) => {
    const id = c.req.param("id");
    const data = c.req.valid("json");
    const admin = c.get("user") as AuthUser;
    const existing = await getElectionRow(c.env, id);
    if (!existing) return c.json({ error: "election not found" }, 404);

    const candidateId = uuid();
    const ballotOrder = data.ballotOrder ?? 0;
    await c.env.DB.prepare(
      `INSERT INTO candidates (id, election_id, name, party, bio, manifesto, ballot_order, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    )
      .bind(
        candidateId,
        id,
        data.name,
        data.party ?? null,
        data.bio ?? null,
        data.manifesto ?? null,
        ballotOrder,
        now(),
      )
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: "candidate.create",
      targetType: "candidate",
      targetId: candidateId,
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true, candidate: { id: candidateId, name: data.name } }, 201);
  },
);

// ---------------------------------------------------------------------------
// GET /elections/:id/results — aggregated tallies. Only when closed+published.
// ---------------------------------------------------------------------------
electionsRoutes.get("/:id/results", async (c) => {
  const id = c.req.param("id");
  const row = await getElectionRow(c.env, id);
  if (!row) return c.json({ error: "election not found" }, 404);

  const status = row.status as ElectionStatus;
  if (status !== "closed" && status !== "published") {
    return c.json({ error: "results not available yet" }, 403);
  }

  const candidates = await c.env.DB.prepare(
    "SELECT id, name, party FROM candidates WHERE election_id = ? ORDER BY ballot_order",
  )
    .bind(id)
    .all<Record<string, unknown>>();

  const tally = await c.env.DB.prepare(
    `SELECT v.selections FROM votes v WHERE v.election_id = ?`,
  )
    .bind(id)
    .all();

  // Build per-candidate counts by scanning selections JSON.
  const counts: Record<string, number> = {};
  for (const vote of tally.results) {
    const selections = JSON.parse((vote as Record<string, unknown>).selections as string) as {
      candidateId: string;
    }[];
    for (const sel of selections) {
      counts[sel.candidateId] = (counts[sel.candidateId] ?? 0) + 1;
    }
  }

  const totalVotes = tally.results.length;
  const results = candidates.results.map((r) => {
    const id = r.id as string;
    return {
      id,
      name: r.name as string,
      party: r.party as string | null,
      votes: counts[id] ?? 0,
      pct: totalVotes ? Math.round(((counts[id] ?? 0) / totalVotes) * 1000) / 10 : 0,
    };
  });
  results.sort((a, b) => b.votes - a.votes);

  return c.json({ electionId: id, totalVotes, turnout: null, results });
});

// ---------------------------------------------------------------------------
// PATCH /elections/:id/candidates/:cid — update candidate (admin only)
// Updates name/party/bio/manifesto/ballotOrder and moderation flags
// (visible/verified). Only fields present in the body are written.
// ---------------------------------------------------------------------------
electionsRoutes.patch(
  "/:id/candidates/:cid",
  auth(),
  requireRole("admin"),
  zValidator("json", updateCandidateSchema),
  async (c) => {
    const id = c.req.param("id");
    const cid = c.req.param("cid");
    const data = c.req.valid("json");
    const admin = c.get("user") as AuthUser;

    const existing = await getElectionRow(c.env, id);
    if (!existing) return c.json({ error: "election not found" }, 404);

    const row = await c.env.DB.prepare(
      "SELECT id FROM candidates WHERE id = ? AND election_id = ?",
    )
      .bind(cid, id)
      .first();
    if (!row) return c.json({ error: "candidate not found" }, 404);

    const fields: Record<string, unknown> = {
      name: data.name,
      party: data.party,
      bio: data.bio,
      manifesto: data.manifesto,
      ballot_order: data.ballotOrder,
      visible: data.visible === undefined ? undefined : data.visible ? 1 : 0,
      verified: data.verified === undefined ? undefined : data.verified ? 1 : 0,
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
    params.push(cid);

    await c.env.DB.prepare(
      `UPDATE candidates SET ${sets.join(", ")} WHERE id = ?`,
    )
      .bind(...params)
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: "candidate.update",
      targetType: "candidate",
      targetId: cid,
      metadata: { electionId: id, fields: Object.keys(data) },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true });
  },
);

// ---------------------------------------------------------------------------
// DELETE /elections/:id/candidates/:cid — remove candidate (admin only)
// Guarded: refuses if the election has any votes, or if its status is already
// active/closed/published (ballot is live or finalized).
// ---------------------------------------------------------------------------
electionsRoutes.delete(
  "/:id/candidates/:cid",
  auth(),
  requireRole("admin"),
  async (c) => {
    const id = c.req.param("id");
    const cid = c.req.param("cid");
    const admin = c.get("user") as AuthUser;

    const existing = await getElectionRow(c.env, id);
    if (!existing) return c.json({ error: "election not found" }, 404);

    const status = existing.status as string;
    if (status === "active" || status === "closed" || status === "published") {
      return c.json(
        { error: "cannot delete a candidate once the election is active or finalized" },
        400,
      );
    }

    const voteCount = await c.env.DB.prepare(
      "SELECT COUNT(*) AS n FROM votes WHERE election_id = ?",
    )
      .bind(id)
      .first<Record<string, number>>();
    if ((voteCount?.n ?? 0) > 0) {
      return c.json(
        { error: "cannot delete a candidate after votes have been cast" },
        400,
      );
    }

    const row = await c.env.DB.prepare(
      "SELECT id FROM candidates WHERE id = ? AND election_id = ?",
    )
      .bind(cid, id)
      .first();
    if (!row) return c.json({ error: "candidate not found" }, 404);

    await c.env.DB.prepare("DELETE FROM candidates WHERE id = ?")
      .bind(cid)
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: "candidate.delete",
      targetType: "candidate",
      targetId: cid,
      metadata: { electionId: id },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true });
  },
);

// ---------------------------------------------------------------------------
// GET /elections/:id/ballot-blocks — list ballot sections/questions (public)
// ---------------------------------------------------------------------------
electionsRoutes.get("/:id/ballot-blocks", async (c) => {
  const id = c.req.param("id");
  const existing = await getElectionRow(c.env, id);
  if (!existing) return c.json({ error: "election not found" }, 404);

  const { results } = await c.env.DB.prepare(
    "SELECT id, election_id, title, kind, order_index FROM ballot_blocks WHERE election_id = ? ORDER BY order_index ASC",
  )
    .bind(id)
    .all<Record<string, unknown>>();

  return c.json({
    ballotBlocks: results.map((r) => ({
      id: r.id,
      electionId: r.election_id,
      title: r.title,
      kind: r.kind,
      orderIndex: r.order_index,
    })),
  });
});

// ---------------------------------------------------------------------------
// POST /elections/:id/ballot-blocks — create ballot block (admin only)
// ---------------------------------------------------------------------------
electionsRoutes.post(
  "/:id/ballot-blocks",
  auth(),
  requireRole("admin"),
  zValidator("json", createBallotBlockSchema),
  async (c) => {
    const id = c.req.param("id");
    const data = c.req.valid("json");
    const admin = c.get("user") as AuthUser;

    const existing = await getElectionRow(c.env, id);
    if (!existing) return c.json({ error: "election not found" }, 404);

    const blockId = uuid();
    const orderIndex = data.orderIndex ?? 0;
    await c.env.DB.prepare(
      `INSERT INTO ballot_blocks (id, election_id, title, kind, order_index)
       VALUES (?, ?, ?, ?, ?)`,
    )
      .bind(blockId, id, data.title, data.kind, orderIndex)
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: "ballot_block.create",
      targetType: "ballot_block",
      targetId: blockId,
      metadata: { electionId: id, kind: data.kind },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json(
      { ok: true, ballotBlock: { id: blockId, title: data.title, kind: data.kind, orderIndex } },
      201,
    );
  },
);

// ---------------------------------------------------------------------------
// PATCH /elections/:id/ballot-blocks/:bid — update ballot block (admin only)
// ---------------------------------------------------------------------------
electionsRoutes.patch(
  "/:id/ballot-blocks/:bid",
  auth(),
  requireRole("admin"),
  zValidator("json", updateBallotBlockSchema),
  async (c) => {
    const id = c.req.param("id");
    const bid = c.req.param("bid");
    const data = c.req.valid("json");
    const admin = c.get("user") as AuthUser;

    const row = await c.env.DB.prepare(
      "SELECT id FROM ballot_blocks WHERE id = ? AND election_id = ?",
    )
      .bind(bid, id)
      .first();
    if (!row) return c.json({ error: "ballot block not found" }, 404);

    const fields: Record<string, unknown> = {
      title: data.title,
      kind: data.kind,
      order_index: data.orderIndex,
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
    params.push(bid);

    await c.env.DB.prepare(
      `UPDATE ballot_blocks SET ${sets.join(", ")} WHERE id = ?`,
    )
      .bind(...params)
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: "ballot_block.update",
      targetType: "ballot_block",
      targetId: bid,
      metadata: { electionId: id, fields: Object.keys(data) },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true });
  },
);

// ---------------------------------------------------------------------------
// DELETE /elections/:id/ballot-blocks/:bid — remove ballot block (admin only)
// ---------------------------------------------------------------------------
electionsRoutes.delete(
  "/:id/ballot-blocks/:bid",
  auth(),
  requireRole("admin"),
  async (c) => {
    const id = c.req.param("id");
    const bid = c.req.param("bid");
    const admin = c.get("user") as AuthUser;

    const row = await c.env.DB.prepare(
      "SELECT id FROM ballot_blocks WHERE id = ? AND election_id = ?",
    )
      .bind(bid, id)
      .first();
    if (!row) return c.json({ error: "ballot block not found" }, 404);

    await c.env.DB.prepare("DELETE FROM ballot_blocks WHERE id = ?")
      .bind(bid)
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: "ballot_block.delete",
      targetType: "ballot_block",
      targetId: bid,
      metadata: { electionId: id },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true });
  },
);

// ---------------------------------------------------------------------------
// POST /elections/:id/publish — transition to published + record distribution
// (admin only). Sets status to 'published' and persists publish_visibility
// and publish_channels on the election row. Requires the election to be
// 'closed' (finalized) first — the status endpoint handles merkle/on-chain.
// ---------------------------------------------------------------------------
electionsRoutes.post(
  "/:id/publish",
  auth(),
  requireRole("admin"),
  zValidator("json", publishElectionSchema),
  async (c) => {
    const id = c.req.param("id");
    const data = c.req.valid("json");
    const admin = c.get("user") as AuthUser;

    const existing = await getElectionRow(c.env, id);
    if (!existing) return c.json({ error: "election not found" }, 404);

    const status = existing.status as string;
    if (status !== "closed" && status !== "published") {
      return c.json(
        { error: "election must be closed (finalized) before publishing" },
        400,
      );
    }

    const visibility = data.visibility ?? "public";
    const channels = JSON.stringify(data.channels ?? ["portal"]);

    await c.env.DB.prepare(
      `UPDATE elections
       SET status = 'published', publish_visibility = ?, publish_channels = ?, updated_at = ?
       WHERE id = ?`,
    )
      .bind(visibility, channels, now(), id)
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: "election.publish",
      targetType: "election",
      targetId: id,
      metadata: { visibility, channels: data.channels ?? ["portal"] },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true, status: "published", visibility, channels: data.channels ?? ["portal"] });
  },
);