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
      <div className="pointer-events-none absolute -left-20 top-16 h-[380px] w-[380px] rounded-full bg-[var(--primary)]/15 blur-[120px]" />
      <div className="pointer-events-none absolute -right-20 top-[35%] h-[360px] w-[360px] rounded-full bg-[var(--secondary)]/12 blur-[110px]" />
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

      <section className="flex w-full justify-center bg-background px-6 py-12 pt-24 lg:w-1/2 lg:px-24">
        <div className="w-full max-w-[460px] self-center reveal-up reveal-fast reveal-delay-1">
          <div className="mb-9">
            <h2 className="text-3xl font-bold tracking-tight">Welcome back</h2>
            <p className="mt-2 text-sm text-[var(--text-muted)]">Sign in to your admin account to manage operations.</p>
            <p className="mt-3 max-w-md text-xs leading-relaxed text-white/55">
              Operator sign-in activity is continuously monitored and tied to immutable audit trails.
            </p>
          </div>

          <form className="space-y-6 reveal-up reveal-fast reveal-delay-2" onSubmit={handleLogin}>
            <div>
              <label className="mb-2 block text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Email Address</label>
              <div className="relative">
                <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-[var(--text-muted)]">mail</span>
                <input
                  type="email"
                  placeholder="admin@securevote.io"
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                  className="w-full rounded-xl bg-[var(--surface-container-low)] py-3.5 pl-12 pr-4 text-sm outline-none ring-1 ring-transparent transition focus:ring-[var(--primary)]"
                />
              </div>
            </div>

            <div>
              <div className="mb-2 flex items-center justify-between">
                <label className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Password</label>
                <Link href="/admin/forgot-password" className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--primary)] hover:text-[var(--secondary)]">
                  Forgot password?
                </Link>
              </div>
              <div className="relative">
                <span className="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-[var(--text-muted)]">lock</span>
                <input
                  type={showPassword ? "text" : "password"}
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                  className="w-full rounded-xl bg-[var(--surface-container-low)] py-3.5 pl-12 pr-12 text-sm outline-none ring-1 ring-transparent transition focus:ring-[var(--primary)]"
                />
                <button type="button" onClick={() => setShowPassword((previous) => !previous)} className="absolute right-4 top-1/2 -translate-y-1/2 text-[var(--text-muted)]">
                  <span className="material-symbols-outlined">{showPassword ? "visibility" : "visibility_off"}</span>
                </button>
              </div>
            </div>

            {error ? <p className="rounded-lg border border-rose-500/30 bg-rose-500/10 px-3 py-2 text-xs text-rose-300">{error}</p> : null}

            <div className="space-y-4">
              <label className="flex items-center gap-3 text-xs text-[var(--text-muted)]">
                <span className="relative h-5 w-9 rounded-full bg-[var(--surface-container-high)]">
                  <span className="absolute left-1 top-1 h-3 w-3 rounded-full bg-[var(--text-muted)]" />
                </span>
                Remember this device for 30 days
              </label>
              <button type="submit" disabled={loading} className="brand-gradient w-full rounded-xl py-4 text-sm font-bold text-white shadow-[0_0_20px_rgba(79,110,247,0.3)] transition hover:brightness-110 disabled:cursor-not-allowed disabled:opacity-60">
                {loading ? "Signing In..." : "Sign In to Portal"}
              </button>
            </div>
          </form>

          <p className="mt-10 text-center text-[10px] leading-relaxed text-white/45 reveal-up reveal-fast reveal-delay-3">
            Protected by enterprise-grade security. By continuing, you agree to SecureVote system terms and data integrity protocols.
          </p>
          <p className="mt-3 text-center text-[11px] text-[var(--text-muted)] reveal-up reveal-fast reveal-delay-3">
            Demo: <span className="font-mono">admin@securevote.io</span> / <span className="font-mono">SecureVote@2026</span>
          </p>
        </div>
      </section>
    </main>
  );
}
