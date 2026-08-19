"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import type { ElectionType } from "@/lib/api-client";
import { clearDraft, loadDraft, saveDraft } from "../draft";

const TYPE_OPTIONS: { value: ElectionType; title: string; desc: string }[] = [
  { value: "single", title: "Single Choice", desc: "One vote per position" },
  { value: "multi", title: "Multi Choice", desc: "Select multiple" },
  { value: "ranked", title: "Ranked Choice", desc: "Order by preference" },
];

export default function CreateElectionBasicInfoPage() {
  const [draft, setDraftState] = useState(loadDraft);
  const [toast, setToast] = useState<string | null>(null);
  const router = useRouter();

  const setField = (patch: Partial<typeof draft>) => {
    setDraftState((prev) => {
      const next = { ...prev, ...patch };
      saveDraft(next);
      return next;
    });
  };

  const saveAndToast = () => {
    saveDraft(draft);
    setToast("Draft saved.");
    setTimeout(() => setToast(null), 2000);
  };

  const cancel = () => {
    clearDraft();
    router.push("/admin/elections");
  };

  return (
    <AdminShell active="elections">
      <section className="mx-auto max-w-5xl space-y-7 pb-24">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">New Election Setup</h1>
          <p className="mt-1 font-mono text-xs text-[var(--text-muted)] uppercase tracking-[0.12em]">New Election (Draft)</p>
        </div>

        <Stepper step={1} />

        <section className="rounded-2xl bg-[var(--surface-container)] p-7">
          <div className="grid gap-8 lg:grid-cols-2">
            <div className="space-y-6">
              <label className="block">
                <span className="mb-2 block text-xs font-semibold text-[var(--text-muted)]">Election Title</span>
                <input
                  value={draft.title}
                  onChange={(e) => setField({ title: e.target.value })}
                  className="w-full rounded-lg bg-[var(--surface-container-low)] px-4 py-3 text-sm outline-none ring-1 ring-transparent focus:ring-[var(--primary)]"
                  placeholder="Student Council Election 2025"
                />
              </label>

              <label className="block">
                <span className="mb-2 block text-xs font-semibold text-[var(--text-muted)]">Description</span>
                <textarea
                  value={draft.description}
                  onChange={(e) => setField({ description: e.target.value })}
                  className="h-28 w-full resize-none rounded-lg bg-[var(--surface-container-low)] px-4 py-3 text-sm outline-none ring-1 ring-transparent focus:ring-[var(--primary)]"
                  placeholder="Provide election context and rules"
                />
              </label>

              <label className="block">
                <span className="mb-2 block text-xs font-semibold text-[var(--text-muted)]">Organization</span>
                <input
                  value={draft.organization}
                  onChange={(e) => setField({ organization: e.target.value })}
                  className="w-full rounded-lg bg-[var(--surface-container-low)] px-4 py-3 text-sm outline-none ring-1 ring-transparent focus:ring-[var(--primary)]"
                  placeholder="Global Education Network"
                />
              </label>

              <div>
                <p className="mb-3 text-xs font-semibold text-[var(--text-muted)]">Election Type</p>
                <div className="grid grid-cols-3 gap-2">
                  {TYPE_OPTIONS.map((option) => (
                    <button
                      key={option.value}
                      type="button"
                      onClick={() => setField({ type: option.value })}
                      className={`rounded-lg p-3 text-center ${
                        draft.type === option.value
                          ? "border border-[var(--primary)]/45 bg-[var(--primary)]/8"
                          : "border border-[var(--border-subtle)] bg-[var(--surface-container-low)]"
                      }`}
                    >
                      <p className="text-xs font-bold">{option.title}</p>
                      <p className="mt-1 text-[10px] text-[var(--text-muted)]">{option.desc}</p>
                    </button>
                  ))}
                </div>
              </div>
            </div>

            <div className="space-y-6">
              <div>
                <p className="mb-3 text-xs font-semibold text-[var(--text-muted)]">Voter Preview</p>
                <article className="top-accent rounded-xl bg-[var(--surface-container-low)] p-5">
                  <div className="mb-3 flex items-center justify-between">
                    <span className="rounded bg-[var(--primary)]/15 px-2 py-0.5 text-[10px] font-bold text-[var(--primary)] uppercase">
                      {draft.type.toUpperCase()} CHOICE
                    </span>
                    <span className="rounded bg-[var(--surface-container-high)] px-2 py-0.5 text-[10px] font-bold text-[var(--text-secondary)]">DRAFT</span>
                  </div>
                  <h4 className="text-sm font-bold">{draft.title || "Untitled Election"}</h4>
                  <p className="mt-1 text-xs text-[var(--text-muted)]">{draft.organization || "—"}</p>
                  {draft.description ? (
                    <p className="mt-2 text-xs text-[var(--text-muted)]">{draft.description}</p>
                  ) : null}
                </article>
              </div>
            </div>
          </div>
        </section>

        {toast ? (
          <div className="rounded-lg bg-emerald-500/15 px-4 py-2 text-sm font-semibold text-emerald-300">{toast}</div>
        ) : null}

        <footer className="fixed bottom-0 left-60 right-0 flex h-[72px] items-center justify-between border-t border-[var(--border-subtle)] bg-[var(--surface-overlay)] px-8 backdrop-blur-lg">
          <button onClick={saveAndToast} className="rounded-lg border border-[var(--border-default)] px-5 py-2.5 text-sm text-[var(--text-muted)]">Save Draft</button>
          <div className="flex items-center gap-3">
            <button onClick={cancel} className="text-sm text-[var(--text-muted)]">Cancel</button>
            <Link href="/admin/elections/create/schedule" className="brand-gradient rounded-lg px-6 py-2.5 text-sm font-semibold text-white">
              Continue to Schedule
            </Link>
          </div>
        </footer>
      </section>
    </AdminShell>
  );
}

function Stepper({ step }: { step: 1 | 2 | 3 | 4 }) {
  const labels = ["Basic Info", "Schedule", "Eligibility", "Review"];
  return (
    <div className="rounded-xl bg-[var(--surface-container)] p-5">
      <div className="flex items-center justify-between gap-3">
        {labels.map((label, idx) => {
          const n = idx + 1;
          const active = step === n;
          const done = step > n;
          return (
            <div key={label} className="flex flex-1 items-center gap-3">
              <div className={`grid h-8 w-8 place-items-center rounded-full border text-xs font-bold ${active ? "border-[var(--primary)] text-[var(--primary)]" : done ? "brand-gradient border-transparent text-white" : "border-[var(--border-default)] text-[var(--text-muted)]"}`}>
                {done ? "✓" : n}
              </div>
              <span className={`text-xs font-semibold uppercase tracking-[0.1em] ${active ? "text-[var(--primary)]" : "text-[var(--text-muted)]"}`}>{label}</span>
              {idx < labels.length - 1 ? <span className="h-px flex-1 bg-[var(--surface-container-highest)]" /> : null}
            </div>
          );
        })}
      </div>
    </div>
  );
}
