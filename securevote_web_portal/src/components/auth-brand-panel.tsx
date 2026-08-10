export function AuthBrandPanel({
  title,
  subtitle,
  badge,
}: {
  title: string;
  subtitle: string;
  badge?: string;
}) {
  return (
    <section className="relative hidden w-1/2 flex-col justify-between overflow-hidden bg-[var(--surface-container-low)] px-12 py-10 lg:flex">
      <div className="dot-grid absolute inset-0 opacity-35" />
      <div className="absolute -left-20 top-1/4 h-[360px] w-[360px] rounded-full bg-[var(--primary)]/15 blur-[120px]" />
      <div className="absolute -right-20 bottom-1/4 h-[320px] w-[320px] rounded-full bg-[var(--secondary)]/15 blur-[120px]" />

      <div className="relative z-10 flex items-center gap-3">
        <div className="brand-gradient flex h-11 w-11 items-center justify-center rounded-xl">
          <span className="material-symbols-outlined text-white" style={{ fontVariationSettings: '"FILL" 1' }}>
            how_to_vote
          </span>
        </div>
        <div>
          <p className="text-xl font-bold tracking-tight">SecureVote</p>
          <p className="text-[10px] font-semibold uppercase tracking-[0.2em] text-[var(--text-muted)]">Enterprise Admin</p>
        </div>
      </div>

      <div className="relative z-10 max-w-xl">
        <h1 className="text-5xl font-bold leading-[1.05] tracking-[-0.03em]">{title}</h1>
        <p className="mt-5 text-base leading-relaxed text-[var(--text-muted)]">{subtitle}</p>

        <div className="mt-9 space-y-4">
          <Feature icon="security" title="Military-grade security" text="End-to-end encrypted voting and audit-safe operations." />
          <Feature icon="monitoring" title="Real-time governance telemetry" text="Monitor turnout, anomalies, and integrity in one command center." />
          <Feature icon="corporate_fare" title="Multi-organization control" text="Manage institutions and elections with role-based precision." />
        </div>
      </div>

      <div className="relative z-10 flex flex-wrap items-center gap-3">
        <Pill text="50K+ Voters" dot="bg-emerald-400" />
        <Pill text="99.9% Uptime" dot="bg-[var(--primary)]" />
        <Pill text="256-bit Encrypted" dot="bg-[var(--secondary)]" />
        {badge ? <Pill text={badge} dot="bg-[var(--tertiary)]" /> : null}
      </div>
    </section>
  );
}

function Feature({
  icon,
  title,
  text,
}: {
  icon: string;
  title: string;
  text: string;
}) {
  return (
    <div className="flex items-start gap-4 rounded-xl bg-[var(--surface-container-high)]/45 p-3">
      <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-[var(--surface-container-high)] text-[var(--primary)]">
        <span className="material-symbols-outlined">{icon}</span>
      </div>
      <div>
        <p className="text-sm font-semibold">{title}</p>
        <p className="mt-1 text-xs text-[var(--text-muted)]">{text}</p>
      </div>
    </div>
  );
}

function Pill({ text, dot }: { text: string; dot: string }) {
  return (
    <div className="glass-panel ghost-border flex items-center gap-2 rounded-full px-3 py-1.5">
      <span className={`h-1.5 w-1.5 rounded-full ${dot}`} />
      <span className="text-[10px] font-semibold uppercase tracking-[0.13em]">{text}</span>
    </div>
  );
}
