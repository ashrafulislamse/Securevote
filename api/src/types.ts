// Cloudflare bindings + shared types for the SecureVote Worker.

export interface Env {
  DB: D1Database;
  STORAGE: R2Bucket;
  SESSIONS: KVNamespace;
  JWT_SECRET: string;
  API_VERSION: string;
  ENV: string;
  // Phase 6 blockchain
  PRIVATE_KEY?: string;
  RPC_URL?: string;
  CONTRACT_ADDRESS?: string;
}

export type Role = "voter" | "admin" | "verifier";
export type KycStatus = "pending" | "approved" | "rejected";
export type ElectionStatus =
  | "draft"
  | "scheduled"
  | "active"
  | "closed"
  | "published";

export interface User {
  id: string;
  email: string;
  fullName: string;
  phone: string | null;
  role: Role;
  kycStatus: KycStatus;
  profilePic: string | null;
  createdAt: number;
}

// Claims embedded in our JWT.
export interface JwtClaims {
  sub: string; // user id
  email: string;
  role: Role;
  jti: string; // session / JWT id
  iat: number;
  exp: number;
}