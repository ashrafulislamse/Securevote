import puppeteer from "puppeteer-core";
const CHROME = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
const url = "https://securevote-web.founder-fb4.workers.dev/verifier";
const b = await puppeteer.launch({ executablePath: CHROME, headless: "new" });
const p = await b.newPage();
await p.setViewport({ width: 1600, height: 960, deviceScaleFactor: 1 });
await p.goto(url, { waitUntil: "networkidle2", timeout: 45000 });
await new Promise((r) => setTimeout(r, 1400));
await p.evaluate(() => {
  const input = document.querySelector('input');
  if (input) {
    const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    setter.call(input, 'SV-A2DC-1C8D-C333-7DCB');
    input.dispatchEvent(new Event('input', { bubbles: true }));
  }
});
await p.evaluate(() => {
  const btn = Array.from(document.querySelectorAll('button')).find(
    (b) => b.textContent.includes('Verify') && !b.textContent.includes('Verifying'),
  );
  if (btn) btn.click();
});
await new Promise((r) => setTimeout(r, 3000));
const txt = await p.evaluate(() => document.body.innerText.slice(0, 1500));
console.log(txt);
await b.close();
