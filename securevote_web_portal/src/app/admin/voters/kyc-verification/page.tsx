"use client";

import { useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";

type QueueItem = {
  id: string;
  name: string;
  voterId: string;
  risk: "Low" | "Medium" | "High";
  submitted: string;
};

const queueSeed: QueueItem[] = [
  { id: "kyc-8829", name: "Siti Aminah", voterId: "SV-3942-MY8", risk: "High", submitted: "2 mins ago" },
  { id: "kyc-9104", name: "Marcus Thorne", voterId: "SV-5510-XZ1", risk: "Medium", submitted: "15 mins ago" },
  { id: "kyc-7721", name: "Elena Rodriguez", voterId: "SV-2004-KL9", risk: "Low", submitted: "1 hour ago" },
  { id: "kyc-6652", name: "Julian Vancore", voterId: "SV-1101-QQ2", risk: "Medium", submitted: "Yesterday" },
];

export default function KycVerificationPage() {
  const [queue, setQueue] = useState<QueueItem[]>(queueSeed);
  const [selectedId, setSelectedId] = useState(queueSeed[0].id);
  const [notes, setNotes] = useState("");

  const selected = useMemo(() => queue.find((item) => item.id === selectedId) ?? null, [queue, selectedId]);

  const handleDecision = (decision: "approve" | "reject") => {
    if (!selected) return;
    setQueue((prev) => prev.filter((item) => item.id !== selected.id));
    setSelectedId((prev) => (prev === selected.id ? "" : prev));
    setNotes("");
    console.log(`KYC ${decision} for`, selected.voterId);
  };

  return (
    <AdminShell active="voters">
      <section className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">KYC Verification Queue</h1>
          <p className="mt-1 text-sm text-[var(--text-muted)]">Review identity documents, biometrics, and risk factors before granting voting eligibility.</p>
        </div>

        <div className="grid gap-6 xl:grid-cols-[300px,1fr,320px]">
          <aside className="rounded-xl bg-[var(--surface-container)] p-4">
            <div className="mb-3 flex items-center justify-between">
              <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Review Queue</p>
              <span className="rounded-full bg-white/10 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em]">{queue.length} pending</span>
            </div>
            <div className="space-y-2">
              {queue.map((item) => (
                <button
                  key={item.id}
                  onClick={() => setSelectedId(item.id)}
                  className={`w-full rounded-lg border px-3 py-3 text-left ${selectedId === item.id ? "border-[var(--primary)]/45 bg-[var(--primary)]/8" : "border-white/8 bg-[var(--surface-container-low)]"}`}
                >
                  <div className="flex items-start justify-between">
                    <p className="font-semibold">{item.name}</p>
                    <RiskPill risk={item.risk} />
                  </div>
                  <p className="mt-1 font-mono text-xs text-[var(--text-muted)]">{item.voterId}</p>
                  <p className="mt-1 text-xs text-[var(--text-muted)]">{item.submitted}</p>
                </button>
              ))}
            </div>
          </aside>

          <section className="space-y-5 rounded-xl bg-[var(--surface-container)] p-6">
            {selected ? (
              <>
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <h2 className="text-2xl font-bold tracking-tight">{selected.name}</h2>
                    <p className="font-mono text-xs text-[var(--text-muted)]">{selected.voterId}</p>
                  </div>
                  <RiskPill risk={selected.risk} />
                </div>

                <div className="grid gap-4 md:grid-cols-2">
                  <DocCard title="National ID" subtitle="OCR match 98.7%" status="Valid" />
                  <DocCard title="Live Selfie" subtitle="Face match 94.2%" status="Valid" />
                  <DocCard title="Address Proof" subtitle="Utility bill, 2026" status="Under review" />
                  <DocCard title="Watchlist" subtitle="Automated screening" status="Clear" />
                </div>

                <div>
                  <label className="text-[11px] font-bold uppercase tracking-[0.12em] text-[var(--text-muted)]">Internal audit notes</label>
                  <textarea
                    value={notes}
                    onChange={(event) => setNotes(event.target.value)}
                    placeholder="Add review rationale, discrepancies, or escalation context..."
                    className="mt-2 min-h-28 w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-sm"
                  />
                </div>
              </>
            ) : (
              <p className="text-sm text-[var(--text-muted)]">Queue is empty or no record selected.</p>
            )}
          </section>

          <aside className="space-y-5 rounded-xl bg-[var(--surface-container)] p-5">
            <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Decision Panel</p>
            <div className="space-y-3">
              <Checklist label="Name matches legal ID" checked />
              <Checklist label="Document expiry valid" checked />
              <Checklist label="Liveness test verified" checked={selected?.risk !== "High"} />
              <Checklist label="Watchlist screening clear" checked={selected?.risk === "Low" || selected?.risk === "Medium"} />
            </div>

            <div className="rounded-lg border border-[var(--primary)]/20 bg-[var(--primary)]/7 p-4 text-xs text-[var(--text-muted)]">
              Actions here map to the blueprint KYC review flow: approve/reject with audit trail and reviewer note.
            </div>

            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => handleDecision("reject")}
                disabled={!selected}
                className="rounded-lg bg-rose-500/15 px-4 py-2 text-sm font-semibold text-rose-300 disabled:opacity-40"
              >
                Reject
              </button>
              <button
                onClick={() => handleDecision("approve")}
                disabled={!selected}
                className="brand-gradient rounded-lg px-4 py-2 text-sm font-semibold text-white disabled:opacity-40"
              >
                Approve
              </button>
            </div>
          </aside>
        </div>
      </section>
    </AdminShell>
  );
}

function RiskPill({ risk }: { risk: QueueItem["risk"] }) {
  const tone = risk === "High" ? "bg-rose-500/15 text-rose-300" : risk === "Medium" ? "bg-amber-500/15 text-amber-300" : "bg-emerald-500/15 text-emerald-300";
  return <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${tone}`}>{risk}</span>;
}

function Checklist({ label, checked }: { label: string; checked?: boolean }) {
  return (
    <div className="flex items-center justify-between rounded-lg bg-[var(--surface-container-low)] px-3 py-2">
      <span className="text-sm">{label}</span>
      <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${checked ? "bg-emerald-500/15 text-emerald-300" : "bg-white/10 text-white/55"}`}>
        {checked ? "Done" : "Pending"}
      </span>
    </div>
  );
}

function DocCard({ title, subtitle, status }: { title: string; subtitle: string; status: string }) {
  const statusTone = status === "Valid" || status === "Clear" ? "text-emerald-300 bg-emerald-500/15" : "text-amber-300 bg-amber-500/15";

  return (
    <article className="rounded-lg bg-[var(--surface-container-low)] p-4">
      <p className="text-sm font-semibold">{title}</p>
      <p className="mt-1 text-xs text-[var(--text-muted)]">{subtitle}</p>
      <span className={`mt-3 inline-block rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${statusTone}`}>{status}</span>
    </article>
  );
}
