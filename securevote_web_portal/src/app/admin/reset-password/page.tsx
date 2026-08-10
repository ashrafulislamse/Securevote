"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { FormEvent, useMemo, useState } from "react";

import { AuthBrandPanel } from "@/components/auth-brand-panel";
import { ThemeToggle } from "@/components/theme-toggle";

export default function ResetPasswordPage() {
  const router = useRouter();
  const [password, setPassword] = useState("SecureVote@2026");
  const [confirmPassword, setConfirmPassword] = useState("SecureVote@2026");
  const [showPassword, setShowPassword] = useState(false);
  const [status, setStatus] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const strength = useMemo(() => {
    let score = 0;
    if (password.length >= 10) score += 1;
    if (/[A-Z]/.test(password) && /[a-z]/.test(password)) score += 1;
    if (/[0-9]/.test(password)) score += 1;
    if (/[^A-Za-z0-9]/.test(password)) score += 1;
    return score;
  }, [password]);

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (password.length < 10) {
      setError("Password must be at least 10 characters.");
      setStatus(null);
      return;
    }
    if (password !== confirmPassword) {
      setError("Passwords do not match.");
      setStatus(null);
      return;
    }
    // TODO: forgot-password endpoint — password reset is not yet implemented
    // on the backend. Show a clear notice instead of faking a reset.
    setError(null);
    setStatus("Password reset is not yet available. Contact your administrator to reset your account.");
  }

  return (
    <main className="relative grid min-h-screen overflow-hidden lg:grid-cols-2">
      <div className="pointer-events-none absolute -left-20 top-20 h-[360px] w-[360px] rounded-full bg-[var(--primary)]/15 blur-[120px]" />
      <div className="pointer-events-none absolute -right-24 top-[40%] h-[360px] w-[360px] rounded-full bg-[var(--tertiary)]/12 blur-[115px]" />
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

      <section className="flex items-center justify-center px-6 py-12 pt-24 lg:px-16">
        <div className="w-full max-w-[470px] space-y-6">
          <div className="text-center reveal-up reveal-fast reveal-delay-1">
            <div className="brand-gradient mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl">
              <span className="material-symbols-outlined text-3xl text-white" style={{ fontVariationSettings: '"FILL" 1' }}>
                lock_reset
              </span>
            </div>
            <h1 className="text-3xl font-bold">Create new password</h1>
            <p className="mt-2 text-[var(--text-muted)]">Your new password must be different from previously used passwords.</p>
            <p className="mx-auto mt-3 max-w-sm text-xs leading-relaxed text-white/55">
              Password changes are recorded and tied to session risk telemetry for post-event investigation.
            </p>
          </div>

          <div className="glass-panel ghost-border flex items-center gap-3 rounded-xl px-4 py-3 reveal-up reveal-fast reveal-delay-2">
            <span className="material-symbols-outlined text-[var(--tertiary)]">schedule</span>
            <span className="text-sm font-medium text-[var(--tertiary)]">Reset link valid for 12 more minutes</span>
          </div>

          <form className="space-y-5 reveal-up reveal-fast reveal-delay-2" onSubmit={handleSubmit}>
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
                <span className="font-bold text-emerald-400">{strength >= 3 ? "Strong" : strength == 2 ? "Medium" : "Weak"}</span>
              </div>
              <div className="grid h-1 grid-cols-4 gap-2">
                {Array.from({ length: 4 }).map((_, idx) => (
                  <span key={idx} className={`rounded-full ${idx < strength ? "bg-emerald-400" : "bg-white/15"}`} />
                ))}
              </div>
            </div>

            <div className="ghost-border rounded-xl bg-[var(--surface-container)] p-5">
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

            {error ? <p className="rounded-lg border border-rose-500/30 bg-rose-500/10 px-3 py-2 text-xs text-rose-300">{error}</p> : null}
            {status ? <p className="rounded-lg border border-emerald-500/30 bg-emerald-500/10 px-3 py-2 text-xs text-emerald-300">{status}</p> : null}

            <button type="submit" className="brand-gradient w-full rounded-xl py-4 font-bold text-white shadow-[0_0_20px_rgba(79,110,247,0.3)] transition hover:brightness-110">
              Update Password
            </button>
          </form>

          <div className="pt-3 text-center reveal-up reveal-fast reveal-delay-3">
            <Link href="/admin/login" className="inline-flex items-center gap-2 text-sm text-[var(--text-muted)] hover:text-[var(--primary)]">
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
      <label className="mb-2 block text-xs font-semibold uppercase tracking-[0.11em] text-[var(--text-muted)]">{label}</label>
      <div className="relative">
        <input
          type={showPassword ? "text" : "password"}
          placeholder={placeholder}
          value={value}
          onChange={(event) => onChange(event.target.value)}
          className="w-full border-0 border-b border-white/15 bg-[var(--surface-container-low)] px-4 py-3 pr-20 text-sm outline-none transition focus:border-[var(--primary)]"
        />
        {trailing ? (
          <span className="absolute right-3 top-1/2 -translate-y-1/2 text-[10px] font-bold uppercase tracking-[0.08em] text-emerald-400">{trailing}</span>
        ) : (
          <button type="button" onClick={onTogglePassword} className="absolute right-3 top-1/2 -translate-y-1/2 text-[var(--text-muted)]">
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
      <span className={`material-symbols-outlined text-sm ${ok ? "text-emerald-400" : "text-white/35"}`} style={{ fontVariationSettings: ok ? '"FILL" 1' : undefined }}>
        {ok ? "check_circle" : "circle"}
      </span>
      <span>{text}</span>
    </li>
  );
}
