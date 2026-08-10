// In-app notification routes: list, unread count, mark-read, mark-all-read,
// delete. All endpoints require authentication. The list returns the latest
// 50 notifications for the calling user (newest first).
//
// Notifications are created by the helpers in `../lib/notifications.ts` from
// elsewhere in the system (KYC, voting, elections). This route file is
// purely the read/acknowledge side.

import { Hono } from "hono";
import type { Env } from "../types";
import { auth, type AuthUser, type AppContext } from "../middleware/auth";
import { audit } from "../middleware/audit";

export const notificationsRoutes = new Hono<AppContext>();

// All endpoints in this router are authenticated.
notificationsRoutes.use("*", auth());

// Map a notifications row (snake_case) to camelCase JSON.
function rowToNotification(row: Record<string, unknown>) {
  return {
    id: row.id as string,
    userId: row.user_id as string,
    title: row.title as string,
    body: (row.body as string | null) ?? "",
    type: row.type as string,
    read: ((row.read as number) ?? 0) === 1,
    createdAt: row.created_at as number,
  };
}

// ---------------------------------------------------------------------------
// GET /notifications — current user's notifications (latest 50).
// ---------------------------------------------------------------------------
notificationsRoutes.get("/", async (c) => {
  const user = c.get("user") as AuthUser;
  const { results } = await c.env.DB.prepare(
    `SELECT id, user_id, title, body, type, read, created_at
     FROM notifications
     WHERE user_id = ?
     ORDER BY created_at DESC
     LIMIT 50`,
  )
    .bind(user.id)
    .all<Record<string, unknown>>();

  return c.json({ notifications: results.map(rowToNotification) });
});

// ---------------------------------------------------------------------------
// GET /notifications/unread-count — `{ count: 5 }`.
// ---------------------------------------------------------------------------
notificationsRoutes.get("/unread-count", async (c) => {
  const user = c.get("user") as AuthUser;
  const row = await c.env.DB.prepare(
    "SELECT COUNT(*) AS n FROM notifications WHERE user_id = ? AND read = 0",
  )
    .bind(user.id)
    .first<{ n: number }>();

  return c.json({ count: row?.n ?? 0 });
});

// ---------------------------------------------------------------------------
// POST /notifications/:id/read — mark a single notification as read.
// Returns 404 if it doesn't exist or doesn't belong to the caller.
// ---------------------------------------------------------------------------
notificationsRoutes.post("/:id/read", async (c) => {
  const id = c.req.param("id");
  const user = c.get("user") as AuthUser;

  const existing = await c.env.DB.prepare(
    "SELECT user_id, read FROM notifications WHERE id = ?",
  )
    .bind(id)
    .first<{ user_id: string; read: number }>();
  if (!existing) return c.json({ error: "notification not found" }, 404);
  if (existing.user_id !== user.id) {
    return c.json({ error: "notification not found" }, 404);
  }

  if (existing.read !== 1) {
    await c.env.DB.prepare(
      "UPDATE notifications SET read = 1 WHERE id = ?",
    )
      .bind(id)
      .run();
    await audit(c.env, {
      actorId: user.id,
      action: "notification.read",
      targetType: "notification",
      targetId: id,
    });
  }

  return c.json({ ok: true });
});

// ---------------------------------------------------------------------------
// POST /notifications/read-all — mark every notification as read.
// ---------------------------------------------------------------------------
notificationsRoutes.post("/read-all", async (c) => {
  const user = c.get("user") as AuthUser;

  const res = await c.env.DB.prepare(
    "UPDATE notifications SET read = 1 WHERE user_id = ? AND read = 0",
  )
    .bind(user.id)
    .run();

  await audit(c.env, {
    actorId: user.id,
    action: "notification.read.all",
    metadata: { updated: res.meta?.changes ?? 0 },
  });

  return c.json({ ok: true, updated: res.meta?.changes ?? 0 });
});

// ---------------------------------------------------------------------------
// DELETE /notifications/:id — soft delete (we don't actually have a deleted
// column, so this simply removes the row). 404 when not found / not owned.
// ---------------------------------------------------------------------------
notificationsRoutes.delete("/:id", async (c) => {
  const id = c.req.param("id");
  const user = c.get("user") as AuthUser;

  const existing = await c.env.DB.prepare(
    "SELECT user_id FROM notifications WHERE id = ?",
  )
    .bind(id)
    .first<{ user_id: string }>();
  if (!existing || existing.user_id !== user.id) {
    return c.json({ error: "notification not found" }, 404);
  }

  await c.env.DB.prepare("DELETE FROM notifications WHERE id = ?")
    .bind(id)
    .run();

  await audit(c.env, {
    actorId: user.id,
    action: "notification.delete",
    targetType: "notification",
    targetId: id,
  });

  return c.json({ ok: true });
});

// Avoid an "unused import" warning when Env is only referenced via context.
export type _NotificationsEnv = Env;
