// Audit logging helper — writes a row to the audit_log table.

import type { Env } from "../types";
import { uuid, now, jsonSafe } from "../lib/utils";

interface AuditInput {
  actorId: string | null;
  action: string;
  targetType?: string;
  targetId?: string;
  metadata?: Record<string, unknown>;
  ip?: string;
}

export async function audit(env: Env, input: AuditInput): Promise<void> {
  try {
    await env.DB.prepare(
      `INSERT INTO audit_log (id, actor_id, action, target_type, target_id, metadata, ip_address, created_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    )
      .bind(
        uuid(),
        input.actorId,
        input.action,
        input.targetType ?? null,
        input.targetId ?? null,
        input.metadata ? jsonSafe(input.metadata) : null,
        input.ip ?? null,
        now(),
      )
      .run();
  } catch (e) {
    // Audit failures must never break the request.
    console.error("audit failed", e);
  }
}