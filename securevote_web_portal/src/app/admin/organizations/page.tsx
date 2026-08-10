"use client";

import { useEffect, useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import { listElections, type Election } from "@/lib/api-client";

type Org = {
  id: string;
  name: string;
  plan: "Enterprise" | "Professional" | "Starter";
  members: number;
  activeElections: number;
  status: "active" | "paused";
};

function slugify(name: string): string {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

function deriveOrgs(elections: Election[]): Org[] {
  const byName = new Map<string, Election[]>();
  for (const election of elections) {
    const name = election.organization?.trim();
    if (!name) continue;
    const list = byName.get(name) ?? [];
    list.push(election);
    byName.set(name, list);
  }

  return Array.from(byName.entries())
    .map(([name, orgElections]) => ({
      id: slugify(name) || `org-${name}`,
      name,
      plan: "Professional" as const,
      members: 0,
      activeElections: orgElections.filter((e) => e.status === "active").length,
      status: orgElections.some((e) => e.status === "active") ? ("active" as const) : ("paused" as const),
    }))
    .sort((a, b) => a.name.localeCompare(b.name));
}

export default function OrganizationManagementPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [organizations, setOrganizations] = useState<Org[]>([]);
  const [query, setQuery] = useState("");
  const [selectedId, setSelectedId] = useState("");

  useEffect(() => {
    let active = true;

    async function load() {
      setLoading(true);
      setError(null);
      try {
        const elections = await listElections();
        if (!active) return;
        const orgs = deriveOrgs(elections);
        setOrganizations(orgs);
        if (orgs.length > 0) setSelectedId(orgs[0].id);
      } catch (err) {
        if (!active) return;
        setError(err instanceof Error ? err.message : "Failed to load organizations");
      } finally {
        if (active) setLoading(false);
      }
    }

    load();
    return () => {
      active = false;
    };
  }, []);

  const filtered = useMemo(() => {
    return organizations.filter((item) => {
      const key = `${item.id} ${item.name} ${item.plan}`.toLowerCase();
      return key.includes(query.toLowerCase());
    });
  }, [organizations, query]);

  const selected = filtered.find((item) => item.id === selectedId) ?? filtered[0] ?? null;

  return (
    <AdminShell active="elections">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Platform / Multi-tenant</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Organization Management</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Manage tenant organizations, admin seats, and election capacity.</p>
          </div>
          <button
            type="button"
            onClick={() => {
              const id = `ORG-${Math.floor(Math.random() * 900 + 100)}`;
              const next: Org = {
                id,
                name: "New Organization",
                plan: "Starter",
                members: 1,
                activeElections: 0,
                status: "active",
              };
              setOrganizations((prev) => [next, ...prev]);
              setSelectedId(id);
            }}
            className="brand-gradient rounded-lg px-4 py-2 text-sm font-semibold text-white"
          >
            New Organization
          </button>
        </div>

        <section className="rounded-xl bg-[var(--surface-container)] p-4">
          <input
            value={query}
            onChange={(event) => setQuery(event.target.value)}
            placeholder="Search organization by name or id..."
            className="h-10 w-full rounded-lg bg-[var(--surface-container-low)] px-3 text-sm outline-none ring-1 ring-transparent focus:ring-[var(--primary)]"
          />
        </section>

        {loading ? (
          <div className="rounded-xl bg-[var(--surface-container)] p-10 text-center text-sm text-[var(--text-muted)]">
            Loading organizations...
          </div>
        ) : error ? (
          <div className="rounded-xl border border-rose-500/30 bg-rose-500/8 p-10 text-center text-sm text-rose-300">
            {error}
          </div>
        ) : (
          <div className="grid gap-6 xl:grid-cols-[1.25fr,0.95fr]">
            <section className="overflow-hidden rounded-xl bg-[var(--surface-container)]">
              <table className="w-full text-left">
                <thead className="bg-[var(--surface-container-low)] text-[11px] uppercase tracking-[0.08em] text-[var(--text-muted)]">
                  <tr>
                    <th className="px-4 py-3">Organization</th>
                    <th className="px-4 py-3">Plan</th>
                    <th className="px-4 py-3">Members</th>
                    <th className="px-4 py-3">Elections</th>
                    <th className="px-4 py-3">Status</th>
                  </tr>
                </thead>
                <tbody>
                  {filtered.map((org) => (
                    <tr
                      key={org.id}
                      onClick={() => setSelectedId(org.id)}
                      className={`cursor-pointer border-t border-white/6 text-sm ${selected?.id === org.id ? "bg-[var(--primary)]/8" : ""}`}
                    >
                      <td className="px-4 py-3">
                        <p className="font-semibold">{org.name}</p>
                        <p className="text-xs text-[var(--text-muted)]">{org.id}</p>
                      </td>
                      <td className="px-4 py-3">{org.plan}</td>
                      <td className="px-4 py-3">{org.members}</td>
                      <td className="px-4 py-3">{org.activeElections}</td>
                      <td className="px-4 py-3">
                        <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${org.status === "active" ? "bg-emerald-500/15 text-emerald-300" : "bg-amber-500/15 text-amber-300"}`}>
                          {org.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {filtered.length === 0 ? (
                <p className="px-4 py-8 text-center text-sm text-[var(--text-muted)]">No organizations found.</p>
              ) : null}
            </section>

            <aside className="rounded-xl bg-[var(--surface-container)] p-5">
              {selected ? (
                <>
                  <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Organization Detail</p>
                  <h2 className="mt-3 text-2xl font-bold tracking-tight">{selected.name}</h2>
                  <p className="text-sm text-[var(--text-muted)]">{selected.id}</p>

                  <div className="mt-5 space-y-3">
                    <Detail label="Plan" value={selected.plan} />
                    <Detail label="Members" value={`${selected.members}`} />
                    <Detail label="Active Elections" value={`${selected.activeElections}`} />
                    <Detail label="Status" value={selected.status} />
                  </div>

                  <div className="mt-6 grid grid-cols-2 gap-3">
                    <button
                      type="button"
                      onClick={() => {
                        setOrganizations((prev) =>
                          prev.map((item) =>
                            item.id === selected.id
                              ? { ...item, status: item.status === "active" ? "paused" : "active" }
                              : item,
                          ),
                        );
                      }}
                      className="rounded-lg bg-[var(--surface-container-high)] px-4 py-2 text-sm"
                    >
                      Toggle Status
                    </button>
                    <button
                      type="button"
                      onClick={() => {
                        setOrganizations((prev) =>
                          prev.map((item) =>
                            item.id === selected.id ? { ...item, members: item.members + 1 } : item,
                          ),
                        );
                      }}
                      className="brand-gradient rounded-lg px-4 py-2 text-sm font-semibold text-white"
                    >
                      Add Admin Seat
                    </button>
                  </div>

                  {/* TODO: organizations module — backend endpoint not yet built.
                      Status toggle / add-admin only update local state for the demo. */}
                </>
              ) : (
                <p className="text-sm text-[var(--text-muted)]">Select an organization to manage details.</p>
              )}
            </aside>
          </div>
        )}
      </section>
    </AdminShell>
  );
}

function Detail({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between rounded-lg bg-[var(--surface-container-low)] px-3 py-2">
      <p className="text-xs uppercase tracking-[0.08em] text-[var(--text-muted)]">{label}</p>
      <p className="text-sm font-semibold capitalize">{value}</p>
    </div>
  );
}