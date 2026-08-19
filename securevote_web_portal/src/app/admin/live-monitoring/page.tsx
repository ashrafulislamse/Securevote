"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import { createAlert, getAuditLog, verifyAuditChain, type AuditLogEntry } from "@/lib/api-client";

type FeedItem = {
  id: string;
  action: string;
  actor: string;
  target: string;
  ip: string;
  timestamp: string;
};

const POLL_INTERVAL_MS = 5000;

function formatTimestamp(value: number): string {
  if (!value) return "—";
  const date = new Date(value);
  return date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", second: "2-digit" });
}

function mapLogToFeed(log: AuditLogEntry): FeedItem {
  return {
    id: log.id,
    action: log.action || "event",
    actor: log.actor_id ?? "unknown",
    target: log.target_type ?? log.target_id ?? "—",
    ip: log.ip_address ?? "—",
    timestamp: formatTimestamp(log.created_at),
  };
}

export default function LiveMonitoringPage() {
  const [feed, setFeed] = useState<FeedItem[]>([]);
  const [autoRefresh, setAutoRefresh] = useState(true);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [actionLoading, setActionLoading] = useState<string | null>(null);
  const [actionToast, setActionToast] = useState<{ text: string; tone: "ok" | "err" } | null>(null);
  const mounted = useRef(true);

  const load = useCallback(async () => {
    try {
      const logs = await getAuditLog({ limit: 50 });
      if (!mounted.current) return;
      setFeed(logs.map(mapLogToFeed));
      setError(null);
    } catch (err) {
      if (!mounted.current) return;
      setError(err instanceof Error ? err.message : "Failed to load audit log");
    } finally {
      if (mounted.current) setLoading(false);
    }
  }, []);

  useEffect(() => {
    mounted.current = true;
    void load();
    return () => {
      mounted.current = false;
    };
  }, [load]);

  useEffect(() => {
    if (!autoRefresh) return;
    const id = setInterval(() => {
      void load();
    }, POLL_INTERVAL_MS);
    return () => clearInterval(id);
  }, [autoRefresh, load]);

  const totals = useMemo(() => {
    const totalEvents = feed.length;
    const uniqueActors = new Set(feed.map((item) => item.actor)).size;
    const distinctActions = new Set(feed.map((item) => item.action)).size;
    return { totalEvents, uniqueActors, distinctActions };
  }, [feed]);

  const runAction = async (key: string, fn: () => Promise<string>) => {
    setActionLoading(key);
    setActionToast(null);
    try {
      const msg = await fn();
      setActionToast({ text: msg, tone: "ok" });
    } catch (err) {
      setActionToast({ text: err instanceof Error ? err.message : "Action failed", tone: "err" });
    } finally {
      setActionLoading(null);
      setTimeout(() => setActionToast(null), 5000);
    }
  };

  const openIncidentBridge = () =>
    runAction("incident", async () => {
      await createAlert({
        type: "incident",
        severity: "high",
        title: "Incident bridge opened",
        body: "Coordinated response initiated from Live Monitoring.",
        target: "live-monitoring",
      });
      return "Incident bridge opened — alert created.";
    });

  const requestRegionLock = () =>
    runAction("lock", async () => {
      await createAlert({
        type: "region_lock",
        severity: "critical",
        title: "Region lock requested",
        body: "Suspicious cluster throttling requested from Live Monitoring.",
        target: "live-monitoring",
      });
      return "Region lock request submitted — critical alert created.";
    });

  const runIntegritySnapshot = () =>
    runAction("snapshot", async () => {
      const chain = await verifyAuditChain();
      return chain.ok
        ? `Audit chain healthy — ${chain.totalEntries} entries verified.`
        : `Chain BROKEN at entry ${chain.brokenAt}.`;
    });

  const notifyOversight = () =>
    runAction("oversight", async () => {
      await createAlert({
        type: "oversight_notice",
        severity: "high",
        title: "Oversight team notified",
        body: "Signed update dispatched to oversight team from Live Monitoring.",
        target: "live-monitoring",
      });
      return "Oversight team notification dispatched — alert created.";
    });

  return (
    <AdminShell active="elections">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Operations / Real-time</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Live Monitoring</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Track audit activity, voting throughput, and anomaly pressure in real time.</p>
          </div>
          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={() => setAutoRefresh((value) => !value)}
              className={`rounded-lg px-4 py-2 text-sm font-semibold ${autoRefresh ? "bg-emerald-500/15 text-emerald-300" : "bg-[var(--surface-container-high)] text-[var(--text-muted)]"}`}
            >
              Auto refresh: {autoRefresh ? "On" : "Off"}
            </button>
            <button type="button" onClick={() => void load()} className="brand-gradient rounded-lg px-4 py-2 text-sm font-semibold text-white">
              Refresh Now
            </button>
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-3">
          <MetricCard title="Total Events" value={totals.totalEvents.toLocaleString()} hint="Audit log entries (last 50)" />
          <MetricCard title="Unique Actors" value={`${totals.uniqueActors}`} hint="Distinct principals" />
          <MetricCard title="Distinct Actions" value={`${totals.distinctActions}`} hint="Observed action types" />
        </div>

        {loading ? (
          <div className="rounded-xl bg-[var(--surface-container)] p-10 text-center text-sm text-[var(--text-muted)]">
            Loading live audit feed...
          </div>
        ) : error ? (
          <div className="rounded-xl border border-rose-500/30 bg-rose-500/8 p-10 text-center text-sm text-rose-300">
            {error}
          </div>
        ) : (
          <section className="grid gap-6 xl:grid-cols-[1.2fr,0.8fr]">
            <article className="rounded-xl bg-[var(--surface-container)] p-5">
              <div className="mb-4 flex items-center justify-between">
                <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Audit Activity Feed</p>
                <p className="text-xs text-[var(--text-muted)]">{autoRefresh ? "Updated live" : "Paused"}</p>
              </div>
              <div className="space-y-3">
                {feed.map((item) => (
                  <div key={item.id} className="rounded-lg bg-[var(--surface-container-low)] p-4">
                    <div className="flex items-center justify-between gap-3">
                      <div>
                        <p className="text-sm font-semibold">{item.action}</p>
                        <p className="text-xs text-[var(--text-muted)]">actor: {item.actor}</p>
                      </div>
                      <span className="text-xs text-[var(--text-muted)]">{item.timestamp}</span>
                    </div>
                    <div className="mt-4 grid gap-3 sm:grid-cols-3">
                      <MiniStat label="Target" value={item.target} />
                      <MiniStat label="IP" value={item.ip} />
                      <MiniStat label="ID" value={item.id} />
                    </div>
                  </div>
                ))}
                {feed.length === 0 ? (
                  <p className="rounded-lg bg-[var(--surface-container-low)] p-4 text-center text-sm text-[var(--text-muted)]">
                    No audit events yet.
                  </p>
                ) : null}
              </div>
            </article>

            <article className="rounded-xl bg-[var(--surface-container)] p-5">
              <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Control Actions</p>
              {actionToast ? (
                <div className={`mb-3 rounded-lg px-3 py-2 text-xs font-semibold ${actionToast.tone === "ok" ? "bg-emerald-500/15 text-emerald-300" : "bg-rose-500/15 text-rose-300"}`}>
                  {actionToast.text}
                </div>
              ) : null}
              <div className="mt-4 space-y-3">
                <ActionButton label="Open Incident Bridge" subtitle="Start coordinated response" loading={actionLoading === "incident"} onClick={openIncidentBridge} />
                <ActionButton label="Request Region Lock" subtitle="Throttle suspicious cluster" loading={actionLoading === "lock"} onClick={requestRegionLock} />
                <ActionButton label="Run Integrity Snapshot" subtitle="Recompute vote hash chain" loading={actionLoading === "snapshot"} onClick={runIntegritySnapshot} />
                <ActionButton label="Notify Oversight Team" subtitle="Dispatch signed update" loading={actionLoading === "oversight"} onClick={notifyOversight} />
              </div>

              <div className="mt-6 rounded-lg border border-[var(--primary)]/20 bg-[var(--primary)]/7 p-4">
                <p className="text-[10px] uppercase tracking-[0.1em] text-[var(--text-muted)]">System Note</p>
                <p className="mt-2 text-sm text-[var(--text-secondary)]">Monitoring polls the backend audit log every 5 seconds. Auto-refresh can be paused.</p>
              </div>
            </article>
          </section>
        )}
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
  const toneClass = tone === "warn" ? "text-rose-300" : tone === "ok" ? "text-emerald-300" : "text-[var(--text-primary)]";
  return (
    <div className="rounded-md bg-[var(--surface-container-high)] px-3 py-2">
      <p className="text-[10px] uppercase tracking-[0.1em] text-[var(--text-muted)]">{label}</p>
      <p className={`mt-1 truncate text-sm font-semibold ${toneClass}`}>{value}</p>
    </div>
  );
}

function ActionButton({ label, subtitle, loading, onClick }: { label: string; subtitle: string; loading?: boolean; onClick?: () => void }) {
  return (
    <button type="button" onClick={onClick} disabled={loading} className="w-full rounded-lg bg-[var(--surface-container-low)] px-4 py-3 text-left transition hover:bg-[var(--surface-container-high)] disabled:opacity-50">
      <p className="text-sm font-semibold">{loading ? "Working..." : label}</p>
      <p className="text-xs text-[var(--text-muted)]">{subtitle}</p>
    </button>
  );
}