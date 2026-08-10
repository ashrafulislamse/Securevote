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
    <section className="relative hidden w-1/2 flex-col justify-between overflow-hidden border-r border-[var(--border-default)] bg-[var(--surface-container-low)] px-12 py-10 lg:flex">
      {/* ambient backdrop */}
      <div className="dot-grid absolute inset-0 opacity-35" />
      <div className="pointer-events-none absolute -left-24 top-0 h-[420px] w-[420px] rounded-full bg-[var(--brand)]/18 blur-[130px] animate-orb" />
      <div className="pointer-events-none absolute -right-24 top-[38%] h-[360px] w-[360px] rounded-full bg-[var(--purple)]/16 blur-[120px] animate-orb-slow" />
      <div className="pointer-events-none absolute -bottom-24 left-[20%] h-[340px] w-[340px] rounded-full bg-[var(--teal)]/12 blur-[120px] animate-orb" />
      <div className="brand-gradient absolute -right-24 top-1/2 h-[420px] w-[420px] rounded-full opacity-[0.07] blur-[120px]" />

      {/* header */}
      <div className="relative z-10 flex items-center gap-3">
        <div className="brand-gradient relative flex h-11 w-11 items-center justify-center rounded-xl shadow-[0_0_24px_rgba(79,110,247,0.4)]">
          <span className="material-symbols-outlined text-white" style={{ fontVariationSettings: '"FILL" 1' }}>
            how_to_vote
          </span>
        </div>
        <div>
          <p className="text-xl font-bold tracking-tight">SecureVote</p>
          <p className="text-[10px] font-semibold uppercase tracking-[0.2em] text-[var(--text-muted)]">Enterprise Admin</p>
        </div>
      </div>

      {/* headline */}
      <div className="relative z-10 max-w-xl">
        <p className="mb-4 inline-flex items-center gap-2 rounded-full border border-[var(--border-brand)] bg-[var(--brand)]/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-[var(--brand)]">
          <span className="status-dot inline-block h-1.5 w-1.5 rounded-full bg-emerald-400" />
          {badge ?? "Sovereign Command Center"}
        </p>
        <h1 className="text-5xl font-bold leading-[1.05] tracking-[-0.03em]">
          {title}
        </h1>
        <p className="mt-5 text-base leading-relaxed text-[var(--text-muted)]">{subtitle}</p>

        <div className="mt-9 space-y-4">
          <Feature icon="security" title="Military-grade security" text="End-to-end encrypted voting and audit-safe operations." />
          <Feature icon="monitoring" title="Real-time governance telemetry" text="Monitor turnout, anomalies, and integrity in one command center." />
          <Feature icon="corporate_fare" title="Multi-organization control" text="Manage institutions and elections with role-based precision." accent />
        </div>
      </div>

      {/* testimonial + stats */}
      <div className="relative z-10 space-y-4">
        <div className="panel-elevated border-gradient flex items-center gap-4 rounded-2xl p-4">
          <div className="brand-gradient flex h-11 w-11 shrink-0 items-center justify-center rounded-full text-sm font-bold text-white">
            KL
          </div>
          <div>
            <p className="text-sm font-medium leading-snug">
              "The tamper-proof audit trail turned our election into a showpiece of transparency."
            </p>
            <p className="mt-1 text-xs text-[var(--text-muted)]">
              Komi L. · Election Administrator
            </p>
          </div>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <Pill text="50K+ Voters" dot="bg-emerald-400" />
          <Pill text="99.9% Uptime" dot="bg-[var(--brand)]" />
          <Pill text="256-bit Encrypted" dot="bg-[var(--teal)]" />
        </div>
      </div>
    </section>
  );
}

function Feature({
  icon,
  title,
  text,
  accent = false,
}: {
  icon: string;
  title: string;
  text: string;
  accent?: boolean;
}) {
  return (
    <div className="group flex items-start gap-4 rounded-xl border border-transparent bg-[var(--surface-container-high)]/45 p-3 transition hover:border-[var(--border-default)] hover:bg-[var(--surface-container-high)]/70">
      <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-[var(--surface-container-high)] text-[var(--primary)] transition group-hover:scale-105">
        <span className="material-symbols-outlined" style={{ fontVariationSettings: accent ? '"FILL" 1, "wght" 500' : '"FILL" 0' }}>
          {icon}
        </span>
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