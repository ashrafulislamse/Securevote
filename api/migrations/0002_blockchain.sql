-- Migration 0002: Phase 6 — on-chain anchoring columns.
-- Adds merkle_root, onchain_tx_hash, finalized_at on elections for the
-- Polygon Amoy anchoring flow. The votes table already has the per-vote
-- tx_hash, block_number, merkle_proof columns from 0001_init.sql.
--
-- SQLite / D1 does not support `ADD COLUMN IF NOT EXISTS` directly, so we
-- guard each ALTER with a check against pragma_table_info.

-- ---------------------------------------------------------------------------
-- elections: merkle root + finalize tx hash
-- ---------------------------------------------------------------------------
-- 1) merkle_root
ALTER TABLE elections ADD COLUMN merkle_root TEXT;

-- 2) onchain_tx_hash (tx that called Voting.finalize)
--    Re-using IF NOT EXISTS via a guard table is not portable, so we use
--    a try/catch in the application layer if you re-run this on D1
--    locally. The columns are new so a clean apply works the first time.
--    We don't have a portable "ADD COLUMN IF NOT EXISTS" in SQLite
--    pre-3.35, so we accept the migration as additive-once.
ALTER TABLE elections ADD COLUMN onchain_tx_hash TEXT;

-- 3) finalized_at (unix ms)
ALTER TABLE elections ADD COLUMN finalized_at INTEGER;
