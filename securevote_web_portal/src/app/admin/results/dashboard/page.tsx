"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { AdminShell } from "@/components/admin-shell";

type Candidate = { name: string; votes: number };

const candidates: Candidate[] = [
  { name: "Ahmad Fariz", votes: 14282 },
  { name: "Elena Rodriguez", votes: 10483 },
  { name: "Marcus Chen", votes: 8914 },
];

export default function ResultsDashboardPage() {
  const [region, setRegion] = useState("All Regions");
  const [window, setWindow] = useState("Final");

  const totalVotes = useMemo(() => candidates.reduce((sum, candidate) => sum + candidate.votes, 0), []);

  return (
    <AdminShell active="elections">
      <section className="mx-auto max-w-6xl space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Results / Analytics</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Results Dashboard</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Official outcome view with candidate standings and turnout intelligence.</p>
          </div>
          <div className="flex items-center gap-3">
            <Link href="/admin/results/publish" className="rounded-md bg-[var(--surface-container)] px-4 py-2 text-xs font-semibold">
              Publish Settings
            </Link>
            <button className="brand-gradient rounded-md px-4 py-2 text-xs font-semibold text-white">Export Report</button>
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-4">
          <Metric title="Total Votes" value={totalVotes.toLocaleString()} tone="text-white" />
          <Metric title="Turnout" value="78.4%" tone="text-emerald-300" />
          <Metric title="Precincts Synced" value="129 / 129" tone="text-[var(--primary)]" />
          <Metric title="Audit Consistency" value="100%" tone="text-cyan-300" />
        </div>

        <article className="rounded-xl bg-[var(--surface-container)] p-5">
          <div className="flex flex-wrap items-center gap-3">
            <select value={region} onChange={(event) => setRegion(event.target.value)} className="h-10 rounded-md bg-[var(--surface-container-low)] px-3 text-sm">
              <option>All Regions</option>
              <option>District 7</option>
              <option>District 9</option>
              <option>District 12</option>
            </select>
            <select value={window} onChange={(event) => setWindow(event.target.value)} className="h-10 rounded-md bg-[var(--surface-container-low)] px-3 text-sm">
              <option>Final</option>
              <option>Latest Snapshot</option>
              <option>Last 24h</option>
            </select>
            <p className="ml-auto text-xs text-[var(--text-muted)]">Filter: {region} / {window}</p>
          </div>

          <div className="mt-5 space-y-4">
            {candidates.map((candidate) => {
              const pct = ((candidate.votes / totalVotes) * 100).toFixed(1);
              return (
                <div key={candidate.name} className="space-y-2">
                  <div className="flex items-center justify-between">
                    <p className="text-sm font-semibold">{candidate.name}</p>
                    <p className="text-xs text-[var(--text-muted)]">{candidate.votes.toLocaleString()} votes ({pct}%)</p>
                  </div>
                  <div className="h-10 overflow-hidden rounded bg-[var(--surface-container-low)]">
                    <div className="brand-gradient h-full" style={{ width: `${pct}%` }} />
                  </div>
                </div>
              );
            })}
          </div>
        </article>

        <div className="grid gap-5 lg:grid-cols-2">
          <article className="rounded-xl bg-[var(--surface-container)] p-5">
            <p className="text-[11px] uppercase tracking-[0.09em] text-[var(--text-muted)]">Winner Projection</p>
            <p className="mt-2 text-2xl font-bold">Ahmad Fariz</p>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Lead margin: 3,799 votes over second candidate.</p>
          </article>
          <article className="rounded-xl bg-[var(--surface-container)] p-5">
            <p className="text-[11px] uppercase tracking-[0.09em] text-[var(--text-muted)]">Integrity Signals</p>
            <ul className="mt-2 space-y-1 text-sm text-[var(--text-muted)]">
              <li>All ballot batches anchored to chain root.</li>
              <li>No unresolved anomalies in the counting window.</li>
              <li>Final tally hash available for public verification.</li>
            </ul>
          </article>
        </div>
      </section>
    </AdminShell>
  );
}

function Metric({ title, value, tone }: { title: string; value: string; tone: string }) {
  return (
    <article className="rounded-xl bg-[var(--surface-container)] p-4">
      <p className="text-[11px] uppercase tracking-[0.08em] text-[var(--text-muted)]">{title}</p>
      <p className={`mt-1 text-2xl font-bold ${tone}`}>{value}</p>
    </article>
  );
}
