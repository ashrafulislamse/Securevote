// Auth + RBAC middleware using Hono's Bindings context.

import type { Context, Next, MiddlewareHandler } from "hono";
import type { Env, Role, User } from "../types";
import { verifyAccessToken } from "../lib/jwt";
import { audit } from "./audit";

export interface AuthUser {
  id: string;
  email: string;
  role: Role;
}

// Hono context shape: binds bindings + custom variables set by middleware.
export type AppContext = {
  Bindings: Env;
  Variables: {
    user: AuthUser;
    jti: string;
  };
};

// Parse `Authorization: Bearer <token>`; attach claims to c.set("user").
export const auth = (): MiddlewareHandler<AppContext> => {
  return async (c: Context<AppContext>, next: Next) => {
    const header = c.req.header("authorization");
    if (!header?.startsWith("Bearer ")) {
      return c.json({ error: "unauthorized" }, 401);
    }
    const token = header.slice(7);
    const claims = await verifyAccessToken(c.env, token);
    if (!claims) {
      return c.json({ error: "invalid or expired token" }, 401);
    }
    c.set("user", { id: claims.sub, email: claims.email, role: claims.role });
    c.set("jti", claims.jti);
    await next();
  };
};

// Require one of the given roles. Must run after `auth()`.
export const requireRole =
  (...roles: Role[]): MiddlewareHandler<AppContext> =>
  async (c: Context<AppContext>, next: Next) => {
    const user = c.get("user") as AuthUser | undefined;
    if (!user) {
      return c.json({ error: "unauthorized" }, 401);
    }
    if (!roles.includes(user.role)) {
      await audit(c.env, {
        actorId: user.id,
        action: "forbidden",
        metadata: { required: roles, actual: user.role },
      });
      return c.json({ error: "forbidden" }, 403);
    }
    await next();
  };

// Optional auth: sets user if a valid token is present, but never rejects.
export const optionalAuth = (): MiddlewareHandler<AppContext> => {
  return async (c: Context<AppContext>, next: Next) => {
    const header = c.req.header("authorization");
    if (header?.startsWith("Bearer ")) {
      const claims = await verifyAccessToken(c.env, header.slice(7));
      if (claims) {
        c.set("user", {
          id: claims.sub,
          email: claims.email,
          role: claims.role,
        });
        c.set("jti", claims.jti);
      }
    }
    await next();
  };
};

// Load the full user row by id (for kycStatus checks etc.).
export async function loadUser(
  env: Env,
  id: string,
): Promise<User | null> {
  const row = await env.DB.prepare(
    "SELECT * FROM users WHERE id = ?",
  )
    .bind(id)
    .first<Record<string, unknown>>();
  if (!row) return null;
  return {
    id: row.id as string,
    email: row.email as string,
    fullName: row.full_name as string,
    phone: (row.phone as string) ?? null,
    role: row.role as Role,
    kycStatus: row.kyc_status as User["kycStatus"],
    profilePic: (row.profile_pic as string) ?? null,
    createdAt: row.created_at as number,
  };
}