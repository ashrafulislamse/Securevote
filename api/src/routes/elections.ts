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
    `SELECT v.selections FROM votes v`,
  ).all();

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