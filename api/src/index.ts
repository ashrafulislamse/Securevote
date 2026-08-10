// SecureVote API — Cloudflare Worker entry point.
//
// Routes are namespaced under /api for easy proxying from the Next.js portal
// and Flutter app. See Phase 1 plan for the full route map.

import { Hono } from "hono";
import type { Env } from "./types";
import { corsHeaders } from "./lib/cors";
import { authRoutes } from "./routes/auth";
import { electionsRoutes } from "./routes/elections";
import { votingRoutes } from "./routes/voting";
import { kycRoutes } from "./routes/kyc";
import { publicRoutes } from "./routes/public";
import { adminRoutes } from "./routes/admin";
import { notificationsRoutes } from "./routes/notifications";
import {
  isChainConfigured,
  syncChainVoteCounts,
} from "./lib/blockchain";

export type { Env };

const app = new Hono<{ Bindings: Env }>();

// Global CORS + security headers.
app.use("*", async (c, next) => {
  const origin = c.req.header("origin") ?? null;
  const cors = corsHeaders(origin);
  Object.entries(cors).forEach(([k, v]) => c.header(k, v));

  if (c.req.method === "OPTIONS") {
    return c.body(null, 204);
  }

  c.header("X-Content-Type-Options", "nosniff");
  c.header("X-Frame-Options", "DENY");
  c.header(
    "Content-Security-Policy",
    "default-src 'self'; frame-ancestors 'none';",
  );

  await next();
});

// Health + version endpoint.
app.get("/api/health", (c) =>
  c.json({
    status: "ok",
    version: c.env.API_VERSION,
    env: c.env.ENV,
    onchain: {
      configured: isChainConfigured(c.env),
      contract: c.env.VOTING_CONTRACT_ADDRESS ?? c.env.CONTRACT_ADDRESS ?? null,
      rpc: c.env.AMOY_RPC_URL ?? c.env.RPC_URL ?? null,
    },
    time: Date.now(),
  }),
);

// Cron-style manual endpoint: GET /api/cron/sync-chain
// Compares D1 vote counts against the on-chain count and logs mismatches.
// Public on purpose so the cron-trigger is callable for a one-off
// reconcile from the admin portal without an auth round-trip.
app.get("/api/cron/sync-chain", async (c) => {
  if (!isChainConfigured(c.env)) {
    return c.json({
      ok: true,
      skipped: true,
      reason: "on-chain anchoring not yet enabled",
    });
  }
  try {
    const report = await syncChainVoteCounts(c.env);
    return c.json({
      ok: true,
      onchainEnabled: true,
      checked: report.checked,
      mismatches: report.mismatches,
      errors: report.skipped,
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return c.json({ ok: false, error: msg }, 500);
  }
});

// Route groups.
app.route("/api/auth", authRoutes);
app.route("/api/elections", electionsRoutes);
app.route("/api/voting", votingRoutes);
app.route("/api/kyc", kycRoutes);
app.route("/api/public", publicRoutes);
app.route("/api/admin", adminRoutes);
app.route("/api/notifications", notificationsRoutes);

// JSON 404 for unknown API routes.
app.onError((err, c) => {
  console.error(err);
  return c.json({ error: "internal server error" }, 500);
});

app.notFound((c) => {
  if (c.req.path.startsWith("/api/")) {
    return c.json({ error: "not found" }, 404);
  }
  return c.text("Not found", 404);
});

export default app;

// ---------------------------------------------------------------------------
// Scheduled handler — runs once a minute per wrangler.toml
//   [triggers] crons = ["* * * * *"]
// Reuses the same syncChainVoteCounts() logic as the manual endpoint.
// ---------------------------------------------------------------------------
export interface ScheduledController {
  scheduledTime: number;
  cron: string;
  noRetry: () => void;
}

export async function scheduled(
  _controller: ScheduledController,
  env: Env,
  _ctx: ExecutionContext,
): Promise<void> {
  if (!isChainConfigured(env)) {
    console.log("scheduled: chain not configured, skipping");
    return;
  }
  try {
    const report = await syncChainVoteCounts(env);
    if (report.mismatches.length > 0) {
      console.warn("scheduled: chain sync mismatches", JSON.stringify(report));
    } else {
      console.log(
        `scheduled: chain sync ok, checked ${report.checked} elections`,
      );
    }
  } catch (e) {
    console.error("scheduled: chain sync failed", e);
  }
}