// Cloudflare bindings + shared types for the SecureVote Worker.

export interface Env {
  DB: D1Database;
  STORAGE: R2Bucket;
  SESSIONS: KVNamespace;
  JWT_SECRET: string;
  API_VERSION: string;
  ENV: string;
  // Workers AI binding (admin AI assistant)
  AI?: Ai;
  // Phase 6 blockchain (Polygon Amoy)
  PRIVATE_KEY?: string;             // deployer EVM private key (hex, 0x-prefixed)
  AMOY_RPC_URL?: string;            // default "https://rpc-amoy.polygon.technology"
  VOTING_CONTRACT_ADDRESS?: string; // set after deploy
  // Legacy aliases (kept for backward compat with any existing code)
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