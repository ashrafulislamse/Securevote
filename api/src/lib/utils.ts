// Small shared helpers: id generation, hashing, time, JSON.

import type { User } from "../types";

export const uuid = (): string => crypto.randomUUID();

export const now = (): number => Date.now();

export const sha256hex = async (input: string): Promise<string> => {
  const data = new TextEncoder().encode(input);
  const digest = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
};

// Uniqueness salt for receipt hashes.
export const bytesToHex = (bytes: Uint8Array): string =>
  Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");

export const randomHex = (len: number): string => {
  const bytes = new Uint8Array(len);
  crypto.getRandomValues(bytes);
  return bytesToHex(bytes);
};

// Map a D1 row (snake_case) to a camelCase User object.
export function rowToUser(row: Record<string, unknown>): User {
  return {
    id: row.id as string,
    email: row.email as string,
    fullName: row.full_name as string,
    phone: (row.phone as string) ?? null,
    role: row.role as User["role"],
    kycStatus: row.kyc_status as User["kycStatus"],
    profilePic: (row.profile_pic as string) ?? null,
    createdAt: row.created_at as number,
  };
}

export function jsonSafe(value: unknown): string {
  return JSON.stringify(value ?? null);
}