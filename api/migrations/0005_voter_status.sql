-- 0005_voter_status.sql
-- Add a status column to users for suspend/reinstate, and a notes column
-- for admin-annotated voter context. Additive — existing rows default to
-- 'active' so nothing breaks.

ALTER TABLE users ADD COLUMN status TEXT NOT NULL DEFAULT 'active'; -- active | suspended
ALTER TABLE users ADD COLUMN notes TEXT;
