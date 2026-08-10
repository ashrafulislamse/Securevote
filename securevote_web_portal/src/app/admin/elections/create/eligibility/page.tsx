import Link from "next/link";
import { AdminShell } from "@/components/admin-shell";

export default function CreateElectionEligibilityPage() {
  return (
    <AdminShell active="elections">
      <section className="mx-auto max-w-6xl space-y-8 pb-28">
        <div>
          <p className="text-xs text-[var(--text-muted)]">Step 3 of 4</p>
          <h1 className="mt-2 text-4xl font-bold tracking-tight">Voter Eligibility</h1>
        </div>

        <Stepper step={3} />

        <div className="grid gap-6 xl:grid-cols-12">
          <div className="space-y-6 xl:col-span-8">
            <section>
              <p className="mb-4 text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Select Voter Base</p>
              <div className="grid gap-4 md:grid-cols-3">
                <Card title="All Verified" text="Include all verified members" value="2,847 voters" active />
                <Card title="Specific Segment" text="Rule based eligibility" value="Rule Based" />
                <Card title="Manual List" text="CSV or paste voter IDs" value="Batch Upload" />
              </div>
            </section>

            <section className="rounded-xl bg-[var(--surface-container)] p-6">
              <div className="mb-4 flex items-center justify-between">
                <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Segment Rules</p>
                <button className="text-xs font-semibold text-[var(--primary)]">Add New Rule</button>
              </div>
              <div className="space-y-3">
                <RuleRow />
                <div className="flex items-center justify-between rounded-lg border border-[var(--primary)]/25 bg-[var(--primary)]/8 p-4">
                  <div>
                    <p className="text-sm font-semibold">Live Match Result</p>
                    <p className="text-xs text-[var(--text-muted)]">Rules currently match Engineering faculty voters.</p>
                  </div>
                  <div className="text-right">
                    <p className="font-mono text-3xl font-bold text-[var(--primary)]">847</p>
                    <p className="text-[10px] uppercase tracking-[0.08em] text-[var(--text-muted)]">Eligible</p>
                  </div>
                </div>
              </div>
            </section>
          </div>

          <aside className="space-y-6 xl:col-span-4">
            <section className="rounded-xl bg-[var(--surface-container)] p-6">
              <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Verification Requirements</p>
              <div className="mt-5 space-y-4">
                <Toggle title="Identity KYC" note="Government-issued ID required" on />
                <Toggle title="Email Verification" note="OTP challenge" on />
                <Toggle title="Device Binding" note="One trusted device" />
              </div>
            </section>

            <section className="rounded-xl bg-[var(--surface-container)] p-6">
              <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Quorum and Turnout</p>
              <div className="mt-5 space-y-5">
                <div>
                  <div className="mb-1 flex items-center justify-between text-xs">
                    <span>Min Turnout Threshold</span>
                    <span className="font-mono text-[var(--primary)]">30%</span>
                  </div>
                  <input type="range" defaultValue={30} className="w-full accent-[var(--primary)]" />
                </div>
                <div>
                  <p className="mb-2 text-xs">Max Votes Per Position</p>
                  <input type="number" defaultValue={1} className="w-24 rounded-lg bg-[var(--surface-container-low)] px-3 py-2 font-mono text-sm" />
                </div>
              </div>
            </section>
          </aside>
        </div>

        <footer className="fixed bottom-0 left-60 right-0 flex h-[76px] items-center justify-between border-t border-white/6 bg-black/55 px-8 backdrop-blur-lg">
          <Link href="/admin/elections/create/schedule" className="text-sm text-[var(--text-muted)]">Back</Link>
          <div className="flex items-center gap-3">
            <button className="rounded-lg bg-[var(--surface-container-high)] px-5 py-2.5 text-sm">Save Draft</button>
            <Link href="/admin/elections/create/review" className="brand-gradient rounded-lg px-8 py-2.5 text-sm font-semibold text-white">Continue</Link>
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

function Card({ title, text, value, active = false }: { title: string; text: string; value: string; active?: boolean }) {
  return (
    <article className={`rounded-xl p-5 ${active ? "border border-[var(--primary)]/40 bg-[var(--primary)]/8" : "bg-[var(--surface-container)]"}`}>
      <h3 className="text-sm font-bold">{title}</h3>
      <p className="mt-1 text-xs text-[var(--text-muted)]">{text}</p>
      <p className="mt-4 text-xs font-mono uppercase tracking-[0.08em] text-[var(--primary)]">{value}</p>
    </article>
  );
}

function RuleRow() {
  return (
    <div className="grid gap-3 rounded-lg bg-[var(--surface-container-low)] p-3 md:grid-cols-[1fr,1fr,2fr,auto]">
      <select className="rounded bg-[var(--surface-container-high)] px-3 py-2 text-sm"><option>Faculty</option></select>
      <select className="rounded bg-[var(--surface-container-high)] px-3 py-2 text-sm"><option>Equals</option></select>
      <input className="rounded bg-[var(--surface-container-high)] px-3 py-2 text-sm" defaultValue="Engineering" />
      <button className="rounded px-3 py-2 text-rose-300">Delete</button>
    </div>
  );
}

function Toggle({ title, note, on = false }: { title: string; note: string; on?: boolean }) {
  return (
    <div className="flex items-center justify-between">
      <div>
        <p className="text-sm font-semibold">{title}</p>
        <p className="text-xs text-[var(--text-muted)]">{note}</p>
      </div>
      <span className={`relative h-5 w-10 rounded-full ${on ? "bg-[var(--primary)]/25" : "bg-white/12"}`}>
        <span className={`absolute top-1 h-3 w-3 rounded-full ${on ? "right-1 bg-[var(--primary)]" : "left-1 bg-white/45"}`} />
      </span>
    </div>
  );
}
