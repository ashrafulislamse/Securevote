"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import { getKycDocument, getKycQueue, reviewKyc } from "@/lib/api-client";
import type { KycQueueItem } from "@/lib/api-client";

function formatDate(ts?: number) {
  if (!ts) return "—";
  return new Date(ts).toLocaleString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

export default function KycVerificationPage() {
  const [queue, setQueue] = useState<KycQueueItem[]>([]);
  const [selectedId, setSelectedId] = useState("");
  const [notes, setNotes] = useState("");
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [actionError, setActionError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [previewLoading, setPreviewLoading] = useState(false);
  const [previewError, setPreviewError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await getKycQueue();
      setQueue(data);
      setSelectedId((prev) =>
        prev && data.some((item) => item.id === prev) ? prev : data[0]?.id ?? "",
      );
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load KYC queue");
      setQueue([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  const selected = useMemo(
    () => queue.find((item) => item.id === selectedId) ?? null,
    [queue, selectedId],
  );

  const handleDecision = async (decision: "approve" | "reject") => {
    if (!selected) return;
    setSubmitting(true);
    setActionError(null);
    setSuccess(null);
    try {
      await reviewKyc(selected.id, decision, notes.trim() || undefined);
      setSuccess(`${selected.full_name} was ${decision === "approve" ? "approved" : "rejected"}.`);
      setNotes("");
      await load();
    } catch (err) {
      setActionError(
        err instanceof Error ? err.message : `Failed to ${decision} KYC record`,
      );
    } finally {
      setSubmitting(false);
    }
  };

  const openPreview = useCallback(async (item: KycQueueItem) => {
    setPreviewLoading(true);
    setPreviewError(null);
    try {
      const blob = await getKycDocument(item.id);
      if (previewUrl) URL.revokeObjectURL(previewUrl);
      setPreviewUrl(URL.createObjectURL(blob));
    } catch (err) {
      setPreviewError(
        err instanceof Error ? err.message : "Failed to load document",
      );
    } finally {
      setPreviewLoading(false);
    }
  }, [previewUrl]);

  const closePreview = useCallback(() => {
    if (previewUrl) URL.revokeObjectURL(previewUrl);
    setPreviewUrl(null);
    setPreviewError(null);
  }, [previewUrl]);

  useEffect(() => {
    return () => {
      if (previewUrl) URL.revokeObjectURL(previewUrl);
    };
  }, [previewUrl]);

  return (
    <AdminShell active="voters">
      <section className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">KYC Verification Queue</h1>
          <p className="mt-1 text-sm text-[var(--text-muted)]">Review identity documents, biometrics, and risk factors before granting voting eligibility.</p>
        </div>

        {success ? (
          <div className="rounded-lg bg-emerald-500/15 px-4 py-3 text-sm font-semibold text-emerald-300">
            {success}
          </div>
        ) : null}
        {actionError ? (
          <div className="rounded-lg bg-rose-500/15 px-4 py-3 text-sm font-semibold text-rose-300">
            {actionError}
          </div>
        ) : null}

        <div className="grid gap-6 xl:grid-cols-[300px,1fr,320px]">
          <aside className="rounded-xl bg-[var(--surface-container)] p-4">
            <div className="mb-3 flex items-center justify-between">
              <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Review Queue</p>
              <span className="rounded-full bg-white/10 px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em]">{queue.length} pending</span>
            </div>

            {loading ? (
              <p className="py-6 text-center text-sm text-[var(--text-muted)]">Loading queue...</p>
            ) : error ? (
              <p className="py-6 text-center text-sm text-rose-300">{error}</p>
            ) : queue.length === 0 ? (
              <p className="py-6 text-center text-sm text-[var(--text-muted)]">Queue is empty.</p>
            ) : (
              <div className="space-y-2">
                {queue.map((item) => (
                  <button
                    key={item.id}
                    onClick={() => setSelectedId(item.id)}
                    className={`w-full rounded-lg border px-3 py-3 text-left ${selectedId === item.id ? "border-[var(--primary)]/45 bg-[var(--primary)]/8" : "border-white/8 bg-[var(--surface-container-low)]"}`}
                  >
                    <div className="flex items-start justify-between gap-2">
                      <p className="font-semibold">{item.full_name}</p>
                      <StatusPill status={item.status} />
                    </div>
                    <p className="mt-1 text-xs text-[var(--text-muted)]">{item.email}</p>
                    <p className="mt-1 font-mono text-xs text-[var(--text-muted)]">{item.doc_type}</p>
                    <p className="mt-1 text-xs text-[var(--text-muted)]">{formatDate(item.created_at)}</p>
                  </button>
                ))}
              </div>
            )}
          </aside>

          <section className="space-y-5 rounded-xl bg-[var(--surface-container)] p-6">
            {selected ? (
              <>
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <h2 className="text-2xl font-bold tracking-tight">{selected.full_name}</h2>
                    <p className="text-xs text-[var(--text-muted)]">{selected.email}</p>
                  </div>
                  <StatusPill status={selected.status} />
                </div>

                <div className="grid gap-4 md:grid-cols-2">
                  <DocCard title="Document Type" subtitle={selected.doc_type} status={selected.status} />
                  <DocCard title="Submitted" subtitle={formatDate(selected.created_at)} status="On file" />
                  <DocCard title="Reviewer" subtitle="Awaiting decision" status="Pending" />
                  <DocCard title="Watchlist" subtitle="Automated screening" status="Clear" />
                </div>

                <div className="rounded-lg border border-white/8 bg-[var(--surface-container-low)] p-4">
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <div>
                      <p className="text-sm font-semibold">Submitted document</p>
                      <p className="mt-1 font-mono text-[11px] text-[var(--text-muted)]">{selected.r2_key}</p>
                    </div>
                    <div className="flex items-center gap-2">
                      <button
                        type="button"
                        onClick={() => openPreview(selected)}
                        disabled={previewLoading}
                        className="rounded-md bg-[var(--primary)]/15 px-3 py-2 text-xs font-semibold text-[var(--primary)] disabled:opacity-40"
                      >
                        {previewLoading ? "Loading..." : "View Document"}
                      </button>
                      <a
                        href={`/api/kyc/document/${selected.id}`}
                        target="_blank"
                        rel="noreferrer"
                        className="rounded-md bg-white/8 px-3 py-2 text-xs font-semibold"
                      >
                        Open in new tab
                      </a>
                    </div>
                  </div>
                  {previewError ? (
                    <p className="mt-3 text-xs text-rose-300">{previewError}</p>
                  ) : null}
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
              <Checklist label="Name matches legal ID" checked={!!selected} />
              <Checklist label="Document expiry valid" checked={!!selected} />
              <Checklist label="Liveness test verified" checked={!!selected} />
              <Checklist label="Watchlist screening clear" checked={!!selected} />
            </div>

            <div className="rounded-lg border border-[var(--primary)]/20 bg-[var(--primary)]/7 p-4 text-xs text-[var(--text-muted)]">
              Actions here map to the blueprint KYC review flow: approve/reject with audit trail and reviewer note.
            </div>

            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => handleDecision("reject")}
                disabled={!selected || submitting}
                className="rounded-lg bg-rose-500/15 px-4 py-2 text-sm font-semibold text-rose-300 disabled:opacity-40"
              >
                Reject
              </button>
              <button
                onClick={() => handleDecision("approve")}
                disabled={!selected || submitting}
                className="brand-gradient rounded-lg px-4 py-2 text-sm font-semibold text-white disabled:opacity-40"
              >
                {submitting ? "Submitting..." : "Approve"}
              </button>
            </div>
          </aside>
        </div>
      </section>

      {previewUrl ? (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 p-6"
          onClick={closePreview}
        >
          <div
            className="relative max-h-[90vh] max-w-[90vw] overflow-auto rounded-xl bg-[var(--surface-container)] p-4"
            onClick={(event) => event.stopPropagation()}
          >
            <div className="mb-3 flex items-center justify-between gap-3">
              <p className="text-sm font-semibold">{selected?.full_name} · {selected?.doc_type}</p>
              <button
                type="button"
                onClick={closePreview}
                className="rounded-md bg-white/10 px-3 py-1 text-xs font-semibold"
              >
                Close
              </button>
            </div>
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={previewUrl}
              alt={`KYC document for ${selected?.full_name ?? ""}`}
              className="max-h-[80vh] max-w-full rounded-md object-contain"
            />
          </div>
        </div>
      ) : null}
    </AdminShell>
  );
}

function StatusPill({ status }: { status: string }) {
  const tone =
    status === "approved"
      ? "bg-emerald-500/15 text-emerald-300"
      : status === "rejected"
        ? "bg-rose-500/15 text-rose-300"
        : "bg-amber-500/15 text-amber-300";

  return <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${tone}`}>{status}</span>;
}

function Checklist({ label, checked }: { label: string; checked?: boolean }) {
  return (
    <div className="flex items-center justify-between rounded-lg bg-[var(--surface-container-low)] px-3 py-2">
      <span className="text-sm">{label}</span>
      <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${checked ? "bg-emerald-500/15 text-emerald-300" : "bg-amber-500/15 text-amber-300"}`}>
        {checked ? "Done" : "Pending"}
      </span>
    </div>
  );
}

function DocCard({ title, subtitle, status }: { title: string; subtitle: string; status: string }) {
  const statusTone = status === "approved" || status === "Clear" || status === "On file" ? "text-emerald-300 bg-emerald-500/15" : "text-amber-300 bg-amber-500/15";

  return (
    <article className="rounded-lg bg-[var(--surface-container-low)] p-4">
      <p className="text-sm font-semibold">{title}</p>
      <p className="mt-1 text-xs text-[var(--text-muted)]">{subtitle}</p>
      <span className={`mt-3 inline-block rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${statusTone}`}>{status}</span>
    </article>
  );
}
