// Voting routes: cast a vote (with anti-double-vote), fetch my votes, verify receipt.

import { Hono } from "hono";
import { zValidator } from "@hono/zod-validator";
import type { Env, ElectionStatus } from "../types";
import { castVoteSchema } from "../schemas";
import { uuid, now, sha256hex, randomHex } from "../lib/utils";
import { auth, requireRole, loadUser, type AuthUser, type AppContext } from "../middleware/auth";
import { audit } from "../middleware/audit";

export const votingRoutes = new Hono<AppContext>();

// Generate a collision-resistant receipt id: SV-XXXX-XXXX-XXXX-XXXX
function makeReceiptId(): string {
  const seg = (n: number) => randomHex(n).toUpperCase();
  return `SV-${seg(2)}-${seg(2)}-${seg(2)}-${seg(2)}`;
}

// ---------------------------------------------------------------------------
// POST /voting/cast — cast a vote. Auth required + KYC approved + active election.
// ---------------------------------------------------------------------------
votingRoutes.post(
  "/cast",
  auth(),
  requireRole("voter"),
  zValidator("json", castVoteSchema),
  async (c) => {
    const user = c.get("user") as AuthUser;
    const { electionId, selections } = c.req.valid("json");

    // Load full user to check KYC.
    const full = await loadUser(c.env, user.id);
    if (!full) return c.json({ error: "user not found" }, 404);
    if (full.kycStatus !== "approved") {
      return c.json({ error: "KYC approval required to vote" }, 403);
    }

    // Election must be active.
    const election = await c.env.DB.prepare(
      "SELECT * FROM elections WHERE id = ?",
    )
      .bind(electionId)
      .first<Record<string, unknown>>();
    if (!election) return c.json({ error: "election not found" }, 404);
    const status = election.status as ElectionStatus;
    if (status !== "active") {
      return c.json({ error: `election is not active (status: ${status})` }, 403);
    }
    const ts = now();
    if (ts < (election.starts_at as number) || ts > (election.ends_at as number)) {
      return c.json({ error: "election is not currently open" }, 403);
    }

    // Validate selections reference real candidates in this election.
    for (const sel of selections) {
      const cand = await c.env.DB.prepare(
        "SELECT id FROM candidates WHERE id = ? AND election_id = ?",
      )
        .bind(sel.candidateId, electionId)
        .first();
      if (!cand) {
        return c.json({ error: `invalid candidate: ${sel.candidateId}` }, 400);
      }
    }

    // Anti-double-vote via DB UNIQUE(election_id, user_id).
    const voteId = uuid();
    const receiptId = makeReceiptId();
    const voteHash = await sha256hex(
      JSON.stringify({ electionId, userId: user.id, selections, receiptId, ts, nonce: randomHex(8) }),
    );
    const selectionsJson = JSON.stringify(selections);

    try {
      await c.env.DB.prepare(
        `INSERT INTO votes (id, election_id, user_id, selections, receipt_id, vote_hash, created_at)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
      )
        .bind(voteId, electionId, user.id, selectionsJson, receiptId, voteHash, ts)
        .run();
    } catch (e) {
      // UNIQUE constraint violation => already voted.
      const msg = (e as Error).message ?? "";
      if (msg.includes("UNIQUE") || msg.includes("constraint")) {
        return c.json({ error: "you have already voted in this election" }, 409);
      }
      throw e;
    }

    // Notify the user.
    await c.env.DB.prepare(
      `INSERT INTO notifications (id, user_id, title, body, type, read, created_at)
       VALUES (?, ?, 'Vote recorded', ?, 'vote', 0, ?)`,
    )
      .bind(uuid(), user.id, `Your vote in election ${electionId} was recorded. Receipt: ${receiptId}`, ts)
      .run();

    await audit(c.env, {
      actorId: user.id,
      action: "vote.cast",
      targetType: "election",
      targetId: electionId,
      metadata: { receiptId },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json(
      {
        ok: true,
        vote: {
          id: voteId,
          electionId,
          receiptId,
          voteHash,
          selections,
          createdAt: ts,
        },
      },
      201,
    );
  },
);

// ---------------------------------------------------------------------------
// GET /voting/mine — the current user's votes.
// ---------------------------------------------------------------------------
votingRoutes.get("/mine", auth(), async (c) => {
  const user = c.get("user") as AuthUser;
  const { results } = await c.env.DB.prepare(
    `SELECT v.*, e.title AS election_title FROM votes v
     JOIN elections e ON e.id = v.election_id
     WHERE v.user_id = ?
     ORDER BY v.created_at DESC`,
  )
    .bind(user.id)
    .all<Record<string, unknown>>();

  return c.json({
    votes: results.map((v) => ({
      id: v.id,
      electionId: v.election_id,
      electionTitle: v.election_title,
      selections: typeof v.selections === "string" ? JSON.parse(v.selections) : v.selections,
      receiptId: v.receipt_id,
      txHash: v.tx_hash,
      blockNumber: v.block_number,
      voteHash: v.vote_hash,
      createdAt: v.created_at,
    })),
  });
});

// ---------------------------------------------------------------------------
// GET /voting/voted/:electionId — has the current user voted here?
// ---------------------------------------------------------------------------
votingRoutes.get("/voted/:electionId", auth(), async (c) => {
  const user = c.get("user") as AuthUser;
  const electionId = c.req.param("electionId");
  const row = await c.env.DB.prepare(
    "SELECT id FROM votes WHERE election_id = ? AND user_id = ?",
  )
    .bind(electionId, user.id)
    .first();
  return c.json({ voted: !!row });
});

export { makeReceiptId };