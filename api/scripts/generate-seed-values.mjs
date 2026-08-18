// Generates cryptographically-consistent values for the demo seed SQL:
//   1. Merkle root + per-vote proofs for the 5 leaves of election A
//   2. The audit-log hash chain (real SHA-256 entry_hash / prev_hash)
// Uses node:crypto (SHA-256 only — D1-safe, deterministic, matches app logic).
import { createHash } from "node:crypto";

const sha256 = (s) => createHash("sha256").update(s).digest("hex");

// ---------------------------------------------------------------------------
// 1) Merkle tree (same algorithm as api/src/lib/merkle.ts):
//    normalize to "0x"+64 hex, SORT, pair-concat->sha256, odd node promoted.
// ---------------------------------------------------------------------------
const LEAVES = [
  "0x9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08",
  "0x60303ae22b998861bce3b28f33e6f8e1c0d8e0b2f7c6a9d4f1e2d3c4b5a69708",
  "0x6b86b273ff34fce19d6b804eff5a3f5747ada4eaa22f1d49c01e52ddb7875b4b",
  "0xd4735e3a265e16eee03f59718b9b5d03019c07d8b6c51f90da3a666eec13ab35",
  "0x2e7d2c03a9507ae265ecf5b5356885a53393a2029d241394997265a1d25e261d",
];

const norm = (h) => (h.startsWith("0x") ? h.slice(2) : h).toLowerCase();
const withP = (h) => "0x" + h;
const hashPair = (a, b) => withP(sha256(norm(a) + norm(b)));

function merkleTree(hexHashes) {
  const proofs = {};
  let level = hexHashes.map(norm).map(withP).sort();
  for (const leaf of level) proofs[leaf] = [];
  while (level.length > 1) {
    const next = [];
    for (let i = 0; i < level.length; i += 2) {
      if (i + 1 < level.length) {
        const left = level[i], right = level[i + 1];
        const parent = hashPair(left, right);
        proofs[parent] = [];
        proofs[left].push(right);
        proofs[right].push(left);
        next.push(parent);
      } else {
        next.push(level[i]); // promote odd
      }
    }
    level = next;
  }
  return { root: level[0], proofs };
}

const { root, proofs } = merkleTree(LEAVES);
console.log("MERKLE ROOT:", root);
LEAVES.forEach((l, i) => {
  console.log(`PROOF leaf${i + 1} (${l}):`, JSON.stringify(proofs["0x" + norm(l)]));
});

// ---------------------------------------------------------------------------
// 2) Audit hash chain — replicate api/src/middleware/audit.ts exactly.
//    serialize = [prev, action, actor, targetType, targetId, metadata, ip,
//                 String(createdAt)].join("|"); entry = sha256hex(serialize).
// ---------------------------------------------------------------------------
const ser = (p) =>
  [p.prevHash, p.action, p.actorId ?? "", p.targetType ?? "", p.targetId ?? "",
   p.metadata ?? "", p.ip ?? "", String(p.createdAt)].join("|");
const hashOf = (p) => sha256(ser({ prevHash: p.prev, action: p.action, actorId: p.actor, targetType: p.tt, targetId: p.tid, metadata: p.md, ip: p.ip, createdAt: p.ts }));

const first = "genesis";
// action, actor, tt, tid, md, ip, ts   (in ascending chain order)
const rows = [
  ["election.create","00000000-0000-0000-0000-000000000001","election","30000000-0000-0000-0000-000000000001","{\"title\":\"Student Council Election 2026\"}","203.0.113.1",1717000000000],
  ["election.status.scheduled","00000000-0000-0000-0000-000000000001","election","30000000-0000-0000-0000-000000000001",null,"203.0.113.1",1717100000000],
  ["election.status.active","00000000-0000-0000-0000-000000000001","election","30000000-0000-0000-0000-000000000001",null,"203.0.113.1",1717150000000],
  ["kyc.submit","20000000-0000-0000-0000-000000000001","kyc_document","50000000-0000-0000-0000-000000000001",null,"203.0.113.10",1717201000000],
  ["kyc.approve","00000000-0000-0000-0000-000000000001","kyc_document","50000000-0000-0000-0000-000000000001","{\"userId\":\"20000000-0000-0000-0000-000000000001\"}","203.0.113.1",1717201800000],
  ["kyc.submit","20000000-0000-0000-0000-000000000002","kyc_document","50000000-0000-0000-0000-000000000003",null,"203.0.113.11",1717202000000],
  ["kyc.approve","00000000-0000-0000-0000-000000000001","kyc_document","50000000-0000-0000-0000-000000000003","{\"userId\":\"20000000-0000-0000-0000-000000000002\"}","203.0.113.1",1717202800000],
  ["kyc.submit","20000000-0000-0000-0000-000000000003","kyc_document","50000000-0000-0000-0000-000000000004",null,"203.0.113.12",1717203000000],
  ["kyc.approve","00000000-0000-0000-0000-000000000001","kyc_document","50000000-0000-0000-0000-000000000004","{\"userId\":\"20000000-0000-0000-0000-000000000003\"}","203.0.113.1",1717203800000],
  ["vote.cast","20000000-0000-0000-0000-000000000001","election","30000000-0000-0000-0000-000000000001","{\"receiptId\":\"SV-A2DC-1C8D-C333-7DCB\"}","203.0.113.10",1718000000000],
  ["vote.cast","20000000-0000-0000-0000-000000000002","election","30000000-0000-0000-0000-000000000001","{\"receiptId\":\"SV-B3ED-2D9E-D444-8ECD\"}","203.0.113.11",1718003600000],
  ["vote.cast","20000000-0000-0000-0000-000000000003","election","30000000-0000-0000-0000-000000000001","{\"receiptId\":\"SV-C4FE-3EAF-E555-9FDE\"}","203.0.113.12",1718007200000],
  ["vote.cast","20000000-0000-0000-0000-000000000004","election","30000000-0000-0000-0000-000000000001","{\"receiptId\":\"SV-D5FF-4FBF-F666-AEEF\"}","203.0.113.13",1718010800000],
  ["vote.cast","20000000-0000-0000-0000-000000000005","election","30000000-0000-0000-0000-000000000001","{\"receiptId\":\"SV-E600-5FC0-0777-BFF0\"}","203.0.113.14",1718014400000],
  ["election.status.closed","00000000-0000-0000-0000-000000000001","election","30000000-0000-0000-0000-000000000001",null,"203.0.113.1",1722600000000],
  ["election.finalize.onchain","00000000-0000-0000-0000-000000000001","election","30000000-0000-0000-0000-000000000001",`{"txHash":"0x7a94b1c2e3f405168192a3b4c5d6e7f8091a2b3c4d5e6f708192a3b4c5d6e7f80","blockNumber":18922104,"merkleRoot":"${root}"}`,"203.0.113.1",1722600100000],
  ["election.status.published","00000000-0000-0000-0000-000000000001","election","30000000-0000-0000-0000-000000000001",null,"203.0.113.1",1722600200000],
  ["auth.admin.login","00000000-0000-0000-0000-000000000001","session",null,null,"203.0.113.1",1722700000000],
  ["kyc.document.download","00000000-0000-0000-0000-000000000001","kyc_document","50000000-0000-0000-0000-000000000001","{\"userId\":\"20000000-0000-0000-0000-000000000001\",\"size\":204800}","203.0.113.1",1722700100000],
  ["audit.log.verify","00000000-0000-0000-0000-000000000001","audit_log",null,"{\"ok\":true,\"totalEntries\":20}","203.0.113.1",1722700200000],
];

let prev = first;
const out = [];
rows.forEach(([action,actor,tt,tid,md,ip,ts], i) => {
  const entry = hashOf({ prev, action, actor, tt, tid, md, ip, ts });
  out.push({ action, actor, tt, tid, md, ip, ts, prev, entry });
  prev = entry;
});

console.log("\nAUDIT CHAIN:");
out.forEach((r) => {
  console.log(`INSERT into audit_log VALUES '${r.prev}' hash='${r.entry}' action='${r.action}' ts=${r.ts}`);
});
