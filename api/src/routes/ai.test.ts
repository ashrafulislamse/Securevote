import { describe, it, expect, beforeEach } from "vitest";
import { Hono } from "hono";

import { aiRoutes } from "./ai";
import { signAccessToken } from "../lib/jwt";
import { MockD1, jsonBody } from "../test/helpers";
import type { Env } from "../types";

// Minimal Workers AI binding shape used by the route: env.AI.run(model, opts).
interface MockAI {
  run: (model: string, opts: { messages: { role: string; content: string }[]; max_tokens?: number }) => Promise<unknown>;
}

function makeEnv(db: MockD1, ai?: MockAI, extra: Partial<Env> = {}): Env {
  return {
    DB: db as unknown as Env["DB"],
    STORAGE: {} as unknown as Env["STORAGE"],
    SESSIONS: {} as unknown as Env["SESSIONS"],
    JWT_SECRET: "test-jwt-secret",
    API_VERSION: "1.0.0",
    ENV: "development",
    AI: ai as unknown as Ai,
    ...extra,
  };
}

async function adminToken(env: Env): Promise<string> {
  const { token } = await signAccessToken(env, {
    id: "admin-1",
    email: "admin@securevote.io",
    role: "admin",
  });
  return token;
}

function authHeader(token: string): Record<string, string> {
  return { Authorization: `Bearer ${token}` };
}

function app(env: Env) {
  const a = new Hono<{ Bindings: Env }>();
  a.route("/api/admin", aiRoutes);
  return {
    request: (path: string, init?: RequestInit) => a.request(path, init, env),
  };
}

describe("AI assistant route", () => {
  let db: MockD1;

  beforeEach(() => {
    db = new MockD1();
    // buildStatsContext runs six COUNT queries. Stub each to 0.
    db.stubFirst("COUNT(*) AS n FROM elections", { n: 3 });
    db.stubFirst("COUNT(*) AS n FROM users", { n: 12 });
    db.stubFirst("COUNT(*) AS n FROM votes", { n: 42 });
    db.stubFirst("COUNT(*) AS n FROM alerts", { n: 1 });
    db.stubAll("GROUP BY status", [{ status: "active", n: 1 }, { status: "closed", n: 2 }]);
  });

  it("uses the Workers AI binding when present and returns its reply", async () => {
    const ai: MockAI = {
      run: async (_model, _opts) => ({ response: "  Risk is low. No anomalies detected.  " }),
    };
    const env = makeEnv(db, ai);

    const res = await app(env).request("/api/admin/ai-assistant", {
      method: "POST",
      headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: "Summarize risk" }),
    });

    expect(res.status).toBe(200);
    const body = await jsonBody<{ reply?: string; model?: string; grounded?: boolean; error?: string }>(res);
    expect(body.reply).toBe("Risk is low. No anomalies detected.");
    expect(body.grounded).toBe(true);
    expect(body.model).toBe("@cf/meta/llama-3.1-8b-instruct");
  });

  it("falls back to the template when the AI binding is absent", async () => {
    const env = makeEnv(db); // no AI binding

    const res = await app(env).request("/api/admin/ai-assistant", {
      method: "POST",
      headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: "What is the turnout?" }),
    });

    expect(res.status).toBe(200);
    const body = await jsonBody<{ reply?: string; model?: string; grounded?: boolean; error?: string }>(res);
    expect(body.reply).toContain("couldn't reach the LLM");
    expect(body.reply).toContain("total elections: 3");
    expect(body.model).toBe("template-fallback");
    expect(body.grounded).toBe(true);
  });

  it("falls back to the template when the AI call throws", async () => {
    const ai: MockAI = {
      run: async () => {
        throw new Error("model unavailable");
      },
    };
    const env = makeEnv(db, ai);

    const res = await app(env).request("/api/admin/ai-assistant", {
      method: "POST",
      headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: "Forecast turnout" }),
    });

    expect(res.status).toBe(200);
    const body = await jsonBody<{ reply?: string; model?: string; grounded?: boolean; error?: string }>(res);
    expect(body.reply).toContain("couldn't reach the LLM");
    expect(body.model).toBe("template-fallback");
    expect(body.error).toBe("model unavailable");
  });

  it("uses an explicit model when provided", async () => {
    let capturedModel = "";
    const ai: MockAI = {
      run: async (model) => {
        capturedModel = model;
        return { response: "ok" };
      },
    };
    const env = makeEnv(db, ai);

    await app(env).request("/api/admin/ai-assistant", {
      method: "POST",
      headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
      body: JSON.stringify({
        prompt: "Analyze",
        model: "@cf/meta/llama-3.3-70b-instruct-fp8-fast",
      }),
    });

    expect(capturedModel).toBe("@cf/meta/llama-3.3-70b-instruct-fp8-fast");
  });

  it("requires admin auth (401 without token)", async () => {
    const env = makeEnv(db);
    const res = await app(env).request("/api/admin/ai-assistant", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: "x" }),
    });
    expect(res.status).toBe(401);
  });

  it("rejects an empty prompt", async () => {
    const env = makeEnv(db);
    const res = await app(env).request("/api/admin/ai-assistant", {
      method: "POST",
      headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: "" }),
    });
    expect(res.status).toBe(400);
  });
});
