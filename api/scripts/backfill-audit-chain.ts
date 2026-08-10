// One-time backfill of the audit_log hash chain.
//
// Re-derives prev_hash + entry_hash for every existing row, ordered by
// created_at ASC (then id ASC for stable tie-breaking). Run this AFTER
// applying migration 0003_audit_chain.sql. New rows written by the audit()
// helper after this point will chain on the backfilled last entry's hash.
//
// Usage (from api/):
//   npx wrangler d1 execute securevote --local --file=./migrations/0003_audit_chain.sql
//   npx tsx scripts/backfill-audit-chain.ts --local
//   npx tsx scripts/backfill-audit-chain.ts --remote
//
// Without tsx you can also run the equivalent SQL emitted by --emit-sql.

import { execSync } from "node:child_process";
import { createHash } from "node:crypto";

const GENESIS = "genesis";

const target = process.argv.includes("--remote") ? "remote" : "local";

interface Row {
  id: string;
  actor_id: string | null;
  action: string;
  target_type: string | null;
  target_id: string | null;
  metadata: string | null;
  ip_address: string | null;
  created_at: number;
}

function serialize(row: {
  prevHash: string;
  action: string;
  actorId: string | null;
  targetType: string | null;
  targetId: string | null;
  metadata: string | null;
  ip: string | null;
  createdAt: number;
}): string {
  return [
    row.prevHash,
    row.action,
    row.actorId ?? "",
    row.targetType ?? "",
    row.targetId ?? "",
    row.metadata ?? "",
    row.ip ?? "",
    String(row.createdAt),
  ].join("|");
}

function hashOf(payload: string): string {
  return createHash("sha256").update(payload).digest("hex");
}

function runWrangler(command: string): string {
  return execSync(`npx wrangler ${command}`, { encoding: "utf8" });
}

function fetchAllRows(): Row[] {
  // Use wrangler d1 execute to read the rows as JSON. Wrangler prints
  // a JSON array after the leading log lines.
  const sql =
    "SELECT id, actor_id, action, target_type, target_id, metadata, " +
    "ip_address, created_at FROM audit_log ORDER BY created_at ASC, id ASC";
  const cmd = `d1 execute securevote --${target} --command=${JSON.stringify(sql)} --json`;
  const raw = runWrangler(cmd);
  // wrangler --json output: array of objects with a "results" array.
  const parsed = JSON.parse(raw) as Array<{ results?: Row[] }>;
  const first = parsed[0];
  if (!first || !Array.isArray(first.results)) {
    throw new Error("unexpected wrangler output: " + raw.slice(0, 200));
  }
  return first.results;
}

function main() {
  const rows = fetchAllRows();
  console.log(`[backfill] target=${target} rows=${rows.length}`);

  let prevHash = GENESIS;
  let updated = 0;

  for (const row of rows) {
    const payload = serialize({
      prevHash,
      action: row.action,
      actorId: row.actor_id,
      targetType: row.target_type,
      targetId: row.target_id,
      metadata: row.metadata,
      ip: row.ip_address,
      createdAt: row.created_at,
    });
    const entryHash = hashOf(payload);

    const sql =
      "UPDATE audit_log SET prev_hash = '" +
      prevHash.replace(/'/g, "''") +
      "', entry_hash = '" +
      entryHash +
      "' WHERE id = '" +
      row.id.replace(/'/g, "''") +
      "'";
    runWrangler(`d1 execute securevote --${target} --command=${JSON.stringify(sql)}`);

    prevHash = entryHash;
    updated += 1;
  }

  console.log(`[backfill] updated ${updated} rows; final hash=${prevHash.slice(0, 16)}...`);
}

main();
