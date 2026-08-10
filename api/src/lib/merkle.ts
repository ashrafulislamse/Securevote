// Merkle tree over SHA-256 hashes.
//
// The on-chain `Voting.finalize(electionId, merkleRoot)` is anchored to the
// root of this tree, where the leaves are the per-vote `vote_hash` values
// (hex, 32-byte / 64-hex-char SHA-256 digests). After finalization, the
// per-vote merkle proof lets any third party verify that their vote was
// included in the anchored root by walking sibling hashes up to the root.
//
// Algorithm:
//   1. Normalize each hex hash to a 0x-prefixed 64-hex-char string.
//   2. Sort the leaves (canonical order — any verifier running the same
//      sort gets the same root, so the on-chain root is reproducible).
//   3. Pair adjacent leaves, concat their 0x-hex strings, and SHA-256 the
//      resulting 64-byte buffer to form the next level.
//   4. If a level has an odd number of nodes, the last node is promoted
//      un-paired (this matches the convention used by the test fixtures
//      and keeps the tree deterministic without duplicating the last node).
//   5. Recurse until one node remains.
//   6. For empty input, return the all-zeros 32-byte root.

import { sha256hex } from "./utils";

const ZERO_BYTES32 = "0x" + "00".repeat(32);

/** Strip a "0x" prefix and lowercase the result. */
function normalizeHex(hex: string): string {
  const stripped = hex.startsWith("0x") ? hex.slice(2) : hex;
  return stripped.toLowerCase();
}

/** Re-prefix a 64-char hex string with "0x". */
function withPrefix(hex64: string): string {
  return "0x" + hex64;
}

/** Concatenate two 32-byte digests and SHA-256 the 64-byte buffer. */
async function hashPair(a: string, b: string): Promise<string> {
  // a, b are 0x-prefixed 64-hex strings (32 bytes each)
  const buf =
    (a.startsWith("0x") ? a.slice(2) : a) +
    (b.startsWith("0x") ? b.slice(2) : b);
  const digest = await sha256hex(buf);
  return withPrefix(digest);
}

/**
 * Build the merkle tree and return the root as "0x" + 64 hex chars.
 * Returns the all-zeros 32-byte root for empty input.
 */
export async function merkleRoot(hexHashes: string[]): Promise<string> {
  if (!hexHashes || hexHashes.length === 0) return ZERO_BYTES32;

  // Normalize + sort for determinism.
  let level: string[] = hexHashes.map(normalizeHex).map(withPrefix);
  level.sort();

  while (level.length > 1) {
    const next: string[] = [];
    for (let i = 0; i < level.length; i += 2) {
      if (i + 1 < level.length) {
        next.push(await hashPair(level[i]!, level[i + 1]!));
      } else {
        // Odd one out — promote un-paired (deterministic).
        next.push(level[i]!);
      }
    }
    level = next;
  }

  return level[0]!;
}

/**
 * Build the full tree and return both the root and a map of leaf ->
 * merkle proof (array of sibling hashes, in low-to-high order).
 * If the input has a single leaf, the proof is an empty array.
 */
export async function merkleTreeWithProofs(
  hexHashes: string[],
): Promise<{
  root: string;
  proofs: Record<string, string[]>;
}> {
  const proofs: Record<string, string[]> = {};
  if (!hexHashes || hexHashes.length === 0) {
    return { root: ZERO_BYTES32, proofs };
  }
  if (hexHashes.length === 1) {
    const only = withPrefix(normalizeHex(hexHashes[0]!));
    return { root: only, proofs: { [only]: [] } };
  }

  // Normalize + sort.
  let level: string[] = hexHashes.map(normalizeHex).map(withPrefix);
  level.sort();

  // Initialise proofs: each leaf starts with an empty sibling list.
  for (const leaf of level) proofs[leaf] = [];

  while (level.length > 1) {
    const next: string[] = [];
    for (let i = 0; i < level.length; i += 2) {
      if (i + 1 < level.length) {
        const left = level[i]!;
        const right = level[i + 1]!;
        const parent = await hashPair(left, right);
        // Each leaf on this level gets the OTHER sibling appended.
        proofs[parent] = []; // initialize parent's proof bucket
        proofs[left]!.push(right);
        proofs[right]!.push(left);
        next.push(parent);
      } else {
        // Odd one out — promote un-paired.
        const lonely = level[i]!;
        const parent = lonely; // identity promotion
        next.push(parent);
      }
    }
    level = next;
  }

  return { root: level[0]!, proofs };
}
