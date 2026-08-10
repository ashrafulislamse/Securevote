import Link from "next/link";
import { ThemeToggle } from "@/components/theme-toggle";

const tiers = [
  {
    severity: "Critical",
    level: 1,
    color: "text-[var(--red)] border-[var(--red)]/30 bg-[var(--red)]/10",
    dot: "bg-[var(--red)]",
  },
  {
    severity: "High",
    level: 2,
    color: "text-[var(--amber)] border-[var(--amber)]/30 bg-[var(--amber)]/10",
    dot: "bg-[var(--amber)]",
  },
  {
    severity: "Standard",
    level: 3,
    color: "text-[var(--teal)] border-[var(--teal)]/30 bg-[var(--teal)]/10",
    dot: "bg-[var(--teal)]",
  },
];

const controls = [
  {
    title: "End-to-End Ballot Encryption",
    text: "Votes are encrypted at origin and never exposed in plaintext across transport, storage, or tally pipelines.",
    icon: "encrypted",
    severity: 1,
  },
  {
    title: "Hardware-Backed Key Management",
    text: "Cryptographic keys are isolated with strict rotation policies and tamper-evident access controls.",
    icon: "key",
    severity: 1,
  },
  {
    title: "Continuous Threat Monitoring",
    text: "Live anomaly detection and risk scoring provide rapid incident response across election windows.",
    icon: "monitoring",
    severity: 2,
  },
  {
    title: "Zero-Trust Access",
    text: "Administrative actions require layered verification, scoped privileges, and full audit traceability.",
    icon: "admin_panel_settings",
    severity: 2,
  },
  {
    title: "Independent Verifiability",
    text: "Public receipts and Merkle proofs allow independent verification without disclosing voter identity.",
    icon: "verified_user",
    severity: 3,
  },
  {
    title: "Immutable Audit Trails",
    text: "Critical election events are recorded in append-only logs for transparent post-election review.",
    icon: "history_toggle_off",
    severity: 3,
  },
];

const certifications = [
  { label: "ISO 27001", icon: "verified" },
  { label: "SOC 2 Type II", icon: "shield" },
  { label: "NIST-Aligned Controls", icon: "policy" },
  { label: "Regional Data Residency", icon: "public" },
];

const chain = [
  { label: "Vote", icon: "how_to_vote" },
  { label: "Merkle Root", icon: "account_tree" },
  { label: "Ledger Anchor", icon: "link" },
  { label: "Public Proof", icon: "verified_user" },
];

export default function SecurityPage() {
  return (
    <main className="relative min-h-screen overflow-hidden bg-background text-foreground">
      {/* Ambient glows */}
      <div className="pointer-events-none absolute -left-28 top-16 h-[520px] w-[520px] rounded-full bg-[var(--primary)]/20 blur-[140px] animate-orb" />
      <div className="pointer-events-none absolute -right-24 top-[30%] h-[480px] w-[480px] rounded-full bg-[var(--teal)]/16 blur-[130px] animate-orb-slow" />
      <div className="dot-grid absolute inset-0 opacity-[0.16]" />

      {/* Header */}
      <header className="fixed inset-x-0 top-0 z-40 border-b border-[var(--border-default)] bg-[var(--surface-overlay)] backdrop-blur-xl">
        <div className="mx-auto flex h-20 max-w-7xl items-center justify-between px-6 md:px-10">
          <Link href="/" className="group flex items-center gap-3">
            <div className="brand-gradient glow-brand grid h-10 w-10 place-items-center rounded-xl transition group-hover:scale-105">
              <span className="material-symbols-outlined text-white" style={{ fontVariationSettings: '"FILL" 1' }}>
                shield_lock
              </span>
            </div>
            <p className="text-2xl font-extrabold tracking-tight">SecureVote Security</p>
          </Link>

          <nav className="hidden items-center gap-8 md:flex">
            <Link href="/" className="text-[11px] font-bold uppercase tracking-[0.15em] text-[var(--text-muted)] transition hover:text-[var(--text-primary)]">
              Home
            </Link>
            <Link href="/security" className="text-[11px] font-bold uppercase tracking-[0.15em] text-[var(--text-primary)]">
              Security
            </Link>
            <Link href="/verifier" className="text-[11px] font-bold uppercase tracking-[0.15em] text-[var(--text-muted)] transition hover:text-[var(--text-primary)]">
              Verifier
            </Link>
          </nav>

          <div className="flex items-center gap-3">
            <ThemeToggle />
            <Link
              href="/verifier"
              className="hidden rounded-xl border border-[var(--border-default)] bg-[var(--surface-high)] px-4 py-2 text-xs font-bold uppercase tracking-[0.11em] text-[var(--text-primary)] transition hover:bg-[var(--surface-highest)] md:inline-flex"
            >
              Verify Receipt
            </Link>
            <Link
              href="/admin/login"
              className="brand-gradient rounded-xl px-4 py-2 text-xs font-bold uppercase tracking-[0.12em] text-white shadow-[0_0_24px_rgba(79,110,247,0.4)]"
            >
              Open Admin
            </Link>
          </div>
        </div>
      </header>

      <section className="mx-auto max-w-7xl px-6 pb-20 pt-32 md:px-10">
        {/* ===== HERO ===== */}
        <div className="grid items-center gap-12 lg:grid-cols-[1.1fr,0.9fr]">
          <div className="mx-auto max-w-4xl text-center reveal-up reveal-slow reveal-delay-1 lg:text-left">
            <p className="inline-flex items-center gap-2 rounded-full border border-[var(--primary)]/25 bg-[var(--primary)]/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-[var(--tertiary)]">
              <span className="status-dot h-1.5 w-1.5 rounded-full bg-emerald-400" />
              Security And Compliance Standards
            </p>
            <h1 className="mt-6 text-[2.8rem] font-extrabold leading-[0.98] tracking-[-0.04em] md:text-[4.6rem]">
              Built For <span className="text-gradient">High-Trust</span> Elections
            </h1>
            <p className="mx-auto mt-5 max-w-3xl text-lg leading-relaxed text-[var(--text-muted)] lg:mx-0">
              Our platform applies layered cryptography, resilient infrastructure, and transparent auditing to protect election integrity from setup to publication.
            </p>
            <div className="mt-8 flex flex-wrap justify-center gap-3 lg:justify-start">
              <Link
                href="/verifier"
                className="brand-gradient inline-flex items-center gap-2 rounded-xl px-7 py-3 text-sm font-bold uppercase tracking-[0.1em] text-white shadow-[0_0_30px_rgba(79,110,247,0.4)]"
              >
                Open Verifier
                <span className="material-symbols-outlined text-[18px]">arrow_forward</span>
              </Link>
              <a
                href="#controls"
                className="rounded-xl border border-[var(--border-default)] bg-[var(--surface-high)] px-7 py-3 text-sm font-bold uppercase tracking-[0.1em] text-[var(--text-primary)] transition hover:bg-[var(--surface-highest)]"
              >
                Explore Controls
              </a>
            </div>
          </div>

          {/* Shield visual */}
          <div className="relative mx-auto grid h-[360px] w-full max-w-[420px] place-items-center reveal-up reveal-slow reveal-delay-2">
            <div className="absolute inset-0 rounded-full border border-[var(--primary)]/25 animate-[spin_30s_linear_infinite]" />
            <div className="absolute inset-10 rounded-full border border-[var(--teal)]/20 animate-[spin_24s_linear_infinite_reverse]" />
            <div className="absolute inset-20 rounded-full border border-white/10" />
            <div className="absolute inset-8 rounded-full blur-2xl opacity-30 brand-gradient" />

            <div className="glass-panel border-gradient relative grid h-44 w-44 place-items-center rounded-[2rem] animate-float">
              <span className="material-symbols-outlined text-[96px] text-[var(--primary)]" style={{ fontVariationSettings: '"FILL" 1' }}>
                shield_lock
              </span>
              <div className="absolute -right-3 -top-3 grid h-12 w-12 place-items-center rounded-full brand-gradient glow-brand check-pop">
                <span className="material-symbols-outlined text-white">lock</span>
              </div>
            </div>

            {tiers.map((t) => (
              <span
                key={t.severity}
                className={`absolute inline-flex items-center gap-1.5 rounded-full border px-3 py-1 text-[10px] font-bold uppercase tracking-[0.1em] ${t.color}`}
                style={{
                  right: t.level % 2 === 0 ? "6%" : "12%",
                  top: t.level === 1 ? "18%" : t.level === 2 ? "58%" : "38%",
                  left: t.level === 3 ? "4%" : undefined,
                }}
              >
                <span className={`status-dot h-1.5 w-1.5 rounded-full ${t.dot}`} />
                {t.severity}
              </span>
            ))}
          </div>
        </div>

        {/* ===== SECURITY CONTROLS ===== */}
        <section id="controls" className="mt-16 grid gap-6 md:grid-cols-2 xl:grid-cols-3 reveal-up reveal-slow reveal-delay-2">
          {controls.map((item) => {
            const sev = tiers.find((t) => t.level === item.severity) ?? tiers[2];
            return (
              <article
                key={item.title}
                className="group glass-panel ghost-border relative overflow-hidden rounded-3xl p-7 card-hover"
              >
                <div className="pointer-events-none absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-[var(--primary)]/50 to-transparent opacity-0 transition group-hover:opacity-100" />
                <div className="mb-6 flex items-center justify-between">
                  <div className="grid h-14 w-14 place-items-center rounded-2xl bg-[var(--primary)]/12 text-[var(--primary)] transition group-hover:scale-110">
                    <span className="material-symbols-outlined text-[26px]" style={{ fontVariationSettings: '"FILL" 1' }}>
                      {item.icon}
                    </span>
                  </div>
                  <span className={`inline-flex items-center gap-1.5 rounded-full border px-2.5 py-0.5 text-[9px] font-bold uppercase tracking-[0.12em] ${sev.color}`}>
                    <span className={`status-dot h-1.5 w-1.5 rounded-full ${sev.dot}`} />
                    {sev.severity}
                  </span>
                </div>
                <h2 className="text-xl font-extrabold tracking-tight">{item.title}</h2>
                <p className="mt-3 text-sm leading-relaxed text-[var(--text-muted)]">{item.text}</p>
              </article>
            );
          })}
        </section>

        {/* ===== VERIFICATION CHAIN ===== */}
        <section className="mt-16 reveal-up reveal-slow reveal-delay-2">
          <div className="glass-panel ghost-border relative overflow-hidden rounded-[2rem] p-7 md:p-10">
            <div className="pointer-events-none absolute -right-20 -top-20 h-64 w-64 rounded-full bg-[var(--primary)]/10 blur-[90px]" />
            <div className="relative flex flex-col items-start gap-6 md:flex-row md:items-center md:justify-between">
              <div>
                <p className="inline-flex items-center gap-2 rounded-full border border-[var(--teal)]/25 bg-[var(--teal)]/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-[var(--teal)]">
                  <span className="status-dot h-1.5 w-1.5 rounded-full bg-[var(--teal)]" />
                  Tamper-Evident Chain
                </p>
                <h2 className="mt-4 text-3xl font-extrabold tracking-tight md:text-4xl">The Verification Chain</h2>
                <p className="mt-3 max-w-2xl text-base leading-relaxed text-[var(--text-muted)]">
                  Every ballot is bound into a hash chain that makes tampering detectable at any link through public proof.
                </p>
              </div>
            </div>

            <div className="relative mt-10 grid gap-3 md:grid-cols-4">
              <div className="pointer-events-none absolute left-[12%] right-[12%] top-1/2 hidden h-px bg-gradient-to-r from-[var(--primary)]/50 via-[var(--secondary)]/50 to-[var(--teal)]/50 md:block" />
              {chain.map((node, i) => (
                <div key={node.label} className="relative flex flex-col items-center rounded-2xl border border-[var(--border-default)] bg-[var(--surface-container)]/70 p-5 text-center card-hover">
                  <div className="grid h-12 w-12 place-items-center rounded-xl brand-gradient glow-brand">
                    <span className="material-symbols-outlined text-white" style={{ fontVariationSettings: '"FILL" 1' }}>
                      {node.icon}
                    </span>
                  </div>
                  <p className="mt-3 font-mono text-[10px] font-bold tracking-[0.18em] text-[var(--text-muted)]">NODE {i + 1}</p>
                  <p className="mt-1 text-sm font-extrabold tracking-tight">{node.label}</p>
                  <p className="mt-1 font-mono text-[10px] text-[var(--text-tertiary)]">
                    {String.fromCharCode(97 + i)}&nbsp;{`0x${"f".repeat(4)}`}...
                  </p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ===== CERTIFICATIONS ===== */}
        <section className="mt-16 reveal-up reveal-slow reveal-delay-2">
          <div className="rounded-[2rem] border border-[var(--border-default)] bg-[var(--surface-low)]/70 p-7 md:p-9">
            <div className="flex flex-col gap-6 md:flex-row md:items-center md:justify-between">
              <div>
                <p className="text-[11px] font-bold uppercase tracking-[0.16em] text-[var(--text-muted)]">Assurance Profile</p>
                <h3 className="mt-2 text-2xl font-extrabold tracking-tight">Certifications &amp; Compliance</h3>
              </div>
              <div className="flex flex-wrap gap-3">
                {certifications.map((item) => (
                  <span
                    key={item.label}
                    className="badge-sheen inline-flex items-center gap-2 rounded-full border border-[var(--primary)]/25 bg-[var(--primary)]/10 px-4 py-1.5 text-xs font-semibold text-[var(--tertiary)]"
                  >
                    <span className="material-symbols-outlined text-[16px]" style={{ fontVariationSettings: '"FILL" 1' }}>
                      {item.icon}
                    </span>
                    {item.label}
                  </span>
                ))}
              </div>
            </div>
            <p className="mt-5 max-w-3xl text-sm leading-relaxed text-[var(--text-muted)]">
              Final compliance posture depends on deployment region, tenant configuration, and election authority policy controls.
            </p>
          </div>
        </section>

        {/* ===== CTA ===== */}
        <section className="relative mt-16 overflow-hidden rounded-[2.4rem] border border-[var(--border-default)] bg-[var(--surface-low)] p-8 md:p-12 reveal-up reveal-slow reveal-delay-3">
          <div className="pointer-events-none absolute -left-20 -top-20 h-64 w-64 rounded-full bg-[var(--primary)]/20 blur-[100px]" />
          <div className="pointer-events-none absolute -bottom-20 -right-20 h-64 w-64 rounded-full bg-[var(--teal)]/15 blur-[100px]" />
          <div className="dot-grid absolute inset-0 opacity-10" />

          <div className="relative flex flex-col gap-8 md:flex-row md:items-center md:justify-between">
            <div>
              <p className="text-[11px] font-bold uppercase tracking-[0.16em] text-[var(--tertiary)]">Validate Through Public Proofs</p>
              <h2 className="mt-3 text-3xl font-extrabold tracking-tight md:text-4xl">
                Security is strongest when <span className="text-gradient">trust is testable.</span>
              </h2>
              <p className="mt-4 max-w-3xl text-base leading-relaxed text-[var(--text-muted)]">
                Use the public verifier to confirm receipt anchoring and proof continuity in the ledger.
              </p>
            </div>
            <div className="flex flex-wrap gap-3">
              <Link
                href="/verifier"
                className="brand-gradient inline-flex items-center gap-2 rounded-xl px-7 py-3.5 text-sm font-bold uppercase tracking-[0.1em] text-white shadow-[0_0_36px_rgba(79,110,247,0.45)]"
              >
                Open Verifier
                <span className="material-symbols-outlined text-[18px]">qr_code_2</span>
              </Link>
              <Link
                href="/"
                className="rounded-xl border border-[var(--border-default)] bg-[var(--surface-high)] px-7 py-3.5 text-sm font-bold uppercase tracking-[0.1em] text-[var(--text-primary)] transition hover:bg-[var(--surface-highest)]"
              >
                Return Home
              </Link>
            </div>
          </div>
        </section>
      </section>
    </main>
  );
}