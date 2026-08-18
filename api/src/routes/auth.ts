// Authentication routes: register, verify-otp, login, refresh, logout, me.

import { Hono } from "hono";
import { zValidator } from "@hono/zod-validator";
import type { Env } from "../types";
import {
  registerSchema,
  verifyOtpSchema,
  loginSchema,
  refreshSchema,
  changePasswordSchema,
  updateProfileSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
  resendOtpSchema,
} from "../schemas";
import { hashPassword, verifyPassword } from "../lib/password";
import {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
} from "../lib/jwt";
import {
  generateOtp,
  isDevOtp,
  otpHasExpired,
  otpAlreadyAttempted,
} from "../lib/otp";
import { sendEmail } from "../lib/email";
import { uuid, now, sha256hex } from "../lib/utils";
import { auth, loadUser, type AuthUser, type AppContext } from "../middleware/auth";
import { audit } from "../middleware/audit";

export const authRoutes = new Hono<AppContext>();

// ---------------------------------------------------------------------------
// POST /auth/register
// Creates a pending registration + sends OTP. Does NOT log the user in.
// ---------------------------------------------------------------------------
authRoutes.post("/register", zValidator("json", registerSchema), async (c) => {
  const { email, password, fullName, phone } = c.req.valid("json");
  const normalized = email.toLowerCase();

  // Unique email check
  const existing = await c.env.DB.prepare(
    "SELECT id FROM users WHERE email = ?",
  )
    .bind(normalized)
    .first();

  if (existing) {
    return c.json({ error: "email already registered" }, 409);
  }

  const passwordHash = await hashPassword(password);
  const otp = generateOtp(c.env);
  const otpHash = await sha256hex(otp);
  const expiresAt = now() + 10 * 60 * 1000;

  await c.env.DB.prepare(
    `INSERT INTO pending_verifications (email, otp_hash, attempts, expires_at, created_at)
     VALUES (?, ?, 0, ?, ?)
     ON CONFLICT(email) DO UPDATE SET
       otp_hash = excluded.otp_hash,
       attempts = 0,
       expires_at = excluded.expires_at,
       created_at = excluded.created_at`,
  )
    .bind(normalized, otpHash, expiresAt, now())
    .run();

  // Retain the password hash across the pending step by writing demographic
  // data ahead of the user row. We keep it simple: store the user row later,
  // but stash the password hash in KV keyed by OTP so verification can create
  // the user atomically. For FYP, store the pending payload in KV.
  await c.env.SESSIONS.put(
    `pending:${normalized}`,
    JSON.stringify({ passwordHash, fullName, phone }),
    { expirationTtl: 600 },
  );

  await sendEmail(c.env, {
    to: normalized,
    subject: "SecureVote verification code",
    text: `Your SecureVote verification code is ${otp}.\n\nIt expires in 10 minutes.`,
  });

  await audit(c.env, {
    actorId: null,
    action: "auth.register",
    targetType: "email",
    targetId: normalized,
    ip: c.req.header("cf-connecting-ip"),
  });

  return c.json({
    ok: true,
    message: "OTP sent",
    // In dev/demo, return the OTP so the flow is testable without email.
    devOtp: isDevOtp(c.env) ? otp : undefined,
    expiresInSeconds: 600,
  });
});

// ---------------------------------------------------------------------------
// POST /auth/verify-otp
// Verifies the OTP, then creates the user + returns tokens.
// ---------------------------------------------------------------------------
authRoutes.post("/verify-otp", zValidator("json", verifyOtpSchema), async (c) => {
  const { email, otp } = c.req.valid("json");
  const normalized = email.toLowerCase();

  const pending = await c.env.DB.prepare(
    "SELECT * FROM pending_verifications WHERE email = ?",
  )
    .bind(normalized)
    .first<Record<string, unknown>>();

  if (!pending) {
    return c.json({ error: "no pending verification — register first" }, 400);
  }

  if (otpHasExpired(pending.expires_at as number)) {
    return c.json({ error: "OTP expired — request a new one" }, 400);
  }

  if (otpAlreadyAttempted((pending.attempts as number) ?? 0)) {
    return c.json(
      { error: "too many attempts — request a new OTP" },
      429,
    );
  }

  const storedHash = pending.otp_hash as string;
  const submittedHash = await sha256hex(otp);
  const valid = submittedHash === storedHash;

  if (!valid) {
    await c.env.DB.prepare(
      "UPDATE pending_verifications SET attempts = attempts + 1 WHERE email = ?",
    )
      .bind(normalized)
      .run();
    return c.json({ error: "invalid OTP" }, 400);
  }

  // OTP valid — fetch stashed payload and create the user.
  const payloadRaw = await c.env.SESSIONS.get(`pending:${normalized}`);
  if (!payloadRaw) {
    return c.json({ error: "registration session expired — register again" }, 400);
  }
  const payload = JSON.parse(payloadRaw) as {
    passwordHash: string;
    fullName: string;
    phone?: string;
  };

  const userId = uuid();
  const ts = now();
  await c.env.DB.prepare(
    `INSERT INTO users (id, email, password_hash, full_name, phone, role, kyc_status, created_at, updated_at)
     VALUES (?, ?, ?, ?, ?, 'voter', 'pending', ?, ?)`,
  )
    .bind(
      userId,
      normalized,
      payload.passwordHash,
      payload.fullName,
      payload.phone ?? null,
      ts,
      ts,
    )
    .run();

  // Clean up pending + KV stash.
  await c.env.DB.prepare("DELETE FROM pending_verifications WHERE email = ?")
    .bind(normalized)
    .run();
  await c.env.SESSIONS.delete(`pending:${normalized}`);

  const user = { id: userId, email: normalized, role: "voter" as const };
  const access = await signAccessToken(c.env, user);
  const refresh = await signRefreshToken(c.env, user);

  // Persist refresh token session.
  await c.env.DB.prepare(
    `INSERT INTO sessions (jti, user_id, refresh_token, expires_at, created_at)
     VALUES (?, ?, ?, ?, ?)`,
  )
    .bind(refresh.jti, userId, refresh.token, refresh.expiresAt, now())
    .run();

  await audit(c.env, {
    actorId: userId,
    action: "auth.verify-otp",
    ip: c.req.header("cf-connecting-ip"),
  });

  return c.json({
    ok: true,
    user: { id: userId, email: normalized, role: "voter", kycStatus: "pending" },
    accessToken: access.token,
    refreshToken: refresh.token,
    expiresAt: access.expiresAt,
  });
});

// ---------------------------------------------------------------------------
// POST /auth/login
// ---------------------------------------------------------------------------
authRoutes.post("/login", zValidator("json", loginSchema), async (c) => {
  const { email, password } = c.req.valid("json");
  const normalized = email.toLowerCase();

  const row = await c.env.DB.prepare("SELECT * FROM users WHERE email = ?")
    .bind(normalized)
    .first<Record<string, unknown>>();

  // Constant-ish timing: always run a hash check against a dummy to reduce
  // user-enumeration timing leaks (best-effort for FYP).
  if (!row) {
    await verifyPassword(password, "pbkdf2$100000$0000000000000000$0000000000000000000000000000000000000000000000000000000000000000");
    return c.json({ error: "invalid email or password" }, 401);
  }

  const valid = await verifyPassword(password, row.password_hash as string);
  if (!valid) {
    return c.json({ error: "invalid email or password" }, 401);
  }

  const user = {
    id: row.id as string,
    email: row.email as string,
    role: row.role as "voter" | "admin" | "verifier",
  };
  const access = await signAccessToken(c.env, user);
  const refresh = await signRefreshToken(c.env, user);

  await c.env.DB.prepare(
    `INSERT INTO sessions (jti, user_id, refresh_token, expires_at, created_at)
     VALUES (?, ?, ?, ?, ?)`,
  )
    .bind(refresh.jti, user.id, refresh.token, refresh.expiresAt, now())
    .run();

  await audit(c.env, {
    actorId: user.id,
    action: "auth.login",
    ip: c.req.header("cf-connecting-ip"),
  });

  return c.json({
    ok: true,
    user: {
      id: user.id,
      email: user.email,
      role: user.role,
      kycStatus: row.kyc_status,
      fullName: row.full_name,
    },
    accessToken: access.token,
    refreshToken: refresh.token,
    expiresAt: access.expiresAt,
  });
});

// ---------------------------------------------------------------------------
// POST /auth/refresh
// Exchange a refresh token for a new access token.
// ---------------------------------------------------------------------------
authRoutes.post("/refresh", zValidator("json", refreshSchema), async (c) => {
  const { refreshToken } = c.req.valid("json");
  const claims = await verifyRefreshToken(c.env, refreshToken);
  if (!claims) {
    return c.json({ error: "invalid refresh token" }, 401);
  }

  // Ensure the refresh token is still active (not revoked/expired).
  const session = await c.env.DB.prepare(
    "SELECT * FROM sessions WHERE jti = ? AND refresh_token = ?",
  )
    .bind(claims.jti, refreshToken)
    .first<Record<string, unknown>>();

  if (!session || session.revoked_at != null) {
    return c.json({ error: "refresh token revoked" }, 401);
  }
  if ((session.expires_at as number) < now()) {
    return c.json({ error: "refresh token expired" }, 401);
  }

  const access = await signAccessToken(c.env, {
    id: claims.sub,
    email: claims.email,
    role: claims.role,
  });

  return c.json({
    ok: true,
    accessToken: access.token,
    expiresAt: access.expiresAt,
  });
});

// ---------------------------------------------------------------------------
// POST /auth/logout (auth required)
// Revokes the current refresh session.
// ---------------------------------------------------------------------------
authRoutes.post("/logout", auth(), async (c) => {
  const user = c.get("user") as AuthUser;
  const jti = c.get("jti") as string;
  const body = await c.req.json().catch(() => ({}));
  const { refreshToken } = body as { refreshToken?: string };

  if (refreshToken) {
    const claims = await verifyRefreshToken(c.env, refreshToken);
    if (claims) {
      await c.env.DB.prepare(
        "UPDATE sessions SET revoked_at = ? WHERE jti = ? AND user_id = ?",
      )
        .bind(now(), claims.jti, user.id)
        .run();
    }
  } else {
    // Revoke all sessions for this user.
    await c.env.DB.prepare(
      "UPDATE sessions SET revoked_at = ? WHERE user_id = ? AND revoked_at IS NULL",
    )
      .bind(now(), user.id)
      .run();
  }

  await audit(c.env, {
    actorId: user.id,
    action: "auth.logout",
    ip: c.req.header("cf-connecting-ip"),
  });

  return c.json({ ok: true });
});

// ---------------------------------------------------------------------------
// GET /auth/me (auth required)
// ---------------------------------------------------------------------------
authRoutes.get("/me", auth(), async (c) => {
  const user = c.get("user") as AuthUser;
  const full = await loadUser(c.env, user.id);
  if (!full) {
    return c.json({ error: "user not found" }, 404);
  }
  return c.json({ user: full });
});

// ---------------------------------------------------------------------------
// PATCH /auth/profile (auth required)
// ---------------------------------------------------------------------------
authRoutes.patch(
  "/profile",
  auth(),
  zValidator("json", updateProfileSchema),
  async (c) => {
    const user = c.get("user") as AuthUser;
    const data = c.req.valid("json");

    const current = await loadUser(c.env, user.id);
    if (!current) return c.json({ error: "user not found" }, 404);

    const fullName = data.fullName ?? current.fullName;
    const phone = data.phone !== undefined ? data.phone : current.phone;

    await c.env.DB.prepare(
      "UPDATE users SET full_name = ?, phone = ?, updated_at = ? WHERE id = ?",
    )
      .bind(fullName, phone, now(), user.id)
      .run();

    await audit(c.env, {
      actorId: user.id,
      action: "auth.profile.update",
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true, user: { ...current, fullName, phone } });
  },
);

// ---------------------------------------------------------------------------
// POST /auth/change-password (auth required)
// ---------------------------------------------------------------------------
authRoutes.post(
  "/change-password",
  auth(),
  zValidator("json", changePasswordSchema),
  async (c) => {
    const user = c.get("user") as AuthUser;
    const { currentPassword, newPassword } = c.req.valid("json");

    const row = await c.env.DB.prepare(
      "SELECT password_hash FROM users WHERE id = ?",
    )
      .bind(user.id)
      .first<Record<string, unknown>>();
    if (!row) return c.json({ error: "user not found" }, 404);

    const valid = await verifyPassword(currentPassword, row.password_hash as string);
    if (!valid) return c.json({ error: "current password is incorrect" }, 400);

    const newHash = await hashPassword(newPassword);
    await c.env.DB.prepare(
      "UPDATE users SET password_hash = ?, updated_at = ? WHERE id = ?",
    )
      .bind(newHash, now(), user.id)
      .run();

    // Revoke all other sessions.
    await c.env.DB.prepare(
      "UPDATE sessions SET revoked_at = ? WHERE user_id = ? AND jti != ?",
    )
      .bind(now(), user.id, c.get("jti"))
      .run();

    await audit(c.env, {
      actorId: user.id,
      action: "auth.password.change",
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true });
  },
);

// ---------------------------------------------------------------------------
// POST /auth/forgot-password (public)
// Always returns ok so the response does not leak which emails are registered.
// Stores a short-lived reset token in KV and emails a link (or returns the
// token in dev/demo so the flow is testable without an email provider).
// ---------------------------------------------------------------------------
authRoutes.post(
  "/forgot-password",
  zValidator("json", forgotPasswordSchema),
  async (c) => {
    const { email } = c.req.valid("json");
    const normalized = email.toLowerCase();

    const genericOk = {
      ok: true,
      message: "If the email exists, a reset link has been sent.",
    };

    const row = await c.env.DB.prepare("SELECT id FROM users WHERE email = ?")
      .bind(normalized)
      .first<Record<string, unknown>>();

    if (!row) {
      return c.json(genericOk);
    }

    const token = uuid();
    await c.env.SESSIONS.put(
      `reset:${token}`,
      JSON.stringify({ userId: row.id as string, email: normalized }),
      { expirationTtl: 600 },
    );

    if (!isDevOtp(c.env)) {
      // APP_URL is an optional binding (read dynamically, like RESEND_API_KEY).
      const appUrl =
        (c.env as unknown as Record<string, string | undefined>)["APP_URL"] ??
        "https://securevote.app";
      const resetLink = `${appUrl}/reset-password?token=${token}`;
      await sendEmail(c.env, {
        to: normalized,
        subject: "SecureVote password reset",
        text: `Reset your SecureVote password by visiting:\n\n${resetLink}\n\nThis link expires in 10 minutes. If you did not request a reset, you can safely ignore this email.`,
      });
    }

    await audit(c.env, {
      actorId: null,
      action: "auth.forgot-password",
      targetType: "email",
      targetId: normalized,
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json(
      isDevOtp(c.env) ? { ...genericOk, devResetToken: token } : genericOk,
    );
  },
);

// ---------------------------------------------------------------------------
// POST /auth/reset-password (public)
// Consumes a reset token, sets the new password, and revokes all sessions.
// ---------------------------------------------------------------------------
authRoutes.post(
  "/reset-password",
  zValidator("json", resetPasswordSchema),
  async (c) => {
    const { token, newPassword } = c.req.valid("json");

    const raw = await c.env.SESSIONS.get(`reset:${token}`);
    if (!raw) {
      return c.json({ error: "reset token expired or invalid" }, 400);
    }

    const payload = JSON.parse(raw) as { userId: string; email: string };
    const userId = payload.userId;

    const newHash = await hashPassword(newPassword);
    await c.env.DB.prepare(
      "UPDATE users SET password_hash = ?, updated_at = ? WHERE id = ?",
    )
      .bind(newHash, now(), userId)
      .run();

    // One-shot token: delete it so it can't be reused.
    await c.env.SESSIONS.delete(`reset:${token}`);

    // Revoke every active session for this user (force re-login everywhere).
    await c.env.DB.prepare(
      "UPDATE sessions SET revoked_at = ? WHERE user_id = ? AND revoked_at IS NULL",
    )
      .bind(now(), userId)
      .run();

    await audit(c.env, {
      actorId: userId,
      action: "auth.password.reset",
      ip: c.req.header("cf-connecting-ip"),
    });

    return c.json({ ok: true });
  },
);

// ---------------------------------------------------------------------------
// POST /auth/resend-otp (public)
// Issues a fresh OTP for an in-flight registration (pending verification).
// ---------------------------------------------------------------------------
authRoutes.post("/resend-otp", zValidator("json", resendOtpSchema), async (c) => {
  const { email } = c.req.valid("json");
  const normalized = email.toLowerCase();

  const pending = await c.env.DB.prepare(
    "SELECT * FROM pending_verifications WHERE email = ?",
  )
    .bind(normalized)
    .first<Record<string, unknown>>();

  if (!pending) {
    return c.json({ error: "no pending verification — register first" }, 400);
  }

  const otp = generateOtp(c.env);
  const otpHash = await sha256hex(otp);
  const expiresAt = now() + 10 * 60 * 1000;

  await c.env.DB.prepare(
    "UPDATE pending_verifications SET otp_hash = ?, attempts = 0, expires_at = ?, created_at = ? WHERE email = ?",
  )
    .bind(otpHash, expiresAt, now(), normalized)
    .run();

  await sendEmail(c.env, {
    to: normalized,
    subject: "SecureVote verification code",
    text: `Your SecureVote verification code is ${otp}.\n\nIt expires in 10 minutes.`,
  });

  await audit(c.env, {
    actorId: null,
    action: "auth.resend-otp",
    targetType: "email",
    targetId: normalized,
    ip: c.req.header("cf-connecting-ip"),
  });

  return c.json({
    ok: true,
    message: "OTP sent",
    devOtp: isDevOtp(c.env) ? otp : undefined,
    expiresInSeconds: 600,
  });
});