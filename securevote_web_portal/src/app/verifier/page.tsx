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
      <div className="pointer-events-none absolute -left-32 top-20 h-[460px] w-[460px] rounded-full bg-[var(--primary)]/20 blur-[130px]" />
      <div className="pointer-events-none absolute -right-24 top-[30%] h-[400px] w-[400px] rounded-full bg-[var(--secondary)]/16 blur-[120px]" />
      <div className="dot-grid absolute inset-0 opacity-20" />

      <header className="fixed inset-x-0 top-0 z-30 border-b border-[var(--border-default)] bg-[var(--surface-overlay)] backdrop-blur-xl">
        <div className="mx-auto flex h-20 max-w-7xl items-center justify-between px-6 md:px-10">
          <div className="flex items-center gap-3">
            <div className="brand-gradient grid h-10 w-10 place-items-center rounded-xl">
              <span className="material-symbols-outlined text-white" style={{ fontVariationSettings: '"FILL" 1' }}>
                verified_user
              </span>
            </div>
            <p className="text-2xl font-extrabold tracking-tight">Public Verifier</p>
          </div>

          <nav className="hidden items-center gap-8 md:flex">
            {publicLinks.map((item) => (
              <Link key={item.label} href={item.href} className={`text-[11px] font-bold uppercase tracking-[0.15em] transition ${item.href === "/verifier" ? "text-[var(--text-primary)]" : "text-[var(--text-muted)] hover:text-[var(--text-primary)]"}`}>
                {item.label}
              </Link>
            ))}
          </nav>

          <div className="flex items-center gap-3">
            <ThemeToggle />
            <Link href="/security" className="hidden rounded-xl border border-[var(--border-default)] bg-[var(--surface-high)] px-4 py-2 text-xs font-bold uppercase tracking-[0.11em] text-[var(--text-primary)] transition hover:bg-[var(--surface-highest)] md:inline-flex">
              Security
            </Link>
            <Link href="/admin/login" className="brand-gradient rounded-xl px-4 py-2 text-xs font-bold uppercase tracking-[0.12em] text-white">
              Open Admin
            </Link>
          </div>
        </div>
      </header>

      <section className="relative mx-auto max-w-7xl px-6 pb-20 pt-32 md:px-10">
        <div className="mx-auto max-w-4xl text-center reveal-up reveal-fast reveal-delay-1">
          <p className="inline-flex items-center gap-2 rounded-full border border-[var(--primary)]/25 bg-[var(--primary)]/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-[var(--tertiary)]">
            <span className="h-1.5 w-1.5 rounded-full bg-emerald-400" />
            Independent Verification Network
          </p>
          <h1 className="mt-6 text-[2.8rem] font-extrabold leading-[0.98] tracking-[-0.04em] md:text-[4.2rem]">Verify Any Vote Receipt</h1>
          <p className="mx-auto mt-5 max-w-2xl text-lg leading-relaxed text-[var(--text-muted)]">
            Confirm that your ballot exists in the immutable ledger without exposing your identity or your vote selection.
          </p>
        </div>

        <article className="glass-panel ghost-border mx-auto mt-10 max-w-4xl rounded-[2rem] p-6 md:p-8 reveal-up reveal-fast reveal-delay-2">
          <label className="text-[11px] font-bold uppercase tracking-[0.16em] text-[var(--text-muted)]">Receipt Identifier</label>
          <div className="mt-3 flex flex-col gap-3 md:flex-row">
            <input
              value={receiptId}
              onChange={(event) => setReceiptId(event.target.value)}
              onKeyDown={(event) => {
                if (event.key === "Enter") verify();
              }}
              className="h-12 flex-1 rounded-xl border border-white/10 bg-[var(--surface-container)] px-4 font-mono text-sm text-[var(--primary)]"
              placeholder="SV-XXXX-XXXX-XXXX-XXXX"
            />
            <button type="button" onClick={verify} disabled={loading} className="brand-gradient h-12 rounded-xl px-6 text-sm font-bold uppercase tracking-[0.1em] text-white disabled:opacity-60">
              {loading ? "Verifying..." : "Verify"}
            </button>
          </div>
          <p className="mt-3 text-xs text-[var(--text-muted)]">Receipt IDs are case-insensitive. Sample: SV-9921-XF82-K012-P811</p>
        </article>

        {error ? (
          <section className="mx-auto mt-8 max-w-4xl rounded-xl border border-rose-500/35 bg-rose-500/10 p-4">
            <p className="text-sm font-semibold text-rose-300">Verification failed</p>
            <p className="mt-1 text-xs text-rose-200/85">{error}</p>
          </section>
        ) : notFound ? (
          <section className="mx-auto mt-8 max-w-4xl rounded-xl border border-rose-500/35 bg-rose-500/10 p-4">
            <p className="text-sm font-semibold text-rose-300">Receipt not found</p>
            <p className="mt-1 text-xs text-rose-200/85">Double-check the ID or contact your election authority for support.</p>
          </section>
        ) : result ? (
          <section className="mx-auto mt-8 grid max-w-4xl gap-5">
            <article className="rounded-xl border border-emerald-500/35 bg-emerald-500/10 p-4">
              <p className="text-sm font-semibold text-emerald-300">Vote verified successfully</p>
              <p className="mt-1 text-xs text-emerald-200/85">
                {result.valid ? "This receipt is anchored in the ledger and the proof path is intact." : "This receipt exists but could not be fully validated."}
              </p>
            </article>

            <article className="glass-panel ghost-border rounded-[1.5rem] p-6">
              <Row label="Election" value={result.electionTitle ?? "—"} />
              <Row label="Organization" value={result.electionOrganization ?? "—"} />
              {result.blockNumber != null ? <Row label="Block Number" value={String(result.blockNumber)} /> : null}
              {result.txHash ? <Row label="Transaction Hash" value={result.txHash} mono /> : null}
              {result.voteHash ? <Row label="Vote Hash" value={result.voteHash} mono /> : null}
              {result.verifiedAt ? <Row label="Verified At" value={result.verifiedAt} /> : null}
            </article>

            <article className="glass-panel ghost-border rounded-[1.5rem] p-6">
              <p className="text-[11px] font-bold uppercase tracking-[0.16em] text-[var(--text-muted)]">Ledger Anchor</p>
              <div className="mt-3 grid gap-2 text-xs sm:grid-cols-3">
                <ProofNode label="Block" value={result.blockNumber != null ? String(result.blockNumber) : "—"} />
                <ProofNode label="Tx" value={result.txHash ? result.txHash.slice(0, 10) + "..." : "—"} />
                <ProofNode label="Vote" value={result.voteHash ? result.voteHash.slice(0, 10) + "..." : "—"} active />
              </div>
            </article>
          </section>
        ) : null}

        <section className="mx-auto mt-12 max-w-4xl rounded-[1.5rem] border border-white/10 bg-[var(--surface-container)]/75 p-5 md:p-6 reveal-up reveal-fast reveal-delay-3">
          <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
            <div>
              <p className="text-sm font-bold">Need more assurance?</p>
              <p className="mt-1 text-xs text-[var(--text-muted)]">Review our cryptographic controls and operational security model.</p>
            </div>
            <Link href="/security" className="brand-gradient inline-flex items-center justify-center rounded-xl px-5 py-3 text-xs font-bold uppercase tracking-[0.1em] text-white">
              View Security Standards
            </Link>
          </div>
        </section>
      </section>
    </main>
  );
}

function Row({ label, value, mono = false }: { label: string; value: string; mono?: boolean }) {
  return (
    <div className="border-b border-white/8 py-3 last:border-b-0">
      <p className="text-[11px] uppercase tracking-[0.08em] text-[var(--text-muted)]">{label}</p>
      <p className={`mt-1 text-sm font-semibold ${mono ? "break-all font-mono text-xs" : ""}`}>{value}</p>
    </div>
  );
}

function ProofNode({ label, value, active = false }: { label: string; value: string; active?: boolean }) {
  return (
    <div className={`rounded-lg px-3 py-2 ${active ? "bg-[var(--primary)]/20 text-[var(--primary)]" : "bg-[var(--surface-container-low)]"}`}>
      <p className="text-[10px] uppercase tracking-[0.08em] text-[var(--text-muted)]">{label}</p>
      <p className="mt-1 font-mono text-xs">{value}</p>
    </div>
  );
}