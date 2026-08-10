// R2 helpers for private KYC documents.
//
// Strategy: keep KYC files in a private R2 bucket and stream them through
// an authenticated admin route (see `routes/kyc.ts` GET /document/:id).
// The signed-URL path (S3 sigv4 / Cloudflare admin API) is more complex
// than necessary for an FYP and the streaming route is equally "real" —
// the file never leaves our origin, audit is straightforward, and we don't
// need to manage S3-compatible credentials.

import type { Env } from "../types";

export interface R2ObjectLike {
  body: ReadableStream<Uint8Array> | null;
  httpMetadata?: { contentType?: string; contentLanguage?: string; contentDisposition?: string; contentEncoding?: string; cacheControl?: string } | undefined;
  customMetadata?: Record<string, string> | undefined;
  etag?: string;
  size?: number;
  uploaded?: Date;
}

/**
 * Fetch a private R2 object by key. Returns null if the object doesn't
 * exist. Throws on transport errors.
 */
export async function getR2Object(
  env: Env,
  key: string,
): Promise<R2ObjectLike | null> {
  const obj = await env.STORAGE.get(key);
  if (!obj) return null;
  return {
    body: obj.body,
    httpMetadata: obj.httpMetadata,
    customMetadata: obj.customMetadata,
    etag: obj.etag,
    size: obj.size,
    uploaded: obj.uploaded,
  };
}

/**
 * Build a `Content-Disposition: attachment; filename="..."` header so the
 * browser downloads the file with a sensible name instead of rendering it
 * inline. Falls back to the last path segment of the R2 key.
 */
export function buildContentDisposition(key: string, overrideName?: string): string {
  const fallback = key.split("/").pop() ?? "document";
  const safe = (overrideName ?? fallback).replace(/[\r\n"]/g, "_");
  return `attachment; filename="${safe}"`;
}
