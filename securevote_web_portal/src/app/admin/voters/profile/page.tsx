"use client";

import { useSearchParams } from "next/navigation";
import { Suspense, useCallback, useEffect, useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import {
  getKycDocument,
  getVoter,
  listKycDocumentsForUser,
  updateVoter,
} from "@/lib/api-client";
import type { KycDocument, MyVote, Voter } from "@/lib/api-client";

type TimelineEvent = {
  id: string;
  title: string;
  time: string;
  receipt: string;
  tone: "good" | "warn" | "neutral";
};

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

function kycTone(status: string) {
  if (status === "approved") return "bg-emerald-500/15 text-emerald-300";
  if (status === "rejected") return "bg-rose-500/15 text-rose-300";
  if (status === "pending") return "bg-amber-500/15 text-amber-300";
  return "bg-[var(--surface-container-high)] text-[var(--text-secondary)]";
}

function VoterProfileContent() {
  const searchParams = useSearchParams();
  const id = searchParams.get("id") ?? "";

  const [tab, setTab] = useState<"overview" | "history" | "security" | "kyc">(
    "overview",
  );

  const [voter, setVoter] = useState<(Voter & { vote_count?: number; status?: string; notes?: string | null }) | null>(null);
  const [votes, setVotes] = useState<(MyVote & { election_title?: string })[]>([]);
  const [documents, setDocuments] = useState<KycDocument[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [previewError, setPreviewError] = useState<string | null>(null);
  const [previewLoadingId, setPreviewLoadingId] = useState<string | null>(null);

  const [action, setAction] = useState<{ busy: boolean; error: string | null; success: string | null }>({
    busy: false,
    error: null,
    success: null,
  });

  const [editing, setEditing] = useState(false);
  const [editForm, setEditForm] = useState({ fullName: "", phone: "", notes: "" });

  const load = useCallback(async () => {
    if (!id) {
      setError("No voter selected. Open a voter from the registry.");
      setLoading(false);
      return;
    }
    setLoading(true);
    setError(null);
    try {
      const data = await getVoter(id);
      setVoter(data.voter);
      setVotes(data.votes ?? []);
      try {
        const docs = await listKycDocumentsForUser(id);
        setDocuments(docs);
      } catch {
        setDocuments([]);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to load voter");
      setVoter(null);
      setVotes([]);
      setDocuments([]);
    } finally {
      setLoading(false);
    }
  }, [id]);

  useEffect(() => {
    load();
  }, [load]);

  const isSuspended = voter?.status === "suspended";

  // Risk score computed from real signals: suspension, KYC rejection,
  // and account age relative to vote count.
  const riskScore = useMemo(() => {
    if (!voter) return 0;
    let score = 0;
    if (isSuspended) score += 40;
    if (voter.kycStatus === "rejected") score += 25;
    const accountAgeDays = (Date.now() - voter.createdAt) / (1000 * 60 * 60 * 24);
    if (accountAgeDays < 1 && votes.length > 0) score += 20;
    return Math.min(score, 100);
  }, [voter, isSuspended, votes.length]);

  const riskLabel = riskScore > 50 ? "High" : riskScore > 25 ? "Elevated" : "Low";

  const timeline = useMemo<TimelineEvent[]>(
    () =>
      votes.map((vote) => ({
        id: vote.id,
        title: vote.election_title ?? vote.electionTitle ?? "Election vote",
        time: formatDate(vote.createdAt),
        receipt: vote.receiptId,
        tone: "good" as const,
      })),
    [votes],
  );

  const openDocumentPreview = useCallback(async (doc: KycDocument) => {
    setPreviewLoadingId(doc.id);
    setPreviewError(null);
    try {
      const blob = await getKycDocument(doc.id);
      if (previewUrl) URL.revokeObjectURL(previewUrl);
      setPreviewUrl(URL.createObjectURL(blob));
    } catch (err) {
      setPreviewError(
        err instanceof Error ? err.message : "Failed to load document",
      );
    } finally {
      setPreviewLoadingId(null);
    }
  }, [previewUrl]);

  const closeDocumentPreview = useCallback(() => {
    if (previewUrl) URL.revokeObjectURL(previewUrl);
    setPreviewUrl(null);
    setPreviewError(null);
  }, [previewUrl]);

  useEffect(() => {
    return () => {
      if (previewUrl) URL.revokeObjectURL(previewUrl);
    };
  }, [previewUrl]);

  const toggleSuspend = async () => {
    if (!voter) return;
    setAction({ busy: true, error: null, success: null });
    try {
      const nextStatus = isSuspended ? "active" : "suspended";
      await updateVoter(voter.id, { status: nextStatus });
      await load();
      setAction({ busy: false, error: null, success: `Voter ${isSuspended ? "reinstated" : "suspended"}.` });
    } catch (err) {
      setAction({ busy: false, error: err instanceof Error ? err.message : "Failed to update voter", success: null });
    }
  };

  const startEdit = () => {
    if (!voter) return;
    setEditForm({
      fullName: voter.fullName,
      phone: voter.phone ?? "",
      notes: voter.notes ?? "",
    });
    setEditing(true);
  };

  const saveEdit = async () => {
    if (!voter) return;
    setAction({ busy: true, error: null, success: null });
    try {
      await updateVoter(voter.id, {
        fullName: editForm.fullName,
        phone: editForm.phone || null,
        notes: editForm.notes || null,
      });
      await load();
      setEditing(false);
      setAction({ busy: false, error: null, success: "Profile updated." });
    } catch (err) {
      setAction({ busy: false, error: err instanceof Error ? err.message : "Failed to update profile", success: null });
    }
  };

  const initials = voter?.fullName
    .split(" ")
    .map((part) => part[0])
    .join("")
    .slice(0, 2)
    .toUpperCase() ?? "—";

  return (
    <AdminShell active="voters">
      <section className="mx-auto max-w-6xl space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Voters / Detail</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Voter Profile</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Identity, activity, and security posture for a single voter account.</p>
          </div>
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={startEdit}
              disabled={action.busy || !voter}
              className="rounded-md bg-[var(--surface-container)] px-4 py-2 text-xs font-semibold disabled:opacity-50"
            >
              Edit Profile
            </button>
            <button
              type="button"
              onClick={toggleSuspend}
              disabled={action.busy || !voter}
              className={`rounded-md px-4 py-2 text-xs font-semibold disabled:opacity-50 ${isSuspended ? "bg-emerald-500/20 text-emerald-300" : "bg-rose-500/20 text-rose-300"}`}
            >
              {action.busy ? "..." : isSuspended ? "Reinstate" : "Suspend"}
            </button>
          </div>
        </div>

        {action.error ? (
          <p className="flex items-center gap-2 rounded-lg border border-rose-500/30 bg-rose-500/10 px-3 py-2 text-xs text-rose-300">
            <span className="material-symbols-outlined text-sm">error</span>
            {action.error}
          </p>
        ) : null}
        {action.success ? (
          <p className="flex items-center gap-2 rounded-lg border border-emerald-500/30 bg-emerald-500/10 px-3 py-2 text-xs text-emerald-300">
            <span className="material-symbols-outlined text-sm">check_circle</span>
            {action.success}
          </p>
        ) : null}

        {loading ? (
          <p className="rounded-xl bg-[var(--surface-container)] px-5 py-10 text-center text-sm text-[var(--text-muted)]">Loading voter profile...</p>
        ) : error ? (
          <p className="rounded-xl bg-[var(--surface-container)] px-5 py-10 text-center text-sm text-rose-300">{error}</p>
        ) : voter ? (
          <div className="grid gap-6 xl:grid-cols-[0.95fr,1.05fr]">
            <article className="space-y-5 rounded-xl bg-[var(--surface-container)] p-5">
              <div className="flex items-center gap-4">
                <div className="grid h-16 w-16 place-items-center rounded-full bg-[var(--surface-container-high)] text-xl font-bold">{initials}</div>
                <div>
                  <p className="text-lg font-semibold">{voter.fullName}</p>
                  <p className="text-xs font-mono text-[var(--primary)]">{voter.id}</p>
                </div>
              </div>

              <div className="space-y-2 rounded-lg bg-[var(--surface-container-low)] p-4 text-sm">
                <Row label="Email" value={voter.email} />
                <Row label="Phone" value={voter.phone ?? "—"} />
                <Row label="Role" value={voter.role} />
                <Row
                  label="KYC Status"
                  value={voter.kycStatus}
                  toneClass={kycTone(voter.kycStatus)}
                />
                <Row
                  label="Account Status"
                  value={isSuspended ? "Suspended" : "Active"}
                  toneClass={isSuspended ? "bg-rose-500/15 text-rose-300" : "bg-emerald-500/15 text-emerald-300"}
                />
                <Row label="Joined" value={formatDate(voter.createdAt)} />
              </div>

              <div className="grid gap-3 sm:grid-cols-3">
                <Stat title="Votes Cast" value={String(voter.vote_count ?? votes.length)} />
                <Stat title="Receipts" value={String(votes.length)} />
                <Stat title="Account Status" value={isSuspended ? "Suspended" : "Active"} />
              </div>

              <div className="rounded-lg border border-[var(--border-subtle)] bg-[var(--surface-container-low)] p-4">
                <p className="text-[11px] uppercase tracking-[0.08em] text-[var(--text-muted)]">Risk Score</p>
                <p className={`mt-2 text-2xl font-bold ${riskScore > 40 ? "text-amber-300" : "text-emerald-300"}`}>{riskScore} — {riskLabel}</p>
                <p className="mt-1 text-xs text-[var(--text-muted)]">Computed from account status, KYC outcome, and vote-timing signals.</p>
              </div>

              {voter.notes ? (
                <div className="rounded-lg border border-[var(--border-subtle)] bg-[var(--surface-container-low)] p-4">
                  <p className="text-[11px] uppercase tracking-[0.08em] text-[var(--text-muted)]">Admin Notes</p>
                  <p className="mt-1 text-sm text-[var(--text-muted)]">{voter.notes}</p>
                </div>
              ) : null}
            </article>

            <article className="rounded-xl bg-[var(--surface-container)] p-5">
              <div className="mb-4 flex flex-wrap gap-2">
                <Tab label="Overview" selected={tab === "overview"} onClick={() => setTab("overview")} />
                <Tab label="Activity History" selected={tab === "history"} onClick={() => setTab("history")} />
                <Tab label="Security" selected={tab === "security"} onClick={() => setTab("security")} />
                <Tab label="KYC" selected={tab === "kyc"} onClick={() => setTab("kyc")} />
              </div>

              {tab === "overview" ? (
                <div className="space-y-3 text-sm">
                  <InfoCard
                    title="KYC Status"
                    text={voter.kycStatus}
                    toneClass={kycTone(voter.kycStatus)}
                  />
                  <InfoCard title="Registered" text={formatDate(voter.createdAt)} />
                  <InfoCard title="Participation" text={`${votes.length} confirmed vote${votes.length === 1 ? "" : "s"} on record.`} />
                  <InfoCard title="Account Status" text={isSuspended ? "Suspended — this voter cannot log in or cast votes." : "Active — this voter can log in and participate."} />
                </div>
              ) : null}

              {tab === "history" ? (
                timeline.length > 0 ? (
                  <div className="space-y-3">
                    {timeline.map((event) => (
                      <div key={event.id} className="rounded-lg border border-[var(--border-subtle)] bg-[var(--surface-container-low)] p-3">
                        <div className="flex items-center justify-between gap-3">
                          <p className="text-sm font-semibold">{event.title}</p>
                          <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase ${toneClass(event.tone)}`}>{event.tone}</span>
                        </div>
                        <p className="mt-1 text-xs text-[var(--text-muted)]">{event.time}</p>
                        <p className="mt-1 font-mono text-[11px] text-[var(--primary)]">{event.receipt}</p>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-sm text-[var(--text-muted)]">No voting activity on record.</p>
                )
              ) : null}

              {tab === "security" ? (
                <div className="space-y-3 text-sm">
                  <InfoCard
                    title="Account Status"
                    text={isSuspended ? "Suspended — login and voting are blocked." : "Active — no restrictions."}
                    toneClass={isSuspended ? "bg-rose-500/15 text-rose-300" : "bg-emerald-500/15 text-emerald-300"}
                  />
                  <InfoCard title="Risk Score" text={`${riskScore} (${riskLabel}) — based on account status, KYC outcome, and vote-timing patterns.`} />
                  <InfoCard title="Admin Notes" text={voter.notes ?? "No notes recorded."} />
                </div>
              ) : null}

              {tab === "kyc" ? (
                <div className="space-y-4 text-sm">
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <p className="text-sm font-semibold">Identity Verification</p>
                    <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${kycTone(voter.kycStatus)}`}>
                      {voter.kycStatus}
                    </span>
                  </div>
                  {documents.length === 0 ? (
                    <p className="rounded-lg border border-[var(--border-subtle)] bg-[var(--surface-container-low)] p-3 text-xs text-[var(--text-muted)]">
                      No KYC documents are currently in the review queue for this voter. Approved or rejected documents may be available from the KYC verification page.
                    </p>
                  ) : (
                    <div className="space-y-2">
                      {documents.map((doc) => (
                        <div key={doc.id} className="flex flex-wrap items-center justify-between gap-2 rounded-lg border border-[var(--border-subtle)] bg-[var(--surface-container-low)] p-3">
                          <div>
                            <p className="text-sm font-semibold">{doc.doc_type}</p>
                            <p className="mt-1 text-[11px] text-[var(--text-muted)]">Submitted {formatDate(doc.created_at)}</p>
                            <p className="mt-1 font-mono text-[11px] text-[var(--text-muted)]">{doc.r2_key}</p>
                          </div>
                          <div className="flex items-center gap-2">
                            <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${kycTone(doc.status)}`}>
                              {doc.status}
                            </span>
                            <button
                              type="button"
                              onClick={() => openDocumentPreview(doc)}
                              disabled={previewLoadingId === doc.id}
                              className="rounded-md bg-[var(--primary)]/15 px-3 py-1.5 text-xs font-semibold text-[var(--primary)] disabled:opacity-40"
                            >
                              {previewLoadingId === doc.id ? "Loading..." : "View Document"}
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                  {previewError ? (
                    <p className="text-xs text-rose-300">{previewError}</p>
                  ) : null}
                </div>
              ) : null}
            </article>
          </div>
        ) : null}
      </section>

      {editing ? (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 p-6" onClick={() => setEditing(false)}>
          <div className="relative max-h-[90vh] w-full max-w-md overflow-auto rounded-xl bg-[var(--surface-container)] p-6" onClick={(e) => e.stopPropagation()}>
            <div className="mb-4 flex items-center justify-between gap-3">
              <p className="text-sm font-semibold">Edit Voter Profile</p>
              <button type="button" onClick={() => setEditing(false)} className="rounded-md bg-[var(--surface-container-high)] px-3 py-1 text-xs font-semibold">Cancel</button>
            </div>
            <div className="space-y-4">
              <div>
                <label className="mb-1 block text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Full Name</label>
                <input
                  value={editForm.fullName}
                  onChange={(e) => setEditForm((prev) => ({ ...prev, fullName: e.target.value }))}
                  className="w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-sm"
                />
              </div>
              <div>
                <label className="mb-1 block text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Phone</label>
                <input
                  value={editForm.phone}
                  onChange={(e) => setEditForm((prev) => ({ ...prev, phone: e.target.value }))}
                  className="w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-sm"
                />
              </div>
              <div>
                <label className="mb-1 block text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Admin Notes</label>
                <textarea
                  value={editForm.notes}
                  onChange={(e) => setEditForm((prev) => ({ ...prev, notes: e.target.value }))}
                  className="min-h-24 w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-2 text-sm"
                  placeholder="Internal notes about this voter (not visible to the voter)..."
                />
              </div>
              <button
                type="button"
                onClick={saveEdit}
                disabled={action.busy}
                className="brand-gradient w-full rounded-lg py-2.5 text-sm font-bold text-white disabled:opacity-50"
              >
                {action.busy ? "Saving..." : "Save Changes"}
              </button>
            </div>
          </div>
        </div>
      ) : null}

      {previewUrl ? (
        <div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 p-6"
          onClick={closeDocumentPreview}
        >
          <div
            className="relative max-h-[90vh] max-w-[90vw] overflow-auto rounded-xl bg-[var(--surface-container)] p-4"
            onClick={(event) => event.stopPropagation()}
          >
            <div className="mb-3 flex items-center justify-between gap-3">
              <p className="text-sm font-semibold">{voter?.fullName} · KYC document</p>
              <button
                type="button"
                onClick={closeDocumentPreview}
                className="rounded-md bg-[var(--surface-container-high)] px-3 py-1 text-xs font-semibold"
              >
                Close
              </button>
            </div>
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={previewUrl}
              alt={`KYC document for ${voter?.fullName ?? ""}`}
              className="max-h-[80vh] max-w-full rounded-md object-contain"
            />
          </div>
        </div>
      ) : null}
    </AdminShell>
  );
}

export default function VoterProfilePage() {
  return (
    <Suspense fallback={null}>
      <VoterProfileContent />
    </Suspense>
  );
}

function Row({ label, value, toneClass }: { label: string; value: string; toneClass?: string }) {
  return (
    <div className="flex items-center justify-between gap-3">
      <p className="text-xs uppercase tracking-[0.08em] text-[var(--text-muted)]">{label}</p>
      {toneClass ? (
        <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${toneClass}`}>{value}</span>
      ) : (
        <p className="text-sm font-semibold">{value}</p>
      )}
    </div>
  );
}

function Stat({ title, value }: { title: string; value: string }) {
  return (
    <div className="rounded-lg bg-[var(--surface-container-low)] p-3">
      <p className="text-[11px] uppercase tracking-[0.08em] text-[var(--text-muted)]">{title}</p>
      <p className="mt-1 text-xl font-bold">{value}</p>
    </div>
  );
}

function Tab({ label, selected, onClick }: { label: string; selected: boolean; onClick: () => void }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`rounded-md px-3 py-2 text-xs font-semibold ${selected ? "bg-[var(--primary)]/15 text-[var(--primary)]" : "bg-[var(--surface-container-low)] text-[var(--text-muted)]"}`}
    >
      {label}
    </button>
  );
}

function InfoCard({ title, text, toneClass }: { title: string; text: string; toneClass?: string }) {
  return (
    <div className="rounded-lg border border-[var(--border-subtle)] bg-[var(--surface-container-low)] p-3">
      <p className="text-sm font-semibold">{title}</p>
      {toneClass ? (
        <span className={`mt-2 inline-block rounded-full px-2 py-0.5 text-[10px] font-bold uppercase tracking-[0.08em] ${toneClass}`}>{text}</span>
      ) : (
        <p className="mt-1 text-xs text-[var(--text-muted)]">{text}</p>
      )}
    </div>
  );
}

function toneClass(tone: "good" | "warn" | "neutral") {
  if (tone === "good") return "bg-emerald-500/20 text-emerald-300";
  if (tone === "warn") return "bg-amber-500/20 text-amber-300";
  return "bg-[var(--surface-container-high)] text-[var(--text-secondary)]";
}
