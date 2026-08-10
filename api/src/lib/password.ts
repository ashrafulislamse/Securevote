// Password hashing using PBKDF2 via the Web Crypto API.
// Workers-compatible (no Node crypto dependency).

const ITERATIONS = 100_000;
const KEY_LEN = 32; // bytes
const SALT_LEN = 16; // bytes

const enc = new TextEncoder();

function bufToHex(buf: ArrayBuffer | Uint8Array): string {
  const bytes = buf instanceof Uint8Array ? buf : new Uint8Array(buf);
  return Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function hexToBuf(hex: string): Uint8Array {
  const bytes = new Uint8Array(hex.length / 2);
  for (let i = 0; i < bytes.length; i++) {
    bytes[i] = parseInt(hex.slice(i * 2, i * 2 + 2), 16);
  }
  return bytes;
}

async function derive(password: string, salt: Uint8Array): Promise<ArrayBuffer> {
  const keyMaterial = await crypto.subtle.importKey(
    "raw",
    enc.encode(password),
    "PBKDF2",
    false,
    ["deriveBits"],
  );
  return crypto.subtle.deriveBits(
    {
      name: "PBKDF2",
      hash: "SHA-256",
      iterations: ITERATIONS,
      salt: salt.buffer as unknown as ArrayBuffer,
    },
    keyMaterial,
    KEY_LEN * 8,
  );
}

// Format: pbkdf2$<iterations>$<saltHex>$<hashHex>
export async function hashPassword(password: string): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(SALT_LEN));
  const derived = await derive(password, salt);
  return `pbkdf2$${ITERATIONS}$${bufToHex(salt)}$${bufToHex(derived)}`;
}

export async function verifyPassword(
  password: string,
  stored: string,
): Promise<boolean> {
  const parts = stored.split("$");
  if (parts.length !== 4 || parts[0] !== "pbkdf2") return false;
  const iterations = parseInt(parts[1]!, 10);
  const salt = hexToBuf(parts[2]!);
  const expected = parts[3]!;

  const keyMaterial = await crypto.subtle.importKey(
    "raw",
    enc.encode(password),
    "PBKDF2",
    false,
    ["deriveBits"],
  );
  const derived = await crypto.subtle.deriveBits(
    {
      name: "PBKDF2",
      hash: "SHA-256",
      iterations,
      salt: salt.buffer as unknown as ArrayBuffer,
    },
    keyMaterial,
    KEY_LEN * 8,
  );
  return bufToHex(derived) === expected;
}