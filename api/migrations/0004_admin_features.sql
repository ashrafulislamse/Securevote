-- Migration 0004: admin-portal features — candidate moderation flags,
-- organizations registry, persisted anomaly/fraud alerts, and election
-- publish distribution metadata.
--
-- Additive only: ALTER TABLE ... ADD COLUMN with DEFAULTs (safe for existing
-- rows) plus two new tables. SQLite/D1 has no `ADD COLUMN IF NOT EXISTS`, so
-- this is an apply-once migration like 0002_blockchain.sql.

-- ---------------------------------------------------------------------------
-- candidates: admin moderation flags (visibility + verification)
-- ---------------------------------------------------------------------------
ALTER TABLE candidates ADD COLUMN visible  INTEGER NOT NULL DEFAULT 1;  -- 0 = hidden from ballot
ALTER TABLE candidates ADD COLUMN verified INTEGER NOT NULL DEFAULT 0;  -- 0 = pending, 1 = approved

-- ---------------------------------------------------------------------------
-- elections: publish distribution metadata (set when status -> published)
-- ---------------------------------------------------------------------------
ALTER TABLE elections ADD COLUMN publish_visibility TEXT;  -- public | participants | internal
ALTER TABLE elections ADD COLUMN publish_channels   TEXT;  -- JSON array: ["portal","email","apiWebhook"]

-- ---------------------------------------------------------------------------
-- organizations: lightweight registry backing the admin Organizations page
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS organizations (
  id         TEXT PRIMARY KEY,                  -- UUID
  name       TEXT NOT NULL,
  plan       TEXT NOT NULL DEFAULT 'Professional', -- Starter | Professional | Enterprise
  members    INTEGER NOT NULL DEFAULT 0,
  status     TEXT NOT NULL DEFAULT 'active',    -- active | paused
  created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_organizations_status ON organizations(status);

-- ---------------------------------------------------------------------------
-- alerts: persisted anomaly / fraud alerts backing the Fraud Alerts page.
-- Previously the GET /admin/alerts endpoint synthesised rows from a sessions
-- heuristic; that synthesis is retained as a fallback when this table is empty.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS alerts (
  id          TEXT PRIMARY KEY,                 -- UUID
  type        TEXT NOT NULL,                    -- e.g. MULTIPLE_SESSIONS, UNUSUAL_BROWSER_PATTERN
  severity    TEXT NOT NULL DEFAULT 'medium',   -- low | medium | high | critical
  target      TEXT,                             -- user / election id the alert points at
  title       TEXT NOT NULL,
  body        TEXT,
  status      TEXT NOT NULL DEFAULT 'open',     -- open | investigating | resolved
  assigned_to TEXT,                             -- analyst display name / user id
  metadata    TEXT,                             -- JSON
  created_at  INTEGER NOT NULL,
  resolved_at INTEGER
);
CREATE INDEX IF NOT EXISTS idx_alerts_status ON alerts(status);
CREATE INDEX IF NOT EXISTS idx_alerts_created ON alerts(created_at);
