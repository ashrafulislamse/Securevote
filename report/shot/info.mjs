import { readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";

const dir = process.argv[2] || ".";
const files = readdirSync(dir).filter((f) => f.endsWith(".png"));
const out = {};
for (const f of files) {
  const header = readFileSync(join(dir, f));
  const w = header.readUInt32BE(16);
  const h = header.readUInt32BE(20);
  out[f] = { bytes: header.length, w, h };
}
console.log(JSON.stringify(out, null, 2));
