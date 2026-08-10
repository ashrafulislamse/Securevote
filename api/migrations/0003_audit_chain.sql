-- SecureVote migration 0003 — tamper-evident audit log hash chain.
--
-- Each audit_log row now stores:
--   prev_hash  — the entry_hash of the previous row in chain order, or 'genesis'
--   entry_hash — sha256(prev_hash || action || actor_id || target_type ||
--                         target_id || metadata || ip_address || created_at)
--
-- A "verify" walk recomputes every entry_hash from the genesis and reports
-- the first row whose recomputed hash does not match the stored one.
--
-- Safe to run on an existing table: ADD COLUMN with a constant DEFAULT
-- backfills existing rows to 'genesis'/'genesis'. Re-run backfill-audit-chain
-- afterwards if you want a real historical chain; existing rows are flagged
-- as genesis/genesis until then, which the verifier will accept as long as
-- new rows chain on top correctly.

ALTER TABLE audit_log ADD COLUMN prev_hash TEXT NOT NULL DEFAULT 'genesis';
ALTER TABLE audit_log ADD COLUMN entry_hash TEXT NOT NULL DEFAULT 'genesis';
CREATE INDEX IF NOT EXISTS idx_audit_entry_hash ON audit_log(entry_hash);
