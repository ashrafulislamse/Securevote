import { describe, it, expect, beforeEach } from "vitest";
import { Hono } from "hono";

import { electionsRoutes } from "./elections";
import { signAccessToken } from "../lib/jwt";
import { MockD1, jsonBody } from "../test/helpers";
import type { Env } from "../types";

// Build a minimal Env wired to the in-memory D1 mock.
function makeEnv(db: MockD1, extra: Partial<Env> = {}): Env {
  return {
    DB: db as unknown as Env["DB"],
    STORAGE: {} as unknown as Env["STORAGE"],
    SESSIONS: {} as unknown as Env["SESSIONS"],
    JWT_SECRET: "test-jwt-secret",
    API_VERSION: "1.0.0",
    ENV: "development",
    ...extra,
  };
}

// Mint a real access token for an admin so auth() + requireRole pass.
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

// Mount the elections sub-app exactly like index.ts does. Hono's
// app.request() accepts the bindings (Env) as its third argument, which is
// the test-mode equivalent of the Workers runtime injecting c.env.
function app(env: Env) {
  const a = new Hono<{ Bindings: Env }>();
  a.route("/api/elections", electionsRoutes);
  return {
    request: (path: string, init?: RequestInit) => a.request(path, init, env),
  };
}

const ELECTION_ROW = {
  id: "el-1",
  title: "Presidential 2026",
  description: "Demo",
  organization: "Acme",
  type: "general",
  status: "draft",
  starts_at: 1000,
  ends_at: 2000,
};

describe("elections routes — new endpoints", () => {
  let db: MockD1;
  let env: Env;

  beforeEach(async () => {
    db = new MockD1();
    env = makeEnv(db);
    // Common stub: SELECT * FROM elections WHERE id = ?
    db.stubFirst("SELECT * FROM elections", ELECTION_ROW);
    // Audit log predecessor lookup (audit() always runs).
    db.stubFirst("SELECT entry_hash FROM audit_log", null);
  });

  // -- PATCH /:id/candidates/:cid -----------------------------------------

  describe("PATCH /:id/candidates/:cid", () => {
    it("updates candidate visible flag and returns 200", async () => {
      db.stubFirst("SELECT id FROM candidates WHERE id", { id: "c-1" });

      const res = await app(env).request("/api/elections/el-1/candidates/c-1", {
        method: "PATCH",
        headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
        body: JSON.stringify({ visible: false }),
      });

      expect(res.status).toBe(200);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.ok).toBe(true);
      expect(db.calledWith("UPDATE candidates SET")).toBe(true);
    });

    it("returns 404 when the candidate does not exist", async () => {
      db.stubFirst("SELECT id FROM candidates WHERE id", null);

      const res = await app(env).request("/api/elections/el-1/candidates/missing", {
        method: "PATCH",
        headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
        body: JSON.stringify({ visible: true }),
      });

      expect(res.status).toBe(404);
    });

    it("rejects an empty update body", async () => {
      db.stubFirst("SELECT id FROM candidates WHERE id", { id: "c-1" });

      const res = await app(env).request("/api/elections/el-1/candidates/c-1", {
        method: "PATCH",
        headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
        body: JSON.stringify({}),
      });

      // zValidator rejects before the handler runs (at least one field required).
      expect(res.status).toBe(400);
    });

    it("requires admin auth (401 without token)", async () => {
      const res = await app(env).request("/api/elections/el-1/candidates/c-1", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ visible: true }),
      });
      expect(res.status).toBe(401);
    });
  });

  // -- DELETE /:id/candidates/:cid ----------------------------------------

  describe("DELETE /:id/candidates/:cid", () => {
    it("deletes a candidate in a draft election with no votes", async () => {
      db.stubFirst("SELECT COUNT(*) AS n FROM votes WHERE election_id", { n: 0 });
      db.stubFirst("SELECT id FROM candidates WHERE id", { id: "c-1" });

      const res = await app(env).request("/api/elections/el-1/candidates/c-1", {
        method: "DELETE",
        headers: authHeader(await adminToken(env)),
      });

      expect(res.status).toBe(200);
      expect(db.calledWith("DELETE FROM candidates")).toBe(true);
    });

    it("refuses deletion when the election is active", async () => {
      db.stubFirst(
        "SELECT * FROM elections",
        { ...ELECTION_ROW, status: "active" },
      );

      const res = await app(env).request("/api/elections/el-1/candidates/c-1", {
        method: "DELETE",
        headers: authHeader(await adminToken(env)),
      });

      expect(res.status).toBe(400);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.error).toMatch(/active or finalized/);
    });

    it("refuses deletion when votes already exist", async () => {
      db.stubFirst("SELECT COUNT(*) AS n FROM votes WHERE election_id", { n: 5 });
      db.stubFirst("SELECT id FROM candidates WHERE id", { id: "c-1" });

      const res = await app(env).request("/api/elections/el-1/candidates/c-1", {
        method: "DELETE",
        headers: authHeader(await adminToken(env)),
      });

      expect(res.status).toBe(400);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.error).toMatch(/votes have been cast/);
    });
  });

  // -- GET /:id/ballot-blocks (public) ------------------------------------

  describe("GET /:id/ballot-blocks", () => {
    it("lists ballot blocks without auth", async () => {
      db.stubAll("FROM ballot_blocks", [
        { id: "b-1", election_id: "el-1", title: "President", kind: "position", order_index: 0 },
        { id: "b-2", election_id: "el-1", title: "Prop A", kind: "yesNo", order_index: 1 },
      ]);

      const res = await app(env).request("/api/elections/el-1/ballot-blocks");

      expect(res.status).toBe(200);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.ballotBlocks).toHaveLength(2);
      expect(body.ballotBlocks[0].title).toBe("President");
      expect(body.ballotBlocks[1].orderIndex).toBe(1);
    });

    it("returns 404 for a missing election", async () => {
      db.stubFirst("SELECT * FROM elections", null);

      const res = await app(env).request("/api/elections/missing/ballot-blocks");
      expect(res.status).toBe(404);
    });
  });

  // -- POST /:id/ballot-blocks --------------------------------------------

  describe("POST /:id/ballot-blocks", () => {
    it("creates a ballot block and returns 201", async () => {
      const res = await app(env).request("/api/elections/el-1/ballot-blocks", {
        method: "POST",
        headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
        body: JSON.stringify({ title: "President", kind: "position", orderIndex: 0 }),
      });

      expect(res.status).toBe(201);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.ok).toBe(true);
      expect(body.ballotBlock.title).toBe("President");
      expect(body.ballotBlock.id).toBeTruthy();
      expect(db.calledWith("INSERT INTO ballot_blocks")).toBe(true);
    });

    it("defaults kind to 'position'", async () => {
      const res = await app(env).request("/api/elections/el-1/ballot-blocks", {
        method: "POST",
        headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
        body: JSON.stringify({ title: "Info Section" }),
      });

      expect(res.status).toBe(201);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.ballotBlock.kind).toBe("position");
    });
  });

  // -- PATCH /:id/ballot-blocks/:bid --------------------------------------

  describe("PATCH /:id/ballot-blocks/:bid", () => {
    it("updates the order index", async () => {
      db.stubFirst("SELECT id FROM ballot_blocks WHERE id", { id: "b-1" });

      const res = await app(env).request("/api/elections/el-1/ballot-blocks/b-1", {
        method: "PATCH",
        headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
        body: JSON.stringify({ orderIndex: 5 }),
      });

      expect(res.status).toBe(200);
      expect(db.calledWith("UPDATE ballot_blocks SET")).toBe(true);
    });

    it("returns 404 when the block does not exist", async () => {
      db.stubFirst("SELECT id FROM ballot_blocks WHERE id", null);

      const res = await app(env).request("/api/elections/el-1/ballot-blocks/missing", {
        method: "PATCH",
        headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
        body: JSON.stringify({ title: "X" }),
      });

      expect(res.status).toBe(404);
    });
  });

  // -- DELETE /:id/ballot-blocks/:bid -------------------------------------

  describe("DELETE /:id/ballot-blocks/:bid", () => {
    it("deletes a ballot block", async () => {
      db.stubFirst("SELECT id FROM ballot_blocks WHERE id", { id: "b-1" });

      const res = await app(env).request("/api/elections/el-1/ballot-blocks/b-1", {
        method: "DELETE",
        headers: authHeader(await adminToken(env)),
      });

      expect(res.status).toBe(200);
      expect(db.calledWith("DELETE FROM ballot_blocks")).toBe(true);
    });
  });

  // -- POST /:id/publish ---------------------------------------------------

  describe("POST /:id/publish", () => {
    it("publishes a closed election and records channels", async () => {
      db.stubFirst("SELECT * FROM elections", { ...ELECTION_ROW, status: "closed" });

      const res = await app(env).request("/api/elections/el-1/publish", {
        method: "POST",
        headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
        body: JSON.stringify({ visibility: "public", channels: ["portal", "email"] }),
      });

      expect(res.status).toBe(200);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.ok).toBe(true);
      expect(body.status).toBe("published");
      expect(body.visibility).toBe("public");
      expect(body.channels).toEqual(["portal", "email"]);
      expect(db.calledWith("UPDATE elections")).toBe(true);
    });

    it("refuses to publish an election that is still active", async () => {
      db.stubFirst("SELECT * FROM elections", { ...ELECTION_ROW, status: "active" });

      const res = await app(env).request("/api/elections/el-1/publish", {
        method: "POST",
        headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
        body: JSON.stringify({}),
      });

      expect(res.status).toBe(400);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.error).toMatch(/must be closed/);
    });

    it("defaults visibility to public and channels to [portal]", async () => {
      db.stubFirst("SELECT * FROM elections", { ...ELECTION_ROW, status: "closed" });

      const res = await app(env).request("/api/elections/el-1/publish", {
        method: "POST",
        headers: { ...authHeader(await adminToken(env)), "Content-Type": "application/json" },
        body: JSON.stringify({}),
      });

      expect(res.status).toBe(200);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.visibility).toBe("public");
      expect(body.channels).toEqual(["portal"]);
    });
  });
});
