"use client";

import { useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";

type FeedItem = {
  id: string;
  election: string;
  voters: number;
  turnout: number;
  anomalies: number;
  updated: string;
};

const initialFeed: FeedItem[] = [
  {
    id: "EL-2026-SC",
    election: "Student Council 2026",
    voters: 2810,
    turnout: 67,
    anomalies: 2,
    updated: "just now",
  },
  {
    id: "EL-2026-UB",
    election: "Union Board Referendum",
    voters: 1950,
    turnout: 58,
    anomalies: 1,
    updated: "8s ago",
  },
  {
    id: "EL-2026-FS",
    election: "Faculty Senate",
    voters: 1220,
    turnout: 42,
    anomalies: 0,
    updated: "13s ago",
  },
];

export default function LiveMonitoringPage() {
  const [feed, setFeed] = useState<FeedItem[]>(initialFeed);
  const [autoRefresh, setAutoRefresh] = useState(true);

  const totals = useMemo(() => {
    const totalVoters = feed.reduce((sum, item) => sum + item.voters, 0);
    const weightedTurnout = Math.round(feed.reduce((sum, item) => sum + item.turnout * item.voters, 0) / totalVoters);
    const totalAnomalies = feed.reduce((sum, item) => sum + item.anomalies, 0);
    return { totalVoters, weightedTurnout, totalAnomalies };
  }, [feed]);

  const pulse = () => {
    setFeed((prev) =>
      prev.map((item) => {
        const voterShift = Math.floor(Math.random() * 18);
        const anomalyShift = Math.random() > 0.7 ? 1 : 0;
        const nextVoters = item.voters + voterShift;
        const nextTurnout = Math.min(100, Math.round(item.turnout + voterShift / 65));
        return {
          ...item,
          voters: nextVoters,
          turnout: nextTurnout,
          anomalies: item.anomalies + anomalyShift,
          updated: "just now",
        };
      }),
    );
  };

  return (
    <AdminShell active="elections">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Operations / Real-time</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Live Monitoring</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Track turnout, voting throughput, and anomaly pressure across active elections.</p>
          </div>
          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={() => setAutoRefresh((value) => !value)}
              className={`rounded-lg px-4 py-2 text-sm font-semibold ${autoRefresh ? "bg-emerald-500/15 text-emerald-300" : "bg-white/10 text-[var(--text-muted)]"}`}
            >
              Auto refresh: {autoRefresh ? "On" : "Off"}
            </button>
            <button type="button" onClick={pulse} className="brand-gradient rounded-lg px-4 py-2 text-sm font-semibold text-white">
              Refresh Now
            </button>
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-3">
          <MetricCard title="Live Voters" value={totals.totalVoters.toLocaleString()} hint="Active verified sessions" />
          <MetricCard title="Turnout" value={`${totals.weightedTurnout}%`} hint="Weighted by electorate size" />
          <MetricCard title="Active Anomalies" value={`${totals.totalAnomalies}`} hint="Open + unresolved events" danger={totals.totalAnomalies > 2} />
        </div>

        <section className="grid gap-6 xl:grid-cols-[1.2fr,0.8fr]">
          <article className="rounded-xl bg-[var(--surface-container)] p-5">
            <div className="mb-4 flex items-center justify-between">
              <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Election Activity Feed</p>
              <p className="text-xs text-[var(--text-muted)]">Updated live</p>
            </div>
            <div className="space-y-3">
              {feed.map((item) => (
                <div key={item.id} className="rounded-lg bg-[var(--surface-container-low)] p-4">
                  <div className="flex items-center justify-between gap-3">
                    <div>
                      <p className="text-sm font-semibold">{item.election}</p>
                      <p className="text-xs text-[var(--text-muted)]">{item.id}</p>
                    </div>
                    <span className="text-xs text-[var(--text-muted)]">{item.updated}</span>
                  </div>
                  <div className="mt-4 grid gap-3 sm:grid-cols-3">
                    <MiniStat label="Voters" value={item.voters.toLocaleString()} />
                    <MiniStat label="Turnout" value={`${item.turnout}%`} />
                    <MiniStat label="Anomalies" value={`${item.anomalies}`} tone={item.anomalies > 0 ? "warn" : "ok"} />
                  </div>
                </div>
              ))}
            </div>
          </article>

          <article className="rounded-xl bg-[var(--surface-container)] p-5">
            <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Control Actions</p>
            <div className="mt-4 space-y-3">
              <ActionButton label="Open Incident Bridge" subtitle="Start coordinated response" />
              <ActionButton label="Request Region Lock" subtitle="Throttle suspicious cluster" />
              <ActionButton label="Run Integrity Snapshot" subtitle="Recompute vote hash chain" />
              <ActionButton label="Notify Oversight Team" subtitle="Dispatch signed update" />
            </div>

            <div className="mt-6 rounded-lg border border-[var(--primary)]/20 bg-[var(--primary)]/7 p-4">
              <p className="text-[10px] uppercase tracking-[0.1em] text-[var(--text-muted)]">System Note</p>
              <p className="mt-2 text-sm text-white/85">Monitoring is in simulation mode until Firebase listeners are connected for production telemetry.</p>
            </div>
          </article>
        </section>
      </section>
    </AdminShell>
  );
}

function MetricCard({ title, value, hint, danger = false }: { title: string; value: string; hint: string; danger?: boolean }) {
  return (
    <article className="rounded-xl bg-[var(--surface-container)] p-5">
      <p className="text-[10px] uppercase tracking-[0.1em] text-[var(--text-muted)]">{title}</p>
      <p className={`mt-2 text-3xl font-bold tracking-tight ${danger ? "text-rose-300" : ""}`}>{value}</p>
      <p className="mt-1 text-xs text-[var(--text-muted)]">{hint}</p>
    </article>
  );
}

function MiniStat({ label, value, tone = "neutral" }: { label: string; value: string; tone?: "neutral" | "warn" | "ok" }) {
  const toneClass = tone === "warn" ? "text-rose-300" : tone === "ok" ? "text-emerald-300" : "text-white";
  return (
    <div className="rounded-md bg-[var(--surface-container-high)] px-3 py-2">
      <p className="text-[10px] uppercase tracking-[0.1em] text-[var(--text-muted)]">{label}</p>
      <p className={`mt-1 text-sm font-semibold ${toneClass}`}>{value}</p>
    </div>
  );
}

function ActionButton({ label, subtitle }: { label: string; subtitle: string }) {
  return (
    <button className="w-full rounded-lg bg-[var(--surface-container-low)] px-4 py-3 text-left transition hover:bg-[var(--surface-container-high)]">
      <p className="text-sm font-semibold">{label}</p>
      <p className="text-xs text-[var(--text-muted)]">{subtitle}</p>
    </button>
  );
}
