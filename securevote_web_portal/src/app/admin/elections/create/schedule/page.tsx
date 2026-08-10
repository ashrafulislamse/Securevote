import Link from "next/link";
import { AdminShell } from "@/components/admin-shell";

export default function CreateElectionSchedulePage() {
  return (
    <AdminShell active="elections">
      <section className="mx-auto max-w-5xl space-y-8 pb-24">
        <div>
          <p className="text-xs text-[var(--text-muted)]">Step 2 of 4</p>
          <h1 className="mt-2 text-3xl font-bold tracking-tight">Election Schedule</h1>
        </div>

        <Stepper step={2} />

        <div className="grid gap-6 md:grid-cols-2">
          <section className="top-accent rounded-xl bg-[var(--surface-container)] p-6">
            <h2 className="text-xs font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Voting Period</h2>
            <div className="mt-5 space-y-4">
              <Field label="Start Date & Time" value="Nov 14, 2025 - 08:00 AM" icon="calendar_today" />
              <Field label="End Date & Time" value="Nov 16, 2025 - 05:00 PM" icon="event_busy" />
              <label className="block">
                <span className="mb-2 block text-sm text-[var(--text-muted)]">Timezone</span>
                <select className="w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-3 text-sm">
                  <option>(UTC-05:00) Eastern Time</option>
                  <option>(UTC+00:00) Universal Coordinated Time</option>
                </select>
              </label>
            </div>
          </section>

          <section className="rounded-xl bg-[var(--surface-container)] p-6">
            <h2 className="text-xs font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Reminders</h2>
            <div className="mt-5 space-y-3">
              <Reminder title="Opening Reminder" value="30m before" on />
              <Reminder title="Midpoint Check" value="24h mark" />
              <Reminder title="Closing Alert" value="2h before" on />
            </div>
          </section>
        </div>

        <section className="rounded-xl bg-[var(--surface-container)] p-6">
          <h2 className="text-xs font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Schedule Preview</h2>
          <div className="mt-5 rounded-lg bg-[var(--surface-container-low)] p-6">
            <div className="flex items-center gap-3">
              <div className="text-center">
                <p className="font-mono text-[10px] text-[var(--text-muted)]">NOV 14</p>
                <p className="text-xs font-bold">START</p>
              </div>
              <div className="relative h-1 flex-1 rounded-full brand-gradient">
                <span className="absolute -top-6 left-1/2 -translate-x-1/2 rounded bg-[var(--primary)]/12 px-2 py-1 font-mono text-[10px] text-[var(--primary)]">57 Hours Duration</span>
              </div>
              <div className="text-center">
                <p className="font-mono text-[10px] text-[var(--text-muted)]">NOV 16</p>
                <p className="text-xs font-bold">CLOSE</p>
              </div>
            </div>
            <p className="mt-4 text-xs text-[var(--text-muted)]">Voters can cast ballots from Friday morning through Sunday afternoon.</p>
          </div>
        </section>

        <footer className="fixed bottom-0 left-60 right-0 flex h-[72px] items-center justify-between border-t border-white/6 bg-black/55 px-8 backdrop-blur-lg">
          <Link href="/admin/elections/create/basic-info" className="text-sm text-[var(--text-muted)]">Back to Basic Info</Link>
          <div className="flex items-center gap-3">
            <button className="rounded-lg bg-[var(--surface-container-high)] px-5 py-2.5 text-sm">Save Draft</button>
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

function Field({ label, value, icon }: { label: string; value: string; icon: string }) {
  return (
    <label className="block">
      <span className="mb-2 block text-sm text-[var(--text-muted)]">{label}</span>
      <div className="relative">
        <input value={value} readOnly className="w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-3 pr-10 text-sm" />
        <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[var(--text-muted)]">{icon}</span>
      </div>
    </label>
  );
}

function Reminder({ title, value, on = false }: { title: string; value: string; on?: boolean }) {
  return (
    <div className="flex items-center justify-between rounded-lg bg-[var(--surface-container-low)] p-3">
      <p className="text-sm font-medium">{title}</p>
      <div className="flex items-center gap-3">
        <span className="rounded bg-[var(--surface-container-high)] px-2 py-1 text-[10px]">{value}</span>
        <span className={`relative h-5 w-10 rounded-full ${on ? "bg-[var(--primary)]/25" : "bg-white/12"}`}>
          <span className={`absolute top-1 h-3 w-3 rounded-full ${on ? "right-1 bg-[var(--primary)]" : "left-1 bg-white/40"}`} />
        </span>
      </div>
    </div>
  );
}
