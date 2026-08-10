-- SecureVote D1 schema — initial migration
-- SQLite-compatible (Cloudflare D1)

PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------------
-- Users
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
  id            TEXT PRIMARY KEY,            -- UUID
  email         TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,               -- bcrypt (via @noble/hashes PBKDF2)
  full_name     TEXT NOT NULL,
  phone         TEXT,
  role          TEXT NOT NULL DEFAULT 'voter', -- voter | admin | verifier
  kyc_status    TEXT NOT NULL DEFAULT 'pending', -- pending | approved | rejected
  profile_pic   TEXT,                        -- R2 key
  created_at    INTEGER NOT NULL,            -- unix ms
  updated_at    INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ---------------------------------------------------------------------------
-- Pending registrations (OTP verification before account is usable)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pending_verifications (
  email      TEXT PRIMARY KEY,
  otp_hash   TEXT NOT NULL,                  -- hash of the 6-digit OTP
  attempts   INTEGER NOT NULL DEFAULT 0,
  expires_at INTEGER NOT NULL,
  created_at INTEGER NOT NULL
);

-- ---------------------------------------------------------------------------
-- Sessions (JWTs we can revoke)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sessions (
  jti        TEXT PRIMARY KEY,               -- JWT id
  user_id    TEXT NOT NULL REFERENCES users(id),
  refresh_token TEXT NOT NULL,
  expires_at INTEGER NOT NULL,
  revoked_at INTEGER,                        -- non-null = revoked
  created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_refresh ON sessions(refresh_token);

-- ---------------------------------------------------------------------------
-- Elections
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS elections (
  id            TEXT PRIMARY KEY,            -- UUID
  title         TEXT NOT NULL,
  description   TEXT,
  organization  TEXT,
  type          TEXT NOT NULL DEFAULT 'single', -- single | multi | ranked
  status        TEXT NOT NULL DEFAULT 'draft',  -- draft | scheduled | active | closed | published
  starts_at     INTEGER NOT NULL,            -- unix ms
  ends_at       INTEGER NOT NULL,
  created_by    TEXT REFERENCES users(id),
  created_at    INTEGER NOT NULL,
  updated_at    INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_elections_status ON elections(status);
CREATE INDEX IF NOT EXISTS idx_elections_starts_at ON elections(starts_at);

-- ---------------------------------------------------------------------------
-- Candidates
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS candidates (
  id           TEXT PRIMARY KEY,             -- UUID
  election_id  TEXT NOT NULL REFERENCES elections(id) ON DELETE CASCADE,
  name         TEXT NOT NULL,
  party        TEXT,
  bio          TEXT,
  manifesto    TEXT,
  photo_url    TEXT,
  ballot_order INTEGER NOT NULL DEFAULT 0,
  created_at   INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_candidates_election ON candidates(election_id);

-- ---------------------------------------------------------------------------
-- Ballot blocks (for multi-position / ranked ballots)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ballot_blocks (
  id           TEXT PRIMARY KEY,
  election_id  TEXT NOT NULL REFERENCES elections(id) ON DELETE CASCADE,
  title        TEXT NOT NULL,
  kind         TEXT NOT NULL DEFAULT 'position', -- position | yesNo | info
  order_index  INTEGER NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS idx_ballot_blocks_election ON ballot_blocks(election_id);

-- ---------------------------------------------------------------------------
-- Votes (one row per vote cast; UNIQUE prevents double voting)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS votes (
  id           TEXT PRIMARY KEY,             -- UUID
  election_id  TEXT NOT NULL REFERENCES elections(id),
  user_id      TEXT NOT NULL REFERENCES users(id),
  selections   TEXT NOT NULL,                -- JSON: [{block_id, candidate_id}]
  receipt_id   TEXT NOT NULL UNIQUE,         -- SV-XXXX-...
  tx_hash      TEXT,                         -- blockchain v2 (Polygon Amoy)
  block_number INTEGER,                      -- blockchain v2
  merkle_proof TEXT,                         -- JSON array (v2)
  vote_hash    TEXT,                         -- sha256 of receipt payload
  created_at   INTEGER NOT NULL,
  UNIQUE(election_id, user_id)
);
CREATE INDEX IF NOT EXISTS idx_votes_user ON votes(user_id);
CREATE INDEX IF NOT EXISTS idx_votes_election ON votes(election_id);
CREATE INDEX IF NOT EXISTS idx_votes_receipt ON votes(receipt_id);

-- ---------------------------------------------------------------------------
-- KYC documents (uploaded to R2, reviewed by admin)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS kyc_documents (
  id         TEXT PRIMARY KEY,
  user_id    TEXT NOT NULL REFERENCES users(id),
  doc_type   TEXT NOT NULL DEFAULT 'id',     -- id | selfie
  r2_key     TEXT NOT NULL,
  status     TEXT NOT NULL DEFAULT 'pending',-- pending | approved | rejected
  admin_note TEXT,
  reviewed_by TEXT REFERENCES users(id),
  created_at INTEGER NOT NULL,
  reviewed_at INTEGER
);
CREATE INDEX IF NOT EXISTS idx_kyc_user ON kyc_documents(user_id);

-- ---------------------------------------------------------------------------
-- Audit log
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_log (
  id          TEXT PRIMARY KEY,
  actor_id    TEXT,
  action      TEXT NOT NULL,
  target_type TEXT,
  target_id   TEXT,
  metadata    TEXT,                          -- JSON
  ip_address  TEXT,
  created_at  INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_audit_created ON audit_log(created_at);
CREATE INDEX IF NOT EXISTS idx_audit_actor ON audit_log(actor_id);

-- ---------------------------------------------------------------------------
-- Notifications
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS notifications (
  id         TEXT PRIMARY KEY,
  user_id    TEXT NOT NULL REFERENCES users(id),
  title      TEXT NOT NULL,
  body       TEXT,
  type       TEXT NOT NULL DEFAULT 'info',
  read       INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);