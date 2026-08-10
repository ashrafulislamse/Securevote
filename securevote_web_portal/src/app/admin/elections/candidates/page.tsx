"use client";

import { useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";

type Candidate = {
  id: string;
  name: string;
  party: string;
  role: "President" | "Secretary" | "Treasurer";
  ballotNo: string;
  verified: boolean;
  visible: boolean;
  manifesto: string;
};

const initialCandidates: Candidate[] = [
  {
    id: "cand-04",
    name: "Ahmad Fariz",
    party: "Progressive Students Front",
    role: "President",
    ballotNo: "04",
    verified: true,
    visible: true,
    manifesto: "Empowering student voices through transparent governance and weekly digital town halls.",
  },
  {
    id: "cand-07",
    name: "Sarah Chen",
    party: "Unity and Tradition Alliance",
    role: "President",
    ballotNo: "07",
    verified: true,
    visible: true,
    manifesto: "Building continuity, stronger campus services, and practical student support pathways.",
  },
  {
    id: "cand-12",
    name: "Leo Thompson",
    party: "Independent",
    role: "Treasurer",
    ballotNo: "12",
    verified: false,
    visible: false,
    manifesto: "Responsible financial controls and monthly public treasury reports for all student bodies.",
  },
  {
    id: "cand-16",
    name: "Maya Siregar",
    party: "Campus Equity Group",
    role: "Secretary",
    ballotNo: "16",
    verified: true,
    visible: true,
    manifesto: "Documentation clarity, student policy literacy, and quicker case escalation handling.",
  },
];

export default function CandidateManagementPage() {
  const [query, setQuery] = useState("");
  const [roleFilter, setRoleFilter] = useState<"All" | Candidate["role"]>("All");
  const [candidates, setCandidates] = useState<Candidate[]>(initialCandidates);
  const [selectedId, setSelectedId] = useState(initialCandidates[0]?.id ?? "");

  const filtered = useMemo(() => {
    return candidates.filter((candidate) => {
      const matchesRole = roleFilter === "All" || candidate.role === roleFilter;
      const haystack = `${candidate.name} ${candidate.party} ${candidate.ballotNo}`.toLowerCase();
      const matchesQuery = haystack.includes(query.toLowerCase());
      return matchesRole && matchesQuery;
    });
  }, [candidates, query, roleFilter]);

  const selected = filtered.find((c) => c.id === selectedId) ?? filtered[0] ?? null;

  return (
    <AdminShell active="elections">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Elections / Student Council 2025</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Candidate Management</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Review, verify, and publish candidate profiles before final ballot lock.</p>
          </div>
          <div className="flex gap-3">
            <button className="rounded-lg bg-[var(--surface-container)] px-4 py-2 text-sm font-semibold">Import CSV</button>
            <button className="brand-gradient rounded-lg px-5 py-2 text-sm font-semibold text-white">Add Candidate</button>
          </div>
        </div>

        <section className="rounded-xl bg-[var(--surface-container)] p-4">
          <div className="flex flex-wrap items-center gap-3">
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search candidate, party, ballot no..."
              className="h-10 w-80 rounded-lg bg-[var(--surface-container-low)] px-3 text-sm outline-none ring-1 ring-transparent focus:ring-[var(--primary)]"
            />
            <select
              value={roleFilter}
              onChange={(e) => setRoleFilter(e.target.value as "All" | Candidate["role"])}
              className="h-10 rounded-lg bg-[var(--surface-container-low)] px-3 text-sm"
            >
              <option value="All">Role: All</option>
              <option value="President">President</option>
              <option value="Secretary">Secretary</option>
              <option value="Treasurer">Treasurer</option>
            </select>
            <p className="ml-auto text-xs text-[var(--text-muted)]">{filtered.length} candidates</p>
          </div>
        </section>

        <div className="grid gap-6 xl:grid-cols-[1.4fr,1fr]">
          <section className="grid gap-4 md:grid-cols-2">
            {filtered.map((candidate) => (
              <article
                key={candidate.id}
                onClick={() => setSelectedId(candidate.id)}
                className={`cursor-pointer rounded-xl border p-4 transition ${
                  selected?.id === candidate.id
                    ? "border-[var(--primary)]/50 bg-[var(--primary)]/8"
                    : "border-white/8 bg-[var(--surface-container)] hover:bg-[var(--surface-container-high)]/40"
                }`}
              >
                <div className="flex items-start justify-between">
                  <div>
                    <p className="text-lg font-semibold">{candidate.name}</p>
                    <p className="text-xs text-[var(--primary)]">{candidate.party}</p>
                  </div>
                  <span className="rounded-md bg-[var(--surface-container-high)] px-2 py-1 text-[10px] font-bold uppercase tracking-[0.08em]">
                    #{candidate.ballotNo}
                  </span>
                </div>
                <p className="mt-3 text-xs text-[var(--text-muted)]">{candidate.manifesto}</p>
                <div className="mt-4 flex items-center justify-between">
                  <span className="rounded-full bg-white/8 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em]">{candidate.role}</span>
                  <div className="flex items-center gap-2">
                    <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold ${candidate.verified ? "bg-emerald-500/15 text-emerald-300" : "bg-amber-500/15 text-amber-300"}`}>
                      {candidate.verified ? "Verified" : "Pending"}
                    </span>
                    <button
                      type="button"
                      onClick={(event) => {
                        event.stopPropagation();
                        setCandidates((prev) =>
                          prev.map((item) => (item.id === candidate.id ? { ...item, visible: !item.visible } : item)),
                        );
                      }}
                      className={`rounded-md px-2 py-1 text-[10px] font-bold uppercase tracking-[0.08em] ${
                        candidate.visible ? "bg-[var(--primary)]/15 text-[var(--primary)]" : "bg-white/10 text-white/65"
                      }`}
                    >
                      {candidate.visible ? "Visible" : "Hidden"}
                    </button>
                  </div>
                </div>
              </article>
            ))}
          </section>

          <aside className="rounded-xl bg-[var(--surface-container)] p-5">
            {selected ? (
              <>
                <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Candidate Detail</p>
                <h2 className="mt-3 text-2xl font-bold tracking-tight">{selected.name}</h2>
                <p className="text-sm text-[var(--primary)]">{selected.party}</p>

                <div className="mt-5 space-y-3 text-sm">
                  <DetailRow label="Role" value={selected.role} />
                  <DetailRow label="Ballot No." value={`#${selected.ballotNo}`} mono />
                  <DetailRow label="Verification" value={selected.verified ? "Approved" : "Awaiting review"} />
                  <DetailRow label="Visibility" value={selected.visible ? "Public" : "Hidden"} />
                </div>

                <div className="mt-6 rounded-lg border border-[var(--primary)]/25 bg-[var(--primary)]/7 p-4">
                  <p className="text-[10px] font-bold uppercase tracking-[0.1em] text-[var(--text-muted)]">Manifesto snippet</p>
                  <p className="mt-2 text-sm text-white/85">{selected.manifesto}</p>
                </div>

                <div className="mt-6 grid grid-cols-2 gap-3">
                  <button className="rounded-lg bg-[var(--surface-container-high)] px-4 py-2 text-sm">Request Edit</button>
                  <button
                    type="button"
                    onClick={() => {
                      setCandidates((prev) =>
                        prev.map((item) => (item.id === selected.id ? { ...item, verified: true, visible: true } : item)),
                      );
                    }}
                    className="brand-gradient rounded-lg px-4 py-2 text-sm font-semibold text-white"
                  >
                    Approve Candidate
                  </button>
                </div>
              </>
            ) : (
              <p className="text-sm text-[var(--text-muted)]">No candidate matches the current filter.</p>
            )}
          </aside>
        </div>
      </section>
    </AdminShell>
  );
}

function DetailRow({ label, value, mono = false }: { label: string; value: string; mono?: boolean }) {
  return (
    <div className="flex items-center justify-between rounded-lg bg-[var(--surface-container-low)] px-3 py-2">
      <p className="text-xs uppercase tracking-[0.08em] text-[var(--text-muted)]">{label}</p>
      <p className={mono ? "font-mono text-sm" : "text-sm font-semibold"}>{value}</p>
    </div>
  );
}
