# Resend Email Setup

SecureVote uses [Resend](https://resend.com) to deliver OTP verification
emails (and any future transactional mail). Resend has a generous free tier
that is more than enough for development and small-scale demos:

- **3,000 emails / month**
- **100 emails / day**
- **No credit card required** to sign up
- REST API, no SDK lock-in

---

## 1. Sign up and grab an API key

1. Go to <https://resend.com> and create an account.
2. Verify your email address.
3. In the Resend dashboard open **API Keys** and click **Create API Key**.
   - Give it a name like `securevote-api` so you can recognise it later.
   - Scope: **Sending access** is enough — you don't need full account access.
4. Copy the key. It starts with `re_…`. You will not be able to see it again
   after you close the dialog, so store it somewhere safe (1Password, etc.)
   before continuing.

> Treat this key like a password. It lets anyone who has it send email
> from your account.

---

## 2. Configure the sender (From address)

When you first sign up, you can only send from Resend's shared testing
address: **`onboarding@resend.dev`**. This is wired up as the default in
`wrangler.toml`, so you can complete a full end-to-end test before
verifying your own domain.

To send from your own domain (recommended for any real deployment):

1. In the Resend dashboard open **Domains** and click **Add Domain**.
2. Add the DNS records Resend shows you (SPF + DKIM + return-path). For
   `securevote.app` that is a few `TXT` / `CNAME` records at your DNS
   provider.
3. Wait for Resend to verify (usually a few minutes).
4. Set the `RESEND_FROM` env var to your verified address, e.g.
   `SecureVote <noreply@securevote.app>`.

Until that DNS is live, leave the default `onboarding@resend.dev` and
everything will still work.

---

## 3. Add the API key to your Worker

The API key is a **secret**, so it must be set with `wrangler secret put`,
never committed to git and never put in `wrangler.toml`.

```bash
cd api
npx wrangler secret put RESEND_API_KEY
# paste your re_... key when prompted
```

For local development, you can put the same key in `.dev.vars`
(file is git-ignored) so `wrangler dev` picks it up:

```ini
# api/.dev.vars
JWT_SECRET="..."
ENV="development"
RESEND_API_KEY="re_xxxxxxxxxxxxxxxx"
```

> Reminder: do **not** commit a real `RESEND_API_KEY` to git. `.dev.vars`
> is already in `.gitignore` for the SecureVote repo — keep it that way.

---

## 4. Deploy and test

```bash
# Local
npx wrangler dev
# In another terminal:
curl -X POST http://localhost:8787/api/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"you@example.com","password":"GoodPass1Word","fullName":"Test User"}'
# → 200 OK with { ok: true, message: "OTP sent", expiresInSeconds: 600 }
#   (no devOtp in production, since ENV != development/demo)

# Production
npx wrangler deploy
```

Then check the inbox of the email you registered with. You should see a
SecureVote-branded email with a 6-digit code. Enter it at
`POST /api/auth/verify-otp` to finish registration.

To re-send the code (e.g. user lost it), hit
`POST /api/auth/resend-otp` with `{ "email": "you@example.com" }`. It
is rate-limited to **3 sends per email per hour** (same limit as
`/register`).

---

## 5. How the dev fallback works

If `RESEND_API_KEY` is **not** set, `src/lib/email.ts` short-circuits and
just `console.log`s the email (subject + text body). In dev/demo modes
(`ENV=development` or `ENV=demo`) the OTP is also returned in the JSON
response of `POST /api/auth/register` as `devOtp` so you can test the
full flow without configuring Resend at all.

This fallback is **strictly opt-in**: in production (`ENV=production` or
anything other than `development`/`demo`) the response never contains
`devOtp` and the only way to see the code is to read the email.

---

## 6. Free-tier limits and what happens when you hit them

- **3,000 / month** rolling quota — counted at the Resend side.
- **100 / day** rolling quota — counted at the Resend side.
- If you hit the limit, Resend returns HTTP `429` from the `/emails`
  endpoint. `src/lib/email.ts` logs the error and `sendEmail` returns
  `false`, but the request still returns 200 to the client (the user
  just never gets the email). For a production deployment you would
  want to:
  - add a `resend_id` response field so you can correlate
  - surface a clearer error to the client (e.g. return 503)
  - subscribe to Resend webhooks (`email.delivered`, `email.bounced`)
    and react in `src/routes/auth.ts` / `src/routes/admin.ts`.

For FYP/demo usage you will not come close to the 3,000/month limit.

---

## 7. Troubleshooting checklist

| Symptom | Likely cause |
| --- | --- |
| Email never arrives, no log line | `RESEND_API_KEY` not set on the deployed environment. Re-run `wrangler secret put RESEND_API_KEY` against the right environment. |
| `domain not verified` 403 from Resend | You set `RESEND_FROM` to a domain that isn't verified yet. Revert to `SecureVote <onboarding@resend.dev>` or finish DNS verification. |
| `daily quota exceeded` | You hit 100/day. Wait until the next UTC day or upgrade. |
| OTP not accepted | Check `pending_verifications` table — is the row still there? `expires_at` is 10 minutes from `created_at`. Use `POST /api/auth/resend-otp` to start fresh. |
| Rate limit error (429) on `/register` | You sent more than 3 OTPs to the same email in the last hour. Wait, or call `wrangler kv:key delete --binding=SESSIONS rl:otp-send:<email>` to reset during dev. |

---

## 8. Related files

- `src/lib/email.ts` — Resend integration + HTML template builder
- `src/lib/otp.ts` — dev/prod OTP generation
- `src/lib/ratelimit.ts` — KV-backed rate limiter used on `/register` and `/resend-otp`
- `src/routes/auth.ts` — `/register`, `/verify-otp`, `/resend-otp` handlers
- `src/middleware/audit.ts` — writes `auth.otp.sent` audit rows
- `wrangler.toml` — `RESEND_FROM` default
- `src/types.ts` — `RESEND_API_KEY` and `RESEND_FROM` typed on `Env`
