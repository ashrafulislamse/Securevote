// Audit logging helper — writes a row to the audit_log table with a
// tamper-evident hash chain.
//
// entry_hash = sha256(prev_hash || action || actor_id || target_type ||
//                      target_id || metadata || ip_address || created_at)
//
// For the very first row, prev_hash is the literal string "genesis".
// Each subsequent row's prev_hash is the previous row's entry_hash, so
// modifying any historical row breaks the chain at that point and all
// rows after it.

import type { Env } from "../types";
import { uuid, now, jsonSafe, sha256hex } from "../lib/utils";

interface AuditInput {
  actorId: string | null;
  action: string;
  targetType?: string;
  targetId?: string;
  metadata?: Record<string, unknown>;
  ip?: string;
}

export const GENESIS_HASH = "genesis";

/** Serialize the row fields that contribute to the chain hash. */
function serializeForHash(parts: {
  prevHash: string;
  action: string;
  actorId: string | null;
  targetType: string | null;
  targetId: string | null;
  metadata: string | null;
  ip: string | null;
  createdAt: number;
}): string {
  // Use a delimiter that cannot appear in any of the fields (it is just "|").
  // Fields are coerced to strings; null becomes the empty string so the
  // resulting payload is stable for a given logical row.
  const fields = [
    parts.prevHash,
    parts.action,
    parts.actorId ?? "",
    parts.targetType ?? "",
    parts.targetId ?? "",
    parts.metadata ?? "",
    parts.ip ?? "",
    String(parts.createdAt),
  ];
  return fields.join("|");
}

export async function computeEntryHash(parts: {
  prevHash: string;
  action: string;
  actorId: string | null;
  targetType: string | null;
  targetId: string | null;
  metadata: string | null;
  ip: string | null;
  createdAt: number;
}): Promise<string> {
  return sha256hex(serializeForHash(parts));
}

export async function audit(env: Env, input: AuditInput): Promise<void> {
  try {
    const createdAt = now();
    const metadataStr = input.metadata ? jsonSafe(input.metadata) : null;
    const actorId = input.actorId ?? null;
    const targetType = input.targetType ?? null;
    const targetId = input.targetId ?? null;
    const ip = input.ip ?? null;

    // Find the most recent entry's entry_hash. The very first row links to
    // "genesis"; otherwise we chain on the previous row's hash. ORDER BY
    // created_at DESC, id DESC so rows inserted in the same millisecond
    // still pick a deterministic predecessor.
    const prevRow = await env.DB.prepare(
      "SELECT entry_hash FROM audit_log ORDER BY created_at DESC, id DESC LIMIT 1",
    )
      .first<{ entry_hash: string } | null>();
    const prevHash = prevRow?.entry_hash ?? GENESIS_HASH;

    const entryHash = await computeEntryHash({
      prevHash,
      action: input.action,
      actorId,
      targetType,
      targetId,
      metadata: metadataStr,
      ip,
      createdAt,
    });

    await env.DB.prepare(
      `INSERT INTO audit_log
         (id, actor_id, action, target_type, target_id, metadata,
          ip_address, created_at, prev_hash, entry_hash)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    )
      .bind(
        uuid(),
        actorId,
        input.action,
        targetType,
        targetId,
        metadataStr,
        ip,
        createdAt,
        prevHash,
        entryHash,
      )
      .run();
  } catch (e) {
    // Audit failures must never break the request.
    console.error("audit failed", e);
  }
}
