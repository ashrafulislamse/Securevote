"use client";

import Link from "next/link";
import { FormEvent, useState } from "react";

import { AuthBrandPanel } from "@/components/auth-brand-panel";
import { ThemeToggle } from "@/components/theme-toggle";
import { forgotPassword } from "@/lib/api-client";

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [status, setStatus] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!email.includes("@")) {
      setError("Enter a valid admin email.");
      setStatus(null);
      return;
    }
    setError(null);
    setStatus(null);
    setSubmitting(true);
    try {
      await forgotPassword(email);
      setStatus("If that email matches an admin account, a reset link has been sent. The link expires in 15 minutes.");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not request a reset link. Please try again.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main className="relative grid min-h-screen overflow-hidden lg:grid-cols-2">
      <div className="pointer-events-none absolute -left-24 top-16 h-[360px] w-[360px] rounded-full bg-[var(--primary)]/15 blur-[120px] animate-orb" />
      <div className="pointer-events-none absolute -right-20 top-[36%] h-[340px] w-[340px] rounded-full bg-[var(--secondary)]/12 blur-[110px] animate-orb-slow" />

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

      <section className="relative flex items-center justify-center px-6 py-12 pt-28 md:px-12">
        <Link href="/admin/login" className="absolute left-8 top-24 inline-flex items-center gap-2 text-sm text-[var(--text-muted)] transition hover:text-[var(--text-primary)]">
          <span className="material-symbols-outlined">arrow_left_alt</span>
          Back to Sign In
        </Link>

        <div className="w-full max-w-[430px] self-center">
          <div className="panel-elevated top-accent card-glow relative rounded-3xl p-7 reveal-up reveal-fast reveal-delay-1 sm:p-10">
            <div className="text-center">
              <div className="mx-auto mb-5 flex h-16 w-16 items-center justify-center rounded-full border border-[var(--border-brand)] bg-[var(--brand)]/12 shadow-[0_0_30px_rgba(79,110,247,0.25)]">
                <span className="material-symbols-outlined text-[28px] text-[var(--brand)]" style={{ fontVariationSettings: '"FILL" 1' }}>
                  mail
                </span>
              </div>
              <h1 className="text-3xl font-bold tracking-tight">
                Reset your <span className="text-gradient">password</span>
              </h1>
              <p className="mt-2 text-[var(--text-muted)]">Enter your admin email to receive reset instructions.</p>
              <p className="mx-auto mt-3 max-w-sm text-xs leading-relaxed text-[var(--text-muted)]">
                Recovery requests are logged and signed in the audit stream to preserve administrative accountability.
              </p>
            </div>

            <form className="mt-8 space-y-5" onSubmit={handleSubmit}>
              <div>
                <label className="mb-2 block text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Admin Email Address</label>
                <div className="relative">
                  <span className="material-symbols-outlined pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-[var(--text-muted)]">mail</span>
                  <input
                    type="email"
                    placeholder="admin@securevote.gov"
                    value={email}
                    onChange={(event) => setEmail(event.target.value)}
                    className="auth-input py-3.5 pl-12 pr-4 font-mono text-sm"
                  />
                </div>
              </div>
              <button type="submit" disabled={submitting} className="brand-gradient glow-brand w-full rounded-xl py-4 text-sm font-bold text-white transition hover:brightness-110 disabled:opacity-60">
                {submitting ? "Sending..." : "Send Reset Link"}
              </button>
            </form>

            {error ? (
              <p className="check-pop mt-5 flex items-center gap-2 rounded-lg border border-rose-500/30 bg-rose-500/10 px-3 py-2 text-xs text-rose-300">
                <span className="material-symbols-outlined text-sm">error</span>
                {error}
              </p>
            ) : null}

            {status ? (
              <div className="check-pop mt-5 rounded-xl border border-emerald-500/30 bg-emerald-500/10 p-4">
                <div className="flex items-start gap-3">
                  <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-emerald-500/15">
                    <span className="material-symbols-outlined text-emerald-300" style={{ fontVariationSettings: '"FILL" 1' }}>
                      check_circle
                    </span>
                  </div>
                  <div>
                    <p className="text-sm font-bold tracking-tight text-emerald-300">Reset link sent</p>
                    <p className="mt-1 text-sm leading-relaxed text-[var(--text-muted)]">{status}</p>
                  </div>
                </div>
              </div>
            ) : null}

            <div className="mt-6 flex items-center justify-center gap-2 rounded-xl border border-[var(--border-subtle)] bg-[var(--surface-low)] px-3 py-2.5">
              <span className="material-symbols-outlined text-sm text-[var(--teal)]">lock_clock</span>
              <span className="text-[11px] font-semibold uppercase tracking-[0.12em] text-[var(--text-muted)]">Reset links expire in 15 minutes</span>
            </div>
          </div>

          <p className="mt-6 text-center text-xs leading-relaxed text-[var(--text-muted)] reveal-up reveal-fast reveal-delay-2">
            If you still have trouble, contact the Department of Digital Integrity support desk.
          </p>
        </div>
      </section>
    </main>
  );
}