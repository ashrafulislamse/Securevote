"use client";

import { useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";

type BlockType = "position" | "yesNo" | "info";

type BallotBlock = {
  id: string;
  title: string;
  description: string;
  type: BlockType;
  selection: "Single" | "Multi" | "N/A";
};

const starterBlocks: BallotBlock[] = [
  {
    id: "position-president",
    title: "President",
    description: "Vote for one candidate for the position of President.",
    type: "position",
    selection: "Single",
  },
  {
    id: "position-secretary",
    title: "Secretary",
    description: "Vote for one candidate for Secretary.",
    type: "position",
    selection: "Single",
  },
  {
    id: "info-conduct",
    title: "Election Conduct Notice",
    description: "Campaigning near voting booths is prohibited during active voting period.",
    type: "info",
    selection: "N/A",
  },
];

export default function BallotBuilderPage() {
  const [blocks, setBlocks] = useState<BallotBlock[]>(starterBlocks);
  const [selectedId, setSelectedId] = useState(starterBlocks[0].id);
  const [showCandidatePhotos, setShowCandidatePhotos] = useState(true);
  const [randomizeOrder, setRandomizeOrder] = useState(false);

  const selected = useMemo(() => blocks.find((b) => b.id === selectedId) ?? null, [blocks, selectedId]);

  const moveBlock = (id: string, direction: -1 | 1) => {
    setBlocks((current) => {
      const index = current.findIndex((item) => item.id === id);
      if (index === -1) return current;
      const nextIndex = index + direction;
      if (nextIndex < 0 || nextIndex >= current.length) return current;
      const clone = [...current];
      const [moved] = clone.splice(index, 1);
      clone.splice(nextIndex, 0, moved);
      return clone;
    });
  };

  const addBlock = (type: BlockType) => {
    const seed = Math.random().toString(36).slice(2, 6).toUpperCase();
    const block: BallotBlock =
      type === "position"
        ? {
            id: `position-${seed}`,
            title: "New Position",
            description: "Add candidates and set selection limits.",
            type,
            selection: "Single",
          }
        : type === "yesNo"
          ? {
              id: `yesno-${seed}`,
              title: "Policy Approval",
              description: "Should this policy be adopted for next term?",
              type,
              selection: "Single",
            }
          : {
              id: `info-${seed}`,
              title: "Information Block",
              description: "Non-voting informational section.",
              type,
              selection: "N/A",
            };

    setBlocks((prev) => [...prev, block]);
    setSelectedId(block.id);
  };

  return (
    <AdminShell active="elections">
      <section className="space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Elections / Student Council 2025</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Ballot Builder</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Compose voting positions and ballot sections with deterministic ordering.</p>
          </div>
          <div className="flex gap-3">
            <button className="rounded-lg bg-[var(--surface-container)] px-4 py-2 text-sm">Preview Ballot</button>
            <button className="brand-gradient rounded-lg px-5 py-2 text-sm font-semibold text-white">Publish Ballot</button>
          </div>
        </div>

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
            {blocks.map((block, index) => (
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
              </article>
            ))}
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
                  <label className="text-xs text-[var(--text-muted)]">Description</label>
                  <textarea
                    value={selected.description}
                    onChange={(e) => {
                      const nextDescription = e.target.value;
                      setBlocks((prev) => prev.map((item) => (item.id === selected.id ? { ...item, description: nextDescription } : item)));
                    }}
                    className="mt-1 min-h-24 w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-sm"
                  />
                </div>
                <button
                  onClick={() => {
                    setBlocks((prev) => prev.filter((item) => item.id !== selected.id));
                    setSelectedId((prev) => (prev === selected.id ? "" : prev));
                  }}
                  className="w-full rounded-lg bg-rose-500/15 px-4 py-2 text-sm font-semibold text-rose-300"
                >
                  Remove Block
                </button>
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
