// KV-backed rate limiting.
// Usage: await rateLimit(c.env, key, limit, windowSeconds) -> { ok, retryAfter }

import type { Env } from "../types";

interface RateResult {
  ok: boolean;
  retryAfter: number;
}

export async function rateLimit(
  env: Env,
  key: string,
  limit: number,
  windowSeconds: number,
): Promise<RateResult> {
  const bucket = `rl:${key}`;
  const value = await env.SESSIONS.get(bucket);
  if (!value) {
    await env.SESSIONS.put(bucket, "1", { expirationTtl: windowSeconds });
    return { ok: true, retryAfter: 0 };
  }
  let count = parseInt(value, 10) || 0;
  if (count >= limit) {
    return { ok: false, retryAfter: windowSeconds };
  }
  count += 1;
  await env.SESSIONS.put(bucket, String(count), {
    expirationTtl: windowSeconds,
    // KV has no read-modify-write atomicity; this is best-effort for FYP.
  });
  return { ok: true, retryAfter: 0 };
}