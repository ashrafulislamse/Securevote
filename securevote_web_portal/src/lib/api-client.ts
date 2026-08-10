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