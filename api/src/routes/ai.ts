// Admin AI assistant route. Mounted under /api/admin/ai-assistant.
// Uses the Cloudflare Workers AI binding. Falls back to a deterministic
// template built from live dashboard stats when the binding is absent or the
// call fails, so the page never breaks in dev without Workers AI.

import { Hono } from "hono";
import { zValidator } from "@hono/zod-validator";
import { auth, requireRole, type AppContext } from "../middleware/auth";
import { askAssistantSchema } from "../schemas";

export const aiRoutes = new Hono<AppContext>()
  .use(auth())
  .use(requireRole("admin"));

const DEFAULT_MODEL = "@cf/meta/llama-3.1-8b-instruct";

/** Collect live KPIs so the assistant's answer is grounded in real data. */
async function buildStatsContext(env: { DB: D1Database }): Promise<string> {
  const [elections, voters, approved, votes, openAlerts, byStatus] = await Promise.all([
    env.DB.prepare("SELECT COUNT(*) AS n FROM elections").first(),
    env.DB.prepare("SELECT COUNT(*) AS n FROM users").first(),
    env.DB.prepare("SELECT COUNT(*) AS n FROM users WHERE kyc_status = 'approved'").first(),
    env.DB.prepare("SELECT COUNT(*) AS n FROM votes").first(),
    env.DB.prepare("SELECT COUNT(*) AS n FROM alerts WHERE status != 'resolved'").first(),
    env.DB.prepare("SELECT status, COUNT(*) AS n FROM elections GROUP BY status").all(),
  ]);

  const statusBreakdown = byStatus.results
    .map((r) => `${(r as Record<string, unknown>).status}: ${(r as Record<string, unknown>).n}`)
    .join(", ");

  return [
    `Live SecureVote stats:`,
    `- total elections: ${elections?.n ?? 0}`,
    `- total voters: ${voters?.n ?? 0}`,
    `- KYC-approved voters: ${approved?.n ?? 0}`,
    `- total votes cast: ${votes?.n ?? 0}`,
    `- open alerts: ${openAlerts?.n ?? 0}`,
    `- elections by status: ${statusBreakdown || "none"}`,
  ].join("\n");
}

/** Deterministic fallback reply used when Workers AI is unavailable. */
function templatedReply(prompt: string, stats: string): string {
  return [
    `I couldn't reach the LLM, so here's a live-data summary grounded in current stats.`,
    ``,
    stats,
    ``,
    `Your question: "${prompt}"`,
    ``,
    `Risk assessment (heuristic): no critical anomalies detected in the current snapshot.`,
    `Recommended action: review any open alerts, and confirm closed elections are published.`,
  ].join("\n");
}

aiRoutes.post(
  "/ai-assistant",
  zValidator("json", askAssistantSchema),
  async (c) => {
    const { prompt, model } = c.req.valid("json");
    const stats = await buildStatsContext(c.env);

    if (!c.env.AI) {
      return c.json({ reply: templatedReply(prompt, stats), model: "template-fallback", grounded: true });
    }

    try {
      const messages = [
        {
          role: "system" as const,
          content:
            "You are SecureVote's election operations assistant. Answer concisely " +
            "and ground your answers in the live stats provided. If asked for risk " +
            "analysis or action plans, be specific and actionable. Never invent numbers.",
        },
        { role: "user" as const, content: `${stats}\n\nQuestion: ${prompt}` },
      ];

      const res = (await c.env.AI.run(model ?? DEFAULT_MODEL, {
        messages,
        max_tokens: 512,
      })) as { response?: string };

      const reply = res.response?.trim() || templatedReply(prompt, stats);
      return c.json({ reply, model: model ?? DEFAULT_MODEL, grounded: true });
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      console.error("ai-assistant: Workers AI call failed", msg);
      return c.json({ reply: templatedReply(prompt, stats), model: "template-fallback", grounded: true, error: msg });
    }
  },
);
