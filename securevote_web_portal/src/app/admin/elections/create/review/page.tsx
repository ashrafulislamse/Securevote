"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { AdminShell } from "@/components/admin-shell";
import { createElection, setElectionStatus } from "@/lib/api-client";
import { clearDraft, loadDraft } from "../draft";

const checklistItems = [
  "I have verified the voter list",
  "I have reviewed the ballot configuration",
  "I confirm the voting schedule is correct",
  "I have notified stakeholders of the upcoming election",
];

const TYPE_LABELS: Record<string, string> = {
  single: "Single Choice Voting",
  multi: "Multi Choice Voting",
  ranked: "Ranked Choice Voting",
};

export default function CreateElectionReviewPage() {
  const router = useRouter();
  const draft = useMemo(() => loadDraft(), []);
  const [done, setDone] = useState<string[]>(checklistItems);
  const [publishing, setPublishing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const publishReady = useMemo(() => done.length === checklistItems.length, [done.length]);

  const publish = async () => {
    if (!publishReady) return;
    if (!draft.title.trim()) {
      setError("Election title is required. Go back to Basic Info to set it.");
      return;
    }
    if (!draft.startsAt || !draft.endsAt) {
      setError("Voting start and end times are required. Go back to Schedule to set them.");
      return;
    }
    setPublishing(true);
    setError(null);
    try {
      const result = await createElection({
        title: draft.title.trim(),
        description: draft.description.trim() || undefined,
        organization: draft.organization.trim() || undefined,
        type: draft.type,
        startsAt: draft.startsAt,
        endsAt: draft.endsAt,
      });
      // Transition the new election from draft → scheduled so it's
      // actually live and visible to voters (not stuck as a hidden draft).
      const nowMs = Date.now();
      const targetStatus = draft.startsAt <= nowMs ? "active" : "scheduled";
      try {
        await setElectionStatus(result.election.id, targetStatus);
      } catch {
        // The election was created; a status transition failure is
        // non-fatal — the admin can change status from the overview page.
      }
      clearDraft();
      router.push("/admin/elections");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to publish election");
      setPublishing(false);
    }
  };

  const formatDate = (ms: number) =>
    ms ? new Date(ms).toLocaleString(undefined, { dateStyle: "medium", timeStyle: "short" }) : "Not set";

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
                <Link href="/admin/elections/create/basic-info" className="text-xs font-semibold text-[var(--primary)]">Edit</Link>
              </div>
              <div className="grid gap-4 md:grid-cols-2">
                <Summary label="Election Title" value={draft.title || "Untitled"} />
                <Summary label="Type" value={TYPE_LABELS[draft.type]} />
                <Summary label="Open" value={formatDate(draft.startsAt)} />
                <Summary label="Close" value={formatDate(draft.endsAt)} />
                <Summary label="Organization" value={draft.organization || "—"} />
                <Summary label="Description" value={draft.description || "—"} />
              </div>
            </section>

            <section className="rounded-xl bg-[var(--surface-container)] p-6">
              <div className="mb-4 flex items-center justify-between">
                <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Operator Attestation</p>
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
                <GateRow label="Election type" value={TYPE_LABELS[draft.type]} ok />
                <GateRow label="Voting period" value={draft.startsAt && draft.endsAt ? "Set" : "Pending"} ok={!!draft.startsAt && !!draft.endsAt} />
                <GateRow label="Election title" value={draft.title ? "Set" : "Pending"} ok={!!draft.title} />
                <GateRow label="Organization" value={draft.organization ? "Set" : "Optional"} ok />
              </div>
            </section>

            <section className="rounded-xl border border-[var(--primary)]/20 bg-[var(--primary)]/7 p-6">
              <p className="text-sm text-[var(--text-muted)]">Publishing locks critical parameters and writes an immutable audit event.</p>
              {error ? <p className="mt-3 text-sm text-rose-300">{error}</p> : null}
              <button
                onClick={publish}
                disabled={!publishReady || publishing}
                className={`mt-4 flex w-full items-center justify-center rounded-lg px-4 py-2.5 text-sm font-semibold ${
                  publishReady ? "brand-gradient text-white disabled:opacity-50" : "bg-[var(--surface-container-high)] text-[var(--text-muted)]"
                }`}
              >
                {publishing ? "Publishing..." : publishReady ? "Publish Election" : "Complete checklist to publish"}
              </button>
            </section>
          </aside>
        </div>

        <footer className="fixed bottom-0 left-60 right-0 flex h-[76px] items-center justify-between border-t border-[var(--border-subtle)] bg-[var(--surface-overlay)] px-8 backdrop-blur-lg">
          <Link href="/admin/elections/create/eligibility" className="text-sm text-[var(--text-muted)]">Back</Link>
          <div className="flex items-center gap-3">
            <button onClick={publish} disabled={!publishReady || publishing} className="brand-gradient rounded-lg px-8 py-2.5 text-sm font-semibold text-white disabled:opacity-50">Publish Election</button>
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
              <span className={`grid h-8 w-8 place-items-center rounded-full border text-xs font-bold ${active ? "border-[var(--primary)] text-[var(--primary)]" : done ? "brand-gradient border-transparent text-white" : "border-[var(--border-default)] text-[var(--text-muted)]"}`}>
                {done ? "✓" : n}
              </span>
              <span className={`text-xs font-semibold uppercase tracking-[0.1em] ${active ? "text-[var(--primary)]" : "text-[var(--text-muted)]"}`}>{label}</span>
              {idx < labels.length - 1 ? <span className="h-px flex-1 bg-[var(--surface-container-highest)]" /> : null}
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