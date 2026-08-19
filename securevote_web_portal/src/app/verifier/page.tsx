"use client";

import Link from "next/link";
import { useState } from "react";
import { ThemeToggle } from "@/components/theme-toggle";

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? "http://127.0.0.1:8787";

type VerifyResult = {
  valid: boolean;
  electionTitle?: string;
  electionOrganization?: string;
  voteHash?: string;
  txHash?: string;
  blockNumber?: number | null;
  verifiedAt?: string;
};

const publicLinks = [
  { label: "Home", href: "/" },
  { label: "Security", href: "/security" },
  { label: "Verifier", href: "/verifier" },
];

export default function PublicVerifierPage() {
  const [receiptId, setReceiptId] = useState("SV-9921-XF82-K012-P811");
  const [result, setResult] = useState<VerifyResult | null>(null);
  const [notFound, setNotFound] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const verify = async () => {
    const id = receiptId.trim().toUpperCase();
    if (!id) return;

    setLoading(true);
    setError(null);
    setNotFound(false);
    setResult(null);

    try {
      // Public endpoint — plain fetch, no auth header.
      const response = await fetch(`${API_BASE}/api/public/verify/${id}`);
      if (response.status === 404) {
        setNotFound(true);
        return;
      }
      if (!response.ok) {
        throw new Error(`Verification failed (${response.status})`);
      }
      const data = (await response.json()) as VerifyResult;
      setResult(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Verification failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="relative min-h-screen overflow-hidden bg-background text-foreground">
      {/* Ambient glows */}
      <div className="pointer-events-none absolute -left-32 top-20 h-[520px] w-[520px] rounded-full bg-[var(--primary)]/20 blur-[140px] animate-orb" />
      <div className="pointer-events-none absolute -right-28 top-[26%] h-[460px] w-[460px] rounded-full bg-[var(--secondary)]/16 blur-[130px] animate-orb-slow" />
      <div className="dot-grid absolute inset-0 opacity-[0.16]" />

      {/* Header */}
      <header className="fixed inset-x-0 top-0 z-40 border-b border-[var(--border-default)] bg-[var(--surface-overlay)] backdrop-blur-xl">
        <div className="mx-auto flex h-20 max-w-7xl items-center justify-between px-6 md:px-10">
          <Link href="/" className="group flex items-center gap-3">
            <div className="brand-gradient glow-brand grid h-10 w-10 place-items-center rounded-xl transition group-hover:scale-105">
              <span className="material-symbols-outlined text-white" style={{ fontVariationSettings: '"FILL" 1' }}>
                verified_user
              </span>
            </div>
            <p className="text-2xl font-extrabold tracking-tight">Public Verifier</p>
          </Link>

          <nav className="hidden items-center gap-8 md:flex">
            {publicLinks.map((item) => (
              <Link
                key={item.label}
                href={item.href}
                className={`text-[11px] font-bold uppercase tracking-[0.15em] transition ${
                  item.href === "/verifier" ? "text-[var(--text-primary)]" : "text-[var(--text-muted)] hover:text-[var(--text-primary)]"
                }`}
              >
                {item.label}
              </Link>
            ))}
          </nav>

          <div className="flex items-center gap-3">
            <ThemeToggle />
            <Link
              href="/security"
              className="hidden rounded-xl border border-[var(--border-default)] bg-[var(--surface-high)] px-4 py-2 text-xs font-bold uppercase tracking-[0.11em] text-[var(--text-primary)] transition hover:bg-[var(--surface-highest)] md:inline-flex"
            >
              Security
            </Link>
            <Link
              href="/admin/login"
              className="brand-gradient rounded-xl px-4 py-2 text-xs font-bold uppercase tracking-[0.12em] text-white shadow-[0_0_24px_rgba(79,110,247,0.4)]"
            >
              Open Admin
            </Link>
          </div>
        </div>
      </header>

      <section className="relative mx-auto max-w-7xl px-6 pb-20 pt-32 md:px-10">
        {/* ===== HERO ===== */}
        <div className="mx-auto max-w-4xl text-center reveal-up reveal-fast reveal-delay-1">
          <p className="inline-flex items-center gap-2 rounded-full border border-[var(--primary)]/25 bg-[var(--primary)]/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-[var(--tertiary)]">
            <span className="status-dot h-1.5 w-1.5 rounded-full bg-emerald-400" />
            Independent Verification Network
          </p>
          <h1 className="mt-6 text-[2.8rem] font-extrabold leading-[0.98] tracking-[-0.04em] md:text-[4.4rem]">
            Verify Any <span className="text-gradient">Vote Receipt</span>
          </h1>
          <p className="mx-auto mt-5 max-w-2xl text-lg leading-relaxed text-[var(--text-muted)]">
            Confirm that your ballot exists in the immutable ledger without exposing your identity or your vote selection.
          </p>
        </div>

        {/* ===== RECEIPT INPUT ===== */}
        <div className="glass-panel border-gradient relative mx-auto mt-12 max-w-4xl rounded-[2.2rem] p-6 md:p-9 reveal-up reveal-fast reveal-delay-2">
          <div className="pointer-events-none absolute -top-4 left-1/2 -translate-x-1/2 rounded-full border border-[var(--primary)]/30 bg-[var(--surface-container)] px-4 py-1 font-mono text-[10px] font-bold uppercase tracking-[0.16em] text-[var(--tertiary)]">
            PUBLIC_VERIFIER_V2
          </div>

          <label className="text-[11px] font-bold uppercase tracking-[0.16em] text-[var(--text-muted)]">Receipt Identifier</label>
          <div className="mt-3 flex flex-col gap-3 md:flex-row">
            <div className="relative flex-1">
              <span className="pointer-events-none absolute left-4 top-1/2 -translate-y-1/2 text-[var(--text-tertiary)]">
                <span className="material-symbols-outlined text-[20px]">qr_code_2</span>
              </span>
              <input
                value={receiptId}
                onChange={(event) => setReceiptId(event.target.value)}
                onKeyDown={(event) => {
                  if (event.key === "Enter") verify();
                }}
                className="w-full rounded-xl border border-[var(--border-default)] bg-[var(--surface-container)] py-3 pl-11 pr-4 font-mono text-sm text-[var(--primary)] outline-none transition focus:border-[var(--brand)] focus:shadow-[0_0_0_3px_rgba(79,110,247,0.15)] md:h-14"
                placeholder="SV-XXXX-XXXX-XXXX-XXXX"
              />
            </div>
            <button
              type="button"
              onClick={verify}
              disabled={loading}
              className="brand-gradient inline-flex h-14 items-center justify-center gap-2 rounded-xl px-8 text-sm font-bold uppercase tracking-[0.1em] text-white shadow-[0_0_30px_rgba(79,110,247,0.45)] transition hover:shadow-[0_0_46px_rgba(79,110,247,0.65)] disabled:opacity-70"
            >
              {loading ? (
                <>
                  <span className="h-4 w-4 animate-spin rounded-full border-2 border-[var(--text-tertiary)] border-t-white" />
                  Verifying
                </>
              ) : (
                <>
                  Verify
                  <span className="material-symbols-outlined text-[18px]">verified_user</span>
                </>
              )}
            </button>
          </div>
          <p className="mt-4 text-xs text-[var(--text-muted)]">Receipt IDs are case-insensitive. Sample: <span className="font-mono text-[var(--primary)]">SV-9921-XF82-K012-P811</span></p>
        </div>

        {/* ===== LOADING STATE ===== */}
        {loading ? (
          <div className="glass-panel ghost-border mx-auto mt-8 max-w-4xl rounded-[2rem] p-10 text-center reveal-up reveal-fast">
            <div className="relative mx-auto h-16 w-16">
              <span className="absolute inset-0 animate-ping rounded-full bg-[var(--primary)]/20" />
              <span className="relative grid h-16 w-16 place-items-center rounded-full border border-[var(--primary)]/30 bg-[var(--primary)]/10">
                <span className="material-symbols-outlined text-[var(--primary)] animate-pulse">verified_user</span>
              </span>
            </div>
            <p className="mt-6 text-lg font-extrabold tracking-tight">Verifying Receipt…</p>
            <p className="mt-2 text-sm text-[var(--text-muted)]">Consulting the ledger and checking the proof path.</p>
            <div className="mx-auto mt-6 h-1 max-w-xs overflow-hidden rounded-full bg-[var(--surface-highest)]">
              <div className="shimmer-line h-full w-full rounded-full" />
            </div>
          </div>
        ) : error ? (
          <section className="border-gradient mx-auto mt-8 max-w-4xl rounded-2xl border border-[var(--red)]/35 bg-[var(--red)]/10 p-6 reveal-up reveal-fast">
            <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
              <div className="flex items-start gap-3">
                <span className="material-symbols-outlined text-[var(--red)]" style={{ fontVariationSettings: '"FILL" 1' }}>
                  error
                </span>
                <div>
                  <p className="text-sm font-bold text-[var(--red)]">Verification failed</p>
                  <p className="mt-1 text-xs text-[var(--text-secondary)]">{error}</p>
                </div>
              </div>
              <button
                type="button"
                onClick={verify}
                className="rounded-xl border border-[var(--red)]/30 bg-[var(--red)]/10 px-5 py-2.5 text-xs font-bold uppercase tracking-[0.1em] text-[var(--red)] transition hover:bg-[var(--red)]/20"
              >
                Retry
              </button>
            </div>
          </section>
        ) : notFound ? (
          <section className="border-gradient mx-auto mt-8 max-w-4xl rounded-2xl border border-[var(--amber)]/35 bg-[var(--amber)]/10 p-6 reveal-up reveal-fast">
            <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
              <div className="flex items-start gap-3">
                <span className="material-symbols-outlined text-[var(--amber)]" style={{ fontVariationSettings: '"FILL" 1' }}>
                  search_off
                </span>
                <div>
                  <p className="text-sm font-bold text-[var(--amber)]">Receipt not found</p>
                  <p className="mt-1 text-xs text-[var(--text-secondary)]">Double-check the ID or contact your election authority for support.</p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => {
                  setNotFound(false);
                  setReceiptId("");
                }}
                className="rounded-xl border border-[var(--amber)]/30 bg-[var(--amber)]/10 px-5 py-2.5 text-xs font-bold uppercase tracking-[0.1em] text-[var(--amber)] transition hover:bg-[var(--amber)]/20"
              >
                Try Again
              </button>
            </div>
          </section>
        ) : result ? (
          /* ===== SUCCESS STATE ===== */
          <div className="mx-auto mt-8 max-w-4xl space-y-5 reveal-up reveal-fast">
            <article className="border-gradient relative overflow-hidden rounded-[2rem] border border-emerald-500/30 bg-emerald-500/8 p-7 md:p-9">
              <div className="pointer-events-none absolute -right-16 -top-16 h-48 w-48 rounded-full bg-emerald-500/15 blur-[80px]" />
              <div className="relative flex flex-col items-start gap-5 md:flex-row md:items-center">
                <div className="check-pop grid h-16 w-16 shrink-0 place-items-center rounded-full bg-emerald-500/15 text-emerald-400">
                  <span className="material-symbols-outlined text-[40px]" style={{ fontVariationSettings: '"FILL" 1' }}>
                    verified
                  </span>
                </div>
                <div className="flex-1">
                  <div className="flex flex-wrap items-center gap-3">
                    <p className="text-xl font-extrabold tracking-tight text-emerald-300">Vote verified successfully</p>
                    {result.txHash ? (
                      <span className="inline-flex items-center gap-1.5 rounded-full border border-[var(--teal)]/30 bg-[var(--teal)]/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.12em] text-[var(--teal)]">
                        <span className="status-dot h-1.5 w-1.5 rounded-full bg-[var(--teal)]" />
                        Verified On-Chain
                      </span>
                    ) : null}
                  </div>
                  <p className="mt-2 text-sm text-[var(--text-secondary)]">
                    {result.valid
                      ? "This receipt is anchored in the ledger and the proof path is intact."
                      : "This receipt exists but could not be fully validated."}
                  </p>
                </div>
              </div>
            </article>

            <article className="glass-panel border-gradient rounded-[1.8rem] p-6 md:p-8">
              <p className="text-[11px] font-bold uppercase tracking-[0.16em] text-[var(--text-muted)]">Receipt Details</p>
              <div className="mt-3">
                <Row label="Election" value={result.electionTitle ?? "—"} />
                <Row label="Organization" value={result.electionOrganization ?? "—"} />
                {result.blockNumber != null ? <Row label="Block Number" value={String(result.blockNumber)} /> : null}
                {result.txHash ? <Row label="Transaction Hash" value={result.txHash} mono /> : null}
                {result.voteHash ? <Row label="Vote Hash" value={result.voteHash} mono /> : null}
                {result.verifiedAt ? <Row label="Verified At" value={result.verifiedAt} /> : null}
              </div>
            </article>

            <article className="glass-panel border-gradient rounded-[1.8rem] p-6 md:p-8">
              <p className="text-[11px] font-bold uppercase tracking-[0.16em] text-[var(--text-muted)]">Ledger Anchor</p>
              <div className="mt-4 grid gap-3 sm:grid-cols-3">
                <ProofNode label="Block" value={result.blockNumber != null ? String(result.blockNumber) : "—"} />
                <ProofNode label="Tx" value={result.txHash ? result.txHash.slice(0, 10) + "..." : "—"} active={!!result.txHash} />
                <ProofNode label="Vote" value={result.voteHash ? result.voteHash.slice(0, 10) + "..." : "—"} active />
              </div>
            </article>
          </div>
        ) : null}

        {/* ===== BOTTOM CTA ===== */}
        <section className="mx-auto mt-12 max-w-4xl rounded-[1.8rem] border border-[var(--border-default)] bg-[var(--surface-low)]/70 p-6 reveal-up reveal-fast reveal-delay-3">
          <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
            <div>
              <p className="text-sm font-bold">Need more assurance?</p>
              <p className="mt-1 text-xs text-[var(--text-muted)]">Review our cryptographic controls and operational security model.</p>
            </div>
            <Link
              href="/security"
              className="brand-gradient inline-flex items-center justify-center gap-2 rounded-xl px-5 py-3 text-xs font-bold uppercase tracking-[0.1em] text-white shadow-[0_0_24px_rgba(79,110,247,0.4)]"
            >
              View Security Standards
              <span className="material-symbols-outlined text-[16px]">arrow_forward</span>
            </Link>
          </div>
        </section>
      </section>
    </main>
  );
}

function Row({ label, value, mono = false }: { label: string; value: string; mono?: boolean }) {
  return (
    <div className="flex items-center justify-between gap-4 border-b border-[var(--border-subtle)] py-3.5 last:border-b-0">
      <p className="shrink-0 text-[11px] uppercase tracking-[0.08em] text-[var(--text-muted)]">{label}</p>
      <p className={`text-right text-sm font-semibold ${mono ? "break-all font-mono text-xs text-[var(--primary)]" : "text-[var(--text-primary)]"}`}>
        {value}
      </p>
    </div>
  );
}

function ProofNode({ label, value, active = false }: { label: string; value: string; active?: boolean }) {
  return (
    <div
      className={`rounded-xl border px-4 py-3 transition ${
        active
          ? "border-[var(--teal)]/25 bg-[var(--teal)]/8 text-[var(--teal)]"
          : "border-[var(--border-default)] bg-[var(--surface-container-low)] text-[var(--text-secondary)]"
      }`}
    >
      <p className="text-[10px] uppercase tracking-[0.08em] text-[var(--text-muted)]">{label}</p>
      <p className="mt-1.5 flex items-center gap-1.5 font-mono text-sm">
        {active ? <span className="status-dot h-1.5 w-1.5 rounded-full bg-[var(--teal)]" /> : null}
        {value}
      </p>
    </div>
  );
}