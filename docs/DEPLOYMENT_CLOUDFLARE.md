# Cloudflare Deployment Guide — SecureVote

This documents how the SecureVote API and web portal are deployed to Cloudflare,
what every binding and data store is wired to, and the commands to redeploy.

Two separate deployables, both on Cloudflare under the same account:

| App | Cloudflare product | Live URL | Source |
|-----|--------------------|----------|--------|
| **securevote-api** | Worker (`wrangler deploy`) | `https://securevote-api.founder-fb4.workers.dev` | `api/` |
| **securevote-web** | Worker + static assets (via **OpenNext**) | `https://securevote-web.founder-fb4.workers.dev` | `securevote_web_portal/` |

The web portal calls the API through `NEXT_PUBLIC_API_URL`, which is set in
`securevote_web_portal/wrangler.jsonc` to the deployed API URL.

---

## 1. Prerequisites

- Wrangler logged in: `npx wrangler whoami`
- A Cloudflare account with D1, R2, KV, Workers AI, and Cron Triggers.
- On a fresh machine: `npm install` / `pnpm install` in `api/` and
  `securevote_web_portal/`.

The following Cloudflare resources already exist in the account (created the
first time the app was deployed):

| Binding (API) | Resource type | Name / ID |
|---------------|---------------|-----------|
| `DB` | D1 database | `securevote` (id `8c3a411c-2787-4a57-98fb-6f33aed5944f`) |
| `STORAGE` | R2 bucket | `securevote-files` |
| `SESSIONS` | KV namespace | `securevote-api-SESSIONS` (id `79069c0b141f4860bbaf5343e12027d2`) |
| `AI` | Workers AI | (binding only) |

Web portal extras: R2 bucket `securevote-web-opennext-cache`, Worker
`WORKER_SELF_REFERENCE`, and `ASSETS` binding — all declared in
`securevote_web_portal/wrangler.jsonc`.

---

## 2. Environment / secrets

Secrets are stored encrypted on the Worker (never in the repo — `.dev.vars` is
git-ignored, `.dev.vars.example` has blank placeholders only).

Set a secret (value is read from stdin so it never appears in command-line
args / logs):

```bash
cd api
printf '%s\n' 'THE_VALUE' | npx wrangler secret put SECRET_NAME
```

### Required secrets — `securevote-api`

| Secret | Purpose |
|--------|---------|
| `JWT_SECRET` | Signs access/refresh tokens. **Without this, login is broken.** |
| `RESEND_API_KEY` | Real email delivery (OTP, reset links). If absent, email is dev-logged and dev OTPs are used. |
| `APP_URL` | Base URL used to build password-reset links in emails. Set to the web portal URL. |

### Deploy-ready (opt-in) secrets — `securevote-api`

These are the **blockchain** secrets from Phase 6. They are intentionally left
**unset** so the app runs in graceful-degradation mode (`onchain.configured:
false` in `/api/health`; votes use the `vote.anchor.skipped` path). Fill them in
**only** once the smart contract is actually deployed on Polygon Amoy:

| Secret | Value when ready |
|--------|------------------|
| `PRIVATE_KEY` | Deployer wallet private key |
| `VOTING_CONTRACT_ADDRESS` | Deployed `Voting.sol` address |
| `AMOY_RPC_URL` | Polygon Amoy RPC endpoint |

See `docs/PHASE6_DEPLOYER_KEY_SETUP.md` for the full blockchain runbook.

---

## 3. Deploy the API

```bash
cd api
npx wrangler deploy
```

Output confirms the new version ID and any binding/env changes. The worker also
runs a cron trigger every 60 seconds (`* * * * *`) declared in
`api/wrangler.toml`.

### Apply D1 migrations to production

Production schema changes are applied with:

```bash
cd api
npx wrangler d1 migrations apply securevote --remote
```

> ⚠️ **Known gotcha (bit us in production).** The `d1_migrations` tracker can
> drift out of sync with the real schema — the tracker may claim a migration is
> applied while the actual columns/tables are missing, which causes 500 errors
> on the new endpoints (e.g. `GET /admin/voters` SELECTs `users.status`/`notes`,
> which 500s if migration 0005 was never truly applied).
>
> If that happens, verify the real schema and apply the missing migration files
> **directly** (they are additive and safe to run once):
>
> ```bash
> npx wrangler d1 execute securevote --remote --file=./migrations/0004_admin_features.sql
> npx wrangler d1 execute securevote --remote --file=./migrations/0005_voter_status.sql
> ```
>
> Check the live schema quickly:
> `npx wrangler d1 execute securevote --remote --command "SELECT name FROM sqlite_master WHERE type='table'"`
> and inspect columns with `pragma_table_info`.

---

## 4. Deploy the web portal

```bash
cd securevote_web_portal
npm run deploy
```

`npm run deploy` runs `opennextjs-cloudflare build && opennextjs-cloudflare
deploy`. The full Next.js build takes a few minutes, then assets + the Worker
are uploaded. The `NEXT_PUBLIC_API_URL` var (in `wrangler.jsonc`) makes the
portal talk to the deployed API.

---

## 5. Verify a deploy

```bash
# API
curl -s https://securevote-api.founder-fb4.workers.dev/api/health
# -> {"status":"ok","version":"1.0.0","env":"development","onchain":{"configured":false,...}}

# Login (admin seeded by migration 9999)
curl -s -X POST https://securevote-api.founder-fb4.workers.dev/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@securevote.io","password":"SecureVote@2026"}'   # returns accessToken

# Web portal
curl -s -o /dev/null -w "%{http_code}\n" https://securevote-web.founder-fb4.workers.dev/
# -> 200
```

---

## 6. How the data is wired ("every data")

**D1 (`DB`) — relational core (SQLite, `securevote`).**
Every business record lives here:

- `users` — voters + admins/verifiers (`kyc_status`, `status`, `notes`)
- `elections`, `candidates`, `ballot_blocks`
- `votes` — cast ballots (hashed, receipt id, optional on-chain anchors)
- `audit_log` — hash-chained immutable audit trail (`prev_hash`/`entry_hash`)
- `organizations`, `alerts` — admin-portal features
- `notifications` — in-app notifications (the admin Notification Bell)
- `kyc_documents`, `pending_verifications`, `sessions`

**R2 (`STORAGE`).** Binary objects — KYC identity documents (uploaded by the
mobile app, previewed/approved in the admin KYC queue) and candidate images.
The web portal has its own R2 cache bucket
(`securevote-web-opennext-cache`) for OpenNext incremental caching.

**KV (`SESSIONS`).** Low-latency key/value — session/refresh-token handling,
rate limiting, and the pending-registration payload keyed by email while a user
completes OTP verification.

**Workers AI (`AI`).** Powers the admin **AI Assistant** (`POST
/api/admin/ai-assistant`, mounted at `/api/admin/ai-assistant`) with an LLM
model binding. Falls back to a template if the binding is unavailable.

**Cron trigger.** A 1-minute job (blockchain/chain-listener background work
from Phase 6).

**Email (Resend).** `api/src/lib/email.ts` sends via Resend whenever
`RESEND_API_KEY` is set, otherwise it dev-logs. Used for verification OTPs and
password-reset links.

### Runtime mode (`ENV`)

`ENV` is a var in `api/wrangler.toml`. In `development`/`demo`, signup returns a
fixed dev OTP (`123456`) and always reports `devOtp` in responses, so the flow
is testable without email. In `production`, a random OTP is generated and only
delivered by email (`api/src/lib/otp.ts`, `api/src/routes/auth.ts`). Flip `ENV`
to `production` **only after** the Resend sending domain is verified, otherwise
users cannot receive their codes.

---

## 7. Redeploy checklist

1. `git push` your changes to GitHub first if you want them recorded.
2. API: `cd api && npx wrangler d1 migrations apply securevote --remote`
   (only if there are new migrations), then `npx wrangler deploy`.
3. Web: `cd securevote_web_portal && npm run deploy`.
4. Add any new secrets: `printf '%s\n' 'VALUE' | npx wrangler secret put NAME`.
5. Re-run the verification commands in §5.
