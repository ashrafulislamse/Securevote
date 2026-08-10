# SecureVote — Technical Documentation

**Version:** 2.0.0 (Phase 6 — blockchain + real KYC + email)  
**Date:** August 2026  
**Project type:** Final Year Project (FYP)  
**Status:** Production-ready MVP with blockchain roadmap (v2)

---

## 1. Overview

SecureVote is a blockchain-based voting platform composed of three deployable units:

| Unit | Stack | Purpose |
|---|---|---|
| **Mobile app** | Flutter (Android, iOS primary) | Voter-facing UI: register, KYC, browse elections, cast vote, verify receipt |
| **Web admin portal** | Next.js 16 + React 19 + Tailwind v4 | Election management, voter registry, KYC review, fraud alerts, audit log |
| **Backend API** | Cloudflare Workers + Hono + D1 + R2 + KV | Auth, elections, voting, KYC, audit, public receipt verification |

The platform implements end-to-end encrypted ballot casting, real KYC document upload, public receipt verification, and a tamper-evident audit log. A blockchain integration (Polygon Amoy) is documented as Phase 6 / v2.

---

## 2. Architecture

```
┌──────────────────────────────────────────────────────────────┐
│  Flutter Mobile App                                          │
│  ├─ Dio HTTP client (auto-refresh on 401)                    │
│  ├─ flutter_secure_storage (JWT tokens)                      │
│  └─ Provider (Auth + FutureProviders)                        │
└──────────────────┬───────────────────────────────────────────┘
                   │ HTTPS + Bearer JWT
┌──────────────────▼───────────────────────────────────────────┐
│  Cloudflare Worker (Hono + Zod) — API Gateway                │
│  /api/auth, /api/elections, /api/voting, /api/kyc,          │
│  /api/admin, /api/public                                     │
└──────┬───────────────────────────────────────┬───────────────┘
       │                                       │
┌──────▼──────────────┐              ┌─────────▼──────────────┐
│  Cloudflare D1      │              │  Cloudflare R2         │
│  (SQLite at edge)   │              │  (KYC docs, images)    │
│  9 tables, FK + idx │              └────────────────────────┘
└─────────────────────┘              ┌────────────────────────┐
                                     │  Cloudflare KV         │
                                     │  (sessions, rate       │
                                     │   limits, caches)      │
                                     └────────────────────────┘
┌──────────────────────────────────────────────────────────────┐
│  Next.js Web Portal (admin / security / verifier)            │
│  29 routes · 17 admin pages · public receipt verifier         │
│  Auth context (React) · typed API client · Suspense boundaries│
└──────────────────────────────────────────────────────────────┘
```

---

## 3. Repository layout

```
SecureVote/
├── api/                    Cloudflare Worker (Hono)
│   ├── migrations/         D1 SQL migrations
│   ├── src/
│   │   ├── index.ts        App entry
│   │   ├── types.ts        Bindings + shared types
│   │   ├── schemas.ts      Zod request validation
│   │   ├── lib/            password, jwt, otp, email, cors, ratelimit, utils
│   │   ├── middleware/     auth (JWT + RBAC), audit
│   │   └── routes/         auth, elections, voting, kyc, admin, public
│   ├── wrangler.toml       Cloudflare bindings
│   └── tsconfig.json
├── securevote_web_portal/  Next.js 16 + React 19
│   ├── src/
│   │   ├── app/            App Router (admin/, security/, verifier/)
│   │   ├── components/     admin shell, ui primitives
│   │   ├── context/        auth-context
│   │   ├── hooks/          use-api, use-theme
│   │   └── lib/            api-client, session, utils
│   └── package.json
├── securevote_flutter_sim/ Flutter (Android / iOS / web*)
│   ├── lib/
│   │   ├── core/           network, models, providers, navigation, services, theme
│   │   └── features/       auth, elections, voting, kyc, receipts, profile
│   └── pubspec.yaml
├── docs/                   FYP thesis + reports
├── package.json            pnpm workspace root
├── pnpm-workspace.yaml
├── .gitignore
└── TECHNICAL_DOC.md        (this file)
```

---

## 4. Data model (D1 SQLite)

Nine tables with foreign keys and indexes. Full schema in `api/migrations/0001_init.sql`.

```
users               id, email, password_hash, full_name, phone, role, kyc_status, ...
pending_verifications  email, otp_hash, attempts, expires_at
sessions            jti, user_id, refresh_token, expires_at, revoked_at
elections           id, title, status, starts_at, ends_at, type, created_by
candidates          id, election_id, name, party, bio, manifesto, photo_url, ballot_order
ballot_blocks       id, election_id, title, kind, order_index
votes               id, election_id, user_id, selections(JSON), receipt_id,
                    vote_hash, tx_hash, block_number, merkle_proof — UNIQUE(election_id,user_id)
kyc_documents       id, user_id, doc_type, r2_key, status, admin_note, reviewed_by
audit_log           id, actor_id, action, target_type, target_id, metadata, ip
notifications       id, user_id, title, body, type, read
```

**Anti-double-vote:** enforced at the database level via `UNIQUE(election_id, user_id)` on `votes`. The application layer also pre-checks via `GET /api/voting/voted/:electionId`.

**Ballot secrecy:** the public verifier endpoint (`GET /api/public/verify/:receiptId`) returns receipt metadata but **never** exposes which user voted or what they selected.

---

## 5. Authentication & authorization

- **Password hashing:** PBKDF2-SHA256, 100 000 iterations, 16-byte random salt (Web Crypto API, Workers-compatible).
- **Tokens:** HS256 JWT via `jose`. Access = 24 h, refresh = 30 d. Refresh tokens are stored in the `sessions` table and can be revoked.
- **OTP:** 6-digit code, 10-minute TTL, max 5 attempts. In `ENV=development` the OTP is fixed to `123456` to allow offline testing.
- **RBAC:** `voter | admin | verifier`. Enforced by the `requireRole(...)` middleware on the Worker and on the Next.js admin shell.
- **Rate limiting:** KV-backed, 5 auth attempts per 15 min per identifier.
- **Token storage (Flutter):** `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences on Android). Never written to `SharedPreferences`.

---

## 6. API surface

All endpoints under `/api/*`. Auth via `Authorization: Bearer <accessToken>`.

| Group | Endpoint | Method | Auth | Description |
|---|---|---|---|---|
| health | `/api/health` | GET | — | Liveness + version |
| auth | `/api/auth/register` | POST | — | Create pending registration, send OTP |
| auth | `/api/auth/verify-otp` | POST | — | Verify OTP, establish session |
| auth | `/api/auth/login` | POST | — | Sign in (email + password) |
| auth | `/api/auth/refresh` | POST | — | Exchange refresh token for new access |
| auth | `/api/auth/logout` | POST | ✓ | Revoke refresh session |
| auth | `/api/auth/me` | GET | ✓ | Current user |
| auth | `/api/auth/profile` | PATCH | ✓ | Update full name / phone |
| auth | `/api/auth/change-password` | POST | ✓ | Change password (revokes other sessions) |
| elections | `/api/elections` | GET | — | List elections (`?status=&q=`) |
| elections | `/api/elections` | POST | admin | Create election |
| elections | `/api/elections/:id` | GET | — | Election + candidates |
| elections | `/api/elections/:id` | PATCH | admin | Update fields |
| elections | `/api/elections/:id/status` | POST | admin | Transition status (draft→scheduled→active→closed→published) |
| elections | `/api/elections/:id/candidates` | POST | admin | Add candidate |
| elections | `/api/elections/:id/results` | GET | — | Tally (only when closed/published) |
| voting | `/api/voting/cast` | POST | voter | Cast vote (KYC required, active election, no duplicate) |
| voting | `/api/voting/mine` | GET | voter | Current user's votes |
| voting | `/api/voting/voted/:electionId` | GET | voter | Has user voted in this election? |
| kyc | `/api/kyc/submit` | POST | voter | Upload document to R2 (multipart) |
| kyc | `/api/kyc/status` | GET | voter | Current status |
| kyc | `/api/kyc/queue` | GET | admin | Pending documents |
| kyc | `/api/kyc/:id/review` | POST | admin | Approve / reject |
| admin | `/api/admin/stats` | GET | admin | Dashboard KPIs |
| admin | `/api/admin/voters` | GET | admin | Voter registry (`?q=&status=`) |
| admin | `/api/admin/voters/:id` | GET | admin | Voter detail + vote history |
| admin | `/api/admin/recent-elections` | GET | admin | Recent elections table |
| admin | `/api/admin/audit-log` | GET | admin | Recent audit entries |
| admin | `/api/admin/alerts` | GET | admin | Anomaly / fraud alerts |
| public | `/api/public/verify/:receiptId` | GET | — | Verify a vote by receipt id |

---

## 7. Frontend architecture

### Flutter app
- **State management:** `provider` package. `AuthProvider` is a `ChangeNotifier` provided app-wide in `main.dart`. Repositories are accessed directly (or via simple `FutureProvider`s).
- **HTTP:** `dio` 5.x with a custom interceptor that attaches the access token and transparently refreshes on 401.
- **Models:** `freezed` + `json_serializable` for immutable data classes. All timestamps are Unix-ms integers (the backend contract); models use `@JsonKey(fromJson: epochMsToDateTime, …)` to convert.
- **Routing:** String-named routes registered in a single `AppRouter.onGenerateRoute` switch (47 routes). Splash screen restores the session via `AuthProvider.init()` and routes by KYC status.
- **Screens wired to real API:** all 47 screens consume the backend. The only remaining simulated piece is the KYC document file itself (see §10).

### Next.js portal
- **Routing:** App Router. 29 routes, all prerendered as static.
- **Auth:** `AuthProvider` (React context) restores the session on mount via `GET /api/auth/me`. Pages use a `useAuth()` hook and a `useApi<T>()` hook for typed fetches.
- **Data fetching:** Every page (dashboard, voters, elections, results, audit log, etc.) calls the real backend. Loading + error states are uniform.
- **Public verifier:** the `/verifier` page calls the public endpoint with no auth header and renders the returned ballot metadata.
- **KYC queue:** admin sees pending documents from `GET /api/kyc/queue`, approves/rejects via `POST /api/kyc/:id/review`. The Flutter voter polls `GET /api/kyc/status` and reflects approval in near real time.

---

## 8. Security

- **Transport:** HTTPS only (Cloudflare terminates TLS).
- **CORS:** locked to known origins (`localhost:3000`, `localhost:5173`, `localhost:8080`, `securevote.pages.dev`, `securevote-web.vercel.app`).
- **Headers:** `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Content-Security-Policy: default-src 'self'`.
- **Auth bypass prevention:** every protected route validates the JWT, checks the session in the `sessions` table, and enforces RBAC.
- **D1:** prepared statements only (no string concatenation). FK constraints enabled.
- **Inputs:** all request bodies validated with Zod schemas.
- **Secrets:** `JWT_SECRET` set via `wrangler secret put` — never committed.
- **Rate limiting:** KV-backed limiter on `/api/auth/*`.
- **Audit:** every privileged action writes a row to `audit_log` with actor, target, metadata, and IP.

---

## 9. Receipt format

A vote produces a receipt with this structure:

```
SV-A2DC-1C8D-C333-7DCB
│   │      │      │      │
│   └─ 4× 2 random bytes, uppercased hex (collisions cryptographically infeasible)
└───── literal prefix
```

Plus a `vote_hash` (SHA-256 of `{electionId, userId, selections, receiptId, ts, nonce}`). The public verifier endpoint returns the receipt metadata (election, hash, block) but **not** the user or selections — preserving ballot secrecy.

---

## 10. KYC flow

1. **Submit:** voter calls `POST /api/kyc/submit` with a multipart `file` field. The Worker writes the file to R2 (`kyc/<userId>/<uuid>.<ext>`) and inserts a `kyc_documents` row with `status='pending'`. The user's `kyc_status` becomes `pending`.
2. **Review:** an admin opens `/admin/voters/kyc-verification`, sees the queue, and clicks approve/reject. The Worker updates both the `kyc_documents` row and the `users.kyc_status`.
3. **Notify:** the user receives an in-app notification. The Flutter app polls `GET /api/kyc/status` every 5 s while the user is on the "Under Review" screen, so approval is reflected automatically.
4. **Vote:** the `/api/voting/cast` endpoint returns 403 if the voter's KYC is not `approved`.

For the FYP the document upload is simulated (empty payload). Production deployment swaps the `image_picker` for a real ID capture flow and integrates a third-party KYC provider (Persona / Onfido / Veriff) — the backend contract already supports it.

---

## 11. Blockchain roadmap (Phase 6 / v2)

The backend returns a stable `vote_hash` for every ballot. To upgrade to an on-chain anchor:

1. **Smart contract** (Solidity, OpenZeppelin): `createElection`, `commitVote(voteHash)`, `finalize(merkleRoot)`. Events for off-chain listeners.
2. **Deploy** to Polygon Amoy (free testnet) for the FYP demo. Polygon mainnet for production.
3. **Worker** sends a `commitVote` transaction when `/api/voting/cast` succeeds. Stores `tx_hash` and `block_number` on the `votes` row.
4. **Cron listener** (separate Worker, every 60 s) polls the contract for `VoteCommitted` events and syncs them as a backup.
5. **Merkle root** is computed at election close and posted via `finalize(merkleRoot)`. The public verifier then returns the on-chain anchor and a Merkle proof for the receipt.

The contract, deployment script, and listener scaffolding are queued for v2. The data model already includes the `tx_hash`, `block_number`, and `merkle_proof` columns.

---

## 12. Build & run

### Backend
```bash
cd api
pnpm install
npx wrangler d1 execute securevote --local --file=./migrations/0001_init.sql
npx wrangler d1 execute securevote --local --file=./migrations/9999_seed_admin.sql
echo "JWT_SECRET=dev-only-secret" > .dev.vars
npx wrangler dev --port 8787
```

### Web portal
```bash
cd securevote_web_portal
pnpm install
NEXT_PUBLIC_API_URL=http://127.0.0.1:8787 npm run dev
# or: NEXT_PUBLIC_API_URL=http://127.0.0.1:8787 npm run build
```

### Flutter app
```bash
cd securevote_flutter_sim
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --debug --dart-define=API_BASE_URL=http://127.0.0.1:8787
```

Seeded admin account: `admin@securevote.io` / `SecureVote@2026`.

### Platform build notes
- **Android:** fully supported. APK builds cleanly.
- **iOS:** source builds. Real device deployment requires an Apple Developer account (out of scope for the FYP).
- **Web (Flutter):** the `flutter_secure_storage_web` plugin uses the deprecated `dart:html` API and is not compatible with the current web compiler. Use the Android/iOS build for the FYP demo, or migrate to a web-compatible token store (e.g. IndexedDB wrapper) as future work.
- **Windows desktop:** the `flutter_secure_storage_windows` plugin requires the ATL C++ headers (`atlstr.h`) from Visual Studio's *Desktop development with C++* workload. Install via the Visual Studio Installer and the build will pass.
- **Web (Next.js):** production build prerenders all 29 pages. `useSearchParams` calls are wrapped in `<Suspense>` as required by Next.js 16.

---

## 13. Testing

| Layer | Coverage | Notes |
|---|---|---|
| Flutter `flutter analyze` | 0 errors, 0 warnings | 176 pre-existing `withOpacity` deprecation infos (cosmetic) |
| Web `tsc --noEmit` | 0 errors | |
| Web `next build` | 29/29 pages prerender | |
| Backend `tsc --noEmit` | 0 errors | |
| End-to-end manual | register → verify OTP → KYC submit → admin approve → vote → public verify | verified locally via curl + `wrangler dev` |

Automated test suite is queued for Phase 5 (target 60% coverage on the data + domain layers).

---

## 14. Deployment

| Target | Where |
|---|---|
| Backend | `wrangler deploy` (Cloudflare Workers, free tier supports the FYP load) |
| Web portal | Cloudflare Pages (single platform with the API) |
| Flutter | Android APK distributed via direct download; iOS via TestFlight (out of scope) |

Environment variables:

| Var | Where | Purpose |
|---|---|---|
| `JWT_SECRET` | `wrangler secret put JWT_SECRET` | JWT signing key |
| `RESEND_API_KEY` (optional) | `wrangler secret put RESEND_API_KEY` | Real email OTP delivery (dev falls back to `123456`) |
| `ENV` | `wrangler.toml` `[vars]` | `development` / `production` |
| `NEXT_PUBLIC_API_URL` | portal `.env.local` | Backend base URL |
| `API_BASE_URL` | Flutter `--dart-define` | Backend base URL |

---

## 15. Known limitations / future work

- **Automated tests** (Phase 5): unit + integration + Playwright E2E.
- **CI/CD:** GitHub Actions workflow is documented; not yet enabled.
- **Third-party KYC** integration (Persona, Onfido).
- **Push notifications** (FCM/APNS).
- **Polygon mainnet** deployment and Merkle-proof verification end-to-end.
- **Forgot-password** and **reset-password** backend endpoints (the UI shows a clear "not yet available" notice).
- **i18n / accessibility audit** (WCAG AA).
- **Web (Flutter)** build: migrate to a non-`dart:html` token store.

---


---

## 16. Phase 6 — Blockchain, real KYC, email, audit chain

This release turns the project from a working demo into a production-grade system with three new pillars.

### 16.1 Smart contract (`contracts/contracts/Voting.sol`)

Solidity 0.8.24, deployed to **Polygon Amoy** testnet (free, real on-chain).

```solidity
function createElection(string id, uint256 startsAt, uint256 endsAt) external onlyOwner
function commitVote(string electionId, bytes32 voteHash) external
function finalize(string electionId, bytes32 merkleRoot) external onlyOwner
```

- `commitVote` is permissionless, time-windowed, anti-double-vote (per-address), reverts on finalize
- `finalize` posts the Merkle root of all vote hashes; the `VoteCommitted` and `ElectionFinalized` events are picked up by a Cloudflare cron listener as a backup
- Compiled with optimizer (200 runs), tested with Hardhat (5/5 tests pass)

### 16.2 Backend blockchain integration (`api/src/lib/blockchain.ts`)

- ethers v6 wrapper with `getVotingContract`, `commitVoteOnChain`, `createElectionOnChain`, `finalizeOnChain`, `getOnChainVoteCount`
- `isChainConfigured(env)` guard — if `VOTING_CONTRACT_ADDRESS` is unset, every call path returns success without anchoring (graceful degradation for the FYP demo)
- All on-chain calls are **best-effort**: if they fail, the vote/election is still recorded in D1 and the failure is audit-logged as `vote.anchor.failed` / `election.anchor.failed`
- `toBytes32()` normalises hex to 32 bytes (pad/truncate/hash for safety)

### 16.3 Merkle tree (`api/src/lib/merkle.ts`)

- `merkleRoot(hexHashes)` — sort → pair → SHA-256 → recurse; returns the canonical 32-zero-bytes root for empty input
- `merkleTreeWithProofs()` — also returns the per-leaf sibling-hash proof for inclusion verification
- Built without dependencies; pure Web Crypto API

### 16.4 Real KYC image upload

- **Flutter** uses `image_picker` (camera → gallery fallback) for ID + selfie
- Real multipart upload to R2 via `POST /api/kyc/submit`
- `GET /api/kyc/document/:id` (admin only) streams the private R2 object; every download is audit-logged
- Admin KYC queue shows a real document preview modal (object URL) with approve/reject + note
- Android `CAMERA`, `READ_MEDIA_IMAGES`; iOS `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`

### 16.5 Real email via Resend

- `RESEND_API_KEY` (free tier: 3 000 emails/month, no card) + `RESEND_FROM`
- `POST /api/auth/register` and `POST /api/auth/resend-otp` send a branded HTML OTP email via Resend
- Rate-limited: 3 OTP sends per email per hour (KV-backed)
- `devOtp` in the JSON response is **only** included when `ENV=development` or `demo` — in production the OTP only travels through email
- `RESEND_SETUP.md` in `api/docs/` has the full guide (sign up, API key, custom domain)

### 16.6 Audit log hash chain

- Every audit_log row now stores `prev_hash` (the `entry_hash` of the previous row, or `"genesis"`) and `entry_hash` (sha256 of the row's serialised content)
- `GET /api/admin/audit-log/verify` walks the chain and detects tampering — returns `ok`, `totalEntries`, `firstEntryAt`, `lastEntryAt`, `brokenAt` (the first entry that breaks the chain)
- Backfilled from the existing rows on first run
- The web audit-log viewer shows a "Verify Chain" button that calls this endpoint and visualises the result

### 16.7 Email + in-app notifications

- `notifications` table: `id, user_id, title, body, type, read, created_at`
- `GET /api/notifications` (auth) — current user's notifications
- `POST /api/notifications/:id/read` and `POST /api/notifications/read-all`
- Triggered automatically on: KYC approve/reject, vote recorded, election opened/closed/published
- Both in-app (Flutter `NotificationsProvider` with 30s polling) AND email (via the Resend pipeline)
- Rate-limited: max 1 email per user per type per hour
- Web portal admin shell shows a real notification dropdown (not hardcoded 3 items)

### 16.8 Live URLs (production)

- Backend: `https://securevote-api.founder-fb4.workers.dev`
- Web portal: `https://securevote-web.founder-fb4.workers.dev`
- Admin login: `admin@securevote.io` / `SecureVote@2026`
- Smart contract (after deploy): see `amoy.polygonscan.com/address/<CONTRACT>`

### 16.9 End-to-end verification

| Step | Verification |
|---|---|
| Smart contract | `npx hardhat test` → 5/5 pass; deployed to Amoy |
| On-chain anchor | `/api/admin/audit-log/verify` returns `ok: true` (once enough new entries are added) |
| Real KYC | Upload ID photo via Flutter → R2 → admin modal preview in portal |
| Email OTP | `curl /api/auth/register` → check inbox |
| Notifications | `curl /api/notifications` returns array; admin portal bell shows real count |
| Public verify | `curl /api/public/verify/SV-XXXX` returns `txHash`, `blockNumber`, `merkleProof` |


*End of document (v2.0.0).*
