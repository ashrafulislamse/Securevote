import Link from "next/link";
import { AdminShell } from "@/components/admin-shell";

export default function CreateElectionBasicInfoPage() {
  return (
    <AdminShell active="elections">
      <section className="mx-auto max-w-5xl space-y-7 pb-24">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">New Election Setup</h1>
          <p className="mt-1 font-mono text-xs text-white/45 uppercase tracking-[0.12em]">Election #SV-2025-NEW</p>
        </div>

        <Stepper step={1} />

        <section className="rounded-2xl bg-[var(--surface-container)] p-7">
          <div className="grid gap-8 lg:grid-cols-2">
            <div className="space-y-6">
              <label className="block">
                <span className="mb-2 block text-xs font-semibold text-[var(--text-muted)]">Election Title</span>
                <input className="w-full rounded-lg bg-[var(--surface-container-low)] px-4 py-3 text-sm outline-none ring-1 ring-transparent focus:ring-[var(--primary)]" placeholder="Student Council Election 2025" />
              </label>

              <label className="block">
                <span className="mb-2 block text-xs font-semibold text-[var(--text-muted)]">Description</span>
                <textarea className="h-28 w-full resize-none rounded-lg bg-[var(--surface-container-low)] px-4 py-3 text-sm outline-none ring-1 ring-transparent focus:ring-[var(--primary)]" placeholder="Provide election context and rules" />
              </label>

              <label className="block">
                <span className="mb-2 block text-xs font-semibold text-[var(--text-muted)]">Organization</span>
                <select className="w-full rounded-lg bg-[var(--surface-container-low)] px-4 py-3 text-sm outline-none">
                  <option>Global Education Network</option>
                  <option>City University Malaysia</option>
                </select>
              </label>

              <div>
                <p className="mb-3 text-xs font-semibold text-[var(--text-muted)]">Election Type</p>
                <div className="grid grid-cols-3 gap-2">
                  <TypeCard title="Single Choice" desc="One vote per position" active />
                  <TypeCard title="Multi Choice" desc="Select multiple" />
                  <TypeCard title="Ranked Choice" desc="Order by preference" />
                </div>
              </div>
            </div>

            <div className="space-y-6">
              <div>
                <p className="mb-3 text-xs font-semibold text-[var(--text-muted)]">Visibility Settings</p>
                <div className="space-y-2">
                  <Option title="After Close" text="Results are released after voting ends." active />
                  <Option title="Live Results" text="Live tally visible during election." />
                </div>
              </div>

              <label className="block">
                <span className="mb-2 block text-xs font-semibold text-[var(--text-muted)]">Tags</span>
                <div className="flex min-h-10 flex-wrap items-center gap-2 rounded-lg bg-[var(--surface-container-low)] px-3 py-2">
                  <Tag text="2025" />
                  <Tag text="High School" />
                  <input className="min-w-20 flex-1 bg-transparent text-xs outline-none" placeholder="Add tag..." />
                </div>
              </label>

              <div>
                <p className="mb-3 text-xs font-semibold text-[var(--text-muted)]">Voter Preview</p>
                <article className="top-accent rounded-xl bg-[var(--surface-container-low)] p-5">
                  <div className="mb-3 flex items-center justify-between">
                    <span className="rounded bg-[var(--primary)]/15 px-2 py-0.5 text-[10px] font-bold text-[var(--primary)]">SINGLE CHOICE</span>
                    <span className="rounded bg-white/10 px-2 py-0.5 text-[10px] font-bold text-white/70">DRAFT</span>
                  </div>
                  <h4 className="text-sm font-bold">Student Council Election 2025</h4>
                  <p className="mt-1 text-xs text-[var(--text-muted)]">Global Education Network</p>
                </article>
              </div>
            </div>
          </div>
        </section>

        <footer className="fixed bottom-0 left-60 right-0 flex h-[72px] items-center justify-between border-t border-white/6 bg-black/55 px-8 backdrop-blur-lg">
          <button className="rounded-lg border border-white/10 px-5 py-2.5 text-sm text-[var(--text-muted)]">Save Draft</button>
          <div className="flex items-center gap-3">
            <button className="text-sm text-[var(--text-muted)]">Cancel</button>
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
              <div className={`grid h-8 w-8 place-items-center rounded-full border text-xs font-bold ${active ? "border-[var(--primary)] text-[var(--primary)]" : done ? "brand-gradient border-transparent text-white" : "border-white/15 text-white/45"}`}>
                {done ? "✓" : n}
              </div>
              <span className={`text-xs font-semibold uppercase tracking-[0.1em] ${active ? "text-[var(--primary)]" : "text-white/45"}`}>{label}</span>
              {idx < labels.length - 1 ? <span className="h-px flex-1 bg-white/15" /> : null}
            </div>
          );
        })}
      </div>
    </div>
  );
}

function TypeCard({ title, desc, active = false }: { title: string; desc: string; active?: boolean }) {
  return (
    <div className={`rounded-lg p-3 text-center ${active ? "border border-[var(--primary)]/45 bg-[var(--primary)]/8" : "border border-white/8 bg-[var(--surface-container-low)]"}`}>
      <p className="text-xs font-bold">{title}</p>
      <p className="mt-1 text-[10px] text-[var(--text-muted)]">{desc}</p>
    </div>
  );
}

function Option({ title, text, active = false }: { title: string; text: string; active?: boolean }) {
  return (
    <label className={`block rounded-lg p-3 ${active ? "border border-[var(--primary)]/35 bg-[var(--primary)]/8" : "bg-[var(--surface-container-low)]"}`}>
      <p className="text-sm font-semibold">{title}</p>
      <p className="text-xs text-[var(--text-muted)]">{text}</p>
    </label>
  );
}

function Tag({ text }: { text: string }) {
  return <span className="rounded-full bg-[var(--primary)]/12 px-2 py-1 text-[10px] font-semibold text-[var(--primary)]">{text}</span>;
}
