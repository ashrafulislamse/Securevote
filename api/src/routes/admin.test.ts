import { describe, it, expect, beforeEach } from "vitest";
import { Hono } from "hono";

import { adminRoutes } from "./admin";
import { signAccessToken } from "../lib/jwt";
import { MockD1, jsonBody } from "../test/helpers";
import type { Env, Role } from "../types";

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

async function tokenFor(env: Env, role: Role, id = "admin-1"): Promise<string> {
  const { token } = await signAccessToken(env, {
    id,
    email: role === "voter" ? "voter@securevote.io" : "admin@securevote.io",
    role,
  });
  return token;
}

function authHeader(token: string): Record<string, string> {
  return { Authorization: `Bearer ${token}` };
}

function app(env: Env) {
  const a = new Hono<{ Bindings: Env }>();
  a.route("/api/admin", adminRoutes);
  return {
    request: (path: string, init?: RequestInit) => a.request(path, init, env),
  };
}

describe("admin routes — new endpoints", () => {
  let db: MockD1;
  let env: Env;

  beforeEach(() => {
    db = new MockD1();
    env = makeEnv(db);
    // audit() predecessor lookup
    db.stubFirst("SELECT entry_hash FROM audit_log", null);
  });

  // -- Organizations -------------------------------------------------------

  describe("GET /organizations", () => {
    it("lists organizations mapped to camelCase", async () => {
      db.stubAll("FROM organizations", [
        { id: "o-1", name: "Acme", plan: "Professional", members: 5, status: "active", created_at: 1000 },
      ]);

      const res = await app(env).request("/api/admin/organizations", {
        headers: authHeader(await tokenFor(env, "admin")),
      });

      expect(res.status).toBe(200);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.organizations).toHaveLength(1);
      expect(body.organizations[0].name).toBe("Acme");
      expect(body.organizations[0].createdAt).toBe(1000);
    });
  });

  describe("POST /organizations", () => {
    it("creates an organization and returns 201", async () => {
      const res = await app(env).request("/api/admin/organizations", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ name: "Globex", plan: "Enterprise" }),
      });

      expect(res.status).toBe(201);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.ok).toBe(true);
      expect(body.organization.name).toBe("Globex");
      expect(body.organization.plan).toBe("Enterprise");
      expect(body.organization.id).toBeTruthy();
      expect(db.calledWith("INSERT INTO organizations")).toBe(true);
    });

    it("rejects an empty name", async () => {
      const res = await app(env).request("/api/admin/organizations", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ name: "" }),
      });
      expect(res.status).toBe(400);
    });
  });

  describe("PATCH /organizations/:id", () => {
    it("updates members count", async () => {
      db.stubFirst("SELECT id FROM organizations WHERE id", { id: "o-1" });

      const res = await app(env).request("/api/admin/organizations/o-1", {
        method: "PATCH",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ members: 10 }),
      });

      expect(res.status).toBe(200);
      expect(db.calledWith("UPDATE organizations SET")).toBe(true);
    });

    it("returns 404 for a missing organization", async () => {
      db.stubFirst("SELECT id FROM organizations WHERE id", null);

      const res = await app(env).request("/api/admin/organizations/missing", {
        method: "PATCH",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ members: 1 }),
      });

      expect(res.status).toBe(404);
    });
  });

  describe("DELETE /organizations/:id", () => {
    it("deletes an organization", async () => {
      db.stubFirst("SELECT id FROM organizations WHERE id", { id: "o-1" });

      const res = await app(env).request("/api/admin/organizations/o-1", {
        method: "DELETE",
        headers: authHeader(await tokenFor(env, "admin")),
      });

      expect(res.status).toBe(200);
      expect(db.calledWith("DELETE FROM organizations")).toBe(true);
    });
  });

  // -- Alerts --------------------------------------------------------------

  describe("POST /alerts", () => {
    it("creates an alert with default severity medium", async () => {
      const res = await app(env).request("/api/admin/alerts", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ type: "turnout_spike", title: "Unusual spike" }),
      });

      expect(res.status).toBe(201);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.ok).toBe(true);
      expect(body.alert.severity).toBe("medium");
      expect(body.alert.status).toBe("open");
      expect(db.calledWith("INSERT INTO alerts")).toBe(true);
    });

    it("accepts a critical severity", async () => {
      const res = await app(env).request("/api/admin/alerts", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ type: "breach", title: "Breach", severity: "critical" }),
      });

      expect(res.status).toBe(201);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.alert.severity).toBe("critical");
    });
  });

  describe("POST /alerts/:id/resolve", () => {
    it("resolves an alert and returns the new status", async () => {
      db.stubFirst("SELECT id FROM alerts WHERE id", { id: "a-1" });

      const res = await app(env).request("/api/admin/alerts/a-1/resolve", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ status: "resolved" }),
      });

      expect(res.status).toBe(200);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.ok).toBe(true);
      expect(body.status).toBe("resolved");
      expect(db.calledWith("UPDATE alerts SET")).toBe(true);
    });

    it("can move an alert to investigating with an assignee", async () => {
      db.stubFirst("SELECT id FROM alerts WHERE id", { id: "a-1" });

      const res = await app(env).request("/api/admin/alerts/a-1/resolve", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ status: "investigating", assignedTo: "analyst-1" }),
      });

      expect(res.status).toBe(200);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.status).toBe("investigating");
    });

    it("returns 404 for a missing alert", async () => {
      db.stubFirst("SELECT id FROM alerts WHERE id", null);

      const res = await app(env).request("/api/admin/alerts/missing/resolve", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ status: "resolved" }),
      });

      expect(res.status).toBe(404);
    });
  });

  describe("POST /alerts/:id/assign", () => {
    it("assigns the alert to the current admin and moves to investigating", async () => {
      db.stubFirst("SELECT id FROM alerts WHERE id", { id: "a-1" });

      const res = await app(env).request("/api/admin/alerts/a-1/assign", {
        method: "POST",
        headers: authHeader(await tokenFor(env, "admin")),
      });

      expect(res.status).toBe(200);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.status).toBe("investigating");
      expect(body.assignedTo).toBe("admin@securevote.io");
    });
  });

  // -- Voters bulk-status + notify ----------------------------------------

  describe("POST /voters/bulk-status", () => {
    it("updates each voter and returns the updated count", async () => {
      // Default .run() returns changes=1 per UPDATE, so 2 ids → updated=2.
      const res = await app(env).request("/api/admin/voters/bulk-status", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ ids: ["u-1", "u-2"], kycStatus: "approved" }),
      });

      expect(res.status).toBe(200);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.ok).toBe(true);
      expect(body.updated).toBe(2);
      expect(db.calledWith("UPDATE users SET kyc_status")).toBe(true);
    });

    it("rejects an empty ids array", async () => {
      const res = await app(env).request("/api/admin/voters/bulk-status", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ ids: [], kycStatus: "approved" }),
      });
      expect(res.status).toBe(400);
    });
  });

  describe("POST /voters/notify", () => {
    it("inserts a notification per voter and returns the inserted count", async () => {
      const res = await app(env).request("/api/admin/voters/notify", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({
          ids: ["u-1", "u-2", "u-3"],
          title: "Election opens soon",
          body: "Voting begins at 8 AM.",
        }),
      });

      expect(res.status).toBe(200);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.ok).toBe(true);
      expect(body.inserted).toBe(3);
      expect(db.calledWith("INSERT INTO notifications")).toBe(true);
    });
  });

  // -- Voter update + import -------------------------------------------------

  describe("PATCH /voters/:id", () => {
    it("suspends a voter", async () => {
      db.stubFirst("FROM users WHERE id", { id: "u-1" });

      const res = await app(env).request("/api/admin/voters/u-1", {
        method: "PATCH",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ status: "suspended" }),
      });

      expect(res.status).toBe(200);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.ok).toBe(true);
      expect(db.calledWith("UPDATE users SET")).toBe(true);
    });

    it("updates profile fields and notes", async () => {
      db.stubFirst("FROM users WHERE id", { id: "u-1" });

      const res = await app(env).request("/api/admin/voters/u-1", {
        method: "PATCH",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ fullName: "Leena Das", phone: "+8801700000000", notes: "Flagged for review" }),
      });

      expect(res.status).toBe(200);
      expect(db.calledWith("UPDATE users SET")).toBe(true);
    });

    it("returns 404 for a missing voter", async () => {
      db.stubFirst("FROM users WHERE id", null);

      const res = await app(env).request("/api/admin/voters/missing", {
        method: "PATCH",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ status: "active" }),
      });

      expect(res.status).toBe(404);
    });

    it("rejects an empty body with 400", async () => {
      db.stubFirst("FROM users WHERE id", { id: "u-1" });

      const res = await app(env).request("/api/admin/voters/u-1", {
        method: "PATCH",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({}),
      });

      expect(res.status).toBe(400);
    });

    it("rejects an invalid status value with 400", async () => {
      db.stubFirst("FROM users WHERE id", { id: "u-1" });

      const res = await app(env).request("/api/admin/voters/u-1", {
        method: "PATCH",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ status: "banned" }),
      });

      expect(res.status).toBe(400);
    });

    it("rejects a verifier token with 403 (admin-only mutation)", async () => {
      db.stubFirst("FROM users WHERE id", { id: "u-1" });

      const res = await app(env).request("/api/admin/voters/u-1", {
        method: "PATCH",
        headers: { ...authHeader(await tokenFor(env, "verifier")), "Content-Type": "application/json" },
        body: JSON.stringify({ status: "suspended" }),
      });

      expect(res.status).toBe(403);
    });
  });

  describe("POST /voters/import", () => {
    it("creates voters when no email exists and reports the count", async () => {
      // Default .first() for the email lookup is null (not found) → all created.
      const res = await app(env).request("/api/admin/voters/import", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({
          voters: [
            { email: "new1@test.io", fullName: "New One" },
            { email: "new2@test.io", fullName: "New Two", phone: "+8801700000001" },
          ],
        }),
      });

      expect(res.status).toBe(200);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.ok).toBe(true);
      expect(body.created).toBe(2);
      expect(body.skipped).toHaveLength(0);
      expect(db.calledWith("INSERT INTO users")).toBe(true);
    });

    it("skips voters whose email already exists", async () => {
      db.stubFirst("FROM users WHERE email", { id: "existing-1" });

      const res = await app(env).request("/api/admin/voters/import", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({
          voters: [
            { email: "taken1@test.io", fullName: "Taken One" },
            { email: "taken2@test.io", fullName: "Taken Two" },
          ],
        }),
      });

      expect(res.status).toBe(200);
      const body = await jsonBody<{ ok?: boolean; [k: string]: any }>(res);
      expect(body.created).toBe(0);
      expect(body.skipped).toEqual(["taken1@test.io", "taken2@test.io"]);
      expect(db.calledWith("INSERT INTO users")).toBe(false);
    });

    it("rejects an empty voters array with 400", async () => {
      const res = await app(env).request("/api/admin/voters/import", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({ voters: [] }),
      });

      expect(res.status).toBe(400);
    });

    it("rejects an invalid email with 400", async () => {
      const res = await app(env).request("/api/admin/voters/import", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "admin")), "Content-Type": "application/json" },
        body: JSON.stringify({
          voters: [{ email: "not-an-email", fullName: "Bad Email" }],
        }),
      });

      expect(res.status).toBe(400);
    });

    it("rejects a voter token with 403", async () => {
      const res = await app(env).request("/api/admin/voters/import", {
        method: "POST",
        headers: { ...authHeader(await tokenFor(env, "voter")), "Content-Type": "application/json" },
        body: JSON.stringify({ voters: [{ email: "x@test.io", fullName: "X" }] }),
      });

      expect(res.status).toBe(403);
    });
  });

  describe("GET /voters", () => {
    it("returns voters mapped to camelCase", async () => {
      db.stubAll("FROM users WHERE role = 'voter'", [
        {
          id: "u-1",
          email: "a@b.io",
          full_name: "Ali",
          phone: null,
          role: "voter",
          kyc_status: "approved",
          status: "active",
          created_at: 123,
        },
      ]);

      const res = await app(env).request("/api/admin/voters", {
        headers: authHeader(await tokenFor(env, "admin")),
      });

      expect(res.status).toBe(200);
      const body = await jsonBody<any>(res);
      expect(body.voters[0].fullName).toBe("Ali");
      expect(body.voters[0].kycStatus).toBe("approved");
      expect(body.voters[0].createdAt).toBe(123);
      expect(body.voters[0].full_name).toBeUndefined();
    });
  });

  describe("GET /voters/:id", () => {
    it("returns voter and votes mapped to camelCase", async () => {
      db.stubFirst("FROM users u WHERE u.id", {
        id: "u-1",
        email: "a@b.io",
        full_name: "Ali",
        phone: null,
        role: "voter",
        kyc_status: "approved",
        status: "active",
        notes: null,
        created_at: 123,
        vote_count: 2,
      });
      db.stubAll("JOIN elections e", [
        { id: "v-1", receipt_id: "R1", created_at: 456, election_title: "Election A" },
      ]);

      const res = await app(env).request("/api/admin/voters/u-1", {
        headers: authHeader(await tokenFor(env, "admin")),
      });

      expect(res.status).toBe(200);
      const body = await jsonBody<any>(res);
      expect(body.voter.fullName).toBe("Ali");
      expect(body.voter.kycStatus).toBe("approved");
      expect(body.voter.createdAt).toBe(123);
      expect(body.voter.vote_count).toBe(2);
      expect(body.votes[0].receiptId).toBe("R1");
      expect(body.votes[0].createdAt).toBe(456);
      expect(body.votes[0].election_title).toBe("Election A");
    });
  });

  // -- RBAC ----------------------------------------------------------------

  describe("RBAC", () => {
    it("rejects a voter token with 403", async () => {
      const res = await app(env).request("/api/admin/organizations", {
        headers: authHeader(await tokenFor(env, "voter")),
      });
      expect(res.status).toBe(403);
    });

    it("rejects an unauthenticated request with 401", async () => {
      const res = await app(env).request("/api/admin/organizations");
      expect(res.status).toBe(401);
    });
  });
});
