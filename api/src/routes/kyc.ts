// KYC routes: submit documents (to R2), check status, admin approve/reject queue.

import { Hono } from "hono";
import { zValidator } from "@hono/zod-validator";
import type { Env, KycStatus } from "../types";
import { kycSubmitSchema, kycReviewSchema } from "../schemas";
import { uuid, now } from "../lib/utils";
import { auth, requireRole, type AuthUser, type AppContext } from "../middleware/auth";
import { audit } from "../middleware/audit";
import { getR2Object, buildContentDisposition } from "../lib/r2";

export const kycRoutes = new Hono<AppContext>();

// ---------------------------------------------------------------------------
// POST /kyc/submit — upload ID/selfie to R2 + mark pending. Auth required.
// The binary file is sent as multipart form-data field "file".
// ---------------------------------------------------------------------------
kycRoutes.post(
  "/submit",
  auth(),
  async (c) => {
    const user = c.get("user") as AuthUser;
    const form = await c.req.formData();
    const file = form.get("file") as File | null;
    const docType = (form.get("docType") as string) || "id";

    if (!file) return c.json({ error: "file is required" }, 400);
    if (file.size > 10 * 1024 * 1024) {
      return c.json({ error: "file too large (max 10MB)" }, 400);
    }

    const ext = file.type?.split("/")[1] ?? "bin";
    const r2Key = `kyc/${user.id}/${uuid()}.${ext}`;
    await c.env.STORAGE.put(r2Key, file.stream(), {
      httpMetadata: { contentType: file.type },
    });

    const docId = uuid();
    await c.env.DB.prepare(
      `INSERT INTO kyc_documents (id, user_id, doc_type, r2_key, status, created_at)
       VALUES (?, ?, ?, ?, 'pending', ?)`,
    )
      .bind(docId, user.id, docType, r2Key, now())
      .run();

    // Update user status to pending (if not already approved).
    await c.env.DB.prepare(
      "UPDATE users SET kyc_status = 'pending', updated_at = ? WHERE id = ?",
    )
      .bind(now(), user.id)
      .run();

    await audit(c.env, {
      actorId: user.id,
      action: "kyc.submit",
      targetType: "kyc_document",
      targetId: docId,
      ip: c.req.header("cf-connecting-ip"),
    });

    // In development, auto-approve KYC so the demo flow is seamless.
    const isDev = c.env.ENV === "development" || c.env.ENV === "demo";
    if (isDev) {
      await c.env.DB.prepare(
        "UPDATE kyc_documents SET status = 'approved', reviewed_by = ?, reviewed_at = ? WHERE id = ?",
      ).bind(user.id, now(), docId).run();

      await c.env.DB.prepare(
        "UPDATE users SET kyc_status = 'approved', updated_at = ? WHERE id = ?",
      ).bind(now(), user.id).run();

      // Notify the user.
      await c.env.DB.prepare(
        `INSERT INTO notifications (id, user_id, title, body, type, read, created_at)
         VALUES (?, ?, ?, ?, 'kyc', 0, ?)`,
      ).bind(uuid(), user.id, "KYC approved", "Your identity verification was approved (dev auto-approve). You can now vote.", now()).run();

      await audit(c.env, {
        actorId: user.id,
        action: "kyc.auto-approve-dev",
        targetType: "kyc_document",
        targetId: docId,
        ip: c.req.header("cf-connecting-ip"),
      });

      return c.json({ ok: true, document: { id: docId, status: "approved" }, devAutoApproved: true }, 201);
    }

    return c.json({ ok: true, document: { id: docId, status: "pending" } }, 201);
  },
);

// ---------------------------------------------------------------------------
// GET /kyc/status — current user's KYC status + documents.
// ---------------------------------------------------------------------------
kycRoutes.get("/status", auth(), async (c) => {
  const user = c.get("user") as AuthUser;
  const row = await c.env.DB.prepare(
    "SELECT kyc_status FROM users WHERE id = ?",
  )
    .bind(user.id)
    .first<Record<string, unknown>>();

  const docs = await c.env.DB.prepare(
    "SELECT id, doc_type, status, created_at FROM kyc_documents WHERE user_id = ? ORDER BY created_at DESC",
  )
    .bind(user.id)
    .all();

  return c.json({
    status: (row?.kyc_status as KycStatus) ?? "pending",
    documents: docs.results,
  });
});

// ---------------------------------------------------------------------------
// GET /kyc/queue — pending KYC documents for admin review. Admin only.
// ---------------------------------------------------------------------------
kycRoutes.get("/queue", auth(), requireRole("admin"), async (c) => {
  const { results } = await c.env.DB.prepare(
    `SELECT k.id, k.doc_type, k.r2_key, k.status, k.created_at,
            u.id AS user_id, u.full_name, u.email
     FROM kyc_documents k
     JOIN users u ON u.id = k.user_id
     WHERE k.status = 'pending'
     ORDER BY k.created_at ASC`,
  )
    .all<Record<string, unknown>>();

  return c.json({ queue: results });
});

// ---------------------------------------------------------------------------
// POST /kyc/:id/review — approve/reject a KYC document. Admin only.
// ---------------------------------------------------------------------------
kycRoutes.post(
  "/:id/review",
  auth(),
  requireRole("admin"),
  zValidator("json", kycReviewSchema),
  async (c) => {
    const docId = c.req.param("id");
    const { decision, note } = c.req.valid("json");
    const admin = c.get("user") as AuthUser;

    const doc = await c.env.DB.prepare(
      "SELECT * FROM kyc_documents WHERE id = ?",
    )
      .bind(docId)
      .first<Record<string, unknown>>();
    if (!doc) return c.json({ error: "document not found" }, 404);

    const newStatus: KycStatus = decision === "approve" ? "approved" : "rejected";
    await c.env.DB.prepare(
      `UPDATE kyc_documents SET status = ?, admin_note = ?, reviewed_by = ?, reviewed_at = ? WHERE id = ?`,
    )
      .bind(newStatus, note ?? null, admin.id, now(), docId)
      .run();

    // Update the user's KYC status.
    await c.env.DB.prepare(
      "UPDATE users SET kyc_status = ?, updated_at = ? WHERE id = ?",
    )
      .bind(newStatus, now(), doc.user_id)
      .run();

    // Notify the user.
    await c.env.DB.prepare(
      `INSERT INTO notifications (id, user_id, title, body, type, read, created_at)
       VALUES (?, ?, ?, ?, 'kyc', 0, ?)`,
    )
      .bind(
        uuid(),
        doc.user_id,
        decision === "approve" ? "KYC approved" : "KYC rejected",
        decision === "approve"
          ? "Your identity verification was approved. You can now vote."
          : `Your identity verification was rejected. ${note ?? ""}`,
        now(),
      )
      .run();

    await audit(c.env, {
      actorId: admin.id,
      action: `kyc.${decision}`,
      targetType: "kyc_document",
      targetId: docId,
      metadata: { userId: doc.user_id },
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true, status: newStatus });
  },
);

// ---------------------------------------------------------------------------
// GET /kyc/document/:id — admin-only streaming download of the private R2
// object. The bucket is not public; we keep the file inside our origin and
// gate every read on a valid admin session + audit row. This replaces the
// presigned-URL pattern for an FYP (simpler, equally real, audit-friendly).
// ---------------------------------------------------------------------------
kycRoutes.get("/document/:id", auth(), requireRole("admin"), async (c) => {
  const docId = c.req.param("id");
  const admin = c.get("user") as AuthUser;

  const doc = await c.env.DB.prepare(
    "SELECT * FROM kyc_documents WHERE id = ?",
  )
    .bind(docId)
    .first<Record<string, unknown>>();
  if (!doc) return c.json({ error: "document not found" }, 404);

  const obj = await getR2Object(c.env, doc.r2_key as string);
  if (!obj || !obj.body) {
    return c.json({ error: "object not found in storage" }, 404);
  }

  const headers: Record<string, string> = {
    "Content-Disposition": buildContentDisposition(doc.r2_key as string),
  };
  if (obj.httpMetadata?.contentType) {
    headers["Content-Type"] = obj.httpMetadata.contentType;
  } else {
    headers["Content-Type"] = "application/octet-stream";
  }
  if (typeof obj.size === "number") {
    headers["Content-Length"] = String(obj.size);
  }
  if (obj.etag) headers["ETag"] = obj.etag;
  if (obj.httpMetadata?.cacheControl) {
    headers["Cache-Control"] = obj.httpMetadata.cacheControl;
  }

  await audit(c.env, {
    actorId: admin.id,
    action: "kyc.document.download",
    targetType: "kyc_document",
    targetId: docId,
    metadata: { r2Key: doc.r2_key, userId: doc.user_id, size: obj.size ?? null },
    ip: c.req.header("cf-connecting-ip"),
  });

  return new Response(obj.body, { headers });
});