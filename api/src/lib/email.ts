// Email delivery abstraction.
// Uses Resend when RESEND_API_KEY is set; otherwise falls back to a dev
// console/response log so the app works without SMTP credentials.

import type { Env } from "../types";

interface EmailInput {
  to: string;
  subject: string;
  text: string;
}

/**
 * Send an email. Returns true if sent (or dev-stubbed), false on failure.
 * In development without a key, we just log — the API still returns the OTP
 * to the client so the demo flow is fully usable offline.
 */
export async function sendEmail(env: Env, input: EmailInput): Promise<boolean> {
  const apiKey =
    (env as unknown as Record<string, string>)["RESEND_API_KEY"] ?? "";
  if (!apiKey) {
    console.log(`[email:dev] to=${input.to} subject=${input.subject}\n${input.text}`);
    return true;
  }
  try {
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: "SecureVote <noreply@securevote.app>",
        to: [input.to],
        subject: input.subject,
        text: input.text,
      }),
    });
    return res.ok;
  } catch {
    return false;
  }
}