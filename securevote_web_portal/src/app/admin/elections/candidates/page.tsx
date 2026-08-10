"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import * as api from "@/lib/api-client";

type CandidateWithMeta = api.Candidate & {
  visible: boolean;
  verified: boolean;
};

export default function CandidateManagementPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [elections, setElections] = useState<api.Election[]>([]);
  const [electionId, setElectionId] = useState<string>("");
  const [candidates, setCandidates] = useState<CandidateWithMeta[]>([]);

  const [query, setQuery] = useState("");
  const [selectedId, setSelectedId] = useState<string>("");

  const [showAddForm, setShowAddForm] = useState(false);
  const [adding, setAdding] = useState(false);
  const [addError, setAddError] = useState<string | null>(null);
  const [form, setForm] = useState({ name: "", party: "", bio: "", manifesto: "", ballotOrder: "" });

  const loadElections = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const list = await api.listElections();
      setElections(list);
      const first = [...list].sort((a, b) => b.startsAt - a.startsAt)[0] ?? null;
      setElectionId(first?.id ?? "");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load elections");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    loadElections();
  }, [loadElections]);

  const loadCandidates = useCallback(async (id: string) => {
    if (!id) {
      setCandidates([]);
      return;
    }
    setLoading(true);
    setError(null);
    try {
      const data = await api.getElection(id);
      const mapped: CandidateWithMeta[] = data.candidates.map((c) => ({
        ...c,
        visible: true,
        verified: true,
      }));
      setCandidates(mapped);
      setSelectedId(mapped[0]?.id ?? "");
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load candidates");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    if (electionId) {
      loadCandidates(electionId);
    }
  }, [electionId, loadCandidates]);

  const filtered = useMemo(() => {
    return candidates.filter((candidate) => {
      const haystack = `${candidate.name} ${candidate.party ?? ""} ${candidate.ballotOrder}`.toLowerCase();
      return haystack.includes(query.toLowerCase());
    });
  }, [candidates, query]);

  const selected = filtered.find((c) => c.id === selectedId) ?? filtered[0] ?? null;

  const toggleVisibility = (id: string) => {
    // TODO: candidate update/delete endpoint
    setCandidates((prev) => prev.map((item) => (item.id === id ? { ...item, visible: !item.visible } : item)));
  };

  const updateSelected = (patch: Partial<CandidateWithMeta>) => {
    // TODO: candidate update/delete endpoint
    setCandidates((prev) => prev.map((item) => (item.id === selected?.id ? { ...item, ...patch } : item)));
  };

  const approveCandidate = () => {
    // TODO: candidate update/delete endpoint
    setCandidates((prev) => prev.map((item) => (item.id === selected?.id ? { ...item, verified: true, visible: true } : item)));
  };

  const addCandidate = async () => {
    if (!form.name.trim()) {
      setAddError("Candidate name is required.");
      return;
    }
    setAdding(true);
    setAddError(null);
    try {
      await api.addCandidate(electionId, {
        name: form.name.trim(),
        party: form.party.trim() || undefined,
        bio: form.bio.trim() || undefined,
        manifesto: form.manifesto.trim() || undefined,
        ballotOrder: form.ballotOrder ? Number(form.ballotOrder) : undefined,
      });
      setForm({ name: "", party: "", bio: "", manifesto: "", ballotOrder: "" });
      setShowAddForm(false);
      await loadCandidates(electionId);
    } catch (err) {
      setAddError(err instanceof Error ? err.message : "Failed to add candidate");
    } finally {
      setAdding(false);
    }
  };

  return (
    <AdminShell active="elections">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Elections / {elections.find((e) => e.id === electionId)?.title ?? "Candidate Management"}</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Candidate Management</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Review, verify, and publish candidate profiles before final ballot lock.</p>
          </div>
          <div className="flex gap-3">
            <select
              value={electionId}
              onChange={(e) => setElectionId(e.target.value)}
              className="h-10 rounded-lg bg-[var(--surface-container)] px-3 text-sm"
            >
              {elections.length === 0 ? <option value="">No elections</option> : null}
              {elections.map((e) => (
                <option key={e.id} value={e.id}>{e.title}</option>
              ))}
            </select>
            <button onClick={() => setShowAddForm((v) => !v)} className="brand-gradient rounded-lg px-5 py-2 text-sm font-semibold text-white">
              Add Candidate
            </button>
          </div>
        </div>

        {showAddForm ? (
          <section className="rounded-xl bg-[var(--surface-container)] p-5">
            <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Add Candidate</p>
            <div className="mt-4 grid gap-4 md:grid-cols-2">
              <label className="block">
                <span className="mb-2 block text-xs text-[var(--text-muted)]">Name *</span>
                <input
                  value={form.name}
                  onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))}
                  className="w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-sm"
                  placeholder="Candidate full name"
                />
              </label>
              <label className="block">
                <span className="mb-2 block text-xs text-[var(--text-muted)]">Party</span>
                <input
                  value={form.party}
                  onChange={(e) => setForm((f) => ({ ...f, party: e.target.value }))}
                  className="w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-sm"
                  placeholder="Party or affiliation"
                />
              </label>
              <label className="block">
                <span className="mb-2 block text-xs text-[var(--text-muted)]">Ballot Order</span>
                <input
                  value={form.ballotOrder}
                  onChange={(e) => setForm((f) => ({ ...f, ballotOrder: e.target.value }))}
                  type="number"
                  className="w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-sm"
                  placeholder="Auto if blank"
                />
              </label>
              <label className="block">
                <span className="mb-2 block text-xs text-[var(--text-muted)]">Bio</span>
                <input
                  value={form.bio}
                  onChange={(e) => setForm((f) => ({ ...f, bio: e.target.value }))}
                  className="w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-sm"
                  placeholder="Short bio"
                />
              </label>
              <label className="block md:col-span-2">
                <span className="mb-2 block text-xs text-[var(--text-muted)]">Manifesto</span>
                <textarea
                  value={form.manifesto}
                  onChange={(e) => setForm((f) => ({ ...f, manifesto: e.target.value }))}
                  className="min-h-24 w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-sm"
                  placeholder="Candidate manifesto"
                />
              </label>
            </div>
            {addError ? <p className="mt-3 text-sm text-rose-300">{addError}</p> : null}
            <div className="mt-4 flex gap-3">
              <button onClick={addCandidate} disabled={adding} className="brand-gradient rounded-lg px-5 py-2 text-sm font-semibold text-white disabled:opacity-50">
                {adding ? "Adding..." : "Save Candidate"}
              </button>
              <button onClick={() => setShowAddForm(false)} className="rounded-lg bg-[var(--surface-container-high)] px-5 py-2 text-sm">Cancel</button>
            </div>
          </section>
        ) : null}

        <section className="rounded-xl bg-[var(--surface-container)] p-4">
          <div className="flex flex-wrap items-center gap-3">
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search candidate, party, ballot no..."
              className="h-10 w-80 rounded-lg bg-[var(--surface-container-low)] px-3 text-sm outline-none ring-1 ring-transparent focus:ring-[var(--primary)]"
            />
            <p className="ml-auto text-xs text-[var(--text-muted)]">{filtered.length} candidates</p>
          </div>
        </section>

        {loading ? (
          <p className="text-sm text-[var(--text-muted)]">Loading candidates...</p>
        ) : error ? (
          <div className="space-y-3">
            <p className="text-sm text-rose-300">{error}</p>
            <button onClick={() => (electionId ? loadCandidates(electionId) : loadElections())} className="text-xs font-semibold text-[var(--primary)]">Retry</button>
          </div>
        ) : (
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
                      <p className="text-xs text-[var(--primary)]">{candidate.party ?? "Independent"}</p>
                    </div>
                    <span className="rounded-md bg-[var(--surface-container-high)] px-2 py-1 text-[10px] font-bold uppercase tracking-[0.08em]">
                      #{candidate.ballotOrder}
                    </span>
                  </div>
                  <p className="mt-3 text-xs text-[var(--text-muted)]">{candidate.manifesto ?? candidate.bio ?? "No manifesto provided."}</p>
                  <div className="mt-4 flex items-center justify-between">
                    <span className="rounded-full bg-white/8 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em]">Candidate</span>
                    <div className="flex items-center gap-2">
                      <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold ${candidate.verified ? "bg-emerald-500/15 text-emerald-300" : "bg-amber-500/15 text-amber-300"}`}>
                        {candidate.verified ? "Verified" : "Pending"}
                      </span>
                      <button
                        type="button"
                        onClick={(event) => {
                          event.stopPropagation();
                          toggleVisibility(candidate.id);
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
              {filtered.length === 0 ? (
                <p className="text-sm text-[var(--text-muted)]">No candidates. Add one to get started.</p>
              ) : null}
            </section>

            <aside className="rounded-xl bg-[var(--surface-container)] p-5">
              {selected ? (
                <>
                  <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Candidate Detail</p>
                  <h2 className="mt-3 text-2xl font-bold tracking-tight">{selected.name}</h2>
                  <p className="text-sm text-[var(--primary)]">{selected.party ?? "Independent"}</p>

                  <div className="mt-5 space-y-3 text-sm">
                    <DetailRow label="Ballot No." value={`#${selected.ballotOrder}`} mono />
                    <DetailRow label="Verification" value={selected.verified ? "Approved" : "Awaiting review"} />
                    <DetailRow label="Visibility" value={selected.visible ? "Public" : "Hidden"} />
                  </div>

                  <div className="mt-6">
                    <p className="mb-2 text-[10px] font-bold uppercase tracking-[0.1em] text-[var(--text-muted)]">Manifesto</p>
                    <textarea
                      value={selected.manifesto ?? ""}
                      onChange={(e) => updateSelected({ manifesto: e.target.value })}
                      className="min-h-28 w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-sm"
                    />
                  </div>

                  <div className="mt-6 grid grid-cols-2 gap-3">
                    <button
                      onClick={approveCandidate}
                      disabled={selected.verified}
                      className="rounded-lg bg-[var(--surface-container-high)] px-4 py-2 text-sm disabled:opacity-40"
                    >
                      {selected.verified ? "Verified" : "Approve"}
                    </button>
                    <button
                      type="button"
                      onClick={() => toggleVisibility(selected.id)}
                      className="brand-gradient rounded-lg px-4 py-2 text-sm font-semibold text-white"
                    >
                      {selected.visible ? "Hide" : "Show"}
                    </button>
                  </div>
                </>
              ) : (
                <p className="text-sm text-[var(--text-muted)]">No candidate matches the current filter.</p>
              )}
            </aside>
          </div>
        )}
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