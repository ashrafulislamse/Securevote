"use client";

import Link from "next/link";
import { useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import { loadDraft, saveDraft } from "../draft";

function toDateTimeLocal(ms: number): string {
  if (!ms) return "";
  const date = new Date(ms);
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
}

export default function CreateElectionSchedulePage() {
  const [draft, setDraft] = useState(loadDraft);
  const [toast, setToast] = useState<string | null>(null);

  const startValue = toDateTimeLocal(draft.startsAt);
  const endValue = toDateTimeLocal(draft.endsAt);

  const setStart = (value: string) => {
    const ms = value ? new Date(value).getTime() : 0;
    setDraft((prev) => {
      const next = { ...prev, startsAt: ms };
      saveDraft(next);
      return next;
    });
  };

  const setEnd = (value: string) => {
    const ms = value ? new Date(value).getTime() : 0;
    setDraft((prev) => {
      const next = { ...prev, endsAt: ms };
      saveDraft(next);
      return next;
    });
  };

  const saveAndToast = () => {
    saveDraft(draft);
    setToast("Draft saved.");
    setTimeout(() => setToast(null), 2000);
  };

  const durationHours =
    draft.startsAt && draft.endsAt && draft.endsAt > draft.startsAt
      ? Math.round((draft.endsAt - draft.startsAt) / 3_600_000)
      : 0;

  return (
    <AdminShell active="elections">
      <section className="mx-auto max-w-5xl space-y-8 pb-24">
        <div>
          <p className="text-xs text-[var(--text-muted)]">Step 2 of 4</p>
          <h1 className="mt-2 text-3xl font-bold tracking-tight">Election Schedule</h1>
        </div>

        <Stepper step={2} />

        <section className="top-accent rounded-xl bg-[var(--surface-container)] p-6">
          <h2 className="text-xs font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Voting Period</h2>
          <p className="mt-1 text-xs text-[var(--text-muted)]">All times are in your local timezone.</p>
          <div className="mt-5 grid gap-4 md:grid-cols-2">
            <label className="block">
              <span className="mb-2 block text-sm text-[var(--text-muted)]">Start Date & Time</span>
              <input
                type="datetime-local"
                value={startValue}
                onChange={(e) => setStart(e.target.value)}
                className="w-full rounded-lg bg-[var(--surface-container-low)] px-4 py-3 text-sm text-white"
              />
            </label>
            <label className="block">
              <span className="mb-2 block text-sm text-[var(--text-muted)]">End Date & Time</span>
              <input
                type="datetime-local"
                value={endValue}
                onChange={(e) => setEnd(e.target.value)}
                className="w-full rounded-lg bg-[var(--surface-container-low)] px-4 py-3 text-sm text-white"
              />
            </label>
          </div>
        </section>

        <section className="rounded-xl bg-[var(--surface-container)] p-6">
          <h2 className="text-xs font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Schedule Preview</h2>
          <div className="mt-5 rounded-lg bg-[var(--surface-container-low)] p-6">
            <div className="flex items-center gap-3">
              <div className="text-center">
                <p className="font-mono text-[10px] text-[var(--text-muted)]">{draft.startsAt ? new Date(draft.startsAt).toLocaleDateString(undefined, { month: "short", day: "numeric" }).toUpperCase() : "—"}</p>
                <p className="text-xs font-bold">START</p>
              </div>
              <div className="relative h-1 flex-1 rounded-full brand-gradient">
                <span className="absolute -top-6 left-1/2 -translate-x-1/2 rounded bg-[var(--primary)]/12 px-2 py-1 font-mono text-[10px] text-[var(--primary)]">{durationHours} Hours Duration</span>
              </div>
              <div className="text-center">
                <p className="font-mono text-[10px] text-[var(--text-muted)]">{draft.endsAt ? new Date(draft.endsAt).toLocaleDateString(undefined, { month: "short", day: "numeric" }).toUpperCase() : "—"}</p>
                <p className="text-xs font-bold">CLOSE</p>
              </div>
            </div>
            <p className="mt-4 text-xs text-[var(--text-muted)]">Voters can cast ballots within the selected voting period.</p>
          </div>
        </section>

        {toast ? (
          <div className="rounded-lg bg-emerald-500/15 px-4 py-2 text-sm font-semibold text-emerald-300">{toast}</div>
        ) : null}

        <footer className="fixed bottom-0 left-60 right-0 flex h-[72px] items-center justify-between border-t border-white/6 bg-black/55 px-8 backdrop-blur-lg">
          <Link href="/admin/elections/create/basic-info" className="text-sm text-[var(--text-muted)]">Back to Basic Info</Link>
          <div className="flex items-center gap-3">
            <button onClick={saveAndToast} className="rounded-lg bg-[var(--surface-container-high)] px-5 py-2.5 text-sm">Save Draft</button>
            <Link href="/admin/elections/create/eligibility" className="brand-gradient rounded-lg px-6 py-2.5 text-sm font-semibold text-white">Continue to Eligibility</Link>
          </div>
        </footer>
      </section>
    </AdminShell>
  );
}

function Stepper({ step }: { step: number }) {
  const labels = ["Basic Info", "Schedule", "Eligibility", "Review"];
  return (
    <div className="rounded-xl bg-[var(--surface-container)] p-5">
      <div className="flex items-center gap-2">
        {labels.map((label, idx) => {
          const n = idx + 1;
          const active = step === n;
          const done = step > n;
          return (
            <div key={label} className="flex flex-1 items-center gap-2">
              <span className={`grid h-8 w-8 place-items-center rounded-full border text-xs font-bold ${active ? "border-[var(--primary)] text-[var(--primary)]" : done ? "brand-gradient border-transparent text-white" : "border-white/15 text-white/45"}`}>
                {done ? "✓" : n}
              </span>
              <span className={`text-xs font-semibold uppercase tracking-[0.1em] ${active ? "text-[var(--primary)]" : "text-white/45"}`}>{label}</span>
              {idx < labels.length - 1 ? <span className="h-px flex-1 bg-white/15" /> : null}
            </div>
          );
        })}
      </div>
    </div>
  );
}
