"use client";

import Link from "next/link";
import { useCallback, useEffect, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import { listVoters, type Voter } from "@/lib/api-client";
import { saveDraft, loadDraft } from "../draft";

export default function CreateElectionEligibilityPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [approvedVoters, setApprovedVoters] = useState<Voter[]>([]);
  const [totalVoters, setTotalVoters] = useState(0);
  const [toast, setToast] = useState<string | null>(null);
  const draft = useState(loadDraft)[0];

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [approved, all] = await Promise.all([
        listVoters({ kycStatus: "approved" }),
        listVoters(),
      ]);
      setApprovedVoters(approved);
      setTotalVoters(all.length);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load voter data");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const saveAndToast = () => {
    saveDraft(draft);
    setToast("Draft saved.");
    setTimeout(() => setToast(null), 2000);
  };

  return (
    <AdminShell active="elections">
      <section className="mx-auto max-w-5xl space-y-8 pb-28">
        <div>
          <p className="text-xs text-[var(--text-muted)]">Step 3 of 4</p>
          <h1 className="mt-2 text-4xl font-bold tracking-tight">Voter Eligibility</h1>
        </div>

        <Stepper step={3} />

        {error ? (
          <div className="rounded-lg bg-rose-500/15 px-4 py-3 text-sm text-rose-300">{error}</div>
        ) : null}

        <section className="rounded-xl bg-[var(--surface-container)] p-6">
          <h2 className="text-xs font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Eligibility Model</h2>
          <p className="mt-3 text-sm text-[var(--text-muted)]">
            Voter eligibility in SecureVote is determined by KYC verification status. Only voters with
            approved KYC status can cast ballots in elections. Manage individual voter eligibility through
            the KYC Verification queue and Voter Registry.
          </p>
          <div className="mt-5 grid gap-4 md:grid-cols-3">
            <StatCard
              label="Approved Voters"
              value={loading ? "—" : approvedVoters.length.toLocaleString()}
              hint="Eligible to vote"
            />
            <StatCard
              label="Total Registered"
              value={loading ? "—" : totalVoters.toLocaleString()}
              hint="All accounts"
            />
            <StatCard
              label="Pending / Rejected"
              value={loading ? "—" : (totalVoters - approvedVoters.length).toLocaleString()}
              hint="Not yet eligible"
            />
          </div>
        </section>

        <section className="rounded-xl bg-[var(--surface-container)] p-6">
          <div className="flex items-center justify-between">
            <h2 className="text-xs font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Approved Voter Preview</h2>
            <Link href="/admin/voters/kyc-verification" className="text-xs font-semibold text-[var(--primary)]">
              Manage KYC Queue
            </Link>
          </div>
          <div className="mt-4 overflow-x-auto rounded-lg border border-[var(--border-subtle)]">
            <table className="w-full min-w-[400px] text-left text-sm">
              <thead className="bg-[var(--surface-container-low)] text-[10px] uppercase tracking-[0.1em] text-[var(--text-muted)]">
                <tr>
                  <th className="px-4 py-2">Name</th>
                  <th className="px-4 py-2">Email</th>
                  <th className="px-4 py-2">KYC Status</th>
                </tr>
              </thead>
              <tbody>
                {loading ? (
                  <tr>
                    <td colSpan={3} className="px-4 py-6 text-center text-sm text-[var(--text-muted)]">Loading voters...</td>
                  </tr>
                ) : approvedVoters.length === 0 ? (
                  <tr>
                    <td colSpan={3} className="px-4 py-6 text-center text-sm text-[var(--text-muted)]">No approved voters yet.</td>
                  </tr>
                ) : (
                  approvedVoters.slice(0, 10).map((voter) => (
                    <tr key={voter.id} className="border-t border-[var(--border-subtle)]">
                      <td className="px-4 py-3 font-semibold">{voter.fullName}</td>
                      <td className="px-4 py-3 text-[var(--text-muted)]">{voter.email}</td>
                      <td className="px-4 py-3">
                        <span className="rounded-full bg-emerald-500/15 px-2 py-0.5 text-[10px] font-bold uppercase text-emerald-300">
                          {voter.kycStatus}
                        </span>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
          {approvedVoters.length > 10 ? (
            <p className="mt-2 text-xs text-[var(--text-muted)]">Showing first 10 of {approvedVoters.length} approved voters.</p>
          ) : null}
        </section>

        {toast ? (
          <div className="rounded-lg bg-emerald-500/15 px-4 py-2 text-sm font-semibold text-emerald-300">{toast}</div>
        ) : null}

        <footer className="fixed bottom-0 left-60 right-0 flex h-[72px] items-center justify-between border-t border-[var(--border-subtle)] bg-[var(--surface-overlay)] px-8 backdrop-blur-lg">
          <Link href="/admin/elections/create/schedule" className="text-sm text-[var(--text-muted)]">Back</Link>
          <div className="flex items-center gap-3">
            <button onClick={saveAndToast} className="rounded-lg bg-[var(--surface-container-high)] px-5 py-2.5 text-sm">Save Draft</button>
            <Link href="/admin/elections/create/review" className="brand-gradient rounded-lg px-8 py-2.5 text-sm font-semibold text-white">Continue</Link>
          </div>
        </footer>
      </section>
    </AdminShell>
  );
}

function Stepper({ step }: { step: number }) {
  const labels = ["Basic Info", "Schedule", "Eligibility", "Review"];
  return (
    <div className="rounded-xl bg-[var(--surface-container)] p-5">
      <div className="flex items-center gap-2">
        {labels.map((label, idx) => {
          const n = idx + 1;
          const active = step === n;
          const done = step > n;
          return (
            <div key={label} className="flex flex-1 items-center gap-2">
              <span className={`grid h-8 w-8 place-items-center rounded-full border text-xs font-bold ${active ? "border-[var(--primary)] text-[var(--primary)]" : done ? "brand-gradient border-transparent text-white" : "border-[var(--border-default)] text-[var(--text-muted)]"}`}>
                {done ? "✓" : n}
              </span>
              <span className={`text-xs font-semibold uppercase tracking-[0.1em] ${active ? "text-[var(--primary)]" : "text-[var(--text-muted)]"}`}>{label}</span>
              {idx < labels.length - 1 ? <span className="h-px flex-1 bg-[var(--surface-container-highest)]" /> : null}
            </div>
          );
        })}
      </div>
    </div>
  );
}

function StatCard({ label, value, hint }: { label: string; value: string; hint: string }) {
  return (
    <article className="rounded-xl bg-[var(--surface-container-low)] p-5">
      <p className="text-[10px] font-bold uppercase tracking-[0.12em] text-[var(--text-muted)]">{label}</p>
      <p className="mt-2 text-3xl font-bold text-[var(--primary)]">{value}</p>
      <p className="mt-1 text-xs text-[var(--text-muted)]">{hint}</p>
    </article>
  );
}
