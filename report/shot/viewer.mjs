import { readFileSync, writeFileSync } from "node:fs";

// Embed tiny base64 data-URI HTML viewer so I can render them via the open browser page.
const names = ["dash.png", "kyc.png", "audit.png", "verifier.png", "login.png"];
const rows = names
  .map((n) => {
    const b = readFileSync(n).toString("base64");
    return `<figure><figcaption>${n}</figcaption><img src="data:image/png;base64,${b}" width="1100"/></figure>`;
  })
  .join("\n");
const html = `<!doctype html><meta charset="utf-8"><body style="background:#12151f;padding:24px;font-family:sans-serif">
<h2 style="color:#fff">Web screenshots</h2>${rows}</body>`;
writeFileSync("viewer.html", html);
console.log("wrote viewer.html", html.length);
