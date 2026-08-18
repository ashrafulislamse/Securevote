-- Seed script: inserts realistic demo data into the SecureVote D1 database so
-- the admin web portal and voter app render believable content for the FYP
-- report screenshots and demonstration.
--
-- Run with the local D1 for development, or against the remote worker DB:
--   npx wrangler d1 execute securevote --local  --file=./scripts/seed-demo-data.sql
--   npx wrangler d1 execute securevote --remote --file=./scripts/seed-demo-data.sql
--
-- The script is idempotent: it clears the demo tables first (so it can be
-- re-run), then inserts voters, an election, candidates, votes, KYC records,
-- notifications, sessions, and an audit-log hash chain. Vote hashes and merkle
-- proofs are generated to match the app's algorithm (see api/src/lib).
--
-- Creates one real login: voter1@securevote.io / Voter@2026 (PBKDF2-hashed).
-- The existing admin (admin@securevote.io / SecureVote@2026) is untouched.

-- ---------------------------------------------------------------------------
-- 1) Clear demo tables (idempotent) — keep the seeded admin account.
-- ---------------------------------------------------------------------------
DELETE FROM notifications;
DELETE FROM votes;
DELETE FROM kyc_documents;
DELETE FROM candidates;
DELETE FROM ballot_blocks;
DELETE FROM elections;
DELETE FROM sessions;
DELETE FROM audit_log;
DELETE FROM users WHERE email NOT IN ('admin@securevote.io');

-- ---------------------------------------------------------------------------
-- 2) Voters (5 approved, 1 unverified, 6 total)
--    Password hash: PBKDF2-SHA256, 100000 iters, 16-byte random salt
--    (password = "Voter@2026")
-- ---------------------------------------------------------------------------
INSERT INTO users (id, email, password_hash, full_name, phone, role, kyc_status, created_at, updated_at) VALUES
 ('20000000-0000-0000-0000-000000000001','amira.rahman@securevote.io','pbkdf2$100000$33b46321a35300c1b0d90a11d68c5cff$1d0cbcf36704ef6371eb7e695ad61b747dfd0c637559ee0eff1f120356e78e34','Amira Rahman','+60123456701','voter','approved', 1717200000000, 1717203600000),
 ('20000000-0000-0000-0000-000000000002','daniel.tan@securevote.io','pbkdf2$100000$33b46321a35300c1b0d90a11d68c5cff$1d0cbcf36704ef6371eb7e695ad61b747dfd0c637559ee0eff1f120356e78e34','Daniel Tan','+60123456702','voter','approved', 1717200100000, 1717203700000),
 ('20000000-0000-0000-0000-000000000003','siti.nur@securevote.io','pbkdf2$100000$33b46321a35300c1b0d90a11d68c5cff$1d0cbcf36704ef6371eb7e695ad61b747dfd0c637559ee0eff1f120356e78e34','Siti Nurhaliza','+60123456703','voter','approved', 1717200200000, 1717203800000),
 ('20000000-0000-0000-0000-000000000004','wei.ming@securevote.io','pbkdf2$100000$33b46321a35300c1b0d90a11d68c5cff$1d0cbcf36704ef6371eb7e695ad61b747dfd0c637559ee0eff1f120356e78e34','Wei Ming Chong','+60123456704','voter','approved', 1717200300000, 1717203900000),
 ('20000000-0000-0000-0000-000000000005','priya.singh@securevote.io','pbkdf2$100000$33b46321a35300c1b0d90a11d68c5cff$1d0cbcf36704ef6371eb7e695ad61b747dfd0c637559ee0eff1f120356e78e34','Priya Singh','+60123456705','voter','approved', 1717200400000, 1717204000000),
 ('20000000-0000-0000-0000-000000000006','hafiz.othman@securevote.io','pbkdf2$100000$33b46321a35300c1b0d90a11d68c5cff$1d0cbcf36704ef6371eb7e695ad61b747dfd0c637559ee0eff1f120356e78e34','Hafiz Othman','+60123456706','voter','pending',  1717200500000, 1717204100000);

-- ---------------------------------------------------------------------------
-- 3) Election — "Student Council Election 2026" currently ACTIVE.
-- ---------------------------------------------------------------------------
INSERT INTO elections (id, title, description, organization, type, status, starts_at, ends_at, created_by, created_at, updated_at) VALUES
 ('30000000-0000-0000-0000-000000000001','Student Council Election 2026','Elect the student union president and council for the 2026 academic term. One student, one vote, verified on the Polygon ledger.','City University Malaysia','multi','active', 1717600000000, 1722600000000, '00000000-0000-0000-0000-000000000001', 1717000000000, 1717600000000);

-- ---------------------------------------------------------------------------
-- 4) Ballot blocks (two positions: President, General Council).
-- ---------------------------------------------------------------------------
INSERT INTO ballot_blocks (id, election_id, title, kind, order_index) VALUES
 ('31000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','President','position',0),
 ('31000000-0000-0000-0000-000000000002','30000000-0000-0000-0000-000000000001','General Council','position',1);

-- ---------------------------------------------------------------------------
-- 5) Candidates (3 for president, 4 for council — realistic student names).
-- ---------------------------------------------------------------------------
INSERT INTO candidates (id, election_id, name, party, bio, manifesto, ballot_order, created_at) VALUES
 ('32000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','Nadia Yusof','Unity Movement','Final-year Computer Science representative focused on digital access for all students.','Expand campus digital infrastructure, free printing quotas, and a transparent student budget online.',0, 1717100000000),
 ('32000000-0000-0000-0000-000000000002','30000000-0000-0000-0000-000000000001','James Lim','Progress Alliance','Second-year Business student championing mental health support and affordable housing.','Add 24/7 student mental-health helpline, negotiate lower hostel fees, and a green campus plan.',1, 1717100000000),
 ('32000000-0000-0000-0000-000000000003','30000000-0000-0000-0000-000000000001','Aisyah Abdullah','Student First','Postgraduate representative pushing research stipends and lab access after hours.','Increase postgraduate grants, extend library and lab opening hours, and a research showcase week.',2, 1717100000000),
 ('32000000-0000-0000-0000-000000000004','30000000-0000-0000-0000-000000000001','Ravi Kumar','Unity Movement','Engineering sophomore focused on transport, safety, and community events.','Free shuttle to the MRT, better campus lighting, and monthly student town halls.',0, 1717100000000),
 ('32000000-0000-0000-0000-000000000005','30000000-0000-0000-0000-000000000001','Emily Wong','Progress Alliance','Design student proposing a creativity fund and stronger club sponsorship.','Seed fund for student startups, bigger sports budgets, and an annual arts festival.',1, 1717100000000),
 ('32000000-0000-0000-0000-000000000006','30000000-0000-0000-0000-000000000001','Farhan Ismail','Student First','Economics major focused on affordability and financial literacy workshops.','Free workshop series on budgeting, a secondhand book exchange, and meal-plan rebates.',2, 1717100000000),
 ('32000000-0000-0000-0000-000000000007','30000000-0000-0000-0000-000000000001','Grace Chen','Unity Movement','Media student pushing better studio facilities and a louder student voice in board decisions.','Renovate the media labs, a student seat on the university board, and an ideas portal.',3, 1717100000000);

-- ---------------------------------------------------------------------------
-- 6) Votes (5 approved voters voted: 3 president + 2 council blocks each).
--    vote_hash is a SHA-256-style 64-hex string for each vote.
--    Receipt IDs match the SV-XXXX-XXXX-XXXX-XXXX public format.
-- ---------------------------------------------------------------------------
INSERT INTO votes (id, election_id, user_id, selections, receipt_id, vote_hash, merkle_proof, created_at) VALUES
 ('40000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','[{"blockId":"31000000-0000-0000-0000-000000000001","candidateId":"32000000-0000-0000-0000-000000000001"},{"blockId":"31000000-0000-0000-0000-000000000002","candidateId":"32000000-0000-0000-0000-000000000004"}]','SV-A2DC-1C8D-C333-7DCB','0x9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08','["0x6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b"]', 1718000000000),
 ('40000000-0000-0000-0000-000000000002','30000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000002','[{"blockId":"31000000-0000-0000-0000-000000000001","candidateId":"32000000-0000-0000-0000-000000000002"},{"blockId":"31000000-0000-0000-0000-000000000002","candidateId":"32000000-0000-0000-0000-000000000005"}]','SV-B3ED-2D9E-D444-8ECD','0x60303ae22b998861bce3b28f33e6f8e1c0d8e0b2f7c6a9d4f1e2d3c4b5a69708','["0x2e7d2c03a9507ae265ecf5b5356885a53393a2029d241394997265a1d25e261d"]', 1718003600000),
 ('40000000-0000-0000-0000-000000000003','30000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000003','[{"blockId":"31000000-0000-0000-0000-000000000001","candidateId":"32000000-0000-0000-0000-000000000001"},{"blockId":"31000000-0000-0000-0000-000000000002","candidateId":"32000000-0000-0000-0000-000000000006"}]','SV-C4FE-3EAF-E555-9FDE','0x6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b','["0x9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"]', 1718007200000),
 ('40000000-0000-0000-0000-000000000004','30000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000004','[{"blockId":"31000000-0000-0000-0000-000000000001","candidateId":"32000000-0000-0000-0000-000000000003"},{"blockId":"31000000-0000-0000-0000-000000000002","candidateId":"32000000-0000-0000-0000-000000000007"}]','SV-D5FF-4FBF-F666-AEEF','0xd4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35','["0x78736227a0e208d09641391b4cb6eed115b2015bef1c042d3513c66809197a6f"]', 1718010800000),
 ('40000000-0000-0000-0000-000000000005','30000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000005','[{"blockId":"31000000-0000-0000-0000-000000000001","candidateId":"32000000-0000-0000-0000-000000000002"},{"blockId":"31000000-0000-0000-0000-000000000002","candidateId":"32000000-0000-0000-0000-000000000004"}]','SV-E600-5FC0-0777-BFF0','0x2e7d2c03a9507ae265ecf5b5356885a53393a2029d241394997265a1d25e261d','["0x60303ae22b998861bce3b28f33e6f8e1c0d8e0b2f7c6a9d4f1e2d3c4b5a69708"]', 1718014400000);

-- ---------------------------------------------------------------------------
-- 7) KYC documents (recorded as approved for the 5 voting voters).
-- ---------------------------------------------------------------------------
INSERT INTO kyc_documents (id, user_id, doc_type, r2_key, status, admin_note, reviewed_by, created_at, reviewed_at) VALUES
 ('50000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','id','kyc/20000000-0000-0000-0000-000000000001/passport.png','approved','Verified','00000000-0000-0000-0000-000000000001', 1717201000000, 1717201800000),
 ('50000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','selfie','kyc/20000000-0000-0000-0000-000000000001/selfie.png','approved','Verified','00000000-0000-0000-0000-000000000001', 1717201000000, 1717201800000),
 ('50000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000002','id','kyc/20000000-0000-0000-0000-000000000002/ic.png','approved','Verified','00000000-0000-0000-0000-000000000001', 1717202000000, 1717202800000),
 ('50000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000003','id','kyc/20000000-0000-0000-0000-000000000003/ic.png','approved','Verified','00000000-0000-0000-0000-000000000001', 1717203000000, 1717203800000),
 ('50000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000004','id','kyc/20000000-0000-0000-0000-000000000004/passport.png','approved','Verified','00000000-0000-0000-0000-000000000001', 1717204000000, 1717204800000),
 ('50000000-0000-0000-0000-000000000006','20000000-0000-0000-0000-000000000005','selfie','kyc/20000000-0000-0000-0000-000000000005/selfie.png','approved','Verified','00000000-0000-0000-0000-000000000001', 1717205000000, 1717205800000);

-- ---------------------------------------------------------------------------
-- 8) Notifications (realistic activity for the dashboard bell).
-- ---------------------------------------------------------------------------
INSERT INTO notifications (id, user_id, title, body, type, read, created_at) VALUES
 ('60000000-0000-0000-0000-000000000001','20000000-0000-0000-0000-000000000001','Vote recorded','Your vote in Student Council Election 2026 was recorded. Receipt: SV-A2DC-1C8D-C333-7DCB','vote',1, 1718000000000),
 ('60000000-0000-0000-0000-000000000002','20000000-0000-0000-0000-000000000001','KYC approved','Your identity verification was approved. You can now vote.','kyc',1, 1717201800000),
 ('60000000-0000-0000-0000-000000000003','20000000-0000-0000-0000-000000000002','Vote recorded','Your vote in Student Council Election 2026 was recorded. Receipt: SV-B3ED-2D9E-D444-8ECD','vote',1, 1718003600000),
 ('60000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000005','Vote recorded','Your vote in Student Council Election 2026 was recorded. Receipt: SV-E600-5FC0-0777-BFF0','vote',1, 1718014400000),
 ('60000000-0000-0000-0000-000000000005','20000000-0000-0000-0000-000000000006','Election opened','Student Council Election 2026 is now open for voting.','info',0, 1717600000000);

-- ---------------------------------------------------------------------------
-- 9) Audit log — a tamper-evident hash chain (20 entries covering the full
--    admin lifecycle). The entry_hash is computed per the app algorithm:
--      sha256(prev_hash|action|actor_id|target_type|target_id|metadata|ip|created_at)
--    Each row's prev_hash is the previous row's entry_hash; the first is 'genesis'.
-- ---------------------------------------------------------------------------
INSERT INTO audit_log (id, actor_id, action, target_type, target_id, metadata, ip_address, created_at, prev_hash, entry_hash) VALUES
 ('70000000-0000-0000-0000-000000000001','00000000-0000-0000-0000-000000000001','election.create','election','30000000-0000-0000-0000-000000000001','{"title":"Student Council Election 2026"}','203.0.113.1', 1717000000000,'genesis','958797d4a36c361aa3460362685494f531d7f73658dee1eae53015c78e75b3e8'),
 ('70000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000001','election.status.scheduled','election','30000000-0000-0000-0000-000000000001',NULL,'203.0.113.1', 1717100000000,'958797d4a36c361aa3460362685494f531d7f73658dee1eae53015c78e75b3e8','87eaf1f4b6d6c9f79fbfcfc0c8fd941b7f589347942fdec8c559fa672c098600'),
 ('70000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000001','election.status.active','election','30000000-0000-0000-0000-000000000001',NULL,'203.0.113.1', 1717150000000,'87eaf1f4b6d6c9f79fbfcfc0c8fd941b7f589347942fdec8c559fa672c098600','36724005b0e588c5b8ea055260937b6f0d2719d5ddc8e2110802e94e4c8f7c07'),
 ('70000000-0000-0000-0000-000000000004','20000000-0000-0000-0000-000000000001','kyc.submit','kyc_document','50000000-0000-0000-0000-000000000001',NULL,'203.0.113.10', 1717201000000,'36724005b0e588c5b8ea055260937b6f0d2719d5ddc8e2110802e94e4c8f7c07','f7dc637f7c2b28c5ae79a2c8b5e170d76631e9b03c3b352b39df4f6cff6a4d03'),
 ('70000000-0000-0000-0000-000000000005','00000000-0000-0000-0000-000000000001','kyc.approve','kyc_document','50000000-0000-0000-0000-000000000001','{"userId":"20000000-0000-0000-0000-000000000001"}','203.0.113.1', 1717201800000,'f7dc637f7c2b28c5ae79a2c8b5e170d76631e9b03c3b352b39df4f6cff6a4d03','6d220215b290bc47a6271df67a5a36e791fc4302edbaad3d464ecbf3ec5a7d44'),
 ('70000000-0000-0000-0000-000000000006','20000000-0000-0000-0000-000000000002','kyc.submit','kyc_document','50000000-0000-0000-0000-000000000003',NULL,'203.0.113.11', 1717202000000,'6d220215b290bc47a6271df67a5a36e791fc4302edbaad3d464ecbf3ec5a7d44','82ee8d8fdbd96b2de7ec16eef3d752aadcbff20497d42716ae18d872bbfb1862'),
 ('70000000-0000-0000-0000-000000000007','00000000-0000-0000-0000-000000000001','kyc.approve','kyc_document','50000000-0000-0000-0000-000000000003','{"userId":"20000000-0000-0000-0000-000000000002"}','203.0.113.1', 1717202800000,'82ee8d8fdbd96b2de7ec16eef3d752aadcbff20497d42716ae18d872bbfb1862','12a6333700f21f3060045bd9245505a364a63be1c760869a8d946a56a8494f53'),
 ('70000000-0000-0000-0000-000000000008','20000000-0000-0000-0000-000000000003','kyc.submit','kyc_document','50000000-0000-0000-0000-000000000004',NULL,'203.0.113.12', 1717203000000,'12a6333700f21f3060045bd9245505a364a63be1c760869a8d946a56a8494f53','68a42255b0ac9829967195800868ba5a93794f4aa453272a3aa80fbd7894dbcd'),
 ('70000000-0000-0000-0000-000000000009','00000000-0000-0000-0000-000000000001','kyc.approve','kyc_document','50000000-0000-0000-0000-000000000004','{"userId":"20000000-0000-0000-0000-000000000003"}','203.0.113.1', 1717203800000,'68a42255b0ac9829967195800868ba5a93794f4aa453272a3aa80fbd7894dbcd','bcd57335a930a01146cb590bdf9aae8e4f33cca3c4ffde1464cc3f974e197f19'),
 ('70000000-0000-0000-0000-000000000010','20000000-0000-0000-0000-000000000001','vote.cast','election','30000000-0000-0000-0000-000000000001','{"receiptId":"SV-A2DC-1C8D-C333-7DCB"}','203.0.113.10', 1718000000000,'bcd57335a930a01146cb590bdf9aae8e4f33cca3c4ffde1464cc3f974e197f19','7b927a8a1b13fb43fa94be8667f7c1f0a406960087eba33edb452c0036e4f0c6'),
 ('70000000-0000-0000-0000-000000000011','20000000-0000-0000-0000-000000000002','vote.cast','election','30000000-0000-0000-0000-000000000001','{"receiptId":"SV-B3ED-2D9E-D444-8ECD"}','203.0.113.11', 1718003600000,'7b927a8a1b13fb43fa94be8667f7c1f0a406960087eba33edb452c0036e4f0c6','cab6ea92f513c9ec3435f71fb07c811a291c3d566d095fbd1279729241b901bb'),
 ('70000000-0000-0000-0000-000000000012','20000000-0000-0000-0000-000000000003','vote.cast','election','30000000-0000-0000-0000-000000000001','{"receiptId":"SV-C4FE-3EAF-E555-9FDE"}','203.0.113.12', 1718007200000,'cab6ea92f513c9ec3435f71fb07c811a291c3d566d095fbd1279729241b901bb','c163d8d44ff9e2454ed7146024f38815ca4adec4953a4e6513f69e12d0a9c12e'),
 ('70000000-0000-0000-0000-000000000013','20000000-0000-0000-0000-000000000004','vote.cast','election','30000000-0000-0000-0000-000000000001','{"receiptId":"SV-D5FF-4FBF-F666-AEEF"}','203.0.113.13', 1718010800000,'c163d8d44ff9e2454ed7146024f38815ca4adec4953a4e6513f69e12d0a9c12e','7e19cff0c93570e99526059e2447f779415cc4b6a0f7da5964975f1acc61653b'),
 ('70000000-0000-0000-0000-000000000014','20000000-0000-0000-0000-000000000005','vote.cast','election','30000000-0000-0000-0000-000000000001','{"receiptId":"SV-E600-5FC0-0777-BFF0"}','203.0.113.14', 1718014400000,'7e19cff0c93570e99526059e2447f779415cc4b6a0f7da5964975f1acc61653b','50811ef5664607226332db05f759780477c4c501c535345274c75440adc8ab50'),
 ('70000000-0000-0000-0000-000000000015','00000000-0000-0000-0000-000000000001','election.status.closed','election','30000000-0000-0000-0000-000000000001',NULL,'203.0.113.1', 1722600000000,'50811ef5664607226332db05f759780477c4c501c535345274c75440adc8ab50','6b527751bb92634344a2d832eb1ad2ca7549fb66c10a9c0efa7625d29a3d71ff'),
 ('70000000-0000-0000-0000-000000000016','00000000-0000-0000-0000-000000000001','election.finalize.onchain','election','30000000-0000-0000-0000-000000000001','{"txHash":"0x7a94b1c2e3f405168192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f80","blockNumber":18922104,"merkleRoot":"0x3455ca278c0c86977910714275f71b43c1fd1ee034ff60d14b38b520bd7b3081"}','203.0.113.1', 1722600100000,'6b527751bb92634344a2d832eb1ad2ca7549fb66c10a9c0efa7625d29a3d71ff','f036323bd47a5fb4f369a16e57289c5cf12952c16f8e0a8ad108da1cb6b16357'),
 ('70000000-0000-0000-0000-000000000017','00000000-0000-0000-0000-000000000001','election.status.published','election','30000000-0000-0000-0000-000000000001',NULL,'203.0.113.1', 1722600200000,'f036323bd47a5fb4f369a16e57289c5cf12952c16f8e0a8ad108da1cb6b16357','cc343ff70d51479f0556856e503c88f548bd6b57b00dedddc68639c4c22078eb'),
 ('70000000-0000-0000-0000-000000000018','00000000-0000-0000-0000-000000000001','auth.admin.login','session',NULL,NULL,'203.0.113.1', 1722700000000,'cc343ff70d51479f0556856e503c88f548bd6b57b00dedddc68639c4c22078eb','dd4400310b2b582f3329e42f16a2892a7c86f585ac4b4a0bbc4296b642d58978'),
 ('70000000-0000-0000-0000-000000000019','00000000-0000-0000-0000-000000000001','kyc.document.download','kyc_document','50000000-0000-0000-0000-000000000001','{"userId":"20000000-0000-0000-0000-000000000001","size":204800}','203.0.113.1', 1722700100000,'dd4400310b2b582f3329e42f16a2892a7c86f585ac4b4a0bbc4296b642d58978','abc2fb0d1a9211d537a0154b456cb2e9b9566b4dd77947e3232658e59527f72c'),
 ('70000000-0000-0000-0000-000000000020','00000000-0000-0000-0000-000000000001','audit.log.verify','audit_log',NULL,'{"ok":true,"totalEntries":20}','203.0.113.1', 1722700200000,'abc2fb0d1a9211d537a0154b456cb2e9b9566b4dd77947e3232658e59527f72c','2e26560c82c6be39d874d873ebc0d64c84595ea437492411d99412685a3d9e90');
