import { AdminShell } from "@/components/admin-shell";

const kpis = [
  { title: "Active Elections", value: "3", note: "+1", noteClass: "text-[var(--primary)] bg-[var(--primary)]/10" },
  { title: "Total Voters", value: "2,847", note: "Verified", noteClass: "text-emerald-400 bg-emerald-500/10" },
  { title: "Live Turnout", value: "47.3%", note: "Realtime", noteClass: "text-[var(--text-muted)] bg-white/5" },
  { title: "Open Anomalies", value: "7", note: "Requires Attention", noteClass: "text-rose-300 bg-rose-500/15" },
];

const rows = [
  { id: "#SV-842", name: "Student Council 2024", status: "Active", statusClass: "text-emerald-400 bg-emerald-500/10", action: "Monitor", progress: "65%" },
  { id: "#SV-791", name: "Faculty Dean Vote", status: "Upcoming", statusClass: "text-[var(--primary)] bg-[var(--primary)]/10", action: "Setup", progress: "0%" },
  { id: "#SV-612", name: "Club President 2023", status: "Closed", statusClass: "text-white/65 bg-white/8", action: "Audit", progress: "100%" },
];

export default function AdminDashboardPage() {
  return (
    <AdminShell active="dashboard">
      <section className="space-y-7">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Dashboard</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">System overview for City University Malaysia</p>
          </div>
          <div className="flex items-center gap-3">
            <button className="rounded-md bg-[var(--surface-container)] px-4 py-2 text-sm">Last 7 days</button>
            <button className="brand-gradient rounded-md px-5 py-2 text-sm font-semibold text-white shadow-[0_0_20px_rgba(79,110,247,0.3)]">New Election</button>
          </div>
        </div>

        <div className="grid gap-5 md:grid-cols-2 xl:grid-cols-4">
          {kpis.map((kpi) => (
            <article key={kpi.title} className="top-accent rounded-xl bg-[var(--surface-container)] p-5">
              <p className="text-[10px] font-bold uppercase tracking-[0.15em] text-[var(--text-muted)]">{kpi.title}</p>
              <div className="mt-3 flex items-end justify-between">
                <h2 className="text-4xl font-bold leading-none">{kpi.value}</h2>
                <span className={`rounded px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${kpi.noteClass}`}>{kpi.note}</span>
              </div>
            </article>
          ))}
        </div>

        <div className="grid gap-5 xl:grid-cols-10">
          <article className="rounded-xl bg-[var(--surface-container)] p-6 xl:col-span-6">
            <div className="mb-5 flex items-center justify-between">
              <div>
                <h3 className="text-lg font-semibold">Voter Turnout</h3>
                <p className="text-xs text-[var(--text-muted)]">Weekly participation trends</p>
              </div>
              <div className="flex items-center gap-4 text-xs">
                <span className="inline-flex items-center gap-2"><i className="h-2.5 w-2.5 rounded-sm brand-gradient" />This Week</span>
                <span className="inline-flex items-center gap-2"><i className="h-2.5 w-2.5 rounded-sm bg-[var(--tertiary)]" />Previous Week</span>
              </div>
            </div>
            <div className="relative h-64 overflow-hidden rounded-lg bg-[var(--surface-container-high)]/30">
              <svg className="h-full w-full" viewBox="0 0 1000 260" preserveAspectRatio="none">
                <defs>
                  <linearGradient id="g1" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#4F6EF7" stopOpacity="0.25" />
                    <stop offset="100%" stopColor="#4F6EF7" stopOpacity="0" />
                  </linearGradient>
                </defs>
                <path d="M0,200 Q150,145 300,175 T600,105 T1000,125 L1000,260 L0,260 Z" fill="url(#g1)" />
                <path d="M0,200 Q150,145 300,175 T600,105 T1000,125" fill="none" stroke="#4F6EF7" strokeWidth="3" />
                <path d="M0,228 Q150,190 300,205 T600,165 T1000,182" fill="none" stroke="#4CD7F6" strokeWidth="2" strokeDasharray="5 7" />
              </svg>
            </div>
          </article>

          <article className="rounded-xl bg-[var(--surface-container)] p-6 xl:col-span-4">
            <h3 className="text-lg font-semibold">Election Status</h3>
            <div className="mt-6 flex justify-center">
              <div className="relative">
                <svg className="h-44 w-44 -rotate-90" viewBox="0 0 100 100">
                  <circle cx="50" cy="50" r="40" fill="none" stroke="#34343a" strokeWidth="12" />
                  <circle cx="50" cy="50" r="40" fill="none" stroke="#4F6EF7" strokeWidth="12" strokeDasharray="14 251" />
                  <circle cx="50" cy="50" r="40" fill="none" stroke="#7C3AED" strokeWidth="12" strokeDasharray="23 251" strokeDashoffset="-14" />
                  <circle cx="50" cy="50" r="40" fill="none" stroke="#10B981" strokeWidth="12" strokeDasharray="55 251" strokeDashoffset="-37" />
                </svg>
                <div className="absolute inset-0 grid place-items-center text-center">
                  <p className="text-3xl font-bold leading-none">22</p>
                  <p className="text-[10px] font-bold uppercase tracking-[0.12em] text-[var(--text-muted)]">Total</p>
                </div>
              </div>
            </div>
            <div className="mt-5 grid grid-cols-2 gap-2 text-xs text-[var(--text-muted)]">
              <StatusDot color="bg-[#4F6EF7]" text="Active (3)" />
              <StatusDot color="bg-[#7C3AED]" text="Upcoming (5)" />
              <StatusDot color="bg-[#10B981]" text="Closed (12)" />
              <StatusDot color="bg-[#34343a]" text="Draft (2)" />
            </div>
          </article>
        </div>

        <div className="grid gap-5 xl:grid-cols-10">
          <article className="overflow-hidden rounded-xl bg-[var(--surface-container)] xl:col-span-6">
            <div className="flex items-center justify-between bg-[var(--surface-container-low)] px-6 py-4">
              <h4 className="text-[10px] font-bold uppercase tracking-[0.15em] text-[var(--text-muted)]">Recent Elections</h4>
              <button className="text-xs font-semibold text-[var(--primary)]">View All</button>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full min-w-[640px] text-left">
                <thead className="bg-[var(--surface-container-low)]/70 text-[10px] font-bold uppercase tracking-[0.12em] text-[var(--text-muted)]">
                  <tr>
                    <th className="px-6 py-3">ID</th>
                    <th className="px-6 py-3">Election Name</th>
                    <th className="px-6 py-3">Status</th>
                    <th className="px-6 py-3">Turnout</th>
                    <th className="px-6 py-3">Action</th>
                  </tr>
                </thead>
                <tbody>
                  {rows.map((row) => (
                    <tr key={row.id} className="border-t border-white/5 text-sm hover:bg-[var(--surface-container-high)]/40">
                      <td className="px-6 py-4 font-mono text-xs text-white/55">{row.id}</td>
                      <td className="px-6 py-4 font-semibold">{row.name}</td>
                      <td className="px-6 py-4">
                        <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${row.statusClass}`}>{row.status}</span>
                      </td>
                      <td className="px-6 py-4">
                        <div className="h-1.5 w-24 rounded-full bg-[var(--surface-container-high)]">
                          <div className="brand-gradient h-1.5 rounded-full" style={{ width: row.progress }} />
                        </div>
                      </td>
                      <td className="px-6 py-4 text-xs font-semibold text-[var(--primary)]">{row.action}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </article>

          <article className="rounded-xl bg-[var(--surface-container)] p-6 xl:col-span-4">
            <div className="mb-5 flex items-center justify-between">
              <h4 className="text-[10px] font-bold uppercase tracking-[0.15em] text-[var(--text-muted)]">Live Alerts</h4>
              <span className="rounded-full bg-rose-500/15 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] text-rose-300">5 Critical</span>
            </div>
            <div className="space-y-3">
              <AlertCard tone="rose" title="Duplicate device detected" sub="ID: 0x82...F2E" />
              <AlertCard tone="amber" title="IP spike from Zone B" sub="Unusual traffic volume" />
              <AlertCard tone="blue" title="Key rotation completed" sub="No service impact" />
            </div>
          </article>
        </div>
      </section>
    </AdminShell>
  );
}

function StatusDot({ color, text }: { color: string; text: string }) {
  return (
    <span className="inline-flex items-center gap-2">
      <i className={`h-2 w-2 rounded-full ${color}`} />
      {text}
    </span>
  );
}

function AlertCard({
  tone,
  title,
  sub,
}: {
  tone: "rose" | "amber" | "blue";
  title: string;
  sub: string;
}) {
  const toneClass = {
    rose: "border-rose-500/45 bg-rose-500/8",
    amber: "border-amber-500/45 bg-amber-500/8",
    blue: "border-sky-500/45 bg-sky-500/8",
  }[tone];

  return (
    <div className={`rounded-lg border-l-2 p-3 ${toneClass}`}>
      <p className="text-sm font-semibold">{title}</p>
      <p className="mt-1 text-xs text-[var(--text-muted)]">{sub}</p>
    </div>
  );
}
