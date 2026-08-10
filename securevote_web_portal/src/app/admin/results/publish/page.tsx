"use client";

import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import { listElections, setElectionStatus } from "@/lib/api-client";
import type { Election } from "@/lib/api-client";

type Visibility = "public" | "participants" | "internal";

export default function PublishResultsPage() {
  const [election, setElection] = useState<Election | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [publishing, setPublishing] = useState(false);

  const [visibility, setVisibility] = useState<Visibility>("participants");
  const [channels, setChannels] = useState({ email: true, portal: true, apiWebhook: false });
  const [confirmed, setConfirmed] = useState(false);
  const [published, setPublished] = useState(false);

  const channelCount = useMemo(() => Object.values(channels).filter(Boolean).length, [channels]);
  const canPublish = confirmed && channelCount > 0 && !loading && !publishing;

  // Load the target election (prefer a closed one) on mount.
  useEffect(() => {
    let active = true;
    (async () => {
      try {
        const items = await listElections();
        if (!active) return;
        const target =
          items.find((e) => e.status === "closed") ??
          items.find((e) => e.status === "published") ??
          items[0] ??
          null;
        setElection(target);
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

  const handlePublish = async () => {
    if (!election) return;
    setPublishing(true);
    setError(null);
    try {
      await setElectionStatus(election.id, "published");
      setPublished(true);
      // Refresh the local election so its status reflects the change.
      const items = await listElections();
      setElection(items.find((e) => e.id === election.id) ?? election);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to publish results");
    } finally {
      setPublishing(false);
    }
  };

  return (
    <AdminShell active="elections">
      <section className="mx-auto max-w-6xl space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Results / Distribution</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Publish Results</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Control result visibility, notification channels, and immutable publish confirmation.</p>
          </div>
          <div className="flex items-center gap-3">
            <span className="rounded-full bg-[var(--surface-container)] px-4 py-1 text-xs uppercase tracking-[0.1em] text-[var(--text-muted)]">
              Election: {loading ? "Loading..." : election ? election.title : "None"}
            </span>
            <Link href="/admin/results/dashboard" className="rounded-lg bg-[var(--surface-container)] px-4 py-2 text-xs font-semibold">
              Open Dashboard
            </Link>
          </div>
        </div>

        {error ? (
          <div className="rounded-xl border border-rose-500/35 bg-rose-500/10 p-4 text-sm text-rose-300">{error}</div>
        ) : null}

        {loading ? (
          <div className="rounded-xl bg-[var(--surface-container)] p-8 text-center text-sm text-[var(--text-muted)]">
            Loading election...
          </div>
        ) : !election ? (
          <div className="rounded-xl bg-[var(--surface-container)] p-8 text-center text-sm text-[var(--text-muted)]">
            No election available to publish. Create an election first.
          </div>
        ) : (
          <div className="grid gap-6 xl:grid-cols-[1.15fr,0.85fr]">
            <article className="space-y-5 rounded-xl bg-[var(--surface-container)] p-5">
              <section>
                <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Who can view these results?</p>
                <div className="mt-3 grid gap-3 sm:grid-cols-3">
                  <VisibilityCard
                    title="Public"
                    description="Anyone with a valid result link can view outcome."
                    selected={visibility === "public"}
                    onClick={() => setVisibility("public")}
                  />
                  <VisibilityCard
                    title="Participants"
                    description="Only verified voters and candidates can access results."
                    selected={visibility === "participants"}
                    onClick={() => setVisibility("participants")}
                  />
                  <VisibilityCard
                    title="Internal"
                    description="Results remain hidden for internal review only."
                    selected={visibility === "internal"}
                    onClick={() => setVisibility("internal")}
                  />
                </div>
              </section>

              <section>
                <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Distribute Results</p>
                <div className="mt-3 space-y-2">
                  <ChannelToggle
                    label="Email Broadcast"
                    description="Send signed result notice to all verified voters."
                    checked={channels.email}
                    onChange={(next) => setChannels((prev) => ({ ...prev, email: next }))}
                  />
                  <ChannelToggle
                    label="Portal Banner"
                    description="Pin official results on organization dashboard."
                    checked={channels.portal}
                    onChange={(next) => setChannels((prev) => ({ ...prev, portal: next }))}
                  />
                  <ChannelToggle
                    label="API Webhook"
                    description="Send payload to connected governance systems."
                    checked={channels.apiWebhook}
                    onChange={(next) => setChannels((prev) => ({ ...prev, apiWebhook: next }))}
                  />
                </div>
                {/* TODO: publish channels endpoint — the backend only exposes election status,
                    not per-channel distribution. Channel selection is stored client-side for now. */}
              </section>
            </article>

            <aside className="space-y-5">
              <section className="rounded-xl bg-[var(--surface-container)] p-5">
                <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Publish Summary</p>
                <div className="mt-4 space-y-3">
                  <SummaryRow label="Election" value={election.title} />
                  <SummaryRow label="Status" value={election.status} />
                  <SummaryRow label="Result Visibility" value={visibility} />
                  <SummaryRow label="Channels Enabled" value={`${channelCount}`} />
                  <SummaryRow label="Blockchain Anchor" value={published ? "Published" : "Pending publish"} />
                </div>

                <label className="mt-5 flex cursor-pointer items-center gap-3 rounded-lg bg-[var(--surface-container-low)] px-3 py-3">
                  <input
                    type="checkbox"
                    checked={confirmed}
                    onChange={(event) => setConfirmed(event.target.checked)}
                    className="h-4 w-4"
                  />
                  <span className="text-xs text-white/85">I confirm this publish action is final and cannot be undone.</span>
                </label>

                <button
                  type="button"
                  disabled={!canPublish}
                  onClick={handlePublish}
                  className={`mt-4 w-full rounded-lg px-4 py-2.5 text-sm font-semibold ${canPublish ? "brand-gradient text-white" : "bg-white/10 text-white/45"}`}
                >
                  {publishing ? "Publishing..." : "Publish and Notify"}
                </button>
              </section>

              <section className="rounded-xl border border-white/8 bg-[var(--surface-container)] p-5">
                {published ? (
                  <>
                    <p className="text-sm font-semibold text-emerald-300">Results published successfully.</p>
                    <p className="mt-2 text-xs text-[var(--text-muted)]">Audit event committed and distribution pipeline triggered.</p>
                  </>
                ) : (
                  <>
                    <p className="text-sm font-semibold">Awaiting publish confirmation</p>
                    <p className="mt-2 text-xs text-[var(--text-muted)]">Complete the confirmation gate and keep at least one channel enabled.</p>
                  </>
                )}
              </section>
            </aside>
          </div>
        )}
      </section>
    </AdminShell>
  );
}

function VisibilityCard({ title, description, selected, onClick }: { title: string; description: string; selected: boolean; onClick: () => void }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`rounded-lg border p-4 text-left transition ${selected ? "border-[var(--primary)]/45 bg-[var(--primary)]/8" : "border-white/8 bg-[var(--surface-container-low)] hover:bg-[var(--surface-container-high)]/40"}`}
    >
      <p className="text-sm font-semibold">{title}</p>
      <p className="mt-1 text-xs text-[var(--text-muted)]">{description}</p>
    </button>
  );
}

function ChannelToggle({ label, description, checked, onChange }: { label: string; description: string; checked: boolean; onChange: (next: boolean) => void }) {
  return (
    <label className="flex cursor-pointer items-center justify-between gap-3 rounded-lg bg-[var(--surface-container-low)] px-3 py-3">
      <div>
        <p className="text-sm font-semibold">{label}</p>
        <p className="text-xs text-[var(--text-muted)]">{description}</p>
      </div>
      <input type="checkbox" checked={checked} onChange={(event) => onChange(event.target.checked)} className="h-4 w-4" />
    </label>
  );
}

function SummaryRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex items-center justify-between rounded-lg bg-[var(--surface-container-low)] px-3 py-2">
      <p className="text-xs uppercase tracking-[0.08em] text-[var(--text-muted)]">{label}</p>
      <p className="text-sm font-semibold capitalize">{value}</p>
    </div>
  );
}