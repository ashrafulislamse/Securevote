"use client";

import { useEffect, useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import { getAuditLog } from "@/lib/api-client";
import type { AuditLogEntry } from "@/lib/api-client";

type LogLevel = "info" | "warning" | "critical";

type AuditItem = {
  id: string;
  actor: string;
  action: string;
  entity: string;
  ip: string;
  level: LogLevel;
  timestamp: string;
};

function toAuditItem(entry: AuditLogEntry): AuditItem {
  return {
    id: entry.id,
    actor: entry.actor_id ?? "-",
    action: entry.action,
    entity: entry.target_id ?? entry.target_type ?? "-",
    ip: entry.ip_address ?? "-",
    level: deriveLevel(entry.action),
    timestamp: entry.created_at ? formatTimestamp(entry.created_at) : "unknown",
  };
}

// The backend audit log has no severity field, so derive a display level from the action name.
function deriveLevel(action: string): LogLevel {
  const upper = action.toUpperCase();
  if (/(ANOMALY|ESCALAT|REJECT|FAIL|OVERRIDE|BLOCKED|BREACH)/.test(upper)) return "critical";
  if (/(WARN|SUSPEND|REVIEW|FLAG)/.test(upper)) return "warning";
  return "info";
}

function formatTimestamp(epochMs: number): string {
  const date = new Date(epochMs);
  if (Number.isNaN(date.getTime())) return "unknown";
  return date.toISOString().replace("T", " ").slice(0, 19) + " UTC";
}

function downloadJson(filename: string, rows: AuditItem[]) {
  const blob = new Blob([JSON.stringify(rows, null, 2)], { type: "application/json" });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.download = filename;
  document.body.appendChild(anchor);
  anchor.click();
  document.body.removeChild(anchor);
  URL.revokeObjectURL(url);
}

export default function AuditLogPage() {
  const [logs, setLogs] = useState<AuditItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [query, setQuery] = useState("");
  const [level, setLevel] = useState<"all" | LogLevel>("all");

  // Load the audit log from the backend on mount.
  useEffect(() => {
    let active = true;
    (async () => {
      try {
        const entries = await getAuditLog({ limit: 100 });
        if (!active) return;
        setLogs(entries.map(toAuditItem));
      } catch (err) {
        if (active) setError(err instanceof Error ? err.message : "Failed to load audit log");
      } finally {
        if (active) setLoading(false);
      }
    })();
    return () => {
      active = false;
    };
  }, []);

  const filtered = useMemo(() => {
    return logs.filter((entry) => {
      const levelOk = level === "all" || entry.level === level;
      const key = `${entry.id} ${entry.actor} ${entry.action} ${entry.entity}`.toLowerCase();
      const queryOk = key.includes(query.toLowerCase());
      return levelOk && queryOk;
    });
  }, [logs, level, query]);

  return (
    <AdminShell active="elections">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Compliance / Traceability</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Audit Log</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Immutable operational history for election, voter, and security actions.</p>
          </div>
          <button
            type="button"
            onClick={() => downloadJson(`audit-log-${new Date().toISOString().slice(0, 10)}.json`, filtered)}
            disabled={filtered.length === 0}
            className="brand-gradient rounded-lg px-4 py-2 text-sm font-semibold text-white disabled:opacity-50"
          >
            Export Snapshot
          </button>
        </div>

        {error ? (
          <div className="rounded-xl border border-rose-500/35 bg-rose-500/10 p-4 text-sm text-rose-300">{error}</div>
        ) : null}

        <section className="rounded-xl bg-[var(--surface-container)] p-4">
          <div className="flex flex-wrap items-center gap-3">
            <input
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Search audit id, actor, action..."
              className="h-10 w-80 rounded-lg bg-[var(--surface-container-low)] px-3 text-sm outline-none ring-1 ring-transparent focus:ring-[var(--primary)]"
            />
            <select
              value={level}
              onChange={(event) => setLevel(event.target.value as "all" | LogLevel)}
              className="h-10 rounded-lg bg-[var(--surface-container-low)] px-3 text-sm"
            >
              <option value="all">Level: All</option>
              <option value="critical">Critical</option>
              <option value="warning">Warning</option>
              <option value="info">Info</option>
            </select>
            <p className="ml-auto text-xs text-[var(--text-muted)]">{loading ? "Loading..." : `${filtered.length} entries`}</p>
          </div>
        </section>

        {loading ? (
          <div className="rounded-xl bg-[var(--surface-container)] p-8 text-center text-sm text-[var(--text-muted)]">
            Loading audit log...
          </div>
        ) : (
          <section className="overflow-hidden rounded-xl bg-[var(--surface-container)]">
            <table className="w-full text-left">
              <thead className="bg-[var(--surface-container-low)] text-[11px] uppercase tracking-[0.08em] text-[var(--text-muted)]">
                <tr>
                  <th className="px-4 py-3">ID</th>
                  <th className="px-4 py-3">Actor</th>
                  <th className="px-4 py-3">Action</th>
                  <th className="px-4 py-3">Entity</th>
                  <th className="px-4 py-3">IP</th>
                  <th className="px-4 py-3">Level</th>
                  <th className="px-4 py-3">Timestamp</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((row) => (
                  <tr key={row.id} className="border-t border-white/6 text-sm">
                    <td className="px-4 py-3 font-mono text-xs text-[var(--text-muted)]">{row.id}</td>
                    <td className="px-4 py-3">{row.actor}</td>
                    <td className="px-4 py-3 font-semibold">{row.action}</td>
                    <td className="px-4 py-3">{row.entity}</td>
                    <td className="px-4 py-3 font-mono text-xs text-[var(--text-muted)]">{row.ip}</td>
                    <td className="px-4 py-3">
                      <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${levelClass(row.level)}`}>
                        {row.level}
                      </span>
                    </td>
                    <td className="px-4 py-3 text-xs text-[var(--text-muted)]">{row.timestamp}</td>
                  </tr>
                ))}
              </tbody>
            </table>
            {filtered.length === 0 ? (
              <p className="px-4 py-8 text-center text-sm text-[var(--text-muted)]">No entries match current filter.</p>
            ) : null}
          </section>
        )}
      </section>
    </AdminShell>
  );
}

function levelClass(level: LogLevel) {
  if (level === "critical") return "bg-rose-500/15 text-rose-300";
  if (level === "warning") return "bg-amber-500/15 text-amber-300";
  return "bg-emerald-500/15 text-emerald-300";
}