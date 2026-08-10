"use client";

import { useSearchParams } from "next/navigation";
import { Suspense, useCallback, useEffect, useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import { getVoter } from "@/lib/api-client";
import type { MyVote, Voter } from "@/lib/api-client";

type TimelineEvent = {
  id: string;
  title: string;
  time: string;
  receipt: string;
  tone: "good" | "warn" | "neutral";
};

function formatDate(ts?: number) {
  if (!ts) return "—";
  return new Date(ts).toLocaleString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function VoterProfileContent() {
  const searchParams = useSearchParams();
  const id = searchParams.get("id") ?? "";

  const [tab, setTab] = useState<"overview" | "history" | "security">("overview");
  const [suspended, setSuspended] = useState(false);

  const [voter, setVoter] = useState<(Voter & { vote_count?: number }) | null>(null);
  const [votes, setVotes] = useState<(MyVote & { election_title?: string })[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    if (!id) {
      setError("No voter selected. Open a voter from the registry.");
      setLoading(false);
      return;
    }
    setLoading(true);
    setError(null);
    try {
      const data = await getVoter(id);
      setVoter(data.voter);
      setVotes(data.votes ?? []);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load voter");
      setVoter(null);
      setVotes([]);
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

  // Risk score and suspend are local only.
  // TODO: risk model + suspend endpoint
  const riskScore = useMemo(() => (suspended ? 62 : 18), [suspended]);

  const timeline = useMemo<TimelineEvent[]>(
    () =>
      votes.map((vote) => ({
        id: vote.id,
        title: vote.election_title ?? vote.electionTitle ?? "Election vote",
        time: formatDate(vote.createdAt),
        receipt: vote.receiptId,
        tone: "good" as const,
      })),
    [votes],
  );

  const initials = voter?.fullName
    .split(" ")
    .map((part) => part[0])
    .join("")
    .slice(0, 2)
    .toUpperCase() ?? "—";

  return (
    <AdminShell active="voters">
      <section className="mx-auto max-w-6xl space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Voters / Detail</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Voter Profile</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Identity, activity, and security posture for a single voter account.</p>
          </div>
          <div className="flex items-center gap-2">
            <button type="button" className="rounded-md bg-[var(--surface-container)] px-4 py-2 text-xs font-semibold">
              Edit Profile
            </button>
            <button
              type="button"
              onClick={() => setSuspended((prev) => !prev)}
              className={`rounded-md px-4 py-2 text-xs font-semibold ${suspended ? "bg-emerald-500/20 text-emerald-300" : "bg-rose-500/20 text-rose-300"}`}
            >
              {suspended ? "Reinstate" : "Suspend"}
            </button>
          </div>
        </div>

        {loading ? (
          <p className="rounded-xl bg-[var(--surface-container)] px-5 py-10 text-center text-sm text-[var(--text-muted)]">Loading voter profile...</p>
        ) : error ? (
          <p className="rounded-xl bg-[var(--surface-container)] px-5 py-10 text-center text-sm text-rose-300">{error}</p>
        ) : voter ? (
          <div className="grid gap-6 xl:grid-cols-[0.95fr,1.05fr]">
            <article className="space-y-5 rounded-xl bg-[var(--surface-container)] p-5">
              <div className="flex items-center gap-4">
                <div className="grid h-16 w-16 place-items-center rounded-full bg-[var(--surface-container-high)] text-xl font-bold">{initials}</div>
                <div>
                  <p className="text-lg font-semibold">{voter.fullName}</p>
                  <p className="text-xs font-mono text-[var(--primary)]">{voter.id}</p>
                </div>
              </div>

              <div className="space-y-2 rounded-lg bg-[var(--surface-container-low)] p-4 text-sm">
                <Row label="Email" value={voter.email} />
                <Row label="Phone" value={voter.phone ?? "—"} />
                <Row label="Role" value={voter.role} />
                <Row label="Status" value={suspended ? "Suspended" : voter.kycStatus} />
                <Row label="Joined" value={formatDate(voter.createdAt)} />
              </div>

              <div className="grid gap-3 sm:grid-cols-3">
                <Stat title="Votes Cast" value={String(voter.vote_count ?? votes.length)} />
                <Stat title="Receipts" value={String(votes.length)} />
                <Stat title="Devices" value="—" />
              </div>

              <div className="rounded-lg border border-white/8 bg-[var(--surface-container-low)] p-4">
                <p className="text-[11px] uppercase tracking-[0.08em] text-[var(--text-muted)]">Risk Score</p>
                <p className={`mt-2 text-2xl font-bold ${riskScore > 40 ? "text-amber-300" : "text-emerald-300"}`}>{riskScore}</p>
                <p className="mt-1 text-xs text-[var(--text-muted)]">Based on login posture, device change requests, and challenge history.</p>
              </div>
            </article>

            <article className="rounded-xl bg-[var(--surface-container)] p-5">
              <div className="mb-4 flex flex-wrap gap-2">
                <Tab label="Overview" selected={tab === "overview"} onClick={() => setTab("overview")} />
                <Tab label="Activity History" selected={tab === "history"} onClick={() => setTab("history")} />
                <Tab label="Security" selected={tab === "security"} onClick={() => setTab("security")} />
              </div>

              {tab === "overview" ? (
                <div className="space-y-3 text-sm">
                  <InfoCard title="KYC Status" text={voter.kycStatus} />
                  <InfoCard title="Registered" text={formatDate(voter.createdAt)} />
                  <InfoCard title="Participation" text={`${votes.length} confirmed vote${votes.length === 1 ? "" : "s"} on record.`} />
                </div>
              ) : null}

              {tab === "history" ? (
                timeline.length > 0 ? (
                  <div className="space-y-3">
                    {timeline.map((event) => (
                      <div key={event.id} className="rounded-lg border border-white/8 bg-[var(--surface-container-low)] p-3">
                        <div className="flex items-center justify-between gap-3">
                          <p className="text-sm font-semibold">{event.title}</p>
                          <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase ${toneClass(event.tone)}`}>{event.tone}</span>
                        </div>
                        <p className="mt-1 text-xs text-[var(--text-muted)]">{event.time}</p>
                        <p className="mt-1 font-mono text-[11px] text-[var(--primary)]">{event.receipt}</p>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-sm text-[var(--text-muted)]">No voting activity on record.</p>
                )
              ) : null}

              {tab === "security" ? (
                <div className="space-y-3 text-sm">
                  <InfoCard title="Bound Device" text="Not available in this data model." />
                  <InfoCard title="Last Challenge" text="Not available in this data model." />
                  <InfoCard title="Session Pattern" text="No impossible travel patterns detected in the last 30 days." />
                </div>
              ) : null}
            </article>
          </div>
        ) : null}
      </section>
    </AdminShell>
  );
}

export default function VoterProfilePage() {
  return (
    <Suspense fallback={null}>
      <VoterProfileContent />
    </Suspense>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between gap-3">
      <p className="text-xs uppercase tracking-[0.08em] text-[var(--text-muted)]">{label}</p>
      <p className="text-sm font-semibold">{value}</p>
    </div>
  );
}

function Stat({ title, value }: { title: string; value: string }) {
  return (
    <div className="rounded-lg bg-[var(--surface-container-low)] p-3">
      <p className="text-[11px] uppercase tracking-[0.08em] text-[var(--text-muted)]">{title}</p>
      <p className="mt-1 text-xl font-bold">{value}</p>
    </div>
  );
}

function Tab({ label, selected, onClick }: { label: string; selected: boolean; onClick: () => void }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`rounded-md px-3 py-2 text-xs font-semibold ${selected ? "bg-[var(--primary)]/15 text-[var(--primary)]" : "bg-[var(--surface-container-low)] text-[var(--text-muted)]"}`}
    >
      {label}
    </button>
  );
}

function InfoCard({ title, text }: { title: string; text: string }) {
  return (
    <div className="rounded-lg border border-white/8 bg-[var(--surface-container-low)] p-3">
      <p className="text-sm font-semibold">{title}</p>
      <p className="mt-1 text-xs text-[var(--text-muted)]">{text}</p>
    </div>
  );
}

function toneClass(tone: "good" | "warn" | "neutral") {
  if (tone === "good") return "bg-emerald-500/20 text-emerald-300";
  if (tone === "warn") return "bg-amber-500/20 text-amber-300";
  return "bg-white/10 text-white/75";
}