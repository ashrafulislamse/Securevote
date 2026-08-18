// Verify which stored PBKDF2 hash matches which password, and generate a
// correct hash for "Voter@2026". Replicates api/src/lib/password.ts exactly.
import { pbkdf2, randomBytes } from "node:crypto";

const ITER = 100000, LEN = 32;
const enc = (s) => Buffer.from(s, "utf8");

function derive(password, salt) {
  return new Promise((res, rej) =>
    pbkdf2(password, salt, ITER, LEN, "sha256", (e, key) => (e ? rej(e) : res(key))),
  );
}
const hex = (b) => b.toString("hex")

async function hashOf(password, salt) {
  const key = await derive(password, salt);
  return `pbkdf2$${ITER}$${salt.toString("hex")}$${hex(key)}`;
}

async function main() {
  // The hash used in 9999_seed_admin.sql (16 zero bytes salt)
  const zeroSalt = Buffer.alloc(16);
  console.log("seed_admin hash for SecureVote@2026 (zero salt):", await hashOf("SecureVote@2026", zeroSalt));
  console.log("zero-salt hash for Voter@2026 :", await hashOf("Voter@2026", zeroSalt));

  // Correct random-salt hash for the demo voter password.
  const salt = randomBytes(16);
  console.log("\nReusable hash for demo voters (password Voter@2026):");
  console.log(await hashOf("Voter@2026", salt));
}
main();
