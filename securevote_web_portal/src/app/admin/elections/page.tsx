"use client";

import Link from "next/link";
import { useCallback, useEffect, useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import * as api from "@/lib/api-client";

type StatusFilter = "All" | api.ElectionStatus;
type TypeFilter = "All" | api.ElectionType;

const STATUS_OPTIONS: { value: StatusFilter; label: string }[] = [
  { value: "All", label: "Status: All" },
  { value: "draft", label: "Draft" },
  { value: "scheduled", label: "Scheduled" },
  { value: "active", label: "Active" },
  { value: "closed", label: "Closed" },
  { value: "published", label: "Published" },
];

const TYPE_OPTIONS: { value: TypeFilter; label: string }[] = [
  { value: "All", label: "Type: All" },
  { value: "single", label: "Single" },
  { value: "multi", label: "Multi" },
  { value: "ranked", label: "Ranked" },
];

export default function ElectionListPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [elections, setElections] = useState<api.Election[]>([]);

  const [query, setQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState<StatusFilter>("All");
  const [typeFilter, setTypeFilter] = useState<TypeFilter>("All");

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await api.listElections({
        status: statusFilter === "All" ? undefined : statusFilter,
        q: query || undefined,
      });
      setElections(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load elections");
    } finally {
      setLoading(false);
    }
  }, [statusFilter, query]);

  useEffect(() => {
    load();
  }, [load]);

  const filtered = useMemo(() => {
    return elections.filter((election) => typeFilter === "All" || election.type === typeFilter);
  }, [elections, typeFilter]);

  const stats = useMemo(() => {
    const count = (status: api.ElectionStatus) => filtered.filter((e) => e.status === status).length;
    return {
      total: filtered.length,
      active: count("active"),
      scheduled: count("scheduled"),
      closed: count("closed"),
      draft: count("draft") + count("published"),
    };
  }, [filtered]);

  const clearFilters = () => {
    setQuery("");
    setStatusFilter("All");
    setTypeFilter("All");
  };

  return (
    <AdminShell active="elections">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Elections</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Manage all elections across your organizations.</p>
          </div>
          <Link href="/admin/elections/create/basic-info" className="brand-gradient rounded-md px-5 py-2.5 text-sm font-semibold text-white shadow-[0_0_20px_rgba(79,110,247,0.3)]">
            Create Election
          </Link>
        </div>

        <div className="rounded-xl bg-[var(--surface-container)] p-4">
          <div className="flex flex-wrap items-center gap-3">
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="h-9 w-72 rounded-lg bg-[var(--surface-container-low)] px-3 text-sm outline-none ring-1 ring-transparent focus:ring-[var(--primary)]"
              placeholder="Search elections..."
            />
            <select value={statusFilter} onChange={(e) => setStatusFilter(e.target.value as StatusFilter)} className="h-9 rounded-lg bg-[var(--surface-container-low)] px-3 text-xs">
              {STATUS_OPTIONS.map((option) => (
                <option key={option.value} value={option.value}>{option.label}</option>
              ))}
            </select>
            <select value={typeFilter} onChange={(e) => setTypeFilter(e.target.value as TypeFilter)} className="h-9 rounded-lg bg-[var(--surface-container-low)] px-3 text-xs">
              {TYPE_OPTIONS.map((option) => (
                <option key={option.value} value={option.value}>{option.label}</option>
              ))}
            </select>
            <button onClick={clearFilters} className="ml-auto text-xs font-semibold text-[var(--primary)]">Clear filters</button>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-6 rounded-xl bg-[var(--surface-container)] px-4 py-3 text-sm">
          <Stat title="Total" value={String(stats.total)} />
          <Stat title="Active" value={String(stats.active)} tone="text-[var(--primary)]" />
          <Stat title="Upcoming" value={String(stats.scheduled)} tone="text-[var(--secondary)]" />
          <Stat title="Closed" value={String(stats.closed)} tone="text-[var(--text-muted)]" />
          <Stat title="Draft" value={String(stats.draft)} tone="text-amber-400" />
        </div>

        <section className="overflow-hidden rounded-xl bg-[var(--surface-container)]">
          <div className="flex items-center justify-between border-b border-[var(--border-subtle)] px-5 py-4">
            <p className="text-sm text-[var(--text-muted)]">{filtered.length} elections found</p>
          </div>

          {loading ? (
            <p className="px-5 py-10 text-center text-sm text-[var(--text-muted)]">Loading elections...</p>
          ) : error ? (
            <div className="px-5 py-10 text-center">
              <p className="text-sm text-rose-300">{error}</p>
              <button onClick={load} className="mt-3 text-xs font-semibold text-[var(--primary)]">Retry</button>
            </div>
          ) : filtered.length === 0 ? (
            <p className="px-5 py-10 text-center text-sm text-[var(--text-muted)]">No elections match your filters.</p>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full min-w-[900px] text-left">
                <thead className="bg-[var(--surface-container-low)]/80 text-[11px] font-semibold uppercase tracking-[0.1em] text-[var(--text-muted)]">
                  <tr>
                    <th className="px-4 py-3">Election</th>
                    <th className="px-4 py-3">Organization</th>
                    <th className="px-4 py-3">Type</th>
                    <th className="px-4 py-3">Schedule</th>
                    <th className="px-4 py-3">Candidates</th>
                    <th className="px-4 py-3">Status</th>
                    <th className="px-4 py-3 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filtered.map((row) => (
                    <tr key={row.id} className="border-t border-[var(--border-subtle)] text-sm hover:bg-[var(--surface-container-high)]/30">
                      <td className="px-4 py-4">
                        <p className="font-semibold">{row.title}</p>
                        <p className="mt-0.5 font-mono text-[11px] text-[var(--text-muted)]">ID: {row.id}</p>
                      </td>
                      <td className="px-4 py-4">{row.organization ?? "—"}</td>
                      <td className="px-4 py-4"><span className="rounded-md bg-[var(--surface-container-high)] px-2 py-0.5 text-xs capitalize">{row.type}</span></td>
                      <td className="px-4 py-4">{formatSchedule(row.startsAt, row.endsAt)}</td>
                      <td className="px-4 py-4">
                        <span className="rounded-full bg-[var(--surface-container-high)] px-2 py-0.5 text-xs font-bold">{row.candidateCount ?? 0}</span>
                      </td>
                      <td className="px-4 py-4">
                        <Status status={row.status} />
                      </td>
                      <td className="px-4 py-4 text-right">
                        <Link href={`/admin/elections/overview?id=${row.id}`} className="text-xs font-semibold text-[var(--primary)] hover:underline">
                          View
                        </Link>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </section>
      </section>
    </AdminShell>
  );
}

function formatSchedule(startsAt: number, endsAt: number): string {
  const start = new Date(startsAt);
  const end = new Date(endsAt);
  const fmt = (date: Date) => date.toLocaleDateString(undefined, { month: "short", day: "numeric" });
  return `${fmt(start)} - ${fmt(end)}`;
}

function Stat({ title, value, tone = "text-[var(--text-primary)]" }: { title: string; value: string; tone?: string }) {
  return (
    <div>
      <p className="text-[10px] font-semibold uppercase tracking-[0.12em] text-[var(--text-muted)]">{title}</p>
      <p className={`text-lg font-bold ${tone}`}>{value}</p>
    </div>
  );
}

function Status({ status }: { status: api.ElectionStatus }) {
  const map: Record<api.ElectionStatus, string> = {
    active: "bg-emerald-500/12 text-emerald-400",
    scheduled: "bg-[var(--primary)]/12 text-[var(--primary)]",
    closed: "bg-[var(--surface-container-high)] text-[var(--text-muted)]",
    draft: "bg-amber-500/12 text-amber-400",
    published: "bg-[var(--secondary)]/12 text-[var(--secondary)]",
  };
  return <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${map[status]}`}>{status}</span>;
}