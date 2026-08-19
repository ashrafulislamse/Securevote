"use client";

import Link from "next/link";
import { useCallback, useEffect, useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import { bulkUpdateVoterStatus, listVoters, notifyVoters } from "@/lib/api-client";
import type { Voter } from "@/lib/api-client";

type StatusFilter = "All" | "approved" | "pending" | "rejected";

/** Backend KYC status value -> display label. */
const STATUS_LABEL: Record<string, string> = {
  approved: "Verified",
  pending: "Pending",
  rejected: "Rejected",
};

function formatDate(ts?: number) {
  if (!ts) return "—";
  return new Date(ts).toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

export default function VoterListPage() {
  const [query, setQuery] = useState("");
  const [status, setStatus] = useState<StatusFilter>("All");
  const [selected, setSelected] = useState<string[]>([]);
  const [voters, setVoters] = useState<Voter[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [action, setAction] = useState<{ busy: boolean; error: string | null; success: string | null }>({
    busy: false,
    error: null,
    success: null,
  });

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await listVoters({
        q: query.trim() || undefined,
        kycStatus: status === "All" ? undefined : status,
      });
      setVoters(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load voters");
      setVoters([]);
    } finally {
      setLoading(false);
    }
  }, [query, status]);

  useEffect(() => {
    load();
  }, [load]);

  const applyBulk = async (decision: "approved" | "rejected") => {
    if (selected.length === 0) return;
    setAction({ busy: true, error: null, success: null });
    try {
      await bulkUpdateVoterStatus(selected, decision);
      setSelected([]);
      await load();
      setAction({ busy: false, error: null, success: `${selected.length} voter(s) marked ${decision}.` });
    } catch (err) {
      setAction({ busy: false, error: err instanceof Error ? err.message : "Failed to update voters", success: null });
    }
  };

  const notifySelected = async () => {
    if (selected.length === 0) return;
    setAction({ busy: true, error: null, success: null });
    try {
      const res = await notifyVoters(selected, "SecureVote update", "You have an update from the election administrator.");
      setSelected([]);
      setAction({ busy: false, error: null, success: `${res.inserted} notification(s) sent.` });
    } catch (err) {
      setAction({ busy: false, error: err instanceof Error ? err.message : "Failed to notify voters", success: null });
    }
  };

  const counts = useMemo(() => {
    const verified = voters.filter((v) => STATUS_LABEL[v.kycStatus] === "Verified").length;
    const pending = voters.filter((v) => STATUS_LABEL[v.kycStatus] === "Pending").length;
    const rejected = voters.filter((v) => STATUS_LABEL[v.kycStatus] === "Rejected").length;
    return { total: voters.length, verified, pending, rejected };
  }, [voters]);

  return (
    <AdminShell active="voters">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Voter Registry</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Track identity status, participation, and KYC readiness across all voters.</p>
          </div>
          <div className="flex gap-3">
            <Link href="/admin/voters/kyc-verification" className="rounded-lg bg-[var(--surface-container)] px-4 py-2 text-sm font-semibold">
              Open KYC Queue
            </Link>
            <Link href="/admin/voters/import" className="brand-gradient rounded-lg px-5 py-2 text-sm font-semibold text-white">
              Import Voters
            </Link>
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-4">
          <StatCard title="Total" value={String(counts.total)} tone="text-[var(--text-primary)]" />
          <StatCard title="Verified" value={String(counts.verified)} tone="text-emerald-300" />
          <StatCard title="Pending" value={String(counts.pending)} tone="text-amber-300" />
          <StatCard title="Rejected" value={String(counts.rejected)} tone="text-rose-300" />
        </div>

        <section className="rounded-xl bg-[var(--surface-container)] p-4">
          <div className="flex flex-wrap items-center gap-3">
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="h-10 w-80 rounded-lg bg-[var(--surface-container-low)] px-3 text-sm"
              placeholder="Search by name, email, voter ID"
            />
            <select value={status} onChange={(e) => setStatus(e.target.value as StatusFilter)} className="h-10 rounded-lg bg-[var(--surface-container-low)] px-3 text-sm">
              <option value="All">Status: All</option>
              <option value="approved">Verified</option>
              <option value="pending">Pending</option>
              <option value="rejected">Rejected</option>
            </select>
            <p className="ml-auto text-xs text-[var(--text-muted)]">{voters.length} records</p>
          </div>
        </section>

        <section className="overflow-hidden rounded-xl bg-[var(--surface-container)]">
          {selected.length > 0 ? (
            <div className="flex flex-wrap items-center justify-between gap-2 border-b border-[var(--border-subtle)] bg-[var(--primary)]/8 px-5 py-3">
              <p className="text-sm">{selected.length} selected</p>
              <div className="flex flex-wrap items-center gap-2">
                {action.error ? <span className="text-xs text-rose-300">{action.error}</span> : null}
                {action.success ? <span className="text-xs text-emerald-300">{action.success}</span> : null}
                <button onClick={() => applyBulk("approved")} disabled={action.busy} className="rounded-md bg-emerald-500/15 px-3 py-1 text-xs font-semibold text-emerald-300 disabled:opacity-50">Approve</button>
                <button onClick={() => applyBulk("rejected")} disabled={action.busy} className="rounded-md bg-rose-500/15 px-3 py-1 text-xs font-semibold text-rose-300 disabled:opacity-50">Reject</button>
                <button onClick={notifySelected} disabled={action.busy} className="rounded-md bg-[var(--surface-container-high)] px-3 py-1 text-xs font-semibold disabled:opacity-50">Notify</button>
              </div>
            </div>
          ) : null}

          {loading ? (
            <p className="px-5 py-10 text-center text-sm text-[var(--text-muted)]">Loading voter registry...</p>
          ) : error ? (
            <p className="px-5 py-10 text-center text-sm text-rose-300">{error}</p>
          ) : voters.length === 0 ? (
            <p className="px-5 py-10 text-center text-sm text-[var(--text-muted)]">No voters match the current filters.</p>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full min-w-[940px] text-left">
                <thead className="bg-[var(--surface-container-low)] text-[11px] uppercase tracking-[0.1em] text-[var(--text-muted)]">
                  <tr>
                    <th className="px-4 py-3">
                      <input
                        type="checkbox"
                        checked={voters.length > 0 && selected.length === voters.length}
                        onChange={(event) => {
                          if (event.target.checked) {
                            setSelected(voters.map((v) => v.id));
                          } else {
                            setSelected([]);
                          }
                        }}
                      />
                    </th>
                    <th className="px-4 py-3">Voter</th>
                    <th className="px-4 py-3">Contact</th>
                    <th className="px-4 py-3">Joined</th>
                    <th className="px-4 py-3 text-center">Status</th>
                    <th className="px-4 py-3 text-center">Role</th>
                    <th className="px-4 py-3 text-right">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {voters.map((voter) => {
                    const checked = selected.includes(voter.id);
                    return (
                      <tr key={voter.id} className={`border-t border-[var(--border-subtle)] text-sm ${checked ? "bg-[var(--primary)]/7" : "hover:bg-[var(--surface-container-high)]/25"}`}>
                        <td className="px-4 py-4">
                          <input
                            type="checkbox"
                            checked={checked}
                            onChange={() => {
                              setSelected((prev) => (checked ? prev.filter((id) => id !== voter.id) : [...prev, voter.id]));
                            }}
                          />
                        </td>
                        <td className="px-4 py-4">
                          <p className="font-semibold">{voter.fullName}</p>
                          <p className="font-mono text-[11px] text-[var(--text-muted)]">{voter.id}</p>
                        </td>
                        <td className="px-4 py-4">
                          <p>{voter.email}</p>
                          <p className="text-xs text-[var(--text-muted)]">{voter.phone ?? "—"}</p>
                        </td>
                        <td className="px-4 py-4">{formatDate(voter.createdAt)}</td>
                        <td className="px-4 py-4 text-center">
                          <StatusPill status={STATUS_LABEL[voter.kycStatus] ?? voter.kycStatus} />
                        </td>
                        <td className="px-4 py-4 text-center capitalize">{voter.role}</td>
                        <td className="px-4 py-4 text-right">
                          <Link href={`/admin/voters/profile?id=${voter.id}`} className="text-xs font-semibold text-[var(--primary)]">
                            View
                          </Link>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
        </section>
      </section>
    </AdminShell>
  );
}

function StatusPill({ status }: { status: string }) {
  const tone =
    status === "Verified"
      ? "bg-emerald-500/15 text-emerald-300"
      : status === "Pending"
        ? "bg-amber-500/15 text-amber-300"
        : "bg-rose-500/15 text-rose-300";

  return <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${tone}`}>{status}</span>;
}

function StatCard({ title, value, tone }: { title: string; value: string; tone: string }) {
  return (
    <article className="top-accent rounded-xl bg-[var(--surface-container)] p-4">
      <p className="text-[10px] font-semibold uppercase tracking-[0.12em] text-[var(--text-muted)]">{title}</p>
      <p className={`mt-1 text-2xl font-bold ${tone}`}>{value}</p>
    </article>
  );
}