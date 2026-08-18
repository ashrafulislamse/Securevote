import puppeteer from "puppeteer-core";

const CHROME = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
const BASE = "https://securevote-web.founder-fb4.workers.dev";

const ACCESS =
  "eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6ImFkbWluQHNlY3VyZXZvdGUuaW8iLCJyb2xlIjoiYWRtaW4iLCJzdWIiOiIwMDAwMDAwMC0wMDAwLTAwMDAtMDAwMC0wMDAwMDAwMDAwMDEiLCJqdGkiOiI0MzE3YmE5NC00MmU5LTQ1NzYtODc0NS1jNzAyNWE3ODEzYmYiLCJpYXQiOjE3ODY3MDg0MjIsImV4cCI6MTc4Njc5NDgyMn0.ah5jwYYruEODHFsW7ubCBdR933ekDh_IVPwVRr4gzcw";
const REFRESH =
  "eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6ImFkbWluQHNlY3VyZXZvdGUuaW8iLCJyb2xlIjoiYWRtaW4iLCJ0eXBlIjoicmVmcmVzaCIsInN1YiI6IjAwMDAwMDAwLTAwMDAtMDAwMC0wMDAwMDAwMDAwMDAwMSIsImp0aSI6IjEwOTVmYzNkLTcxZGYtNGNlMi05MzgzLWE3MTZjNTcxZjViZCIsImlhdCI6MTc4NjcwODQyMiwiZXhwIjoxNzg5MzAwNDIyfQ._OLIpeec6I5v2mz7jF-EMJkQ3KMxEex2D-0K_uJIXtc";

const targets = process.argv.slice(2);

async function shot(page, url, out, opts = {}) {
  await page.goto(url, { waitUntil: "networkidle2", timeout: 45000 });
  await new Promise((r) => setTimeout(r, 1600));
  await page.screenshot({ path: out, fullPage: opts.fullPage ?? false });
  console.log("SAVED", out, "from", url);
}

const browser = await puppeteer.launch({
  executablePath: CHROME,
  headless: "new",
  args: ["--window-size=1600,1000", "--force-device-scale-factor=1", "--hide-scrollbars"],
  defaultViewport: { width: 1600, height: 960, deviceScaleFactor: 1 },
  args: [
    "--window-size=1600,1000",
    "--force-device-scale-factor=1",
    "--hide-scrollbars",
    "--disable-overlay-scrollbar",
    "--hide-crash-restore-bubble",
  ],
});
const page = await browser.newPage();

// Seed admin session + light theme
await page.goto(BASE + "/", { waitUntil: "domcontentloaded", timeout: 45000 }).catch(() => {});
await page.evaluate(
  (a, r) => {
    localStorage.setItem("sv-theme", "light");
    localStorage.setItem("securevote_access_token", a);
    localStorage.setItem("securevote_refresh_token", r);
    document.documentElement.setAttribute("data-theme", "light");
  },
  ACCESS,
  REFRESH,
);

const D = "E:\\SecureVote\\report\\shot";

for (const t of targets) {
  switch (t) {
    case "dash":
      await shot(page, BASE + "/admin/dashboard", D + "\\dash.png");
      break;
    case "kyc":
      await shot(page, BASE + "/admin/voters/kyc-verification", D + "\\kyc.png");
      break;
    case "audit":
      await shot(page, BASE + "/admin/audit-log", D + "\\audit.png");
      break;
    case "verifier":
      await page.goto(BASE + "/verifier", { waitUntil: "networkidle2", timeout: 45000 });
      await new Promise((r) => setTimeout(r, 1400));
      // Fill a real seeded receipt and trigger verification so the result card renders.
      try {
        await page.evaluate(() => {
          const input = document.querySelector('input');
          if (input) {
            const setter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
            setter.call(input, 'SV-A2DC-1C8D-C333-7DCB');
            input.dispatchEvent(new Event('input', { bubbles: true }));
          }
        });
        // Click the Verify button
        await page.evaluate(() => {
          const btn = Array.from(document.querySelectorAll('button')).find(
            (b) => b.textContent.includes('Verify') && !b.textContent.includes('Verifying'),
          );
          if (btn) btn.click();
        });
        await new Promise((r) => setTimeout(r, 2600));
        const hasResult = await page.evaluate(() =>
          document.body.innerText.includes("Vote verified successfully"),
        );
        console.log("verifier result rendered:", hasResult);
      } catch (e) {
        console.log("verifier interaction skipped:", e.message);
      }
      await page.screenshot({ path: D + "\\verifier.png" });
      console.log("SAVED", D + "\\verifier.png");
      break;
    case "login":
      await shot(page, BASE + "/admin/login", D + "\\login.png");
      break;
  }
}

await browser.close();
console.log("DONE");
