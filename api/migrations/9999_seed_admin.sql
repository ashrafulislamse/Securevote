-- Seed script: creates the demo admin account used by the web portal.
-- Usage:
--   wrangler d1 execute securevote --local --file=./migrations/9999_seed_admin.sql
--   wrangler d1 execute securevote --remote --file=./migrations/9999_seed_admin.sql
--
-- Password: "SecureVote@2026"
-- Hash: PBKDF2-SHA256, 100000 iterations, 16 zero-bytes salt (matches lib/password.ts).

INSERT INTO users (id, email, password_hash, full_name, phone, role, kyc_status, created_at, updated_at)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'admin@securevote.io',
  'pbkdf2$100000$00000000000000000000000000000000$275b6a2b58c000e3da7a21c0e6bfb8a25087b905186f994ff3fc0808d6a4136f',
  'Alex Sterling',
  NULL,
  'admin',
  'approved',
  strftime('%s','now') * 1000,
  strftime('%s','now') * 1000
)
ON CONFLICT(email) DO UPDATE SET role = 'admin', kyc_status = 'approved';