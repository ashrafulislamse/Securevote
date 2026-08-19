"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import * as api from "@/lib/api-client";
import type { Alert } from "@/lib/api-client";

type Severity = "critical" | "high" | "medium" | "low";
type AlertStatus = "open" | "investigating" | "resolved";

type FraudAlert = {
  id: string;
  election: string;
  rule: string;
  severity: Severity;
  score: number;
  status: AlertStatus;
  detectedAt: string;
  signal: string;
};

const API_SEVERITY: Severity[] = ["critical", "high", "medium", "low"];
const API_STATUS: AlertStatus[] = ["open", "investigating", "resolved"];

function toFraudAlert(alert: Alert): FraudAlert {
  const severity: Severity = API_SEVERITY.includes(alert.severity as Severity)
    ? (alert.severity as Severity)
    : "medium";
  const status: AlertStatus = API_STATUS.includes(alert.status as AlertStatus)
    ? (alert.status as AlertStatus)
    : "open";
  const detectedAt = formatDetectedAt(alert.createdAt);
  const target = alert.target ?? alert.title ?? "Unknown election";
  return {
    id: alert.id,
    election: target,
    rule: alert.type,
    severity,
    score: alert.count ?? 50,
    status,
    detectedAt,
    signal: alert.body ?? `Flagged by ${alert.type} rule${alert.count ? ` (${alert.count} signals)` : ""}. Target: ${target}.`,
  };
}

function formatDetectedAt(createdAt: number): string {
  if (!createdAt) return "unknown";
  const seconds = Math.max(0, Math.floor((Date.now() - createdAt) / 1000));
  if (seconds < 60) return "just now";
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.floor(hours / 24);
  return `${days}d ago`;
}

export default function AnomalyFraudAlertsPage() {
  const [alerts, setAlerts] = useState<FraudAlert[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [severityFilter, setSeverityFilter] = useState<"all" | Severity>("all");
  const [statusFilter, setStatusFilter] = useState<"all" | AlertStatus>("all");
  const [selected, setSelected] = useState("");
  const [action, setAction] = useState<{ busy: boolean; error: string | null; success: string | null }>({
    busy: false,
    error: null,
    success: null,
  });

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const items = await api.getAlerts();
      const mapped = items.map(toFraudAlert);
      setAlerts(mapped);
      setSelected((prev) => (prev && mapped.some((a) => a.id === prev) ? prev : mapped[0]?.id ?? ""));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load alerts");
      setAlerts([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const filtered = useMemo(() => {
    return alerts.filter((alert) => {
      const severityOk = severityFilter === "all" || alert.severity === severityFilter;
      const statusOk = statusFilter === "all" || alert.status === statusFilter;
      return severityOk && statusOk;
    });
  }, [alerts, severityFilter, statusFilter]);

  const active = filtered.find((item) => item.id === selected) ?? filtered[0] ?? null;
  const openCount = alerts.filter((item) => item.status === "open").length;
  const criticalCount = alerts.filter((item) => item.severity === "critical" && item.status !== "resolved").length;

  const runMutation = async (fn: () => Promise<unknown>, successMsg: string, errMsg: string) => {
    setAction({ busy: true, error: null, success: null });
    try {
      await fn();
      await load();
      setAction({ busy: false, error: null, success: successMsg });
    } catch (err) {
      setAction({ busy: false, error: err instanceof Error ? err.message : errMsg, success: null });
    }
  };

  const simulateAlert = () => {
    void runMutation(
      () =>
        api.createAlert({
          type: "UNUSUAL_BROWSER_PATTERN",
          severity: "medium",
          target: "Student Council 2026",
          title: "Browser fingerprint variance",
          body: "Automated fingerprint variance crossed threshold.",
        }),
      "Alert created.",
      "Failed to create alert",
    );
  };

  const assignAnalyst = () => {
    if (!active) return;
    void runMutation(
      () => api.assignAlert(active.id),
      "Alert assigned to you.",
      "Failed to assign alert",
    );
  };

  const markResolved = () => {
    if (!active) return;
    void runMutation(
      () => api.resolveAlert(active.id, "resolved"),
      "Alert marked resolved.",
      "Failed to resolve alert",
    );
  };

  return (
    <AdminShell active="elections">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Risk Engine / Fraud Rules</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Anomaly and Fraud Alerts</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Real-time detection surface for suspicious voting behavior and cryptographic integrity violations.</p>
          </div>
          <div className="flex items-center gap-2">
            <Badge label="Open" value={openCount} tone="amber" />
            <Badge label="Critical" value={criticalCount} tone="rose" />
          </div>
        </div>

        {error ? (
          <div className="rounded-xl border border-rose-500/35 bg-rose-500/10 p-4 text-sm text-rose-300">{error}</div>
        ) : null}

        <section className="rounded-xl bg-[var(--surface-container)] p-4">
          <div className="flex flex-wrap items-center gap-3">
            <select
              value={severityFilter}
              onChange={(event) => setSeverityFilter(event.target.value as "all" | Severity)}
              className="h-10 rounded-lg bg-[var(--surface-container-low)] px-3 text-sm"
            >
              <option value="all">Severity: All</option>
              <option value="critical">Critical</option>
              <option value="high">High</option>
              <option value="medium">Medium</option>
              <option value="low">Low</option>
            </select>
            <select
              value={statusFilter}
              onChange={(event) => setStatusFilter(event.target.value as "all" | AlertStatus)}
              className="h-10 rounded-lg bg-[var(--surface-container-low)] px-3 text-sm"
            >
              <option value="all">Status: All</option>
              <option value="open">Open</option>
              <option value="investigating">Investigating</option>
              <option value="resolved">Resolved</option>
            </select>
            <button
              type="button"
              onClick={simulateAlert}
              disabled={action.busy}
              className="ml-auto rounded-lg bg-[var(--surface-container-high)] px-4 py-2 text-sm font-semibold disabled:opacity-50"
            >
              {action.busy ? "Working..." : "Simulate Alert"}
            </button>
          </div>
        </section>

        {action.error ? <p className="text-sm text-rose-300">{action.error}</p> : null}
        {action.success ? <p className="text-sm text-emerald-300">{action.success}</p> : null}

        {loading ? (
          <div className="rounded-xl bg-[var(--surface-container)] p-8 text-center text-sm text-[var(--text-muted)]">
            Loading alerts...
          </div>
        ) : (
          <div className="grid gap-6 xl:grid-cols-[1.25fr,0.95fr]">
            <section className="space-y-3">
              {filtered.map((alert) => (
                <article
                  key={alert.id}
                  onClick={() => setSelected(alert.id)}
                  className={`cursor-pointer rounded-xl border p-4 transition ${
                    active?.id === alert.id
                      ? "border-[var(--primary)]/50 bg-[var(--primary)]/8"
                      : "border-[var(--border-subtle)] bg-[var(--surface-container)] hover:bg-[var(--surface-container-high)]/40"
                  }`}
                >
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <div>
                      <p className="text-sm font-semibold">{alert.rule}</p>
                      <p className="text-xs text-[var(--text-muted)]">{alert.election}</p>
                    </div>
                    <div className="flex items-center gap-2">
                      <SeverityPill severity={alert.severity} />
                      <StatusPill status={alert.status} />
                    </div>
                  </div>
                  <p className="mt-3 text-sm text-[var(--text-secondary)]">{alert.signal}</p>
                  <div className="mt-3 flex items-center justify-between text-xs text-[var(--text-muted)]">
                    <span>Risk score: {alert.score}</span>
                    <span>{alert.detectedAt}</span>
                  </div>
                </article>
              ))}
              {filtered.length === 0 ? (
                <p className="rounded-lg bg-[var(--surface-container)] px-4 py-6 text-center text-sm text-[var(--text-muted)]">No alerts match selected filters.</p>
              ) : null}
            </section>

            <aside className="rounded-xl bg-[var(--surface-container)] p-5">
              {active ? (
                <>
                  <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Investigation Panel</p>
                  <h2 className="mt-3 text-2xl font-bold tracking-tight">{active.id}</h2>
                  <p className="text-sm text-[var(--text-muted)]">{active.rule} in {active.election}</p>

                  <div className="mt-5 space-y-3 text-sm">
                    <Detail label="Severity" value={active.severity.toUpperCase()} />
                    <Detail label="Risk Score" value={`${active.score}/100`} mono />
                    <Detail label="Status" value={active.status} />
                    <Detail label="Detected" value={active.detectedAt} />
                  </div>

                  <div className="mt-5 rounded-lg border border-[var(--border-subtle)] bg-[var(--surface-container-low)] p-4">
                    <p className="text-[10px] font-bold uppercase tracking-[0.1em] text-[var(--text-muted)]">Signal Trace</p>
                    <p className="mt-2 text-sm text-[var(--text-secondary)]">{active.signal}</p>
                  </div>

                  <div className="mt-6 grid grid-cols-2 gap-3">
                    <button
                      type="button"
                      onClick={assignAnalyst}
                      disabled={action.busy || active.status === "resolved"}
                      className="rounded-lg bg-[var(--surface-container-high)] px-4 py-2 text-sm disabled:opacity-50"
                    >
                      Assign Analyst
                    </button>
                    <button
                      type="button"
                      onClick={markResolved}
                      disabled={action.busy || active.status === "resolved"}
                      className="brand-gradient rounded-lg px-4 py-2 text-sm font-semibold text-white disabled:opacity-50"
                    >
                      Mark Resolved
                    </button>
                  </div>
                </>
              ) : (
                <p className="text-sm text-[var(--text-muted)]">Select an alert to inspect details.</p>
              )}
            </aside>
          </div>
        )}
      </section>
    </AdminShell>
  );
}

function Detail({ label, value, mono = false }: { label: string; value: string; mono?: boolean }) {
  return (
    <div className="flex items-center justify-between rounded-lg bg-[var(--surface-container-low)] px-3 py-2">
      <p className="text-xs uppercase tracking-[0.08em] text-[var(--text-muted)]">{label}</p>
      <p className={mono ? "font-mono text-sm" : "text-sm font-semibold"}>{value}</p>
    </div>
  );
}

function SeverityPill({ severity }: { severity: Severity }) {
  const styles: Record<Severity, string> = {
    critical: "bg-rose-500/15 text-rose-300",
    high: "bg-orange-500/15 text-orange-300",
    medium: "bg-amber-500/15 text-amber-300",
    low: "bg-emerald-500/15 text-emerald-300",
  };
  return <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${styles[severity]}`}>{severity}</span>;
}

function StatusPill({ status }: { status: AlertStatus }) {
  const styles: Record<AlertStatus, string> = {
    open: "bg-rose-500/15 text-rose-300",
    investigating: "bg-blue-500/15 text-blue-300",
    resolved: "bg-emerald-500/15 text-emerald-300",
  };
  return <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${styles[status]}`}>{status}</span>;
}

function Badge({ label, value, tone }: { label: string; value: number; tone: "amber" | "rose" }) {
  return (
    <div className={`rounded-lg px-3 py-2 ${tone === "rose" ? "bg-rose-500/12" : "bg-amber-500/12"}`}>
      <p className="text-[10px] uppercase tracking-[0.1em] text-[var(--text-muted)]">{label}</p>
      <p className="text-lg font-bold">{value}</p>
    </div>
  );
}