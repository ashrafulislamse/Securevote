"use client";

import { useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";

type TimelineEvent = {
  id: string;
  title: string;
  time: string;
  tone: "good" | "warn" | "neutral";
};

const timeline: TimelineEvent[] = [
  { id: "1", title: "Identity verified through KYC", time: "2026-03-14 09:18 UTC", tone: "good" },
  { id: "2", title: "Cast vote in Student Council Election", time: "2026-03-18 14:27 UTC", tone: "good" },
  { id: "3", title: "Device rebind request submitted", time: "2026-03-22 11:06 UTC", tone: "warn" },
  { id: "4", title: "Security challenge passed", time: "2026-03-22 11:11 UTC", tone: "neutral" },
];

export default function VoterProfilePage() {
  const [tab, setTab] = useState<"overview" | "history" | "security">("overview");
  const [suspended, setSuspended] = useState(false);

  const riskScore = useMemo(() => (suspended ? 62 : 18), [suspended]);

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

        <div className="grid gap-6 xl:grid-cols-[0.95fr,1.05fr]">
          <article className="space-y-5 rounded-xl bg-[var(--surface-container)] p-5">
            <div className="flex items-center gap-4">
              <div className="grid h-16 w-16 place-items-center rounded-full bg-[var(--surface-container-high)] text-xl font-bold">AI</div>
              <div>
                <p className="text-lg font-semibold">Ashraful Islam</p>
                <p className="text-xs font-mono text-[var(--primary)]">V-00421</p>
              </div>
            </div>

            <div className="space-y-2 rounded-lg bg-[var(--surface-container-low)] p-4 text-sm">
              <Row label="Email" value="ashraful.islam@gov.bd" />
              <Row label="Phone" value="+880 1712 345678" />
              <Row label="Faculty" value="Public Policy" />
              <Row label="Status" value={suspended ? "Suspended" : "Verified"} />
            </div>

            <div className="grid gap-3 sm:grid-cols-3">
              <Stat title="Votes Cast" value="2" />
              <Stat title="Receipts" value="2" />
              <Stat title="Devices" value="1" />
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
                <InfoCard title="Participation" text="Eligible for 3 elections. Participated in 2. Missed 1 local committee vote." />
                <InfoCard title="Receipt Integrity" text="All published receipts validated against final chain anchor." />
                <InfoCard title="Communication" text="Email notifications enabled. SMS fallback enabled." />
              </div>
            ) : null}

            {tab === "history" ? (
              <div className="space-y-3">
                {timeline.map((event) => (
                  <div key={event.id} className="rounded-lg border border-white/8 bg-[var(--surface-container-low)] p-3">
                    <div className="flex items-center justify-between gap-3">
                      <p className="text-sm font-semibold">{event.title}</p>
                      <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase ${toneClass(event.tone)}`}>{event.tone}</span>
                    </div>
                    <p className="mt-1 text-xs text-[var(--text-muted)]">{event.time}</p>
                  </div>
                ))}
              </div>
            ) : null}

            {tab === "security" ? (
              <div className="space-y-3 text-sm">
                <InfoCard title="Bound Device" text="iPhone 13 Pro / iOS 17 / UUID: 8E92-B21C-44F1-X902" />
                <InfoCard title="Last Challenge" text="Face verification + OTP passed on 2026-03-22." />
                <InfoCard title="Session Pattern" text="No impossible travel patterns detected in the last 30 days." />
              </div>
            ) : null}
          </article>
        </div>
      </section>
    </AdminShell>
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
