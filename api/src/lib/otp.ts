// OTP generation + verification.
// In dev/demo, OTP is fixed to 123456 (matching the Flutter prototype) so the
// flow is testable without an email provider. In production ENV, a real OTP is
// generated and sent via email.

import type { Env } from "../types";
import { now } from "./utils";

export const DEV_OTP = "123456";
const OTP_TTL_MS = 10 * 60 * 1000; // 10 minutes
const MAX_ATTEMPTS = 5;

/**
 * Compute the OTP to deliver for a registration.
 * In ENV=development (or "demo"), returns the fixed dev OTP.
 * Otherwise returns a random 6-digit code.
 */
export function generateOtp(env: Env): string {
  if (env.ENV === "development" || env.ENV === "demo") return DEV_OTP;
  return String(Math.floor(100000 + Math.random() * 900000));
}

export function isDevOtp(env: Env): boolean {
  return env.ENV === "development" || env.ENV === "demo";
}

export const otpHasExpired = (expiresAt: number): boolean =>
  now() > expiresAt;

export function otpAlreadyAttempted(attempts: number): boolean {
  return attempts >= MAX_ATTEMPTS;
}