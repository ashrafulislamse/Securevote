"use client";

import { useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";

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

const seedLogs: AuditItem[] = [
  {
    id: "AUD-12001",
    actor: "admin@securevote.io",
    action: "ELECTION_PUBLISHED",
    entity: "Student Council 2026",
    ip: "103.44.20.9",
    level: "info",
    timestamp: "2026-03-24 10:13:02 UTC",
  },
  {
    id: "AUD-12002",
    actor: "security.bot",
    action: "ANOMALY_ESCALATED",
    entity: "ALG-9942",
    ip: "internal",
    level: "critical",
    timestamp: "2026-03-24 10:12:44 UTC",
  },
  {
    id: "AUD-12003",
    actor: "ops@securevote.io",
    action: "VOTER_IMPORT_COMPLETED",
    entity: "2,048 records",
    ip: "103.10.61.20",
    level: "info",
    timestamp: "2026-03-24 09:59:18 UTC",
  },
  {
    id: "AUD-12004",
    actor: "admin@securevote.io",
    action: "KYC_OVERRIDE_REJECTED",
    entity: "VOTER-7712",
    ip: "103.44.20.9",
    level: "warning",
    timestamp: "2026-03-24 09:44:57 UTC",
  },
];

export default function AuditLogPage() {
  const [logs, setLogs] = useState<AuditItem[]>(seedLogs);
  const [query, setQuery] = useState("");
  const [level, setLevel] = useState<"all" | LogLevel>("all");

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
            onClick={() => {
              const now = new Date();
              const log: AuditItem = {
                id: `AUD-${Math.floor(Math.random() * 90000 + 10000)}`,
                actor: "admin@securevote.io",
                action: "AUDIT_EXPORT_GENERATED",
                entity: "CSV snapshot",
                ip: "103.44.20.9",
                level: "info",
                timestamp: `${now.toISOString().slice(0, 19).replace("T", " ")} UTC`,
              };
              setLogs((prev) => [log, ...prev]);
            }}
            className="brand-gradient rounded-lg px-4 py-2 text-sm font-semibold text-white"
          >
            Export Snapshot
          </button>
        </div>

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
            <p className="ml-auto text-xs text-[var(--text-muted)]">{filtered.length} entries</p>
          </div>
        </section>

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
      </section>
    </AdminShell>
  );
}

function levelClass(level: LogLevel) {
  if (level === "critical") return "bg-rose-500/15 text-rose-300";
  if (level === "warning") return "bg-amber-500/15 text-amber-300";
  return "bg-emerald-500/15 text-emerald-300";
}
