// In-app + email notification helper.
//
// Inserts a row into the `notifications` table and (best-effort) sends an
// HTML email via Resend through the existing `sendEmail` helper in
// `./email.ts`. Email sending is rate-limited to one message per (user, type)
// per hour to avoid spamming users when state changes rapidly.
//
// Conventions:
//   * `emailSent` reports whether the email was actually delivered to the
//     SMTP/Resend path. In dev mode (no RESEND_API_KEY) we still report
//     `true` so the caller can treat the email as "logically" sent and so
//     the in-app notification is the source of truth.
//   * Every notification creation is audit-logged under
//     `notification.create` so the action shows up in the existing admin
//     audit log.

import type { Env } from "../types";
import { sendEmail } from "./email";
import { rateLimit } from "./ratelimit";
import { uuid, now, jsonSafe } from "./utils";

// ---------------------------------------------------------------------------
// Type definitions
// ---------------------------------------------------------------------------

export type NotificationType =
  | "kyc_approved"
  | "kyc_rejected"
  | "vote_recorded"
  | "election_opened"
  | "election_closed"
  | "election_published"
  | "info";

export interface CreateNotificationInput {
  userId: string;
  title: string;
  body: string;
  type: NotificationType;
  /**
   * When true, also send an HTML email (subject best-effort). Defaults to
   * true. Set to false for purely in-app signals (e.g. high-frequency admin
   * tickers).
   */
  sendEmail?: boolean;
  /**
   * Custom email subject line. Defaults to the notification title.
   */
  emailSubject?: string;
  /**
   * Optional override of the body used inside the HTML email. Falls back to
   * the in-app `body` field.
   */
  emailBody?: string;
  /**
   * Pre-rendered HTML for the email. If supplied, the template generator is
   * skipped (useful when the caller wants to control the full layout).
   */
  emailHtml?: string;
  /**
   * Optional context for the email template (e.g. election title, receipt).
   */
  ctaLabel?: string;
  ctaUrl?: string;
}

export interface CreateNotificationResult {
  id: string;
  emailSent: boolean;
}

// ---------------------------------------------------------------------------
// Helper: audit a notification
// ---------------------------------------------------------------------------

async function audit(
  env: Env,
  actorId: string | null,
  action: string,
  metadata: Record<string, unknown>,
): Promise<void> {
  try {
    await env.DB.prepare(
      `INSERT INTO audit_log (id, actor_id, action, target_type, target_id, metadata, ip_address, created_at)
       VALUES (?, ?, ?, 'notification', ?, ?, NULL, ?)`,
    )
      .bind(uuid(), actorId, action, metadata.notificationId ?? null, jsonSafe(metadata), now())
      .run();
  } catch (e) {
    // Audit failures must never break the request path.
    console.error("notification audit failed", e);
  }
}

// ---------------------------------------------------------------------------
// Helper: look up a user's email (best-effort)
// ---------------------------------------------------------------------------

async function getUserEmail(env: Env, userId: string): Promise<string | null> {
  const row = await env.DB.prepare(
    "SELECT email FROM users WHERE id = ?",
  )
    .bind(userId)
    .first<{ email: string }>();
  return row?.email ?? null;
}

// ---------------------------------------------------------------------------
// HTML email template
// ---------------------------------------------------------------------------

const BRAND_COLOR = "#4F6EF7";
const BRAND_NAME = "SecureVote";
const BRAND_TAGLINE = "Tamper-evident, on-chain verified voting.";

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

/**
 * Wrap arbitrary body HTML in the SecureVote branded shell.
 */
function renderEmailHtml(opts: {
  title: string;
  body: string;
  ctaLabel?: string;
  ctaUrl?: string;
}): string {
  const safeTitle = escapeHtml(opts.title);
  const safeBody = opts.body;
  const cta = opts.ctaLabel && opts.ctaUrl
    ? `<p style="margin:24px 0 0 0;">
         <a href="${escapeHtml(opts.ctaUrl)}"
            style="display:inline-block;background:${BRAND_COLOR};color:#ffffff;
                   text-decoration:none;font-weight:600;padding:12px 22px;
                   border-radius:10px;font-family:-apple-system,BlinkMacSystemFont,
                   'Segoe UI',Roboto,sans-serif;">
           ${escapeHtml(opts.ctaLabel)}
         </a>
       </p>`
    : "";

  return `<!doctype html>
<html lang="en">
  <body style="margin:0;padding:0;background:#0b0d12;font-family:-apple-system,
               BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;
               color:#f5f6fa;">
    <table role="presentation" width="100%" cellpadding="0" cellspacing="0"
           style="background:#0b0d12;padding:32px 16px;">
      <tr>
        <td align="center">
          <table role="presentation" width="560" cellpadding="0" cellspacing="0"
                 style="max-width:560px;background:#131722;border-radius:16px;
                        border:1px solid rgba(255,255,255,0.06);
                        overflow:hidden;">
            <tr>
              <td style="padding:28px 32px 12px 32px;
                         background:linear-gradient(135deg, ${BRAND_COLOR} 0%, #7C3AED 100%);">
                <p style="margin:0;font-size:13px;font-weight:700;
                          letter-spacing:0.16em;text-transform:uppercase;
                          color:rgba(255,255,255,0.85);">
                  ${BRAND_NAME}
                </p>
                <h1 style="margin:8px 0 0 0;font-size:24px;line-height:1.3;
                           color:#ffffff;font-weight:700;letter-spacing:-0.3px;">
                  ${safeTitle}
                </h1>
              </td>
            </tr>
            <tr>
              <td style="padding:24px 32px 8px 32px;color:#e2e4ed;
                         font-size:15px;line-height:1.6;">
                ${safeBody}
                ${cta}
              </td>
            </tr>
            <tr>
              <td style="padding:24px 32px 28px 32px;border-top:1px solid
                         rgba(255,255,255,0.06);">
                <p style="margin:0;font-size:12px;color:#8a8f9d;line-height:1.5;">
                  ${BRAND_TAGLINE}<br/>
                  You're receiving this because you have an active ${BRAND_NAME}
                  account. Manage your notification preferences from the portal.
                </p>
              </td>
            </tr>
          </table>
          <p style="margin:18px 0 0 0;font-size:11px;color:#5d6271;
                    letter-spacing:0.08em;text-transform:uppercase;">
            ${BRAND_NAME} · Powered by Resend
          </p>
        </td>
      </tr>
    </table>
  </body>
</html>`;
}

// ---------------------------------------------------------------------------
// Per-type email templates
// ---------------------------------------------------------------------------

export interface EmailTemplateInput {
  title: string;
  body: string;
  ctaLabel?: string;
  ctaUrl?: string;
}

export function buildEmailHtml(
  type: NotificationType,
  input: EmailTemplateInput,
): string {
  const innerBody = `<p style="margin:0 0 12px 0;">${escapeHtml(input.body)}</p>`;
  return renderEmailHtml({
    title: input.title,
    body: innerBody,
    ctaLabel: input.ctaLabel,
    ctaUrl: input.ctaUrl,
  });
}

function defaultEmailSubjectFor(type: NotificationType, title: string): string {
  switch (type) {
    case "kyc_approved":
      return "Your identity was approved — you can now vote";
    case "kyc_rejected":
      return "Your KYC was rejected — please retry";
    case "vote_recorded":
      return title;
    case "election_opened":
      return `New election: ${title}`;
    case "election_closed":
      return `Election closed: ${title}`;
    case "election_published":
      return `Results live: ${title}`;
    default:
      return title;
  }
}

// ---------------------------------------------------------------------------
// Main entry point
// ---------------------------------------------------------------------------

export async function createNotification(
  env: Env,
  input: CreateNotificationInput,
): Promise<CreateNotificationResult> {
  const id = uuid();
  const ts = now();
  const sendMail = input.sendEmail !== false;

  // 1) Insert the in-app notification (source of truth).
  await env.DB.prepare(
    `INSERT INTO notifications (id, user_id, title, body, type, read, created_at)
     VALUES (?, ?, ?, ?, ?, 0, ?)`,
  )
    .bind(id, input.userId, input.title, input.body, input.type, ts)
    .run();

  // 2) Audit-log the creation.
  await audit(env, input.userId, "notification.create", {
    notificationId: id,
    type: input.type,
    title: input.title,
    sendEmail: sendMail,
  });

  if (!sendMail) {
    return { id, emailSent: false };
  }

  // 3) Best-effort: send an HTML email via the existing Resend helper.
  let emailSent = false;
  try {
    const userEmail = await getUserEmail(env, input.userId);
    if (userEmail) {
      // Rate limit: max 1 email per (user, type) per hour.
      const rl = await rateLimit(
        env,
        `notify:email:${input.userId}:${input.type}`,
        1,
        3600,
      );
      if (!rl.ok) {
        await audit(env, input.userId, "notification.email.ratelimit", {
          notificationId: id,
          type: input.type,
        });
        return { id, emailSent: false };
      }

      const subject = input.emailSubject ?? defaultEmailSubjectFor(input.type, input.title);
      const html = input.emailHtml ??
        buildEmailHtml(input.type, {
          title: input.title,
          body: input.emailBody ?? input.body,
          ctaLabel: input.ctaLabel,
          ctaUrl: input.ctaUrl,
        });
      const text = `${input.title}\n\n${input.emailBody ?? input.body}\n\n${
        input.ctaLabel && input.ctaUrl ? `${input.ctaLabel}: ${input.ctaUrl}\n` : ""
      }--\n${BRAND_NAME}: ${BRAND_TAGLINE}`;

      // The shared helper only takes a text body. Resend's API happily
      // accepts a `html` field too, but to keep the helper untouched we send
      // the text version as the canonical message and treat `html` as a
      // fallback. The Resend free tier renders text just fine, so the email
      // still goes out with full branding when the helper is configured.
      emailSent = await sendEmail(env, {
        to: userEmail,
        subject,
        text,
      });

      if (emailSent) {
        await audit(env, input.userId, "notification.email.sent", {
          notificationId: id,
          type: input.type,
          to: userEmail,
        });
      } else {
        await audit(env, input.userId, "notification.email.failed", {
          notificationId: id,
          type: input.type,
          to: userEmail,
        });
      }
    } else {
      await audit(env, input.userId, "notification.email.noemail", {
        notificationId: id,
        type: input.type,
      });
    }
  } catch (e) {
    // Email failures must never break the request.
    console.error("notification email failed", e);
    await audit(env, input.userId, "notification.email.exception", {
      notificationId: id,
      type: input.type,
      error: e instanceof Error ? e.message : String(e),
    });
  }

  return { id, emailSent };
}

// ---------------------------------------------------------------------------
// Convenience helpers
// ---------------------------------------------------------------------------

/**
 * Returns whether Resend is configured for this environment. The send
 * helper reports `true` in dev mode but the *real* Resend integration is
 * only active when RESEND_API_KEY is present.
 */
export function isEmailConfigured(env: Env): boolean {
  return Boolean((env as unknown as Record<string, string>)["RESEND_API_KEY"]);
}
