import { describe, it, expect } from "vitest";
import {
  generateOtp,
  isDevOtp,
  otpHasExpired,
  otpAlreadyAttempted,
  DEV_OTP,
} from "./otp";
import type { Env } from "../types";

function makeEnv(env: string): Env {
  return {
    DB: {} as unknown as Env["DB"],
    STORAGE: {} as unknown as Env["STORAGE"],
    SESSIONS: {} as unknown as Env["SESSIONS"],
    JWT_SECRET: "test-secret",
    API_VERSION: "1.0.0",
    ENV: env,
  };
}

describe("OTP generation", () => {
  it("returns the fixed dev OTP in development", () => {
    expect(generateOtp(makeEnv("development"))).toBe(DEV_OTP);
    expect(DEV_OTP).toBe("123456");
  });

  it("returns the fixed dev OTP in demo", () => {
    expect(generateOtp(makeEnv("demo"))).toBe(DEV_OTP);
  });

  it("returns a random 6-digit code in production", () => {
    const code = generateOtp(makeEnv("production"));
    expect(code).toMatch(/^\d{6}$/);
    expect(code).not.toBe(DEV_OTP);
  });

  it("isDevOtp mirrors generateOtp logic", () => {
    expect(isDevOtp(makeEnv("development"))).toBe(true);
    expect(isDevOtp(makeEnv("demo"))).toBe(true);
    expect(isDevOtp(makeEnv("production"))).toBe(false);
  });
});

describe("OTP expiry / attempts", () => {
  it("otpHasExpired returns true when now > expiresAt", () => {
    expect(otpHasExpired(Date.now() - 1000)).toBe(true);
  });

  it("otpHasExpired returns false when now < expiresAt", () => {
    expect(otpHasExpired(Date.now() + 60_000)).toBe(false);
  });

  it("otpAlreadyAttempted flags at MAX_ATTEMPTS (5)", () => {
    expect(otpAlreadyAttempted(4)).toBe(false);
    expect(otpAlreadyAttempted(5)).toBe(true);
    expect(otpAlreadyAttempted(10)).toBe(true);
  });
});
