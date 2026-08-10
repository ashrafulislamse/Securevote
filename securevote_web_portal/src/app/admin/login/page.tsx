"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { FormEvent, useState } from "react";

import { AuthBrandPanel } from "@/components/auth-brand-panel";
import { ThemeToggle } from "@/components/theme-toggle";
import { useAuth } from "@/context/auth-context";

// Pre-filled with the real seeded admin account for convenience.
const DEFAULT_ADMIN_EMAIL = "admin@securevote.io";
const DEFAULT_ADMIN_PASSWORD = "SecureVote@2026";

export default function AdminLoginPage() {
  const router = useRouter();
  const { login } = useAuth();
  const [email, setEmail] = useState(DEFAULT_ADMIN_EMAIL);
  const [password, setPassword] = useState(DEFAULT_ADMIN_PASSWORD);
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleLogin(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setLoading(true);
    setError(null);

    try {
      await login(email, password);
      router.push("/admin/dashboard");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Sign in failed.");
      setLoading(false);
    }
  }

  return (
    <main className="relative flex min-h-screen w-full overflow-hidden">
      <div className="pointer-events-none absolute -left-20 top-16 h-[380px] w-[380px] rounded-full bg-[var(--primary)]/15 blur-[120px] animate-orb" />
      <div className="pointer-events-none absolute -right-20 top-[35%] h-[360px] w-[360px] rounded-full bg-[var(--secondary)]/12 blur-[110px] animate-orb-slow" />

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
          <Link href="/verifier" className="rounded-lg border border-[var(--border-default)] bg-[var(--surface-high)] px-3 py-1.5 text-[11px] font-bold uppercase tracking-[0.1em] text-[var(--text-primary)] transition hover:bg-[var(--surface-highest)]">
            Verify Vote
          </Link>
        </div>
      </header>

      <AuthBrandPanel
        title="The Sovereign Vault for Electoral Operations"
        subtitle="Sign in to your admin command center and orchestrate secure, transparent elections with institutional-grade confidence."
      />

      <section className="flex w-full justify-center px-6 py-12 pt-28 lg:w-1/2 lg:px-16">
        <div className="w-full max-w-[440px] self-center">
          <div className="panel-elevated top-accent card-glow relative rounded-3xl p-7 reveal-up reveal-fast reveal-delay-1 sm:p-10">
            <div className="mb-8">
              <div className="mb-5 inline-flex items-center gap-2 rounded-full border border-[var(--border-brand)] bg-[var(--brand)]/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-[var(--brand)]">
                <span className="status-dot inline-block h-1.5 w-1.5 rounded-full bg-emerald-400" />
                Secure Admin Portal
              </div>
              <h2 className="text-[2rem] font-bold leading-tight tracking-tight">
                Welcome <span className="text-gradient">back</span>
              </h2>
              <p className="mt-2 text-sm text-[var(--text-muted)]">Sign in to your admin account to manage operations.</p>
              <p className="mt-3 max-w-md text-xs leading-relaxed text-white/55">
                Operator sign-in activity is continuously monitored and tied to immutable audit trails.
              </p>
            </div>

            <form className="space-y-5" onSubmit={handleLogin}>
              <div>
                <label className="mb-2 block text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Email Address</label>
                <div className="relative">
                  <span className="material-symbols-outlined pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-[var(--text-muted)]">mail</span>
                  <input
                    type="email"
                    placeholder="admin@securevote.io"
                    value={email}
                    onChange={(event) => setEmail(event.target.value)}
                    className="auth-input py-3.5 pl-12 pr-4 text-sm"
                  />
                </div>
              </div>

              <div>
                <div className="mb-2 flex items-center justify-between">
                  <label className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Password</label>
                  <Link href="/admin/forgot-password" className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--primary)] transition hover:text-[var(--secondary)]">
                    Forgot password?
                  </Link>
                </div>
                <div className="relative">
                  <span className="material-symbols-outlined pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-[var(--text-muted)]">lock</span>
                  <input
                    type={showPassword ? "text" : "password"}
                    value={password}
                    onChange={(event) => setPassword(event.target.value)}
                    className="auth-input py-3.5 pl-12 pr-12 text-sm"
                  />
                  <button type="button" onClick={() => setShowPassword((previous) => !previous)} className="absolute right-4 top-1/2 -translate-y-1/2 text-[var(--text-muted)] transition hover:text-[var(--text-primary)]">
                    <span className="material-symbols-outlined">{showPassword ? "visibility" : "visibility_off"}</span>
                  </button>
                </div>
              </div>

              {error ? (
                <p className="check-pop flex items-center gap-2 rounded-lg border border-rose-500/30 bg-rose-500/10 px-3 py-2 text-xs text-rose-300">
                  <span className="material-symbols-outlined text-sm">error</span>
                  {error}
                </p>
              ) : null}

              <button type="submit" disabled={loading} className="brand-gradient glow-brand w-full rounded-xl py-4 text-sm font-bold text-white transition hover:brightness-110 disabled:cursor-not-allowed disabled:opacity-60">
                {loading ? (
                  <span className="inline-flex items-center justify-center gap-2">
                    <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/30 border-t-white" />
                    Signing In...
                  </span>
                ) : (
                  "Sign In to Portal"
                )}
              </button>
            </form>

            <div className="mt-6 flex flex-wrap items-center justify-center gap-x-4 gap-y-2 border-t border-[var(--border-subtle)] pt-5 text-[10px] font-medium uppercase tracking-[0.1em] text-[var(--text-muted)]">
              <span className="inline-flex items-center gap-1.5">
                <span className="material-symbols-outlined text-sm text-emerald-400">lock</span>
                256-bit Encryption
              </span>
              <span className="inline-flex items-center gap-1.5">
                <span className="material-symbols-outlined text-sm text-[var(--teal)]">shield_lock</span>
                Session Protected
              </span>
              <span className="inline-flex items-center gap-1.5">
                <span className="material-symbols-outlined text-sm text-[var(--purple)]">receipt_long</span>
                Audit-logged
              </span>
            </div>
          </div>

          <p className="mt-8 text-center text-[10px] leading-relaxed text-white/45 reveal-up reveal-fast reveal-delay-2">
            Protected by enterprise-grade security. By continuing, you agree to SecureVote system terms and data integrity protocols.
          </p>
          <p className="mt-3 flex items-center justify-center gap-2 text-[11px] text-[var(--text-muted)] reveal-up reveal-fast reveal-delay-3">
            <span>Demo credentials</span>
            <span className="glass-panel ghost-border inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 font-mono text-[11px] text-[var(--text-primary)]">
              admin@securevote.io
            </span>
            <span className="text-white/40">/</span>
            <span className="glass-panel ghost-border inline-flex items-center rounded-full px-2.5 py-1 font-mono text-[11px] text-[var(--text-primary)]">
              SecureVote@2026
            </span>
          </p>
        </div>
      </section>
    </main>
  );
}