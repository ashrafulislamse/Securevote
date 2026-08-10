"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";

const checklistItems = [
  "Voter list integrity check",
  "Ballot logic validation",
  "Network signature keys synced",
  "Outreach notifications scheduled",
];

export default function CreateElectionReviewPage() {
  const [done, setDone] = useState<string[]>(checklistItems.slice(0, 3));

  const publishReady = useMemo(() => done.length === checklistItems.length, [done.length]);

  return (
    <AdminShell active="elections">
      <section className="mx-auto max-w-6xl space-y-8 pb-28">
        <div className="flex items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Step 4 of 4</p>
            <h1 className="mt-2 text-4xl font-bold tracking-tight">Review Election</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Final immutability checks before publishing to the election network.</p>
          </div>
          <div className="rounded-full bg-[var(--primary)]/12 px-4 py-1 text-xs font-bold uppercase tracking-[0.1em] text-[var(--primary)]">
            {done.length}/{checklistItems.length} checks complete
          </div>
        </div>

        <Stepper step={4} />

        <div className="grid gap-6 xl:grid-cols-12">
          <div className="space-y-6 xl:col-span-7">
            <section className="rounded-xl bg-[var(--surface-container)] p-6">
              <div className="mb-5 flex items-center justify-between">
                <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Election Summary</p>
                <button className="text-xs font-semibold text-[var(--primary)]">Edit</button>
              </div>
              <div className="grid gap-4 md:grid-cols-2">
                <Summary label="Election Title" value="2026 Global Executive Council Election" />
                <Summary label="Type" value="Ranked Choice Voting" />
                <Summary label="Open" value="Oct 14, 2026 09:00 UTC" />
                <Summary label="Close" value="Oct 21, 2026 23:59 UTC" />
                <Summary label="Eligible Voters" value="2,847 verified accounts" />
                <Summary label="Ballot Sections" value="3 positions, 1 policy question" />
              </div>
            </section>

            <section className="rounded-xl bg-[var(--surface-container)] p-6">
              <div className="mb-4 flex items-center justify-between">
                <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Pre-Publish Checklist</p>
                <button
                  type="button"
                  onClick={() => setDone(checklistItems)}
                  className="text-xs font-semibold text-[var(--primary)]"
                >
                  Mark all done
                </button>
              </div>
              <div className="space-y-3">
                {checklistItems.map((item) => {
                  const checked = done.includes(item);
                  return (
                    <button
                      key={item}
                      type="button"
                      onClick={() => {
                        setDone((prev) => (checked ? prev.filter((x) => x !== item) : [...prev, item]));
                      }}
                      className="flex w-full items-center justify-between rounded-lg bg-[var(--surface-container-low)] px-4 py-3 text-left"
                    >
                      <span className="text-sm">{item}</span>
                      <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${checked ? "bg-emerald-500/15 text-emerald-300" : "bg-amber-500/15 text-amber-300"}`}>
                        {checked ? "Done" : "Pending"}
                      </span>
                    </button>
                  );
                })}
              </div>
            </section>
          </div>

          <aside className="space-y-6 xl:col-span-5">
            <section className="rounded-xl bg-[var(--surface-container)] p-6">
              <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Risk Gate</p>
              <div className="mt-4 space-y-4">
                <GateRow label="KYC verified rate" value="84.3%" ok />
                <GateRow label="Device anomaly score" value="Low" ok />
                <GateRow label="Election quorum config" value="Set" ok />
                <GateRow label="Admin signing key" value="Attached" ok />
              </div>
            </section>

            <section className="rounded-xl border border-[var(--primary)]/20 bg-[var(--primary)]/7 p-6">
              <p className="text-sm text-[var(--text-muted)]">Publishing locks critical parameters and writes an immutable audit event.</p>
              <button
                disabled={!publishReady}
                className={`mt-4 w-full rounded-lg px-4 py-2.5 text-sm font-semibold ${publishReady ? "brand-gradient text-white" : "bg-white/10 text-white/45"}`}
              >
                {publishReady ? "Publish Election" : "Complete checklist to publish"}
              </button>
            </section>
          </aside>
        </div>

        <footer className="fixed bottom-0 left-60 right-0 flex h-[76px] items-center justify-between border-t border-white/6 bg-black/55 px-8 backdrop-blur-lg">
          <Link href="/admin/elections/create/eligibility" className="text-sm text-[var(--text-muted)]">Back</Link>
          <div className="flex items-center gap-3">
            <button className="rounded-lg bg-[var(--surface-container-high)] px-5 py-2.5 text-sm">Save Draft</button>
            <button className="brand-gradient rounded-lg px-8 py-2.5 text-sm font-semibold text-white">Generate Final Package</button>
          </div>
        </footer>
      </section>
    </AdminShell>
  );
}

function Stepper({ step }: { step: number }) {
  const labels = ["General", "Ballot", "Eligibility", "Review"];
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

function Summary({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-lg bg-[var(--surface-container-low)] p-4">
      <p className="text-[10px] uppercase tracking-[0.1em] text-[var(--text-muted)]">{label}</p>
      <p className="mt-1 text-sm font-semibold">{value}</p>
    </div>
  );
}

function GateRow({ label, value, ok = false }: { label: string; value: string; ok?: boolean }) {
  return (
    <div className="flex items-center justify-between rounded-lg bg-[var(--surface-container-low)] px-4 py-3">
      <p className="text-sm">{label}</p>
      <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${ok ? "bg-emerald-500/15 text-emerald-300" : "bg-rose-500/15 text-rose-300"}`}>{value}</span>
    </div>
  );
}
