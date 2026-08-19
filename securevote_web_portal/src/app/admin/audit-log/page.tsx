"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import {
  getAuditLog,
  verifyAuditChain,
  type AuditLogEntry,
  type ChainStatus,
} from "@/lib/api-client";

type LogLevel = "info" | "warning" | "critical";

type AuditItem = {
  id: string;
  actor: string;
  action: string;
  entity: string;
  ip: string;
  level: LogLevel;
  timestamp: string;
  prevHash: string;
  entryHash: string;
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
    prevHash: entry.prev_hash ?? "-",
    entryHash: entry.entry_hash ?? "-",
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

function formatHash(hash: string): string {
  if (!hash || hash === "-") return "-";
  if (hash === "genesis") return "genesis";
  // Show first 10 + last 6 chars for compact, monospace display.
  return `${hash.slice(0, 10)}\u2026${hash.slice(-6)}`;
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

type VerifyState =
  | { kind: "idle" }
  | { kind: "loading" }
  | { kind: "ok"; status: ChainStatus }
  | { kind: "broken"; status: ChainStatus };

export default function AuditLogPage() {
  const [logs, setLogs] = useState<AuditItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [query, setQuery] = useState("");
  const [level, setLevel] = useState<"all" | LogLevel>("all");
  const [verify, setVerify] = useState<VerifyState>({ kind: "idle" });

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

  const onVerify = useCallback(async () => {
    setVerify({ kind: "loading" });
    try {
      const status = await verifyAuditChain();
      setVerify(status.ok ? { kind: "ok", status } : { kind: "broken", status });
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to verify chain");
      setVerify({ kind: "idle" });
    }
  }, []);

  const filtered = useMemo(() => {
    return logs.filter((entry) => {
      const levelOk = level === "all" || entry.level === level;
      const key = `${entry.id} ${entry.actor} ${entry.action} ${entry.entity} ${entry.entryHash}`.toLowerCase();
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
            <p className="mt-1 text-sm text-[var(--text-muted)]">
              Immutable operational history with a tamper-evident hash chain. Each entry references the previous
              one via a SHA-256 link, so any modification breaks the chain.
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-2">
            <button
              type="button"
              onClick={onVerify}
              disabled={verify.kind === "loading"}
              className="rounded-lg bg-[var(--surface-container)] px-4 py-2 text-sm font-semibold ring-1 ring-white/10 hover:bg-[var(--surface-container-high)] disabled:opacity-50"
            >
              {verify.kind === "loading" ? "Verifying..." : "Verify Chain"}
            </button>
            <button
              type="button"
              onClick={() => downloadJson(`audit-log-${new Date().toISOString().slice(0, 10)}.json`, filtered)}
              disabled={filtered.length === 0}
              className="brand-gradient rounded-lg px-4 py-2 text-sm font-semibold text-white disabled:opacity-50"
            >
              Export Snapshot
            </button>
          </div>
        </div>

        {error ? (
          <div className="rounded-xl border border-rose-500/35 bg-rose-500/10 p-4 text-sm text-rose-300">{error}</div>
        ) : null}

        <ChainStatusBanner verify={verify} />

        <section className="rounded-xl bg-[var(--surface-container)] p-4">
          <div className="flex flex-wrap items-center gap-3">
            <input
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Search audit id, actor, action, hash..."
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
            <div className="overflow-x-auto">
              <table className="w-full min-w-[1100px] text-left">
                <thead className="bg-[var(--surface-container-low)] text-[11px] uppercase tracking-[0.08em] text-[var(--text-muted)]">
                  <tr>
                    <th className="px-4 py-3">ID</th>
                    <th className="px-4 py-3">Actor</th>
                    <th className="px-4 py-3">Action</th>
                    <th className="px-4 py-3">Entity</th>
                    <th className="px-4 py-3">IP</th>
                    <th className="px-4 py-3">Level</th>
                    <th className="px-4 py-3">Entry Hash</th>
                    <th className="px-4 py-3">Prev Hash</th>
                    <th className="px-4 py-3">Timestamp</th>
                  </tr>
                </thead>
                <tbody>
                  {filtered.map((row) => (
                    <tr key={row.id} className="border-t border-[var(--border-subtle)] text-sm">
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
                      <td className="px-4 py-3">
                        <code className="rounded bg-[var(--surface-container-low)] px-2 py-1 font-mono text-[11px] text-[var(--text-muted)]" title={row.entryHash}>
                          {formatHash(row.entryHash)}
                        </code>
                      </td>
                      <td className="px-4 py-3">
                        <code className="rounded bg-[var(--surface-container-low)] px-2 py-1 font-mono text-[11px] text-[var(--text-muted)]" title={row.prevHash}>
                          {formatHash(row.prevHash)}
                        </code>
                      </td>
                      <td className="px-4 py-3 text-xs text-[var(--text-muted)]">{row.timestamp}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            {filtered.length === 0 ? (
              <p className="px-4 py-8 text-center text-sm text-[var(--text-muted)]">No entries match current filter.</p>
            ) : null}
          </section>
        )}

        <section className="rounded-xl bg-[var(--surface-container)] p-4 text-xs text-[var(--text-muted)]">
          <p className="font-semibold text-[var(--text-secondary)]">How the chain works</p>
          <p className="mt-2">
            <code className="font-mono">entry_hash = sha256(prev_hash || action || actor_id || target_type || target_id || metadata || ip_address || created_at)</code>
          </p>
          <p className="mt-1">
            The first row links to <code className="font-mono">genesis</code>. Every later row links to the previous
            row&apos;s <code className="font-mono">entry_hash</code>. Editing any historical row invalidates every hash
            from that point forward.
          </p>
        </section>
      </section>
    </AdminShell>
  );
}

function ChainStatusBanner({ verify }: { verify: VerifyState }) {
  if (verify.kind === "idle") {
    return (
      <div className="rounded-xl border border-[var(--border-default)] bg-[var(--surface-container)] p-4 text-sm text-[var(--text-muted)]">
        Click <span className="font-semibold text-[var(--text-secondary)]">Verify Chain</span> to walk every entry and
        confirm the hash links are intact.
      </div>
    );
  }
  if (verify.kind === "loading") {
    return (
      <div className="rounded-xl border border-sky-500/35 bg-sky-500/10 p-4 text-sm text-sky-200">
        Walking the hash chain...
      </div>
    );
  }
  const { status } = verify;
  if (status.ok) {
    return (
      <div className="rounded-xl border border-emerald-500/35 bg-emerald-500/10 p-4 text-sm text-emerald-200">
        <p className="font-semibold">Chain integrity verified</p>
        <p className="mt-1 text-xs text-emerald-200/80">
          {status.totalEntries} entries checked
          {status.firstEntryAt ? ` from ${formatTimestamp(status.firstEntryAt)}` : ""}
          {status.lastEntryAt ? ` to ${formatTimestamp(status.lastEntryAt)}` : ""}.
          All hashes match.
        </p>
      </div>
    );
  }
  return (
    <div className="rounded-xl border border-rose-500/45 bg-rose-500/10 p-4 text-sm text-rose-200">
      <p className="font-semibold">Chain integrity BROKEN</p>
      <p className="mt-1 text-xs text-rose-200/85">
        {status.totalEntries} entries inspected; first mismatch at entry{" "}
        <code className="font-mono">{status.brokenAt}</code>.
      </p>
      {status.reason ? <p className="mt-1 text-xs text-rose-200/75">{status.reason}</p> : null}
    </div>
  );
}

function levelClass(level: LogLevel) {
  if (level === "critical") return "bg-rose-500/15 text-rose-300";
  if (level === "warning") return "bg-amber-500/15 text-amber-300";
  return "bg-emerald-500/15 text-emerald-300";
}
