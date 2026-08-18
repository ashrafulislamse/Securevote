"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import {
  getAdminStats,
  getAlerts,
  getRecentElections,
  getUnreadNotificationCount,
  listElections,
  verifyAuditChain,
  type AdminStats,
  type Alert,
  type ChainStatus,
  type Election,
} from "@/lib/api-client";

type Kpi = {
  title: string;
  value: string;
  note: string;
  noteClass: string;
};

type StatusTone = "rose" | "amber" | "blue";

const DONUT_CIRCUMFERENCE = 251;

const statusMeta: Record<'active' | 'upcoming' | 'closed' | 'draft', { label: string; color: string }> = {
  active: { label: "Active", color: "#4F6EF7" },
  upcoming: { label: "Upcoming", color: "#7C3AED" },
  closed: { label: "Closed", color: "#10B981" },
  draft: { label: "Draft", color: "#34343a" },
};

function countByBucket(elections: Election[]): Record<'active' | 'upcoming' | 'closed' | 'draft', number> {
  const buckets: Record<'active' | 'upcoming' | 'closed' | 'draft', number> = {
    active: 0,
    upcoming: 0,
    closed: 0,
    draft: 0,
  };
  for (const election of elections) {
    if (election.status === "active") buckets.active += 1;
    else if (election.status === "scheduled" || election.status === "published") buckets.upcoming += 1;
    else if (election.status === "closed") buckets.closed += 1;
    else buckets.draft += 1;
  }
  return buckets;
}

function toneForSeverity(severity: string): StatusTone {
  const sev = (severity ?? "").toLowerCase();
  if (sev === "critical" || sev === "high" || sev === "error") return "rose";
  if (sev === "warning" || sev === "medium" || sev === "warn") return "amber";
  return "blue";
}

export default function AdminDashboardPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [stats, setStats] = useState<AdminStats | null>(null);
  const [recentElections, setRecentElections] = useState<Election[]>([]);
  const [alerts, setAlerts] = useState<Alert[]>([]);
  const [statusCounts, setStatusCounts] = useState<Record<'active' | 'upcoming' | 'closed' | 'draft', number>>({
    active: 0,
    upcoming: 0,
    closed: 0,
    draft: 0,
  });
  const [unreadNotifications, setUnreadNotifications] = useState(0);
  const [chain, setChain] = useState<ChainStatus | null>(null);
  const [chainError, setChainError] = useState<string | null>(null);

  useEffect(() => {
    let active = true;

    async function load() {
      setLoading(true);
      setError(null);
      try {
        const [statsData, recentData, alertsData, electionsData, unread] = await Promise.all([
          getAdminStats(),
          getRecentElections(),
          getAlerts(),
          listElections(),
          getUnreadNotificationCount().catch(() => 0),
        ]);
        if (!active) return;
        setStats(statsData);
        setRecentElections(recentData);
        setAlerts(alertsData);
        setStatusCounts(countByBucket(electionsData));
        setUnreadNotifications(unread);
      } catch (err) {
        if (!active) return;
        setError(err instanceof Error ? err.message : "Failed to load dashboard data");
      } finally {
        if (active) setLoading(false);
      }
    }

    // The chain check is best-effort — if it fails the rest of the dashboard
    // should still load. The badge just stays in an "unknown" state.
    (async () => {
      try {
        const status = await verifyAuditChain();
        if (active) setChain(status);
      } catch (err) {
        if (active) {
          setChainError(err instanceof Error ? err.message : "Chain check unavailable");
        }
      }
    })();

    load();
    return () => {
      active = false;
    };
  }, []);

  const kpis: Kpi[] = [
    { title: "Total Elections", value: stats ? String(stats.totalElections) : "–", note: "All elections", noteClass: "text-[var(--primary)] bg-[var(--primary)]/10" },
    { title: "Total Voters", value: stats ? stats.totalVoters.toLocaleString() : "–", note: "Registered", noteClass: "text-emerald-400 bg-emerald-500/10" },
    { title: "Approved Voters", value: stats ? stats.approvedVoters.toLocaleString() : "–", note: "Verified", noteClass: "text-[var(--text-muted)] bg-white/5" },
    { title: "Total Votes", value: stats ? stats.totalVotes.toLocaleString() : "–", note: "Cast", noteClass: "text-[var(--text-muted)] bg-white/5" },
    { title: "Unread Notifications", value: unreadNotifications.toLocaleString(), note: unreadNotifications > 0 ? "Inbox" : "All clear", noteClass: unreadNotifications > 0 ? "text-rose-300 bg-rose-500/10" : "text-emerald-400 bg-emerald-500/10" },
  ];

  const totalByStatus =
    statusCounts.active + statusCounts.upcoming + statusCounts.closed + statusCounts.draft;

  const turnoutPct = stats && stats.approvedVoters > 0
    ? Math.round((stats.totalVotes / stats.approvedVoters) * 100)
    : 0;

  const donutSegments = (["active", "upcoming", "closed", "draft"] as const).reduce<
    { key: 'active' | 'upcoming' | 'closed' | 'draft'; dasharray: string; dashoffset: string; length: number }[]
  >((segments, key) => {
    const count = statusCounts[key];
    if (count <= 0 || totalByStatus <= 0) return segments;
    const length = (count / totalByStatus) * DONUT_CIRCUMFERENCE;
    const previous = segments.reduce((sum, seg) => sum + seg.length, 0);
    const dasharray = `${length} ${DONUT_CIRCUMFERENCE - length}`;
    const dashoffset = previous > 0 ? `-${previous}` : "0";
    segments.push({ key, dasharray, dashoffset, length });
    return segments;
  }, []);

  return (
    <AdminShell active="dashboard">
      <section className="space-y-7">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Dashboard</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">System overview for City University Malaysia</p>
          </div>
          <div className="flex items-center gap-3">
            <ChainBadge chain={chain} error={chainError} />
            <Link href="/admin/elections/create/basic-info" className="brand-gradient rounded-md px-5 py-2 text-sm font-semibold text-white shadow-[0_0_20px_rgba(79,110,247,0.3)]">New Election</Link>
          </div>
        </div>

        {loading ? (
          <div className="rounded-xl bg-[var(--surface-container)] p-10 text-center text-sm text-[var(--text-muted)]">
            Loading dashboard data...
          </div>
        ) : error ? (
          <div className="rounded-xl border border-rose-500/30 bg-rose-500/8 p-10 text-center text-sm text-rose-300">
            {error}
          </div>
        ) : (
          <>
            <div className="grid gap-5 md:grid-cols-2 xl:grid-cols-5">
              {kpis.map((kpi) => (
                <article key={kpi.title} className="card-soft rounded-2xl p-5 transition-shadow duration-300 hover:shadow-[0_18px_40px_-18px_color-mix(in_srgb,var(--brand)_30%,transparent)]">
                  <p className="text-[10px] font-bold uppercase tracking-[0.15em] text-[var(--text-muted)]">{kpi.title}</p>
                  <div className="mt-3 flex items-end justify-between">
                    <h2 className="text-4xl font-bold leading-none">{kpi.value}</h2>
                    <span className={`rounded px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${kpi.noteClass}`}>{kpi.note}</span>
                  </div>
                </article>
              ))}
            </div>

            <div className="grid gap-5 xl:grid-cols-10">
              <article className="rounded-xl bg-[var(--surface-container)] p-6 xl:col-span-6">
                <div className="mb-5 flex items-center justify-between">
                  <div>
                    <h3 className="text-lg font-semibold">Voter Turnout</h3>
                    <p className="text-xs text-[var(--text-muted)]">Aggregate participation across all elections</p>
                  </div>
                </div>
                <div className="flex items-center gap-8">
                  <div className="shrink-0 text-center">
                    <p className="text-5xl font-bold text-[var(--primary)]">{turnoutPct}%</p>
                    <p className="mt-1 text-xs text-[var(--text-muted)]">Turnout rate</p>
                  </div>
                  <div className="flex-1 space-y-3">
                    <TurnoutBar label="Votes cast" value={stats?.totalVotes ?? 0} max={stats?.approvedVoters ?? 0} />
                    <TurnoutBar label="Approved voters" value={stats?.approvedVoters ?? 0} max={stats?.approvedVoters ?? 0} />
                    <TurnoutBar label="Total registered" value={stats?.totalVoters ?? 0} max={stats?.totalVoters ?? 0} />
                  </div>
                </div>
              </article>

              <article className="rounded-xl bg-[var(--surface-container)] p-6 xl:col-span-4">
                <h3 className="text-lg font-semibold">Election Status</h3>
                <div className="mt-6 flex justify-center">
                  <div className="relative">
                    <svg className="h-44 w-44 -rotate-90" viewBox="0 0 100 100">
                      <circle cx="50" cy="50" r="40" fill="none" stroke="#34343a" strokeWidth="12" />
                      {donutSegments.map((seg) => (
                        <circle
                          key={seg.key}
                          cx="50"
                          cy="50"
                          r="40"
                          fill="none"
                          stroke={statusMeta[seg.key].color}
                          strokeWidth="12"
                          strokeDasharray={seg.dasharray}
                          strokeDashoffset={seg.dashoffset}
                        />
                      ))}
                    </svg>
                    <div className="absolute inset-0 grid place-items-center text-center">
                      <p className="text-3xl font-bold leading-none">{totalByStatus}</p>
                      <p className="text-[10px] font-bold uppercase tracking-[0.12em] text-[var(--text-muted)]">Total</p>
                    </div>
                  </div>
                </div>
                <div className="mt-5 grid grid-cols-2 gap-2 text-xs text-[var(--text-muted)]">
                  <StatusDot color="bg-[#4F6EF7]" text={`Active (${statusCounts.active})`} />
                  <StatusDot color="bg-[#7C3AED]" text={`Upcoming (${statusCounts.upcoming})`} />
                  <StatusDot color="bg-[#10B981]" text={`Closed (${statusCounts.closed})`} />
                  <StatusDot color="bg-[#34343a]" text={`Draft (${statusCounts.draft})`} />
                </div>
              </article>
            </div>

            <div className="grid gap-5 xl:grid-cols-10">
              <article className="overflow-hidden rounded-xl bg-[var(--surface-container)] xl:col-span-6">
                <div className="flex items-center justify-between bg-[var(--surface-container-low)] px-6 py-4">
                  <h4 className="text-[10px] font-bold uppercase tracking-[0.15em] text-[var(--text-muted)]">Recent Elections</h4>
                  <Link href="/admin/elections" className="text-xs font-semibold text-[var(--primary)]">View All</Link>
                </div>
                <div className="overflow-x-auto">
                  <table className="w-full min-w-[640px] text-left">
                    <thead className="bg-[var(--surface-container-low)]/70 text-[10px] font-bold uppercase tracking-[0.12em] text-[var(--text-muted)]">
                      <tr>
                        <th className="px-6 py-3">ID</th>
                        <th className="px-6 py-3">Election Name</th>
                        <th className="px-6 py-3">Status</th>
                        <th className="px-6 py-3">Candidates</th>
                        <th className="px-6 py-3">Action</th>
                      </tr>
                    </thead>
                    <tbody>
                      {recentElections.map((row) => {
                        const statusLabel = row.status.charAt(0).toUpperCase() + row.status.slice(1);
                        const statusClass =
                          row.status === "active"
                            ? "text-emerald-400 bg-emerald-500/10"
                            : row.status === "closed"
                              ? "text-white/65 bg-white/8"
                              : "text-[var(--primary)] bg-[var(--primary)]/10";
                        return (
                          <tr key={row.id} className="border-t border-white/5 text-sm hover:bg-[var(--surface-container-high)]/40">
                            <td className="px-6 py-4 font-mono text-xs text-white/55">#{row.id}</td>
                            <td className="px-6 py-4 font-semibold">{row.title}</td>
                            <td className="px-6 py-4">
                              <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${statusClass}`}>{statusLabel}</span>
                            </td>
                            <td className="px-6 py-4">
                              <span className="rounded-full bg-white/8 px-2 py-0.5 text-xs font-bold">{row.candidateCount ?? 0}</span>
                            </td>
                            <td className="px-6 py-4">
                              <Link href={`/admin/elections/overview?id=${row.id}`} className="text-xs font-semibold text-[var(--primary)] hover:underline">
                                {row.status === "active" ? "Monitor" : row.status === "closed" ? "Audit" : "Setup"}
                              </Link>
                            </td>
                          </tr>
                        );
                      })}
                      {recentElections.length === 0 ? (
                        <tr className="border-t border-white/5">
                          <td colSpan={5} className="px-6 py-8 text-center text-sm text-[var(--text-muted)]">
                            No elections found.
                          </td>
                        </tr>
                      ) : null}
                    </tbody>
                  </table>
                </div>
              </article>

              <article className="rounded-xl bg-[var(--surface-container)] p-6 xl:col-span-4">
                <div className="mb-5 flex items-center justify-between">
                  <h4 className="text-[10px] font-bold uppercase tracking-[0.15em] text-[var(--text-muted)]">Live Alerts</h4>
                  <span className="rounded-full bg-rose-500/15 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] text-rose-300">
                    {alerts.filter((alert) => toneForSeverity(alert.severity) === "rose").length} Critical
                  </span>
                </div>
                <div className="space-y-3">
                  {alerts.slice(0, 5).map((alert) => (
                    <AlertCard
                      key={alert.id}
                      tone={toneForSeverity(alert.severity)}
                      title={alert.type}
                      sub={alert.target ?? alert.severity}
                    />
                  ))}
                  {alerts.length === 0 ? (
                    <p className="rounded-lg bg-[var(--surface-container-low)] p-3 text-sm text-[var(--text-muted)]">
                      No active alerts.
                    </p>
                  ) : null}
                </div>
              </article>
            </div>
          </>
        )}
      </section>
    </AdminShell>
  );
}

function TurnoutBar({ label, value, max }: { label: string; value: number; max: number }) {
  const pct = max > 0 ? Math.round((value / max) * 100) : 0;
  return (
    <div>
      <div className="mb-1 flex items-center justify-between text-xs">
        <span className="text-[var(--text-muted)]">{label}</span>
        <span className="font-mono">{value.toLocaleString()}</span>
      </div>
      <div className="h-2 rounded-full bg-[var(--surface-container-high)]">
        <div className="brand-gradient h-2 rounded-full" style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

function StatusDot({ color, text }: { color: string; text: string }) {
  return (
    <span className="inline-flex items-center gap-2">
      <i className={`h-2 w-2 rounded-full ${color}`} />
      {text}
    </span>
  );
}

function AlertCard({
  tone,
  title,
  sub,
}: {
  tone: StatusTone;
  title: string;
  sub: string;
}) {
  const toneClass = {
    rose: "border-rose-500/45 bg-rose-500/8",
    amber: "border-amber-500/45 bg-amber-500/8",
    blue: "border-sky-500/45 bg-sky-500/8",
  }[tone];

  return (
    <div className={`rounded-lg border-l-2 p-3 ${toneClass}`}>
      <p className="text-sm font-semibold">{title}</p>
      <p className="mt-1 text-xs text-[var(--text-muted)]">{sub}</p>
    </div>
  );
}

function ChainBadge({ chain, error }: { chain: ChainStatus | null; error: string | null }) {
  if (error) {
    return (
      <span
        title={error}
        className="inline-flex items-center gap-2 rounded-full bg-white/5 px-3 py-1.5 text-xs text-[var(--text-muted)]"
      >
        <i className="h-2 w-2 rounded-full bg-white/30" />
        Audit chain: unknown
      </span>
    );
  }
  if (!chain) {
    return (
      <span className="inline-flex items-center gap-2 rounded-full bg-white/5 px-3 py-1.5 text-xs text-[var(--text-muted)]">
        <i className="h-2 w-2 animate-pulse rounded-full bg-white/40" />
        Audit chain: checking...
      </span>
    );
  }
  if (chain.ok) {
    return (
      <span
        title={`${chain.totalEntries} entries verified`}
        className="inline-flex items-center gap-2 rounded-full bg-emerald-500/12 px-3 py-1.5 text-xs font-semibold text-emerald-300 ring-1 ring-emerald-500/30"
      >
        <i className="h-2 w-2 rounded-full bg-emerald-400" />
        Audit chain healthy ({chain.totalEntries})
      </span>
    );
  }
  return (
    <span
      title={`Broken at entry ${chain.brokenAt}`}
      className="inline-flex items-center gap-2 rounded-full bg-rose-500/15 px-3 py-1.5 text-xs font-semibold text-rose-300 ring-1 ring-rose-500/35"
    >
      <i className="h-2 w-2 rounded-full bg-rose-400" />
      Audit chain BROKEN
    </span>
  );
}