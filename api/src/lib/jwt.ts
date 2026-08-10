// JWT creation + verification using jose (Workers-compatible).

import { SignJWT, jwtVerify } from "jose";
import type { Env, JwtClaims, Role } from "../types";
import { uuid, now } from "./utils";

const ACCESS_TTL = 60 * 60 * 24; // 24h access token (short enough for FYP)
const REFRESH_TTL = 60 * 60 * 24 * 30; // 30d refresh token

function secretKey(env: Env) {
  return new TextEncoder().encode(env.JWT_SECRET);
}

export async function signAccessToken(
  env: Env,
  user: { id: string; email: string; role: Role },
): Promise<{ token: string; jti: string; expiresAt: number }> {
  const jti = uuid();
  const iat = Math.floor(now() / 1000);
  const exp = iat + ACCESS_TTL;
  const token = await new SignJWT({
    email: user.email,
    role: user.role,
  })
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(user.id)
    .setJti(jti)
    .setIssuedAt(iat)
    .setExpirationTime(exp)
    .sign(secretKey(env));
  return { token, jti, expiresAt: exp * 1000 };
}

export async function signRefreshToken(
  env: Env,
  user: { id: string; email: string; role: Role },
): Promise<{ token: string; jti: string; expiresAt: number }> {
  const jti = uuid();
  const iat = Math.floor(now() / 1000);
  const exp = iat + REFRESH_TTL;
  const token = await new SignJWT({
    email: user.email,
    role: user.role,
    type: "refresh",
  })
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(user.id)
    .setJti(jti)
    .setIssuedAt(iat)
    .setExpirationTime(exp)
    .sign(secretKey(env));
  return { token, jti, expiresAt: exp * 1000 };
}

export async function verifyAccessToken(
  env: Env,
  token: string,
): Promise<JwtClaims | null> {
  try {
    const { payload } = await jwtVerify(token, secretKey(env), {
      algorithms: ["HS256"],
    });
    if (payload.type === "refresh") return null; // refresh tokens can't be access
    if (!payload.sub || !payload.jti) return null;
    return {
      sub: payload.sub,
      email: (payload.email as string) ?? "",
      role: (payload.role as Role) ?? "voter",
      jti: payload.jti,
      iat: payload.iat ?? 0,
      exp: payload.exp ?? 0,
    };
  } catch {
    return null;
  }
}

export async function verifyRefreshToken(
  env: Env,
  token: string,
): Promise<JwtClaims | null> {
  try {
    const { payload } = await jwtVerify(token, secretKey(env), {
      algorithms: ["HS256"],
    });
    if (payload.type !== "refresh") return null;
    if (!payload.sub || !payload.jti) return null;
    return {
      sub: payload.sub,
      email: (payload.email as string) ?? "",
      role: (payload.role as Role) ?? "voter",
      jti: payload.jti,
      iat: payload.iat ?? 0,
      exp: payload.exp ?? 0,
    };
  } catch {
    return null;
  }
}