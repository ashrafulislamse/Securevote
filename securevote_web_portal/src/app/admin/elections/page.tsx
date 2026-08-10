import Link from "next/link";
import { AdminShell } from "@/components/admin-shell";

const rows = [
  {
    id: "SV-2025-0034",
    title: "Student Council Election 2025",
    org: "CU Malaysia",
    type: "Single",
    schedule: "Nov 14 - Nov 16",
    turnout: 47,
    status: "Active",
  },
  {
    id: "SV-2025-0041",
    title: "Faculty Dean Vote",
    org: "MMU",
    type: "Ranked",
    schedule: "Nov 20 - Nov 22",
    turnout: 0,
    status: "Upcoming",
  },
  {
    id: "SV-2024-0982",
    title: "Club President 2024",
    org: "UM",
    type: "Multi",
    schedule: "Oct 10 - Oct 12",
    turnout: 100,
    status: "Closed",
  },
];

export default function ElectionListPage() {
  return (
    <AdminShell active="elections">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Elections</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Manage all elections across your organizations.</p>
          </div>
          <Link href="/admin/elections/create/basic-info" className="brand-gradient rounded-md px-5 py-2.5 text-sm font-semibold text-white shadow-[0_0_20px_rgba(79,110,247,0.3)]">
            Create Election
          </Link>
        </div>

        <div className="rounded-xl bg-[var(--surface-container)] p-4">
          <div className="flex flex-wrap items-center gap-3">
            <input className="h-9 w-72 rounded-lg bg-[var(--surface-container-low)] px-3 text-sm outline-none ring-1 ring-transparent focus:ring-[var(--primary)]" placeholder="Search elections..." />
            <select className="h-9 rounded-lg bg-[var(--surface-container-low)] px-3 text-xs"><option>Organization: All</option></select>
            <select className="h-9 rounded-lg bg-[var(--surface-container-low)] px-3 text-xs"><option>Status: All</option></select>
            <select className="h-9 rounded-lg bg-[var(--surface-container-low)] px-3 text-xs"><option>Type: All</option></select>
            <button className="ml-auto text-xs font-semibold text-[var(--primary)]">Clear filters</button>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-6 rounded-xl bg-[var(--surface-container)] px-4 py-3 text-sm">
          <Stat title="Total" value="22" />
          <Stat title="Active" value="3" tone="text-[var(--primary)]" />
          <Stat title="Upcoming" value="5" tone="text-[var(--secondary)]" />
          <Stat title="Closed" value="12" tone="text-white/65" />
          <Stat title="Draft" value="2" tone="text-amber-400" />
        </div>

        <section className="overflow-hidden rounded-xl bg-[var(--surface-container)]">
          <div className="flex items-center justify-between border-b border-white/6 px-5 py-4">
            <p className="text-sm text-[var(--text-muted)]">22 elections found</p>
            <button className="text-xs font-semibold text-[var(--primary)]">Columns</button>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full min-w-[900px] text-left">
              <thead className="bg-[var(--surface-container-low)]/80 text-[11px] font-semibold uppercase tracking-[0.1em] text-[var(--text-muted)]">
                <tr>
                  <th className="px-4 py-3">Election</th>
                  <th className="px-4 py-3">Organization</th>
                  <th className="px-4 py-3">Type</th>
                  <th className="px-4 py-3">Schedule</th>
                  <th className="px-4 py-3">Turnout</th>
                  <th className="px-4 py-3">Status</th>
                  <th className="px-4 py-3 text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((row) => (
                  <tr key={row.id} className="border-t border-white/6 text-sm hover:bg-[var(--surface-container-high)]/30">
                    <td className="px-4 py-4">
                      <p className="font-semibold">{row.title}</p>
                      <p className="mt-0.5 font-mono text-[11px] text-white/45">ID: {row.id}</p>
                    </td>
                    <td className="px-4 py-4">{row.org}</td>
                    <td className="px-4 py-4"><span className="rounded-md bg-[var(--surface-container-high)] px-2 py-0.5 text-xs">{row.type}</span></td>
                    <td className="px-4 py-4">{row.schedule}</td>
                    <td className="px-4 py-4">
                      <div className="flex items-center gap-2">
                        <div className="h-1.5 w-20 rounded-full bg-[var(--surface-container-high)]">
                          <div className="brand-gradient h-1.5 rounded-full" style={{ width: `${row.turnout}%` }} />
                        </div>
                        <span className="text-xs">{row.turnout}%</span>
                      </div>
                    </td>
                    <td className="px-4 py-4">
                      <Status status={row.status} />
                    </td>
                    <td className="px-4 py-4 text-right">
                      <Link href="/admin/elections/overview" className="text-xs font-semibold text-[var(--primary)] hover:underline">
                        View
                      </Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      </section>
    </AdminShell>
  );
}

function Stat({ title, value, tone = "text-white" }: { title: string; value: string; tone?: string }) {
  return (
    <div>
      <p className="text-[10px] font-semibold uppercase tracking-[0.12em] text-[var(--text-muted)]">{title}</p>
      <p className={`text-lg font-bold ${tone}`}>{value}</p>
    </div>
  );
}

function Status({ status }: { status: string }) {
  const map = {
    Active: "bg-emerald-500/12 text-emerald-400",
    Upcoming: "bg-[var(--primary)]/12 text-[var(--primary)]",
    Closed: "bg-white/10 text-white/65",
  }[status] ?? "bg-white/10 text-white/70";
  return <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${map}`}>{status}</span>;
}
