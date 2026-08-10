// Ethers v6 wrapper for the SecureVote `Voting` contract on Polygon Amoy.
//
// All on-chain calls go through this module. If the contract address is not
// yet set (e.g. before deployment), the helpers throw a typed "not yet
// on-chain" error so callers can fall back to the off-chain-only path
// without exploding the user-visible API.

import { JsonRpcProvider, Wallet, Contract, isHexString, getBytes, hexlify, toUtf8Bytes, zeroPadValue, dataLength, AbstractSigner } from "ethers";
import type { Env } from "../types";

// ---------------------------------------------------------------------------
// ABI — just the methods we call from the API. Mirrors Voting.sol.
// ---------------------------------------------------------------------------
export const VOTING_ABI = [
  // write
  "function createElection(string id, uint256 startsAt, uint256 endsAt) external",
  "function commitVote(string electionId, bytes32 voteHash) external",
  "function finalize(string electionId, bytes32 merkleRoot) external",
  // read
  "function getVoteCount(string electionId) view returns (uint256)",
  "function getVoteHashes(string electionId) view returns (bytes32[])",
  "function getElection(string id) view returns (string, uint256, uint256, bytes32, bool)",
  "function owner() view returns (address)",
  // events
  "event ElectionCreated(string indexed id, uint256 startsAt, uint256 endsAt)",
  "event VoteCommitted(string indexed electionId, address indexed voter, bytes32 indexed voteHash)",
  "event ElectionFinalized(string indexed id, bytes32 indexed merkleRoot, uint256 voteCount)",
] as const;

export const DEFAULT_AMOY_RPC = "https://rpc-amoy.polygon.technology";

export class ChainNotConfiguredError extends Error {
  constructor(msg = "on-chain anchoring not yet enabled (contract address missing)") {
    super(msg);
    this.name = "ChainNotConfiguredError";
  }
}

// ---------------------------------------------------------------------------
// Connection helpers
// ---------------------------------------------------------------------------

/** True if both the private key and contract address are configured. */
export function isChainConfigured(env: Env): boolean {
  return Boolean(env.PRIVATE_KEY && (env.VOTING_CONTRACT_ADDRESS || env.CONTRACT_ADDRESS));
}

/** Get the contract address, or null if unset. */
export function getContractAddress(env: Env): string | null {
  return env.VOTING_CONTRACT_ADDRESS ?? env.CONTRACT_ADDRESS ?? null;
}

/** Get the RPC URL, defaulting to Amoy public. */
export function getRpcUrl(env: Env): string {
  return env.AMOY_RPC_URL ?? env.RPC_URL ?? DEFAULT_AMOY_RPC;
}

/** Build a JSON RPC provider pointed at Amoy (or whatever the env says). */
export function getProvider(env: Env): JsonRpcProvider {
  return new JsonRpcProvider(getRpcUrl(env));
}

/** Build a Wallet signer connected to the provider. */
export function getSigner(env: Env): AbstractSigner {
  if (!env.PRIVATE_KEY) {
    throw new ChainNotConfiguredError("PRIVATE_KEY is not set");
  }
  // ethers v6 accepts 0x-prefixed or raw hex; normalize.
  const key = env.PRIVATE_KEY.startsWith("0x")
    ? env.PRIVATE_KEY
    : `0x${env.PRIVATE_KEY}`;
  const provider = getProvider(env);
  return new Wallet(key, provider);
}

/**
 * Get a typed Contract connected to a signer. Throws ChainNotConfiguredError
 * if the contract address is not configured.
 */
export function getVotingContract(env: Env): Contract {
  const address = getContractAddress(env);
  if (!address) {
    throw new ChainNotConfiguredError(
      "VOTING_CONTRACT_ADDRESS is not set — on-chain anchoring disabled",
    );
  }
  const signer = getSigner(env);
  return new Contract(address, VOTING_ABI as unknown as string[], signer);
}

// ---------------------------------------------------------------------------
// bytes32 helpers
// ---------------------------------------------------------------------------

/**
 * Normalise an arbitrary hex string to a 0x-prefixed 32-byte value.
 *   - If exactly 32 bytes (64 hex chars) — use as-is.
 *   - If shorter — left-pad with zeros.
 *   - If longer  — SHA-256 it down to 32 bytes.
 */
export async function toBytes32(input: string): Promise<string> {
  let hex = input.startsWith("0x") ? input.slice(2) : input;
  hex = hex.toLowerCase();

  if (hex.length === 64 && /^[0-9a-f]+$/.test(hex)) {
    return "0x" + hex;
  }
  if (hex.length < 64 && /^[0-9a-f]+$/.test(hex)) {
    return zeroPadValue("0x" + hex, 32);
  }
  // Longer (or non-hex) — hash it.
  // For non-hex input, hash the raw UTF-8 bytes.
  if (!/^[0-9a-f]+$/.test(hex)) {
    const { sha256hex } = await import("./utils");
    return "0x" + (await sha256hex(input));
  }
  // Hex but too long — hash the bytes.
  const buf = getBytes("0x" + hex);
  const { sha256hex } = await import("./utils");
  // sha256hex expects string; concat the bytes as a hex string for hashing.
  return "0x" + (await sha256hex(hexlify(buf).slice(2)));
}

// ---------------------------------------------------------------------------
// Write helpers
// ---------------------------------------------------------------------------

export interface TxReceiptLite {
  txHash: string;
  blockNumber: number;
}

async function sendAndWait(
  env: Env,
  fn: (c: Contract) => Promise<{ wait: () => Promise<{ hash: string; blockNumber: number } | null> }>,
): Promise<TxReceiptLite> {
  const contract = getVotingContract(env);
  const tx = await fn(contract);
  const receipt = await tx.wait();
  if (!receipt) throw new Error("transaction did not produce a receipt");
  return { txHash: receipt.hash, blockNumber: receipt.blockNumber };
}

export async function createElectionOnChain(
  env: Env,
  electionId: string,
  startsAt: number,
  endsAt: number,
): Promise<TxReceiptLite> {
  return sendAndWait(env, (c) =>
    c.getFunction("createElection")(electionId, BigInt(startsAt), BigInt(endsAt)) as unknown as Promise<{ wait: () => Promise<{ hash: string; blockNumber: number } | null> }>,
  );
}

export async function commitVoteOnChain(
  env: Env,
  electionId: string,
  voteHashHex: string,
): Promise<TxReceiptLite> {
  const bytes32 = await toBytes32(voteHashHex);
  return sendAndWait(env, (c) =>
    c.getFunction("commitVote")(electionId, bytes32) as unknown as Promise<{ wait: () => Promise<{ hash: string; blockNumber: number } | null> }>,
  );
}

export async function finalizeOnChain(
  env: Env,
  electionId: string,
  merkleRootHex: string,
): Promise<TxReceiptLite> {
  const bytes32 = await toBytes32(merkleRootHex);
  return sendAndWait(env, (c) =>
    c.getFunction("finalize")(electionId, bytes32) as unknown as Promise<{ wait: () => Promise<{ hash: string; blockNumber: number } | null> }>,
  );
}

// ---------------------------------------------------------------------------
// Read helpers
// ---------------------------------------------------------------------------

export async function getOnChainVoteCount(env: Env, electionId: string): Promise<number> {
  const contract = getVotingContract(env);
  const n = (await (contract.getFunction("getVoteCount")(electionId) as Promise<bigint>));
  return Number(n);
}

// ---------------------------------------------------------------------------
// Sync listener — run by the cron (every minute) and by the manual
// GET /api/cron/sync-chain route. Compares on-chain vote counts against
// D1's per-election vote count and logs any mismatch to audit_log.
// ---------------------------------------------------------------------------
export interface SyncReport {
  checked: number;
  mismatches: Array<{ electionId: string; db: number; chain: number }>;
  skipped: number;
}

export async function syncChainVoteCounts(env: Env): Promise<SyncReport> {
  if (!isChainConfigured(env)) {
    return { checked: 0, mismatches: [], skipped: 0 };
  }

  const { results } = await env.DB.prepare(
    `SELECT id, title, status FROM elections
     WHERE status IN ('active', 'closed', 'published')`,
  ).all<{ id: string; title: string; status: string }>();

  const report: SyncReport = { checked: 0, mismatches: [], skipped: 0 };
  for (const row of results) {
    report.checked++;
    const dbRow = await env.DB.prepare(
      "SELECT COUNT(*) AS n FROM votes WHERE election_id = ?",
    )
      .bind(row.id)
      .first<{ n: number }>();
    const db = dbRow?.n ?? 0;
    try {
      const chain = await getOnChainVoteCount(env, row.id);
      if (chain !== db) {
        report.mismatches.push({ electionId: row.id, db, chain });
        await env.DB.prepare(
          `INSERT INTO audit_log (id, actor_id, action, target_type, target_id, metadata, ip_address, created_at)
           VALUES (?, NULL, 'chain.sync.mismatch', 'election', ?, ?, NULL, ?)`,
        )
          .bind(
            crypto.randomUUID(),
            row.id,
            JSON.stringify({ title: row.title, db, chain }),
            Date.now(),
          )
          .run();
      }
    } catch (e) {
      report.skipped++;
      const msg = e instanceof Error ? e.message : String(e);
      await env.DB.prepare(
        `INSERT INTO audit_log (id, actor_id, action, target_type, target_id, metadata, ip_address, created_at)
         VALUES (?, NULL, 'chain.sync.error', 'election', ?, ?, NULL, ?)`,
      )
        .bind(
          crypto.randomUUID(),
          row.id,
          JSON.stringify({ title: row.title, error: msg }),
          Date.now(),
        )
        .run();
    }
  }
  return report;
}
