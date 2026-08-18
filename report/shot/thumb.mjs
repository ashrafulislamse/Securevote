import puppeteer from "puppeteer-core";
import { readFileSync, writeFileSync } from "node:fs";

const CHROME = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
const src = process.argv[2];
const out = process.argv[3];

const b64 = readFileSync(src).toString("base64");
const html = `<!doctype html><body style="margin:0"><img src="data:image/png;base64,${b64}" style="width:1200px;height:auto"/></body>`;
const browser = await puppeteer.launch({ executablePath: CHROME, headless: "new" });
const page = await browser.newPage();
await page.setViewport({ width: 1200, height: 720, deviceScaleFactor: 1 });
await page.setContent(html, { waitUntil: "networkidle0" });
const el = await page.$("img");
await el.screenshot({ path: out });
await browser.close();
console.log("ok", out);
