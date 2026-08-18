import { describe, it, expect } from "vitest";
import { hashPassword, verifyPassword } from "./password";

describe("password hashing", () => {
  it("hashes a password into the pbkdf2$iterations$salt$hash format", async () => {
    const stored = await hashPassword("CorrectHorseBatteryStaple");
    expect(stored).toMatch(/^pbkdf2\$100000\$[0-9a-f]{32}\$[0-9a-f]{64}$/);
  });

  it("verifies the correct password", async () => {
    const stored = await hashPassword("S3cureVote!2026");
    await expect(verifyPassword("S3cureVote!2026", stored)).resolves.toBe(true);
  });

  it("rejects the wrong password", async () => {
    const stored = await hashPassword("S3cureVote!2026");
    await expect(verifyPassword("wrong-password", stored)).resolves.toBe(false);
  });

  it("generates a different salt each time (unique hashes)", async () => {
    const a = await hashPassword("samePassword");
    const b = await hashPassword("samePassword");
    expect(a).not.toBe(b);
    // Both should still verify.
    await expect(verifyPassword("samePassword", a)).resolves.toBe(true);
    await expect(verifyPassword("samePassword", b)).resolves.toBe(true);
  });

  it("rejects a malformed stored string", async () => {
    await expect(verifyPassword("x", "not-a-valid-hash")).resolves.toBe(false);
  });
});
