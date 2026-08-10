import { AdminShell } from "@/components/admin-shell";

export default function ElectionOverviewPage() {
  return (
    <AdminShell active="elections">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Elections / Student Council Election 2025</p>
            <h1 className="mt-2 text-4xl font-bold tracking-tight">Election Control Center</h1>
          </div>
          <div className="flex gap-3">
            <button className="rounded-lg bg-[var(--surface-container)] px-4 py-2 text-sm">Suspend</button>
            <button className="brand-gradient rounded-lg px-5 py-2 text-sm font-semibold text-white">Export Live Feed</button>
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-3 xl:grid-cols-6">
          <Card title="Votes" value="94/200" tone="text-white" />
          <Card title="Turnout" value="47%" tone="text-[var(--primary)]" />
          <Card title="Candidates" value="8" tone="text-[var(--secondary)]" />
          <Card title="Positions" value="3" tone="text-[var(--text-muted)]" />
          <Card title="Anomalies" value="7" tone="text-rose-300" />
          <Card title="Time Left" value="1h 47m" tone="text-amber-300" />
        </div>

        <div className="grid gap-5 xl:grid-cols-12">
          <aside className="space-y-5 xl:col-span-3">
            <section className="rounded-xl bg-[var(--surface-container)] p-5">
              <h3 className="text-[10px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Election Info</h3>
              <div className="mt-4 space-y-3 text-sm">
                <Field label="Election ID" value="SEC-STU-2025-004" mono />
                <Field label="Type" value="Standard Plurality Voting" />
                <Field label="Organization" value="Pacific Crest University" />
                <Field label="Primary Admin" value="Alex Rivera" />
              </div>
            </section>
            <section className="rounded-xl bg-[var(--surface-container)] p-5">
              <h3 className="text-[10px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Voter Conditions</h3>
              <div className="mt-4 flex flex-wrap gap-2">
                {[
                  "ACTIVE_STUDENT",
                  "CREDITS > 12",
                  "NO_HOLDS",
                  "FACULTY_NONE",
                ].map((t) => (
                  <span key={t} className="rounded-lg bg-[var(--surface-container-high)] px-2 py-1 text-[10px] font-bold">
                    {t}
                  </span>
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
                {["Position 1: President", "Position 2: Secretary", "Position 3: Treasurer"].map((p) => (
                  <div key={p} className="flex items-center gap-3 rounded-lg bg-[var(--surface-container-low)] p-3">
                    <div className="grid h-10 w-10 place-items-center rounded-lg bg-[var(--surface-container-high)] text-[var(--primary)]">
                      <span className="material-symbols-outlined">person</span>
                    </div>
                    <div>
                      <p className="text-sm font-semibold">{p}</p>
                      <p className="text-xs text-[var(--text-muted)]">Select 1 candidate</p>
                    </div>
                  </div>
                ))}
              </div>
            </section>
          </div>

          <aside className="space-y-5 xl:col-span-3">
            <section className="rounded-xl bg-[var(--surface-container)] p-5">
              <div className="mb-3 flex items-center justify-between">
                <h3 className="text-[10px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Live Alerts</h3>
                <span className="rounded-full bg-rose-500/15 px-2 py-0.5 text-[10px] font-bold text-rose-300">7 Open</span>
              </div>
              <div className="space-y-3">
                <Alert text="Duplicate device signature detected" />
                <Alert text="Traffic spike from Zone B" />
                <Alert text="Unverified voter attempt blocked" />
              </div>
            </section>
            <section className="rounded-xl bg-[var(--surface-container)] p-5">
              <h3 className="text-[10px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Actions</h3>
              <div className="mt-3 space-y-2">
                <button className="w-full rounded-lg bg-[var(--surface-container-high)] px-3 py-2 text-left text-sm">Pause Election</button>
                <button className="w-full rounded-lg bg-[var(--surface-container-high)] px-3 py-2 text-left text-sm">Broadcast Notice</button>
                <button className="w-full rounded-lg bg-rose-500/10 px-3 py-2 text-left text-sm text-rose-300">Close Election</button>
              </div>
            </section>
          </aside>
        </div>
      </section>
    </AdminShell>
  );
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
