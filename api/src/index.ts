// SecureVote API — Cloudflare Worker entry point.
//
// Routes are namespaced under /api for easy proxying from the Next.js portal
// and Flutter app. See Phase 1 plan for the full route map.

import { Hono } from "hono";
import type { Env } from "./types";
import { corsHeaders } from "./lib/cors";
import { authRoutes } from "./routes/auth";

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
  c.json({ status: "ok", version: c.env.API_VERSION, env: c.env.ENV, time: Date.now() }),
);

// Route groups.
app.route("/api/auth", authRoutes);
// Phase 2-4: elections, voting, kyc, admin, public routes registered here.

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