// Public verifier: anyone can look up a vote by receipt id (no auth).
// This is the "proof of vote" feature powering the public /verifier page.

import { Hono } from "hono";
import type { AppContext } from "../middleware/auth";

export const publicRoutes = new Hono<AppContext>();

// ---------------------------------------------------------------------------
// GET /public/verify/:receiptId — verify a vote by its receipt id.
// Returns vote details + election title + validity + on-chain anchoring
// data (per-vote merkle proof + election merkle root + finalize tx). No
// auth required.
// ---------------------------------------------------------------------------
publicRoutes.get("/verify/:receiptId", async (c) => {
  const receiptId = c.req.param("receiptId").toUpperCase().trim();
  if (!/^SV-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}$/.test(receiptId)) {
    return c.json({ error: "invalid receipt format" }, 400);
  }

  const vote = await c.env.DB.prepare(
    `SELECT v.*, e.title AS election_title, e.organization AS election_org,
            e.merkle_root AS election_merkle_root,
            e.onchain_tx_hash AS election_onchain_tx_hash,
            e.finalized_at AS election_finalized_at
     FROM votes v JOIN elections e ON e.id = v.election_id
     WHERE v.receipt_id = ?`,
  )
    .bind(receiptId)
    .first<Record<string, unknown>>();

  if (!vote) {
    return c.json({ valid: false, message: "receipt not found", receiptId }, 404);
  }

  // merkle_proof is a JSON-encoded array of sibling hashes (low-to-high).
  let merkleProof: string[] = [];
  if (vote.merkle_proof && typeof vote.merkle_proof === "string") {
    try {
      const parsed = JSON.parse(vote.merkle_proof);
      if (Array.isArray(parsed)) merkleProof = parsed.map(String);
    } catch {
      merkleProof = [];
    }
  }

  return c.json({
    valid: true,
    verifiedAt: Date.now(),
    receiptId,
    electionId: vote.election_id,
    electionTitle: vote.election_title,
    electionOrganization: vote.election_org,
    voteHash: vote.vote_hash,
    txHash: vote.tx_hash ?? null,
    blockNumber: vote.block_number ?? null,
    merkleProof,
    onchain: {
      merkleRoot: vote.election_merkle_root ?? null,
      finalizeTxHash: vote.election_onchain_tx_hash ?? null,
      finalizedAt: vote.election_finalized_at ?? null,
    },
    createdAt: vote.created_at,
    // Note: we do NOT expose WHO voted or WHAT they voted for — only that a
    // valid ballot exists for this receipt. Candidate selections are kept
    // private to preserve ballot secrecy.
  });
});