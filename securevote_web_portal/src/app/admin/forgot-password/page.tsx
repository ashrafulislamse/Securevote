"use client";

import Link from "next/link";
import { FormEvent, useState } from "react";

import { AuthBrandPanel } from "@/components/auth-brand-panel";
import { ThemeToggle } from "@/components/theme-toggle";
import { requestReset } from "@/lib/demo-auth";

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("admin@securevote.io");
  const [status, setStatus] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const result = requestReset(email);
    if (!result.ok) {
      setError(result.message);
      setStatus(null);
      return;
    }

    setError(null);
    setStatus(`Reset link sent to ${email}.`);
  }

  return (
    <main className="relative grid min-h-screen overflow-hidden lg:grid-cols-2">
      <div className="pointer-events-none absolute -left-24 top-16 h-[360px] w-[360px] rounded-full bg-[var(--primary)]/15 blur-[120px]" />
      <div className="pointer-events-none absolute -right-20 top-[36%] h-[340px] w-[340px] rounded-full bg-[var(--secondary)]/12 blur-[110px]" />
      <header className="fixed inset-x-0 top-0 z-30 border-b border-[var(--border-default)] bg-[var(--surface-overlay)] backdrop-blur-xl">
        <div className="mx-auto flex h-16 w-full max-w-7xl items-center justify-between px-5 md:px-8">
          <Link href="/" className="flex items-center gap-2 text-base font-extrabold tracking-tight">
            <span className="material-symbols-outlined text-[var(--primary)]">security</span>
            SecureVote
          </Link>
          <ThemeToggle />
          <nav className="hidden items-center gap-6 md:flex">
            <Link href="/" className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)] transition hover:text-[var(--text-primary)]">
              Home
            </Link>
            <Link href="/security" className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)] transition hover:text-[var(--text-primary)]">
              Security
            </Link>
            <Link href="/verifier" className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)] transition hover:text-[var(--text-primary)]">
              Verifier
            </Link>
          </nav>
          <Link href="/admin/login" className="brand-gradient rounded-lg px-3 py-1.5 text-[11px] font-bold uppercase tracking-[0.1em] text-white">
            Sign In
          </Link>
        </div>
      </header>

      <AuthBrandPanel
        title="The Sovereign Vault of Democracy"
        subtitle="Enterprise-grade encryption and biometric verification protocols ensuring every vote is immutable and every result is absolute."
        badge="Reset Integrity Mode"
      />

      <section className="relative flex items-center justify-center px-6 py-12 pt-24 md:px-12">
        <Link href="/admin/login" className="absolute left-8 top-24 inline-flex items-center gap-2 text-sm text-[var(--text-muted)] hover:text-white">
          <span className="material-symbols-outlined">arrow_left_alt</span>
          Back to Sign In
        </Link>

        <div className="w-full max-w-[430px] space-y-8">
          <div className="text-center reveal-up reveal-fast reveal-delay-1">
            <div className="mx-auto mb-5 flex h-16 w-16 items-center justify-center rounded-full bg-[var(--primary)]/15">
              <span className="material-symbols-outlined text-[28px] text-[var(--primary)]" style={{ fontVariationSettings: '"FILL" 1' }}>
                mail
              </span>
            </div>
            <h1 className="text-3xl font-bold tracking-tight">Reset your password</h1>
            <p className="mt-2 text-[var(--text-muted)]">Enter your admin email to receive reset instructions.</p>
            <p className="mx-auto mt-3 max-w-sm text-xs leading-relaxed text-white/55">
              Recovery requests are logged and signed in the audit stream to preserve administrative accountability.
            </p>
          </div>

          <form className="space-y-5 reveal-up reveal-fast reveal-delay-2" onSubmit={handleSubmit}>
            <div>
              <label className="mb-2 ml-1 block text-xs font-semibold uppercase tracking-[0.12em] text-[var(--text-muted)]">Admin Email Address</label>
              <input
                type="email"
                placeholder="admin@securevote.gov"
                value={email}
                onChange={(event) => setEmail(event.target.value)}
                className="w-full rounded-lg bg-[var(--surface-container-low)] px-5 py-4 font-mono text-sm outline-none ring-1 ring-transparent transition focus:ring-[var(--primary)]"
              />
            </div>
            <button type="submit" className="brand-gradient w-full rounded-lg py-4 font-semibold text-white shadow-[0_0_20px_rgba(79,110,247,0.3)] transition hover:brightness-110">
              Send Reset Link
            </button>
          </form>

          <div className="rounded-xl border border-emerald-500/25 bg-emerald-500/8 p-5 reveal-up reveal-fast reveal-delay-3">
            <div className="flex items-start gap-3">
              <div className="mt-0.5 flex h-8 w-8 items-center justify-center rounded-full bg-emerald-500/15">
                <span className="material-symbols-outlined text-emerald-400" style={{ fontVariationSettings: '"FILL" 1' }}>
                  check_circle
                </span>
              </div>
              <div>
                <p className="font-semibold">{status ? "Reset link sent!" : "Ready to send"}</p>
                <p className="mt-1 text-sm text-[var(--text-muted)]">
                  {status ?? "Submit an admin email to generate a secure reset request in demo mode."}{" "}
                  <button type="button" onClick={() => setStatus(`Reset link resent to ${email}.`)} className="font-semibold text-[var(--primary)] hover:underline">
                    Resend
                  </button>
                </p>
              </div>
            </div>
          </div>

          {error ? <p className="rounded-lg border border-rose-500/30 bg-rose-500/10 px-3 py-2 text-xs text-rose-300 reveal-up reveal-fast reveal-delay-3">{error}</p> : null}

          <div className="space-y-3 text-center reveal-up reveal-fast reveal-delay-3">
            <div className="inline-flex items-center gap-2 rounded-full bg-[var(--surface-container)] px-3 py-1.5 text-[10px] font-semibold uppercase tracking-[0.12em] text-[var(--text-muted)]">
              <span className="material-symbols-outlined text-sm">lock_clock</span>
              Reset links expire in 15 minutes
            </div>
            <p className="text-xs leading-relaxed text-white/50">
              If you still have trouble, contact the Department of Digital Integrity support desk.
            </p>
          </div>
        </div>
      </section>
    </main>
  );
}
