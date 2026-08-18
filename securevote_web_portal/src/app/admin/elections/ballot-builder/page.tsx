"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import * as api from "@/lib/api-client";

type BlockType = "position" | "yesNo" | "info";

// UI block: backend-persisted fields (id/title/type/orderIndex) plus a
// client-only description shown in the inspector (the ballot_blocks table has
// no description column, so description stays local to the builder session).
type BallotBlock = {
  id: string;
  title: string;
  description: string;
  type: BlockType;
  orderIndex: number;
  selection: "Single" | "Multi" | "N/A";
};

function selectionFor(type: BlockType, electionType: api.ElectionType): "Single" | "Multi" | "N/A" {
  if (type === "info") return "N/A";
  return electionType === "single" ? "Single" : "Multi";
}

export default function BallotBuilderPage() {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [elections, setElections] = useState<api.Election[]>([]);
  const [electionId, setElectionId] = useState<string>("");
  const [election, setElection] = useState<api.Election | null>(null);
  const [candidates, setCandidates] = useState<api.Candidate[]>([]);

  const [blocks, setBlocks] = useState<BallotBlock[]>([]);
  const [selectedId, setSelectedId] = useState("");
  const [showCandidatePhotos, setShowCandidatePhotos] = useState(true);
  const [randomizeOrder, setRandomizeOrder] = useState(false);
  const [action, setAction] = useState<{ busy: boolean; error: string | null; success: string | null }>({
    busy: false,
    error: null,
    success: null,
  });
  const [publishing, setPublishing] = useState(false);

  // --- Data loading ---

  const loadBlocks = useCallback(async (id: string, elect: api.Election) => {
    try {
      const remote = await api.listBallotBlocks(id);
      setBlocks(
        remote.map((b) => ({
          id: b.id,
          title: b.title,
          description: "",
          type: b.kind as BlockType,
          orderIndex: b.orderIndex,
          selection: selectionFor(b.kind as BlockType, elect.type),
        })),
      );
      setSelectedId(remote[0]?.id ?? "");
    } catch {
      setBlocks([]);
      setSelectedId("");
    }
  }, []);

  useEffect(() => {
    let active = true;
    (async () => {
      setLoading(true);
      setError(null);
      try {
        const list = await api.listElections();
        if (!active) return;
        setElections(list);
        const first = [...list].sort((a, b) => b.startsAt - a.startsAt)[0] ?? null;
        setElectionId(first?.id ?? "");
      } catch (err) {
        if (active) setError(err instanceof Error ? err.message : "Failed to load elections");
      } finally {
        if (active) setLoading(false);
      }
    })();
    return () => {
      active = false;
    };
  }, []);

  useEffect(() => {
    if (!electionId) {
      setElection(null);
      setCandidates([]);
      setBlocks([]);
      return;
    }
    let active = true;
    setLoading(true);
    setError(null);
    (async () => {
      try {
        const data = await api.getElection(electionId);
        if (!active) return;
        setElection(data.election);
        setCandidates(data.candidates);
        await loadBlocks(electionId, data.election);
      } catch (err) {
        if (active) setError(err instanceof Error ? err.message : "Failed to load election");
      } finally {
        if (active) setLoading(false);
      }
    })();
    return () => {
      active = false;
    };
  }, [electionId, loadBlocks]);

  const selected = useMemo(() => blocks.find((b) => b.id === selectedId) ?? null, [blocks, selectedId]);

  // --- Mutations: persist to the backend, then reload so order/ids stay in sync ---

  const runMutation = async (fn: () => Promise<unknown>, successMsg: string, errMsg: string) => {
    setAction({ busy: true, error: null, success: null });
    try {
      await fn();
      if (election) await loadBlocks(electionId, election);
      setAction({ busy: false, error: null, success: successMsg });
    } catch (err) {
      setAction({ busy: false, error: err instanceof Error ? err.message : errMsg, success: null });
    }
  };

  const moveBlock = (id: string, direction: -1 | 1) => {
    // Reorder locally first for snappy UI, then persist the new orderIndex.
    const reordered: BallotBlock[] = [];
    setBlocks((current) => {
      const index = current.findIndex((item) => item.id === id);
      if (index === -1) return current;
      const nextIndex = index + direction;
      if (nextIndex < 0 || nextIndex >= current.length) return current;
      const clone = [...current];
      const [moved] = clone.splice(index, 1);
      clone.splice(nextIndex, 0, moved);
      reordered.push(...clone.map((b, i) => ({ ...b, orderIndex: i })));
      return reordered;
    });
    if (reordered.length && election) {
      void Promise.all(
        reordered.map((b) => api.updateBallotBlock(electionId, b.id, { orderIndex: b.orderIndex })),
      ).catch(() => {
        /* best-effort; reload on next interaction */
      });
    }
  };

  const addBlock = (type: BlockType) => {
    if (!election) return;
    const title = type === "position" ? "New Position" : type === "yesNo" ? "Policy Approval" : "Information Block";
    void runMutation(
      () =>
        api.createBallotBlock(electionId, {
          title,
          kind: type,
          orderIndex: blocks.length,
        }),
      "Block added.",
      "Failed to add block",
    );
  };

  const saveSelected = () => {
    if (!selected) return;
    void runMutation(
      () =>
        api.updateBallotBlock(electionId, selected.id, {
          title: selected.title,
          kind: selected.type,
        }),
      "Block updated.",
      "Failed to update block",
    );
  };

  const removeBlock = () => {
    if (!selected) return;
    void runMutation(
      () => api.deleteBallotBlock(electionId, selected.id),
      "Block removed.",
      "Failed to remove block",
    );
  };

  const publishBallot = async () => {
    if (!election) return;
    if (election.status !== "draft" && election.status !== "scheduled") {
      setAction({ busy: false, error: "Ballot can only be published while the election is draft/scheduled.", success: null });
      return;
    }
    setPublishing(true);
    try {
      // "Publish" the ballot by scheduling the election (status -> scheduled).
      await api.setElectionStatus(electionId, "scheduled");
      setAction({ busy: false, error: null, success: "Ballot published. Election is now scheduled." });
    } catch (err) {
      setAction({ busy: false, error: err instanceof Error ? err.message : "Failed to publish ballot", success: null });
    } finally {
      setPublishing(false);
    }
  };

  return (
    <AdminShell active="elections">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Elections / {election?.title ?? "Ballot Builder"}</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Ballot Builder</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Compose voting positions and ballot sections with deterministic ordering.</p>
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
            <button className="rounded-lg bg-[var(--surface-container)] px-4 py-2 text-sm">Preview Ballot</button>
            <button
              onClick={publishBallot}
              disabled={publishing || !election}
              className="brand-gradient rounded-lg px-5 py-2 text-sm font-semibold text-white disabled:opacity-50"
            >
              {publishing ? "Publishing..." : "Publish Ballot"}
            </button>
          </div>
        </div>

        {action.error ? <p className="text-sm text-rose-300">{action.error}</p> : null}
        {action.success ? <p className="text-sm text-emerald-300">{action.success}</p> : null}

        <div className="grid gap-6 xl:grid-cols-[300px,1fr,320px]">
          <aside className="rounded-xl bg-[var(--surface-container)] p-5">
            <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Add Blocks</p>
            <div className="mt-4 space-y-2">
              <button onClick={() => addBlock("position")} className="w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-left text-sm hover:bg-[var(--surface-container-high)]">+ Position / Role</button>
              <button onClick={() => addBlock("yesNo")} className="w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-left text-sm hover:bg-[var(--surface-container-high)]">+ Yes / No Question</button>
              <button onClick={() => addBlock("info")} className="w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-left text-sm hover:bg-[var(--surface-container-high)]">+ Information Section</button>
            </div>

            <div className="mt-6 space-y-3">
              <Toggle label="Randomize candidate order" on={randomizeOrder} setOn={setRandomizeOrder} />
              <Toggle label="Show candidate photos" on={showCandidatePhotos} setOn={setShowCandidatePhotos} />
            </div>
          </aside>

          <section className="space-y-3 rounded-xl bg-[var(--surface-container)] p-5">
            <div className="flex items-center justify-between">
              <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Canvas ({blocks.length})</p>
              <p className="text-xs text-[var(--text-muted)]">Drag simulation via up/down actions</p>
            </div>

            {loading ? (
              <p className="py-10 text-center text-sm text-[var(--text-muted)]">Loading ballot...</p>
            ) : error ? (
              <div className="py-10 text-center">
                <p className="text-sm text-rose-300">{error}</p>
                <p className="mt-2 text-xs text-[var(--text-muted)]">Try selecting a different election.</p>
              </div>
            ) : blocks.length === 0 ? (
              <p className="py-10 text-center text-sm text-[var(--text-muted)]">No candidates yet — add a block or add candidates to this election.</p>
            ) : (
              blocks.map((block, index) => (
                <article
                  key={block.id}
                  onClick={() => setSelectedId(block.id)}
                  className={`rounded-lg border p-4 ${selectedId === block.id ? "border-[var(--primary)]/45 bg-[var(--primary)]/8" : "border-white/8 bg-[var(--surface-container-low)]"}`}
                >
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <p className="text-lg font-semibold">{index + 1}. {block.title}</p>
                      <p className="text-sm text-[var(--text-muted)]">{block.description}</p>
                    </div>
                    <div className="flex gap-1">
                      <button onClick={(e) => { e.stopPropagation(); moveBlock(block.id, -1); }} className="rounded bg-[var(--surface-container-high)] px-2 py-1 text-xs">↑</button>
                      <button onClick={(e) => { e.stopPropagation(); moveBlock(block.id, 1); }} className="rounded bg-[var(--surface-container-high)] px-2 py-1 text-xs">↓</button>
                    </div>
                  </div>
                  <div className="mt-3 flex flex-wrap items-center gap-2">
                    <span className="rounded-full bg-white/8 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em]">{block.type}</span>
                    <span className="rounded-full bg-[var(--primary)]/12 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] text-[var(--primary)]">{block.selection}</span>
                  </div>
                  <div className="mt-3 flex flex-wrap gap-2">
                    {candidates.map((candidate) => (
                      <span key={candidate.id} className="rounded-full bg-[var(--surface-container-high)] px-2 py-0.5 text-[10px]">
                        #{candidate.ballotOrder} {candidate.name}
                      </span>
                    ))}
                  </div>
                </article>
              ))
            )}
          </section>

          <aside className="rounded-xl bg-[var(--surface-container)] p-5">
            <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Inspector</p>
            {selected ? (
              <div className="mt-4 space-y-4">
                <div>
                  <label className="text-xs text-[var(--text-muted)]">Title</label>
                  <input
                    value={selected.title}
                    onChange={(e) => {
                      const nextTitle = e.target.value;
                      setBlocks((prev) => prev.map((item) => (item.id === selected.id ? { ...item, title: nextTitle } : item)));
                    }}
                    className="mt-1 w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-sm"
                  />
                </div>
                <div>
                  <label className="text-xs text-[var(--text-muted)]">Type</label>
                  <select
                    value={selected.type}
                    onChange={(e) => {
                      const nextType = e.target.value as BlockType;
                      setBlocks((prev) =>
                        prev.map((item) =>
                          item.id === selected.id
                            ? { ...item, type: nextType, selection: selectionFor(nextType, election?.type ?? "single") }
                            : item,
                        ),
                      );
                    }}
                    className="mt-1 w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-sm"
                  >
                    <option value="position">Position / Role</option>
                    <option value="yesNo">Yes / No</option>
                    <option value="info">Information</option>
                  </select>
                </div>
                <div>
                  <label className="text-xs text-[var(--text-muted)]">Description (preview only)</label>
                  <textarea
                    value={selected.description}
                    onChange={(e) => {
                      const nextDescription = e.target.value;
                      setBlocks((prev) => prev.map((item) => (item.id === selected.id ? { ...item, description: nextDescription } : item)));
                    }}
                    className="mt-1 min-h-24 w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-sm"
                  />
                </div>
                <div className="flex gap-3">
                  <button
                    onClick={saveSelected}
                    disabled={action.busy}
                    className="brand-gradient flex-1 rounded-lg px-4 py-2 text-sm font-semibold text-white disabled:opacity-50"
                  >
                    {action.busy ? "Saving..." : "Save"}
                  </button>
                  <button
                    onClick={removeBlock}
                    disabled={action.busy}
                    className="rounded-lg bg-rose-500/15 px-4 py-2 text-sm font-semibold text-rose-300 disabled:opacity-50"
                  >
                    Remove
                  </button>
                </div>
              </div>
            ) : (
              <p className="mt-4 text-sm text-[var(--text-muted)]">Select a canvas block to edit settings.</p>
            )}
          </aside>
        </div>
      </section>
    </AdminShell>
  );
}

function Toggle({ label, on, setOn }: { label: string; on: boolean; setOn: (value: boolean) => void }) {
  return (
    <button
      type="button"
      onClick={() => setOn(!on)}
      className="flex w-full items-center justify-between rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-left"
    >
      <span className="text-sm">{label}</span>
      <span className={`relative h-5 w-10 rounded-full ${on ? "bg-[var(--primary)]/30" : "bg-white/12"}`}>
        <span className={`absolute top-1 h-3 w-3 rounded-full ${on ? "right-1 bg-[var(--primary)]" : "left-1 bg-white/50"}`} />
      </span>
    </button>
  );
}