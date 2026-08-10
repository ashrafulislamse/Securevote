"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";

type VoterStatus = "Verified" | "Pending" | "Rejected";

type Voter = {
  id: string;
  name: string;
  email: string;
  phone: string;
  joined: string;
  elections: number;
  status: VoterStatus;
};

const voterSeed: Voter[] = [
  {
    id: "SV-8291-TK0",
    name: "Ashraful Islam",
    email: "ashraful.i@vault.io",
    phone: "+880 171 2938 12",
    joined: "Oct 12, 2025",
    elections: 12,
    status: "Verified",
  },
  {
    id: "SV-3942-MY8",
    name: "Siti Aminah",
    email: "siti.aminah@global.net",
    phone: "+60 11 2049 881",
    joined: "Jan 05, 2026",
    elections: 0,
    status: "Pending",
  },
  {
    id: "SV-5510-XZ1",
    name: "Marcus Thorne",
    email: "marcus.thorne@securemail.io",
    phone: "+1 404 290 3300",
    joined: "Dec 28, 2025",
    elections: 4,
    status: "Verified",
  },
  {
    id: "SV-2004-KL9",
    name: "Elena Rodriguez",
    email: "elena.r@citymail.org",
    phone: "+34 621 10 88 22",
    joined: "Nov 16, 2025",
    elections: 1,
    status: "Rejected",
  },
];

export default function VoterListPage() {
  const [query, setQuery] = useState("");
  const [status, setStatus] = useState<"All" | VoterStatus>("All");
  const [selected, setSelected] = useState<string[]>([]);

  const voters = useMemo(() => {
    return voterSeed.filter((voter) => {
      const matchesStatus = status === "All" || voter.status === status;
      const matchesQuery = `${voter.name} ${voter.email} ${voter.id}`.toLowerCase().includes(query.toLowerCase());
      return matchesStatus && matchesQuery;
    });
  }, [query, status]);

  return (
    <AdminShell active="voters">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold tracking-tight">Voter Registry</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Track identity status, participation, and KYC readiness across all voters.</p>
          </div>
          <div className="flex gap-3">
            <Link href="/admin/voters/kyc-verification" className="rounded-lg bg-[var(--surface-container)] px-4 py-2 text-sm font-semibold">
              Open KYC Queue
            </Link>
            <Link href="/admin/voters/import" className="brand-gradient rounded-lg px-5 py-2 text-sm font-semibold text-white">
              Import Voters
            </Link>
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-4">
          <StatCard title="Total" value="2,847" tone="text-white" />
          <StatCard title="Verified" value="2,401" tone="text-emerald-300" />
          <StatCard title="Pending" value="312" tone="text-amber-300" />
          <StatCard title="Rejected" value="134" tone="text-rose-300" />
        </div>

        <section className="rounded-xl bg-[var(--surface-container)] p-4">
          <div className="flex flex-wrap items-center gap-3">
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              className="h-10 w-80 rounded-lg bg-[var(--surface-container-low)] px-3 text-sm"
              placeholder="Search by name, email, voter ID"
            />
            <select value={status} onChange={(e) => setStatus(e.target.value as "All" | VoterStatus)} className="h-10 rounded-lg bg-[var(--surface-container-low)] px-3 text-sm">
              <option value="All">Status: All</option>
              <option value="Verified">Verified</option>
              <option value="Pending">Pending</option>
              <option value="Rejected">Rejected</option>
            </select>
            <p className="ml-auto text-xs text-[var(--text-muted)]">{voters.length} records</p>
          </div>
        </section>

        <section className="overflow-hidden rounded-xl bg-[var(--surface-container)]">
          {selected.length > 0 ? (
            <div className="flex items-center justify-between border-b border-white/8 bg-[var(--primary)]/8 px-5 py-3">
              <p className="text-sm">{selected.length} selected</p>
              <div className="flex gap-2">
                <button className="rounded-md bg-emerald-500/15 px-3 py-1 text-xs font-semibold text-emerald-300">Approve</button>
                <button className="rounded-md bg-rose-500/15 px-3 py-1 text-xs font-semibold text-rose-300">Reject</button>
                <button className="rounded-md bg-white/10 px-3 py-1 text-xs font-semibold">Notify</button>
              </div>
            </div>
          ) : null}

          <div className="overflow-x-auto">
            <table className="w-full min-w-[940px] text-left">
              <thead className="bg-[var(--surface-container-low)] text-[11px] uppercase tracking-[0.1em] text-[var(--text-muted)]">
                <tr>
                  <th className="px-4 py-3">
                    <input
                      type="checkbox"
                      checked={voters.length > 0 && selected.length === voters.length}
                      onChange={(event) => {
                        if (event.target.checked) {
                          setSelected(voters.map((v) => v.id));
                        } else {
                          setSelected([]);
                        }
                      }}
                    />
                  </th>
                  <th className="px-4 py-3">Voter</th>
                  <th className="px-4 py-3">Contact</th>
                  <th className="px-4 py-3">Joined</th>
                  <th className="px-4 py-3 text-center">Status</th>
                  <th className="px-4 py-3 text-center">Elections</th>
                  <th className="px-4 py-3 text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {voters.map((voter) => {
                  const checked = selected.includes(voter.id);
                  return (
                    <tr key={voter.id} className={`border-t border-white/8 text-sm ${checked ? "bg-[var(--primary)]/7" : "hover:bg-[var(--surface-container-high)]/25"}`}>
                      <td className="px-4 py-4">
                        <input
                          type="checkbox"
                          checked={checked}
                          onChange={() => {
                            setSelected((prev) => (checked ? prev.filter((id) => id !== voter.id) : [...prev, voter.id]));
                          }}
                        />
                      </td>
                      <td className="px-4 py-4">
                        <p className="font-semibold">{voter.name}</p>
                        <p className="font-mono text-[11px] text-[var(--text-muted)]">{voter.id}</p>
                      </td>
                      <td className="px-4 py-4">
                        <p>{voter.email}</p>
                        <p className="text-xs text-[var(--text-muted)]">{voter.phone}</p>
                      </td>
                      <td className="px-4 py-4">{voter.joined}</td>
                      <td className="px-4 py-4 text-center">
                        <StatusPill status={voter.status} />
                      </td>
                      <td className="px-4 py-4 text-center">
                        <span className="rounded-full bg-white/8 px-2 py-0.5 text-xs font-bold">{voter.elections}</span>
                      </td>
                      <td className="px-4 py-4 text-right">
                        <Link href="/admin/voters/profile" className="text-xs font-semibold text-[var(--primary)]">
                          View
                        </Link>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </section>
      </section>
    </AdminShell>
  );
}

function StatusPill({ status }: { status: VoterStatus }) {
  const tone =
    status === "Verified"
      ? "bg-emerald-500/15 text-emerald-300"
      : status === "Pending"
        ? "bg-amber-500/15 text-amber-300"
        : "bg-rose-500/15 text-rose-300";

  return <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${tone}`}>{status}</span>;
}

function StatCard({ title, value, tone }: { title: string; value: string; tone: string }) {
  return (
    <article className="top-accent rounded-xl bg-[var(--surface-container)] p-4">
      <p className="text-[10px] font-semibold uppercase tracking-[0.12em] text-[var(--text-muted)]">{title}</p>
      <p className={`mt-1 text-2xl font-bold ${tone}`}>{value}</p>
    </article>
  );
}
