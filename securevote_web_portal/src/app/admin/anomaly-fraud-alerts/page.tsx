"use client";

import { useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";

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

const starterAlerts: FraudAlert[] = [
  {
    id: "ALG-9942",
    election: "Student Council 2026",
    rule: "DUPLICATE_DEVICE",
    severity: "critical",
    score: 94,
    status: "open",
    detectedAt: "2m ago",
    signal: "7 votes from one device fingerprint in 48s",
  },
  {
    id: "ALG-9921",
    election: "Union Board Referendum",
    rule: "GEOLOCATION_JUMP",
    severity: "high",
    score: 82,
    status: "investigating",
    detectedAt: "9m ago",
    signal: "4,320km movement within 3 minutes",
  },
  {
    id: "ALG-9878",
    election: "Faculty Senate 2026",
    rule: "SESSION_REPLAY",
    severity: "high",
    score: 76,
    status: "open",
    detectedAt: "24m ago",
    signal: "Repeated signed payload hash detected",
  },
  {
    id: "ALG-9806",
    election: "Clubs Council",
    rule: "VOTE_RATE_SPIKE",
    severity: "medium",
    score: 64,
    status: "resolved",
    detectedAt: "1h ago",
    signal: "Traffic spike normalized after captcha challenge",
  },
];

export default function AnomalyFraudAlertsPage() {
  const [alerts, setAlerts] = useState<FraudAlert[]>(starterAlerts);
  const [severityFilter, setSeverityFilter] = useState<"all" | Severity>("all");
  const [statusFilter, setStatusFilter] = useState<"all" | AlertStatus>("all");
  const [selected, setSelected] = useState(starterAlerts[0]?.id ?? "");

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
              onClick={() => {
                const id = `ALG-${Math.floor(Math.random() * 9000 + 1000)}`;
                const injected: FraudAlert = {
                  id,
                  election: "Student Council 2026",
                  rule: "UNUSUAL_BROWSER_PATTERN",
                  severity: "medium",
                  score: 61,
                  status: "open",
                  detectedAt: "just now",
                  signal: "Automated fingerprint variance crossed threshold",
                };
                setAlerts((prev) => [injected, ...prev]);
                setSelected(id);
              }}
              className="ml-auto rounded-lg bg-[var(--surface-container-high)] px-4 py-2 text-sm font-semibold"
            >
              Simulate Alert
            </button>
          </div>
        </section>

        <div className="grid gap-6 xl:grid-cols-[1.25fr,0.95fr]">
          <section className="space-y-3">
            {filtered.map((alert) => (
              <article
                key={alert.id}
                onClick={() => setSelected(alert.id)}
                className={`cursor-pointer rounded-xl border p-4 transition ${
                  active?.id === alert.id
                    ? "border-[var(--primary)]/50 bg-[var(--primary)]/8"
                    : "border-white/8 bg-[var(--surface-container)] hover:bg-[var(--surface-container-high)]/40"
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
                <p className="mt-3 text-sm text-white/85">{alert.signal}</p>
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

                <div className="mt-5 rounded-lg border border-white/8 bg-[var(--surface-container-low)] p-4">
                  <p className="text-[10px] font-bold uppercase tracking-[0.1em] text-[var(--text-muted)]">Signal Trace</p>
                  <p className="mt-2 text-sm text-white/85">{active.signal}</p>
                </div>

                <div className="mt-6 grid grid-cols-2 gap-3">
                  <button
                    type="button"
                    onClick={() => {
                      setAlerts((prev) =>
                        prev.map((item) => (item.id === active.id ? { ...item, status: "investigating" } : item)),
                      );
                    }}
                    className="rounded-lg bg-[var(--surface-container-high)] px-4 py-2 text-sm"
                  >
                    Assign Analyst
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setAlerts((prev) =>
                        prev.map((item) => (item.id === active.id ? { ...item, status: "resolved" } : item)),
                      );
                    }}
                    className="brand-gradient rounded-lg px-4 py-2 text-sm font-semibold text-white"
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
