"use client";

import { Suspense } from "react";
import { useCallback, useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { AdminShell } from "@/components/admin-shell";
import * as api from "@/lib/api-client";

const STATUS_LABELS: Record<api.ElectionStatus, string> = {
  draft: "Draft",
  scheduled: "Scheduled",
  active: "Active",
  closed: "Closed",
  published: "Published",
};

export default function ElectionOverviewPage() {
  return (
    <Suspense
      fallback={
        <AdminShell active="elections">
          <p className="text-sm text-[var(--text-muted)]">Loading election control center...</p>
        </AdminShell>
      }
    >
      <ElectionOverviewContent />
    </Suspense>
  );
}

function ElectionOverviewContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const requestedId = searchParams?.get("id") ?? null;

  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [election, setElection] = useState<api.Election | null>(null);
  const [candidateCount, setCandidateCount] = useState<number>(0);
  const [updating, setUpdating] = useState(false);
  const [toast, setToast] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      if (requestedId) {
        const data = await api.getElection(requestedId);
        setElection(data.election);
        setCandidateCount(data.candidates.length);
      } else {
        const elections = await api.listElections();
        const sorted = [...elections].sort((a, b) => b.startsAt - a.startsAt);
        const focus = sorted.find((e) => e.status === "active") ?? sorted[0] ?? null;
        setElection(focus);
        setCandidateCount(focus?.candidateCount ?? 0);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load election");
    } finally {
      setLoading(false);
    }
  }, [requestedId]);

  useEffect(() => {
    load();
  }, [load]);

  const changeStatus = async (next: api.ElectionStatus) => {
    if (!election) return;
    setUpdating(true);
    setToast(null);
    try {
      const result = await api.setElectionStatus(election.id, next);
      if (result.ok) {
        setElection((prev) => (prev ? { ...prev, status: result.status } : prev));
        setToast(`Election status updated to ${STATUS_LABELS[result.status]}.`);
      }
    } catch (err) {
      setToast(err instanceof Error ? err.message : "Failed to update status");
    } finally {
      setUpdating(false);
      setTimeout(() => setToast(null), 4000);
    }
  };

  if (loading) {
    return (
      <AdminShell active="elections">
        <section className="space-y-6">
          <p className="text-sm text-[var(--text-muted)]">Loading election control center...</p>
        </section>
      </AdminShell>
    );
  }

  if (error || !election) {
    return (
      <AdminShell active="elections">
        <section className="space-y-6">
          <p className="text-sm text-rose-300">{error ?? "No election found."}</p>
          <button
            onClick={() => router.push("/admin/elections")}
            className="text-xs font-semibold text-[var(--primary)]"
          >
            Back to elections
          </button>
        </section>
      </AdminShell>
    );
  }

  const typeName = election.type === "single" ? "Single Choice" : election.type === "multi" ? "Multi Choice" : "Ranked Choice";

  return (
    <AdminShell active="elections">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Elections / {election.title}</p>
            <h1 className="mt-2 text-4xl font-bold tracking-tight">Election Control Center</h1>
          </div>
          <div className="flex gap-3">
            <button
              onClick={() => changeStatus(election.status === "active" ? "draft" : "active")}
              disabled={updating}
              className="rounded-lg bg-[var(--surface-container)] px-4 py-2 text-sm disabled:opacity-50"
            >
              {election.status === "active" ? "Suspend" : "Activate"}
            </button>
            <button className="brand-gradient rounded-lg px-5 py-2 text-sm font-semibold text-white">Export Live Feed</button>
          </div>
        </div>

        {toast ? (
          <div className="rounded-lg border-l-2 border-[var(--primary)] bg-[var(--primary)]/10 px-4 py-3 text-sm">{toast}</div>
        ) : null}

        <div className="grid gap-4 md:grid-cols-3 xl:grid-cols-6">
          <Card title="Status" value={STATUS_LABELS[election.status]} tone="text-[var(--primary)]" />
          <Card title="Type" value={typeName} tone="text-[var(--secondary)]" />
          <Card title="Candidates" value={String(candidateCount)} tone="text-white" />
          <Card title="Eligible Voters" value="—" tone="text-[var(--text-muted)]" />
          <Card title="Anomalies" value="—" tone="text-rose-300" />
          <Card title="Time Left" value={formatTimeLeft(election.endsAt)} tone="text-amber-300" />
        </div>

        <div className="grid gap-5 xl:grid-cols-12">
          <aside className="space-y-5 xl:col-span-3">
            <section className="rounded-xl bg-[var(--surface-container)] p-5">
              <h3 className="text-[10px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Election Info</h3>
              <div className="mt-4 space-y-3 text-sm">
                <Field label="Election ID" value={election.id} mono />
                <Field label="Type" value={typeName} />
                <Field label="Organization" value={election.organization ?? "—"} />
                <Field label="Schedule" value={formatSchedule(election.startsAt, election.endsAt)} />
              </div>
            </section>
            <section className="rounded-xl bg-[var(--surface-container)] p-5">
              <h3 className="text-[10px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Status Controls</h3>
              <div className="mt-3 space-y-2">
                {(["draft", "scheduled", "active", "closed", "published"] as api.ElectionStatus[]).map((status) => (
                  <button
                    key={status}
                    onClick={() => changeStatus(status)}
                    disabled={updating || status === election.status}
                    className={`w-full rounded-lg px-3 py-2 text-left text-sm disabled:opacity-40 ${
                      status === election.status ? "brand-gradient text-white" : "bg-[var(--surface-container-high)]"
                    }`}
                  >
                    {STATUS_LABELS[status]}
                  </button>
                ))}
              </div>
            </section>
          </aside>

          <div className="space-y-5 xl:col-span-6">
            <section className="rounded-xl bg-[var(--surface-container)] p-6">
              <h3 className="text-lg font-semibold">Voting Momentum</h3>
              <p className="text-xs text-[var(--text-muted)]">Real-time vote ingestion speed</p>
              <div className="mt-4 h-40 rounded-lg bg-[var(--surface-container-high)]/20 p-4">
                <div className="flex h-full items-end gap-1">
                  {[20, 30, 35, 50, 62, 70, 84, 95, 88, 98].map((h, idx) => (
                    <div key={idx} className="h-full flex-1 rounded-t-sm bg-[var(--primary)]/20">
                      <div className="w-full rounded-t-sm bg-[var(--primary)]" style={{ height: `${h}%`, marginTop: `${100 - h}%` }} />
                    </div>
                  ))}
                </div>
              </div>
            </section>

            <section className="rounded-xl bg-[var(--surface-container)] p-6">
              <h3 className="text-lg font-semibold">Mobile Ballot Preview</h3>
              <div className="mt-4 space-y-3">
                {election.description ? (
                  <div className="rounded-lg bg-[var(--surface-container-low)] p-3 text-sm">{election.description}</div>
                ) : (
                  ["Position 1: President", "Position 2: Secretary", "Position 3: Treasurer"].map((p) => (
                    <div key={p} className="flex items-center gap-3 rounded-lg bg-[var(--surface-container-low)] p-3">
                      <div className="grid h-10 w-10 place-items-center rounded-lg bg-[var(--surface-container-high)] text-[var(--primary)]">
                        <span className="material-symbols-outlined">person</span>
                      </div>
                      <div>
                        <p className="text-sm font-semibold">{p}</p>
                        <p className="text-xs text-[var(--text-muted)]">Select 1 candidate</p>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </section>
          </div>

          <aside className="space-y-5 xl:col-span-3">
            <section className="rounded-xl bg-[var(--surface-container)] p-5">
              <div className="mb-3 flex items-center justify-between">
                <h3 className="text-[10px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Live Alerts</h3>
                <span className="rounded-full bg-rose-500/15 px-2 py-0.5 text-[10px] font-bold text-rose-300">—</span>
              </div>
              <div className="space-y-3">
                <Alert text="No live alerts available for this election." />
              </div>
            </section>
            <section className="rounded-xl bg-[var(--surface-container)] p-5">
              <h3 className="text-[10px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Actions</h3>
              <div className="mt-3 space-y-2">
                <button
                  onClick={() => changeStatus("draft")}
                  disabled={updating}
                  className="w-full rounded-lg bg-[var(--surface-container-high)] px-3 py-2 text-left text-sm disabled:opacity-50"
                >
                  Pause Election
                </button>
                <button className="w-full rounded-lg bg-[var(--surface-container-high)] px-3 py-2 text-left text-sm">Broadcast Notice</button>
                <button
                  onClick={() => changeStatus("closed")}
                  disabled={updating}
                  className="w-full rounded-lg bg-rose-500/10 px-3 py-2 text-left text-sm text-rose-300 disabled:opacity-50"
                >
                  Close Election
                </button>
              </div>
            </section>
          </aside>
        </div>
      </section>
    </AdminShell>
  );
}

function formatTimeLeft(endsAt: number): string {
  const diff = endsAt - Date.now();
  if (diff <= 0) return "Closed";
  const hours = Math.floor(diff / 3_600_000);
  const minutes = Math.floor((diff % 3_600_000) / 60_000);
  if (hours <= 0) return `${minutes}m`;
  return `${hours}h ${minutes}m`;
}

function formatSchedule(startsAt: number, endsAt: number): string {
  const start = new Date(startsAt);
  const end = new Date(endsAt);
  const fmt = (date: Date) => date.toLocaleDateString(undefined, { month: "short", day: "numeric" });
  return `${fmt(start)} - ${fmt(end)}`;
}

function Card({ title, value, tone }: { title: string; value: string; tone: string }) {
  return (
    <article className="top-accent rounded-xl bg-[var(--surface-container)] p-4">
      <p className="text-[10px] font-semibold uppercase tracking-[0.13em] text-[var(--text-muted)]">{title}</p>
      <p className={`mt-1 text-2xl font-bold ${tone}`}>{value}</p>
    </article>
  );
}

function Field({ label, value, mono = false }: { label: string; value: string; mono?: boolean }) {
  return (
    <div>
      <p className="text-[10px] uppercase tracking-[0.1em] text-[var(--text-muted)]">{label}</p>
      <p className={mono ? "mt-1 rounded bg-[var(--surface-container-high)] px-2 py-1 font-mono text-xs" : "mt-1 font-semibold"}>{value}</p>
    </div>
  );
}

function Alert({ text }: { text: string }) {
  return <div className="rounded-lg border-l-2 border-rose-400 bg-rose-500/8 p-3 text-xs">{text}</div>;
}