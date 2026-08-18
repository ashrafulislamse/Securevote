"use client";

import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { FormEvent, Suspense, useMemo, useState } from "react";

import { AuthBrandPanel } from "@/components/auth-brand-panel";
import { ThemeToggle } from "@/components/theme-toggle";
import { resetPassword } from "@/lib/api-client";

const STRENGTH_LABELS = ["Very Weak", "Weak", "Medium", "Strong", "Excellent"] as const;
const STRENGTH_COLORS = ["bg-rose-400", "bg-rose-400", "bg-amber-400", "bg-emerald-400", "bg-[var(--teal)]"];

export default function ResetPasswordPage() {
  return (
    <Suspense fallback={null}>
      <ResetPasswordContent />
    </Suspense>
  );
}

function ResetPasswordContent() {
  const searchParams = useSearchParams();
  const token = searchParams.get("token") ?? "";
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [status, setStatus] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const strength = useMemo(() => {
    let score = 0;
    if (password.length >= 10) score += 1;
    if (/[A-Z]/.test(password) && /[a-z]/.test(password)) score += 1;
    if (/[0-9]/.test(password)) score += 1;
    if (/[^A-Za-z0-9]/.test(password)) score += 1;
    return score;
  }, [password]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!token) {
      setError("Reset link is missing a token. Use the link from your reset email.");
      setStatus(null);
      return;
    }
    if (password.length < 8) {
      setError("Password must be at least 8 characters and include upper, lower, and a digit.");
      setStatus(null);
      return;
    }
    if (password !== confirmPassword) {
      setError("Passwords do not match.");
      setStatus(null);
      return;
    }
    setSubmitting(true);
    setError(null);
    try {
      await resetPassword(token, password);
      setStatus("Your password has been reset. All other sessions were signed out — please log in again.");
      setPassword("");
      setConfirmPassword("");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to reset password. The link may have expired.");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main className="relative grid min-h-screen overflow-hidden lg:grid-cols-2">
      <div className="pointer-events-none absolute -left-20 top-20 h-[360px] w-[360px] rounded-full bg-[var(--primary)]/15 blur-[120px] animate-orb" />
      <div className="pointer-events-none absolute -right-24 top-[40%] h-[360px] w-[360px] rounded-full bg-[var(--tertiary)]/12 blur-[115px] animate-orb-slow" />

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
        title="Reinforce your digital sovereignty"
        subtitle="Update your credentials to maintain encrypted access to the SecureVote governance infrastructure."
      />

      <section className="flex items-center justify-center px-6 py-12 pt-28 lg:px-16">
        <div className="w-full max-w-[470px] self-center space-y-6">
          <div className="panel-elevated top-accent card-glow relative rounded-3xl p-7 reveal-up reveal-fast reveal-delay-1 sm:p-9">
            <div className="text-center">
              <div className="brand-gradient mx-auto mb-5 flex h-16 w-16 items-center justify-center rounded-2xl shadow-[0_0_30px_rgba(79,110,247,0.4)]">
                <span className="material-symbols-outlined text-3xl text-white" style={{ fontVariationSettings: '"FILL" 1' }}>
                  lock_reset
                </span>
              </div>
              <h1 className="text-3xl font-bold tracking-tight">
                Create new <span className="text-gradient">password</span>
              </h1>
              <p className="mt-2 text-[var(--text-muted)]">Your new password must be different from previously used passwords.</p>
              <p className="mx-auto mt-3 max-w-sm text-xs leading-relaxed text-white/55">
                Password changes are recorded and tied to session risk telemetry for post-event investigation.
              </p>
            </div>

            <div className="glass-panel ghost-border mt-6 flex items-center gap-3 rounded-xl px-4 py-3">
              <span className="material-symbols-outlined text-[var(--tertiary)]">schedule</span>
              <span className="text-sm font-medium text-[var(--tertiary)]">Reset link valid for 12 more minutes</span>
            </div>

            <form className="mt-6 space-y-5" onSubmit={handleSubmit}>
              <Field
                label="New Password"
                placeholder="Enter your new password"
                value={password}
                onChange={setPassword}
                showPassword={showPassword}
                onTogglePassword={() => setShowPassword((previous) => !previous)}
              />

              <div className="space-y-2">
                <div className="flex items-center justify-between text-xs">
                  <span className="font-semibold uppercase tracking-[0.11em] text-[var(--text-muted)]">Password Strength</span>
                  <span className={`font-bold ${strength >= 3 ? "text-emerald-400" : strength == 2 ? "text-amber-400" : "text-rose-400"}`}>
                    {STRENGTH_LABELS[strength]}
                  </span>
                </div>
                <div className="grid h-1.5 grid-cols-4 gap-2">
                  {Array.from({ length: 4 }).map((_, idx) => (
                    <span
                      key={idx}
                      className={`rounded-full transition-all duration-300 ${idx < strength ? STRENGTH_COLORS[strength] : "bg-white/15"}`}
                    />
                  ))}
                </div>
              </div>

              <div className="border border-[var(--border-subtle)] rounded-xl bg-[var(--surface-low)] p-5">
                <p className="mb-3 text-xs font-semibold uppercase tracking-[0.11em] text-[var(--text-muted)]">Requirements</p>
                <ul className="space-y-2 text-sm">
                  <ReqItem ok={password.length >= 10} text="At least 10 characters" />
                  <ReqItem ok={/[A-Z]/.test(password) && /[a-z]/.test(password)} text="Uppercase and lowercase letters" />
                  <ReqItem ok={/[0-9]/.test(password)} text="At least one number" />
                  <ReqItem ok={/[^A-Za-z0-9]/.test(password)} text="At least one special character" />
                </ul>
              </div>

              <Field
                label="Confirm Password"
                placeholder="Confirm your new password"
                value={confirmPassword}
                onChange={setConfirmPassword}
                trailing={confirmPassword && confirmPassword === password ? "MATCH" : ""}
                showPassword={showPassword}
                onTogglePassword={() => setShowPassword((previous) => !previous)}
              />

              <label className="flex items-center justify-between py-1">
                <span className="text-sm">Sign out all other devices</span>
                <span className="relative h-5 w-10 rounded-full bg-[var(--surface-container-high)]">
                  <span className="absolute right-1 top-1 h-3 w-3 rounded-full bg-[var(--primary)]" />
                </span>
              </label>

              {error ? (
                <p className="check-pop flex items-center gap-2 rounded-lg border border-rose-500/30 bg-rose-500/10 px-3 py-2 text-xs text-rose-300">
                  <span className="material-symbols-outlined text-sm">error</span>
                  {error}
                </p>
              ) : null}

              {status ? (
                <div className="check-pop rounded-xl border border-emerald-500/30 bg-emerald-500/10 p-4">
                  <div className="flex items-start gap-3">
                    <div className="flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-emerald-500/15">
                      <span className="material-symbols-outlined text-emerald-300" style={{ fontVariationSettings: '"FILL" 1' }}>
                        check_circle
                      </span>
                    </div>
                    <div>
                      <p className="text-sm font-bold tracking-tight text-emerald-300">Password reset</p>
                      <p className="text-sm leading-relaxed text-[var(--text-muted)]">{status}</p>
                    </div>
                  </div>
                </div>
              ) : null}

              <button type="submit" disabled={submitting} className="brand-gradient glow-brand w-full rounded-xl py-4 text-sm font-bold text-white transition hover:brightness-110 disabled:opacity-50">
                {submitting ? "Resetting..." : "Update Password"}
              </button>
            </form>
          </div>

          <div className="pt-1 text-center reveal-up reveal-fast reveal-delay-2">
            <Link href="/admin/login" className="inline-flex items-center gap-2 text-sm text-[var(--text-muted)] transition hover:text-[var(--primary)]">
              <span className="material-symbols-outlined text-sm">arrow_back</span>
              Back to Login
            </Link>
          </div>
        </div>
      </section>
    </main>
  );
}

function Field({
  label,
  placeholder,
  value,
  onChange,
  trailing,
  showPassword,
  onTogglePassword,
}: {
  label: string;
  placeholder: string;
  value: string;
  onChange: (next: string) => void;
  trailing?: string;
  showPassword: boolean;
  onTogglePassword: () => void;
}) {
  return (
    <div>
      <label className="mb-2 block text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">{label}</label>
      <div className="relative">
        <span className="material-symbols-outlined pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-[var(--text-muted)]">key</span>
        <input
          type={showPassword ? "text" : "password"}
          placeholder={placeholder}
          value={value}
          onChange={(event) => onChange(event.target.value)}
          className="auth-input py-3.5 pl-12 pr-20 text-sm"
        />
        {trailing ? (
          <span className="check-pop absolute right-3 top-1/2 -translate-y-1/2 text-[10px] font-bold uppercase tracking-[0.08em] text-emerald-400">{trailing}</span>
        ) : (
          <button type="button" onClick={onTogglePassword} className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--text-muted)] transition hover:text-[var(--text-primary)]">
            <span className="material-symbols-outlined text-base">{showPassword ? "visibility_off" : "visibility"}</span>
          </button>
        )}
      </div>
    </div>
  );
}

function ReqItem({ ok = false, text }: { ok?: boolean; text: string }) {
  return (
    <li className="flex items-center gap-2 text-[var(--text-muted)]">
      <span
        className={`material-symbols-outlined text-sm transition-colors ${ok ? "text-emerald-400" : "text-white/35"}`}
        style={{ fontVariationSettings: ok ? '"FILL" 1' : undefined }}
      >
        {ok ? "check_circle" : "circle"}
      </span>
      <span className={ok ? "text-[var(--text-primary)]" : undefined}>{text}</span>
    </li>
  );
}