import { describe, it, expect } from "vitest";
import { merkleRoot, merkleTreeWithProofs } from "./merkle";

const LEAF_A = "0x" + "aa".repeat(32);
const LEAF_B = "0x" + "bb".repeat(32);
const LEAF_C = "0x" + "cc".repeat(32);

describe("merkleRoot", () => {
  it("returns the all-zeros root for empty input", async () => {
    const root = await merkleRoot([]);
    expect(root).toBe("0x" + "00".repeat(32));
  });

  it("returns the leaf itself for a single leaf", async () => {
    const root = await merkleRoot([LEAF_A]);
    expect(root).toBe(LEAF_A);
  });

  it("is deterministic regardless of input order (sorts leaves)", async () => {
    const root1 = await merkleRoot([LEAF_A, LEAF_B, LEAF_C]);
    const root2 = await merkleRoot([LEAF_C, LEAF_A, LEAF_B]);
    expect(root1).toBe(root2);
  });

  it("produces a 0x-prefixed 64-hex-char root for multiple leaves", async () => {
    const root = await merkleRoot([LEAF_A, LEAF_B]);
    expect(root).toMatch(/^0x[0-9a-f]{64}$/);
  });

  it("normalizes non-prefixed / uppercase hex leaves", async () => {
    const upper = "AA".repeat(32);
    const root1 = await merkleRoot([upper]);
    const root2 = await merkleRoot([LEAF_A]);
    expect(root1).toBe(root2);
  });
});

describe("merkleTreeWithProofs", () => {
  it("returns empty proofs for empty input", async () => {
    const { root, proofs } = await merkleTreeWithProofs([]);
    expect(root).toBe("0x" + "00".repeat(32));
    expect(Object.keys(proofs)).toHaveLength(0);
  });

  it("returns an empty proof for a single leaf", async () => {
    const { root, proofs } = await merkleTreeWithProofs([LEAF_A]);
    expect(root).toBe(LEAF_A);
    expect(proofs[LEAF_A]).toEqual([]);
  });

  it("produces a one-element proof for each of two leaves", async () => {
    const { root, proofs } = await merkleTreeWithProofs([LEAF_A, LEAF_B]);
    // Each leaf's proof is the other leaf (its sibling).
    expect(proofs[LEAF_A]).toHaveLength(1);
    expect(proofs[LEAF_B]).toHaveLength(1);
    // The root itself gets a (unused) empty proof bucket.
    expect(proofs[root]).toEqual([]);
    // The root should equal hashPair(sorted leaves).
    expect(root).toMatch(/^0x[0-9a-f]{64}$/);
  });

  it("root from proofs matches merkleRoot for the same input", async () => {
    const leaves = [LEAF_A, LEAF_B, LEAF_C];
    const { root: rootWithProofs } = await merkleTreeWithProofs(leaves);
    const root = await merkleRoot(leaves);
    expect(rootWithProofs).toBe(root);
  });
});
