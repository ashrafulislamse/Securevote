import {
  clearTokens,
  getAccessToken,
  getRefreshToken,
  setAccessToken,
  setTokens,
} from "./session";

export type Role = "voter" | "admin" | "verifier";

export type User = {
  id: string;
  email: string;
  fullName: string;
  phone?: string | null;
  role: Role;
  kycStatus: string;
  createdAt: string;
};

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? "http://127.0.0.1:8787";

export class ApiError extends Error {
  status: number;

  constructor(status: number, message: string) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }
}

/**
 * Low-level authenticated fetch wrapper.
 * - Attaches `Authorization: Bearer <accessToken>` from localStorage.
 * - On 401, attempts a single token refresh and retries the request once.
 */
export async function apiRequest<T>(
  path: string,
  options: RequestInit = {},
  retryOnUnauthorized = true,
): Promise<T> {
  const headers = new Headers(options.headers);
  headers.set("Content-Type", "application/json");

  const token = getAccessToken();
  if (token) {
    headers.set("Authorization", `Bearer ${token}`);
  }

  const response = await fetch(`${API_BASE}${path}`, { ...options, headers });

  if (response.status === 401 && retryOnUnauthorized) {
    const refreshed = await refresh();
    if (refreshed) {
      return apiRequest<T>(path, options, false);
    }
  }

  if (!response.ok) {
    const body = (await response.json().catch(() => ({}))) as { message?: string };
    throw new ApiError(response.status, body?.message ?? `Request failed (${response.status})`);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return (await response.json()) as T;
}

/** Attempts to refresh the access token using the stored refresh token. */
export async function refresh(): Promise<boolean> {
  const refreshToken = getRefreshToken();
  if (!refreshToken) {
    return false;
  }

  try {
    const response = await fetch(`${API_BASE}/api/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken }),
    });

    if (!response.ok) {
      return false;
    }

    const data = (await response.json()) as { ok: boolean; accessToken: string };
    if (!data.ok || !data.accessToken) {
      return false;
    }

    setAccessToken(data.accessToken);
    return true;
  } catch {
    return false;
  }
}

type LoginResponse = {
  ok: boolean;
  user: User;
  accessToken: string;
  refreshToken: string;
};

export async function login(email: string, password: string): Promise<User> {
  const data = await apiRequest<LoginResponse>(
    "/api/auth/login",
    {
      method: "POST",
      body: JSON.stringify({ email, password }),
    },
    false,
  );

  setTokens(data.accessToken, data.refreshToken);
  return data.user;
}

type RegisterResponse = {
  ok: boolean;
  message: string;
  devOtp?: string;
  expiresInSeconds?: number;
};

export async function register(input: {
  email: string;
  password: string;
  fullName: string;
  phone?: string;
}): Promise<RegisterResponse> {
  return apiRequest<RegisterResponse>(
    "/api/auth/register",
    {
      method: "POST",
      body: JSON.stringify(input),
    },
    false,
  );
}

export async function verifyOtp(email: string, otp: string): Promise<User> {
  const data = await apiRequest<LoginResponse>(
    "/api/auth/verify-otp",
    {
      method: "POST",
      body: JSON.stringify({ email, otp }),
    },
    false,
  );

  setTokens(data.accessToken, data.refreshToken);
  return data.user;
}

export async function logout(): Promise<void> {
  const refreshToken = getRefreshToken();
  try {
    await apiRequest<{ ok: boolean }>(
      "/api/auth/logout",
      {
        method: "POST",
        body: JSON.stringify({ refreshToken }),
      },
      false,
    );
  } catch {
    // Ignore errors on logout — the client state is cleared regardless.
  } finally {
    clearTokens();
  }
}

export async function me(): Promise<User> {
  const data = await apiRequest<{ user: User }>("/api/auth/me");
  return data.user;
}

export async function updateProfile(patch: {
  fullName?: string;
  phone?: string;
}): Promise<User> {
  const data = await apiRequest<{ ok: boolean; user: User }>("/api/auth/profile", {
    method: "PATCH",
    body: JSON.stringify(patch),
  });
  return data.user;
}

// ---------------------------------------------------------------------------
// Domain types (mirror the backend responses)
// ---------------------------------------------------------------------------

export type ElectionStatus =
  | "draft"
  | "scheduled"
  | "active"
  | "closed"
  | "published";

export type ElectionType = "single" | "multi" | "ranked";

export type Election = {
  id: string;
  title: string;
  description?: string | null;
  organization?: string | null;
  type: ElectionType;
  status: ElectionStatus;
  startsAt: number;
  endsAt: number;
  canVote?: boolean;
  candidateCount?: number;
};

export type Candidate = {
  id: string;
  electionId: string;
  name: string;
  party?: string | null;
  bio?: string | null;
  manifesto?: string | null;
  photoUrl?: string | null;
  ballotOrder: number;
};

export type Voter = {
  id: string;
  email: string;
  fullName: string;
  phone?: string | null;
  role: Role;
  kycStatus: string;
  createdAt: number;
};

export type AuditLogEntry = {
  id: string;
  actor_id?: string | null;
  action: string;
  target_type?: string | null;
  target_id?: string | null;
  metadata?: string | null;
  ip_address?: string | null;
  created_at: number;
};

export type Alert = {
  id: string;
  type: string;
  severity: string;
  target?: string | null;
  count?: number;
  createdAt: number;
};

export type ResultCandidate = {
  id: string;
  name: string;
  party?: string | null;
  votes: number;
  pct: number;
};

// ---------------------------------------------------------------------------
// Elections
// ---------------------------------------------------------------------------

export async function listElections(params?: {
  status?: ElectionStatus;
  q?: string;
}): Promise<Election[]> {
  const qs = new URLSearchParams();
  if (params?.status) qs.set("status", params.status);
  if (params?.q) qs.set("q", params.q);
  const suffix = qs.toString() ? `?${qs.toString()}` : "";
  const data = await apiRequest<{ elections: Election[] }>(`/api/elections${suffix}`);
  return data.elections;
}

export async function getElection(id: string): Promise<{
  election: Election;
  candidates: Candidate[];
}> {
  return apiRequest<{ election: Election; candidates: Candidate[] }>(
    `/api/elections/${id}`,
  );
}

export async function createElection(input: {
  title: string;
  description?: string;
  organization?: string;
  type: ElectionType;
  startsAt: number;
  endsAt: number;
}): Promise<{ ok: boolean; election: Election }> {
  return apiRequest("/api/elections", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function updateElection(
  id: string,
  patch: Partial<{
    title: string;
    description: string;
    organization: string;
    type: ElectionType;
    startsAt: number;
    endsAt: number;
  }>,
): Promise<{ ok: boolean }> {
  return apiRequest(`/api/elections/${id}`, {
    method: "PATCH",
    body: JSON.stringify(patch),
  });
}

export async function setElectionStatus(
  id: string,
  status: ElectionStatus,
): Promise<{ ok: boolean; status: ElectionStatus }> {
  return apiRequest(`/api/elections/${id}/status`, {
    method: "POST",
    body: JSON.stringify({ status }),
  });
}

export async function addCandidate(
  electionId: string,
  input: {
    name: string;
    party?: string;
    bio?: string;
    manifesto?: string;
    ballotOrder?: number;
  },
): Promise<{ ok: boolean; candidate: Candidate }> {
  return apiRequest(`/api/elections/${electionId}/candidates`, {
    method: "POST",
    body: JSON.stringify(input),
  });
}

export async function getResults(
  electionId: string,
): Promise<{ electionId: string; totalVotes: number; results: ResultCandidate[] }> {
  return apiRequest(`/api/elections/${electionId}/results`);
}

// ---------------------------------------------------------------------------
// Voting
// ---------------------------------------------------------------------------

export type MyVote = {
  id: string;
  electionId: string;
  electionTitle: string;
  selections: { blockId: string; candidateId: string }[];
  receiptId: string;
  txHash?: string | null;
  blockNumber?: number | null;
  voteHash: string;
  createdAt: number;
};

export async function getMyVotes(): Promise<MyVote[]> {
  const data = await apiRequest<{ votes: MyVote[] }>("/api/voting/mine");
  return data.votes;
}

export async function castVote(input: {
  electionId: string;
  selections: { blockId: string; candidateId: string }[];
}): Promise<{ ok: boolean; vote: MyVote }> {
  return apiRequest("/api/voting/cast", {
    method: "POST",
    body: JSON.stringify(input),
  });
}

// ---------------------------------------------------------------------------
// KYC (admin)
// ---------------------------------------------------------------------------

export type KycQueueItem = {
  id: string;
  doc_type: string;
  r2_key: string;
  status: string;
  created_at: number;
  user_id: string;
  full_name: string;
  email: string;
};

export async function getKycQueue(): Promise<KycQueueItem[]> {
  const data = await apiRequest<{ queue: KycQueueItem[] }>("/api/kyc/queue");
  return data.queue;
}

export async function reviewKyc(
  documentId: string,
  decision: "approve" | "reject",
  note?: string,
): Promise<{ ok: boolean; status: string }> {
  return apiRequest(`/api/kyc/${documentId}/review`, {
    method: "POST",
    body: JSON.stringify({ decision, note }),
  });
}

/**
 * Downloads a KYC document binary as a Blob (admin only).
 *
 * The returned Blob can be converted to an object URL for inline previewing
 * (e.g. `<img src={URL.createObjectURL(blob)} />`) or saved via a download
 * link. The endpoint is `GET /api/kyc/document/:id`.
 */
export async function getKycDocument(documentId: string): Promise<Blob> {
  const response = await fetch(`${API_BASE}/api/kyc/document/${documentId}`, {
    headers: { Authorization: `Bearer ${getAccessToken()}` },
  });

  if (response.status === 401) {
    // Mirror apiRequest's refresh-once behavior before failing.
    if (await refresh()) {
      return getKycDocument(documentId);
    }
  }

  if (!response.ok) {
    throw new ApiError(response.status, "Failed to load document");
  }
  return response.blob();
}

export type KycDocument = {
  id: string;
  user_id: string;
  doc_type: string;
  status: string;
  r2_key: string;
  created_at: number;
};

/**
 * Lists KYC documents for a given user.
 *
 * The backend currently exposes the pending review queue via
 * `GET /api/kyc/queue`. We filter that by `user_id` to surface every
 * document that admin reviewers have already seen; for documents that
 * have already been approved/rejected and dropped off the queue, the
 * caller is expected to know the document ID from another source
 * (e.g. a future `GET /api/admin/users/:id/kyc` endpoint).
 */
export async function listKycDocumentsForUser(userId: string): Promise<KycDocument[]> {
  const queue = await getKycQueue();
  return queue
    .filter((item) => item.user_id === userId)
    .map((item) => ({
      id: item.id,
      user_id: item.user_id,
      doc_type: item.doc_type,
      status: item.status,
      r2_key: item.r2_key,
      created_at: item.created_at,
    }));
}

// ---------------------------------------------------------------------------
// Admin
// ---------------------------------------------------------------------------

export type AdminStats = {
  totalElections: number;
  totalVoters: number;
  approvedVoters: number;
  totalVotes: number;
};

export async function getAdminStats(): Promise<AdminStats> {
  const data = await apiRequest<{ stats: AdminStats }>("/api/admin/stats");
  return data.stats;
}

export async function listVoters(params?: {
  q?: string;
  status?: string;
}): Promise<Voter[]> {
  const qs = new URLSearchParams();
  if (params?.q) qs.set("q", params.q);
  if (params?.status) qs.set("status", params.status);
  const suffix = qs.toString() ? `?${qs.toString()}` : "";
  const data = await apiRequest<{ voters: Voter[] }>(`/api/admin/voters${suffix}`);
  return data.voters;
}

export async function getVoter(id: string): Promise<{
  voter: Voter & { vote_count?: number };
  votes: (MyVote & { election_title?: string })[];
}> {
  return apiRequest(`/api/admin/voters/${id}`);
}

export async function getAuditLog(params?: {
  limit?: number;
  action?: string;
}): Promise<AuditLogEntry[]> {
  const qs = new URLSearchParams();
  if (params?.limit) qs.set("limit", String(params.limit));
  if (params?.action) qs.set("action", params.action);
  const suffix = qs.toString() ? `?${qs.toString()}` : "";
  const data = await apiRequest<{ logs: AuditLogEntry[] }>(`/api/admin/audit-log${suffix}`);
  return data.logs;
}

export async function getAlerts(): Promise<Alert[]> {
  const data = await apiRequest<{ alerts: Alert[] }>("/api/admin/alerts");
  return data.alerts;
}

export async function getRecentElections(): Promise<Election[]> {
  const data = await apiRequest<{ elections: Election[] }>("/api/admin/recent-elections");
  return data.elections;
}