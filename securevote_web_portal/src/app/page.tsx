import Link from "next/link";
import { ThemeToggle } from "@/components/theme-toggle";

const securityPillars = [
  {
    title: "Military Grade Security",
    text: "Hardened cryptographic controls protect vote integrity from submission through final publication.",
    icon: "shield_lock",
    tint: "bg-[var(--primary)]/12 text-[var(--primary)]",
    ring: "hover:text-[var(--primary)]",
    stat: "AES-256-GCM",
  },
  {
    title: "Real-Time Operations",
    text: "Active telemetry and anomaly watch keep election teams aware of suspicious patterns in real time.",
    icon: "monitoring",
    tint: "bg-[var(--secondary)]/12 text-[var(--secondary)]",
    ring: "hover:text-[var(--secondary)]",
    stat: "LIVE MOTION",
  },
  {
    title: "Public Auditability",
    text: "Receipts and verification workflows make trust measurable for every participant and observer.",
    icon: "verified_user",
    tint: "bg-[var(--tertiary)]/12 text-[var(--tertiary)]",
    ring: "hover:text-[var(--tertiary)]",
    stat: "VERIFIABLE",
  },
];

const capabilities = [
  {
    title: "End-to-End Encryption",
    text: "Every vote stays private from device to tally with layered cryptographic wrapping.",
    icon: "lock",
    label: "E2E",
    accent: "text-[var(--primary)] bg-[var(--primary)]/10 border-[var(--primary)]/25",
  },
  {
    title: "Merkle Immutability",
    text: "Tampering with one record breaks proof integrity across the chain, making manipulation detectable.",
    icon: "account_tree",
    label: "MERKLE",
    accent: "text-[var(--secondary)] bg-[var(--secondary)]/10 border-[var(--secondary)]/25",
  },
  {
    title: "Zero-Knowledge Receipts",
    text: "Confirm your ballot is counted without ever revealing your identity or your selection.",
    icon: "fingerprint",
    label: "ZKP",
    accent: "text-[var(--tertiary)] bg-[var(--tertiary)]/10 border-[var(--tertiary)]/25",
  },
  {
    title: "On-Chain Anchoring",
    text: "Receipt roots are anchored to a public ledger for an independent, tamper-evident source of truth.",
    icon: "hub",
    label: "CHAIN",
    accent: "text-[var(--purple)] bg-[var(--purple)]/10 border-[var(--purple)]/25",
  },
];

const stats = [
  { label: "Auditable", value: "100%", suffix: "", icon: "verified" },
  { label: "Encryption", value: "AES-256", suffix: "-GCM", icon: "encrypted" },
  { label: "Ledger", value: "Polygon", suffix: "-backed", icon: "link" },
  { label: "Receipts", value: "Zero", suffix: "-knowledge", icon: "fingerprint" },
];

const platformLinks = [
  { label: "Technology", href: "#architecture" },
  { label: "Security", href: "/security" },
  { label: "Verifier", href: "/verifier" },
];

const footerGroups = [
  {
    title: "Platform",
    links: [
      { label: "Architecture", href: "#architecture" },
      { label: "Security Standards", href: "/security" },
      { label: "Public Verifier", href: "/verifier" },
      { label: "Admin Portal", href: "/admin/login" },
      { label: "AI Assistant", href: "/admin/ai-assistant" },
    ],
  },
  {
    title: "Operations",
    links: [
      { label: "Election List", href: "/admin/elections" },
      { label: "KYC Verification", href: "/admin/voters/kyc-verification" },
      { label: "Live Monitoring", href: "/admin/live-monitoring" },
      { label: "Audit Log", href: "/admin/audit-log" },
    ],
  },
  {
    title: "Company",
    links: [
      { label: "About", href: "#" },
      { label: "Documentation", href: "#" },
      { label: "Compliance", href: "#" },
      { label: "Contact", href: "#" },
    ],
  },
];

const steps = [
  {
    step: "01",
    title: "Configure",
    text: "Authorize an election, define the electorate, and set cryptographic parameters in minutes.",
    icon: "tune",
  },
  {
    step: "02",
    title: "Cast",
    text: "Votes are encrypted at origin and sealed before they ever reach the network.",
    icon: "how_to_vote",
  },
  {
    step: "03",
    title: "Verify",
    text: "Receipts are anchored to the ledger and validation is one click away for every voter.",
    icon: "verified_user",
  },
];

export default function HomePage() {
  return (
    <main className="relative min-h-screen overflow-hidden bg-background text-foreground">
      {/* Ambient glows */}
      <div className="pointer-events-none absolute -left-40 top-10 h-[560px] w-[560px] rounded-full bg-[var(--primary)]/20 blur-[150px] animate-orb" />
      <div className="pointer-events-none absolute -right-32 top-[24%] h-[500px] w-[500px] rounded-full bg-[var(--secondary)]/18 blur-[140px] animate-orb-slow" />
      <div className="pointer-events-none absolute bottom-[-120px] left-[24%] h-[440px] w-[440px] rounded-full bg-[var(--tertiary)]/14 blur-[130px] animate-orb" />
      <div className="dot-grid absolute inset-0 opacity-[0.16]" />

      {/* Site-wide header */}
      <header className="fixed inset-x-0 top-0 z-40 border-b border-[var(--border-default)] bg-[var(--surface-overlay)] backdrop-blur-xl">
        <div className="mx-auto flex h-20 max-w-7xl items-center justify-between px-6 md:px-10">
          <Link href="/" className="group flex items-center gap-3">
            <div className="brand-gradient glow-brand flex h-10 w-10 items-center justify-center rounded-xl transition group-hover:scale-105">
              <span className="material-symbols-outlined text-white" style={{ fontVariationSettings: '"FILL" 1' }}>
                security
              </span>
            </div>
            <p className="text-2xl font-extrabold tracking-tight">SecureVote</p>
          </Link>

          <nav className="hidden items-center gap-8 md:flex">
            {platformLinks.map((item) =>
              item.href.startsWith("/") ? (
                <Link
                  key={item.label}
                  href={item.href}
                  className="text-[11px] font-bold uppercase tracking-[0.15em] text-[var(--text-muted)] transition hover:text-[var(--text-primary)]"
                >
                  {item.label}
                </Link>
              ) : (
                <a
                  key={item.label}
                  href={item.href}
                  className="text-[11px] font-bold uppercase tracking-[0.15em] text-[var(--text-muted)] transition hover:text-[var(--text-primary)]"
                >
                  {item.label}
                </a>
              ),
            )}
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
              className="brand-gradient rounded-xl px-4 py-2 text-xs font-bold uppercase tracking-[0.12em] text-white shadow-[0_0_24px_rgba(79,110,247,0.4)] transition hover:shadow-[0_0_38px_rgba(79,110,247,0.6)]"
            >
              Open Admin
            </Link>
          </div>
        </div>
      </header>

      <div className="relative mx-auto max-w-7xl px-6 pb-16 pt-28 md:px-10">
        {/* ===== HERO ===== */}
        <section className="grid min-h-[calc(100vh-7rem)] gap-14 py-12 lg:grid-cols-[1.15fr,0.85fr] lg:items-center">
          <div className="reveal-up reveal-slow reveal-delay-1">
            <p className="mb-6 inline-flex items-center gap-2 rounded-full border border-[var(--primary)]/25 bg-[var(--primary)]/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-[var(--tertiary)]">
              <span className="status-dot h-1.5 w-1.5 rounded-full bg-emerald-400" />
              Sovereign Vault Online
            </p>
            <h1 className="text-[3.2rem] font-extrabold leading-[0.98] tracking-[-0.04em] md:text-[5.2rem]">
              The Sovereign
              <br />
              Vault of <span className="text-gradient">Digital</span>
              <br />
              Democracy
            </h1>
            <p className="mt-7 max-w-2xl text-xl leading-relaxed text-[var(--text-muted)]">
              Secure, immutable, and transparent election infrastructure for institutions that demand operational clarity and cryptographic trust.
            </p>
            <div className="mt-10 flex flex-wrap gap-4">
              <Link
                href="/admin/login"
                className="brand-gradient group inline-flex items-center gap-2 rounded-2xl px-8 py-4 text-sm font-bold uppercase tracking-[0.12em] text-white shadow-[0_0_40px_rgba(79,110,247,0.4)] transition hover:shadow-[0_0_60px_rgba(79,110,247,0.6)]"
              >
                Open Admin Portal
                <span className="material-symbols-outlined text-[18px] transition group-hover:translate-x-0.5">arrow_forward</span>
              </Link>
              <Link
                href="/verifier"
                className="inline-flex items-center gap-2 rounded-2xl border border-white/15 bg-white/6 px-8 py-4 text-sm font-bold uppercase tracking-[0.12em] text-white transition hover:bg-white/10"
              >
                <span className="material-symbols-outlined text-[18px]">check_circle</span>
                Verify a Receipt
              </Link>
            </div>

            {/* Credibility strip */}
            <div className="mt-14 grid grid-cols-2 gap-4 sm:grid-cols-4">
              {stats.map((stat) => (
                <div
                  key={stat.label}
                  className="glass-panel ghost-border rounded-2xl px-4 py-4 text-center transition card-hover"
                >
                  <div className="inline-flex items-center gap-1.5">
                    <span className="material-symbols-outlined text-base text-[var(--primary)]" style={{ fontVariationSettings: '"FILL" 1' }}>
                      {stat.icon}
                    </span>
                    <p className="text-base font-extrabold tracking-tight">
                      {stat.value}
                      <span className="text-gradient">{stat.suffix}</span>
                    </p>
                  </div>
                  <p className="mt-1 text-[10px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">{stat.label}</p>
                </div>
              ))}
            </div>
          </div>

          {/* Hero visual */}
          <div className="relative mx-auto h-[440px] w-full max-w-[460px] reveal-up reveal-slow reveal-delay-2">
            <div className="absolute inset-0 rounded-full border border-[var(--primary)]/30 animate-[spin_28s_linear_infinite]" />
            <div className="absolute inset-9 rounded-full border border-[var(--secondary)]/20 animate-[spin_24s_linear_infinite_reverse]" />
            <div className="absolute inset-20 rounded-full border border-white/10" />
            <div className="absolute inset-0 blur-2xl opacity-40">
              <div className="absolute inset-16 rounded-full brand-gradient" />
            </div>

            <div className="absolute inset-0 grid place-items-center">
              <div className="glass-panel border-gradient relative w-[260px] rounded-[2.25rem] p-8 text-center animate-float">
                <div className="pointer-events-none absolute -right-4 -top-4 grid h-12 w-12 place-items-center rounded-full brand-gradient glow-brand check-pop">
                  <span className="material-symbols-outlined text-white">check_circle</span>
                </div>
                <span className="material-symbols-outlined text-[88px] text-[var(--primary)]" style={{ fontVariationSettings: '"FILL" 1' }}>
                  shield_lock
                </span>
                <p className="mt-5 font-mono text-[11px] font-bold tracking-[0.24em] text-[var(--tertiary)]">ENCRYPT_SHA256</p>
                <div className="mt-4 flex items-center justify-center gap-2">
                  <span className="status-dot h-2 w-2 rounded-full bg-emerald-400" />
                  <span className="text-[10px] font-bold uppercase tracking-[0.16em] text-[var(--text-muted)]">Chain Anchored</span>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* ===== ARCHITECTURE / CAPABILITIES ===== */}
        <section id="architecture" className="py-28 reveal-up reveal-slow reveal-delay-1">
          <div className="mx-auto mb-16 max-w-3xl text-center">
            <p className="inline-flex items-center gap-2 rounded-full border border-[var(--primary)]/20 bg-[var(--primary)]/8 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.18em] text-[var(--primary)]">
              Core Infrastructure
            </p>
            <h2 className="mt-5 text-5xl font-extrabold tracking-tight md:text-6xl">
              The Architecture of <span className="text-gradient">Trust</span>
            </h2>
            <p className="mt-5 text-lg text-[var(--text-muted)]">
              The ballot box is rebuilt as a distributed cryptographic primitive with end-to-end assurance.
            </p>
          </div>

          <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-4">
            {capabilities.map((cap) => (
              <article
                key={cap.title}
                className="group glass-panel ghost-border relative overflow-hidden rounded-3xl p-7 card-hover"
              >
                <div className="pointer-events-none absolute -right-10 -top-10 h-32 w-32 rounded-full bg-[var(--primary)]/10 blur-2xl opacity-0 transition group-hover:opacity-100" />
                <div className={`mb-6 inline-grid h-14 w-14 place-items-center rounded-2xl border ${cap.accent} transition group-hover:scale-110`}>
                  <span className="material-symbols-outlined text-[26px]" style={{ fontVariationSettings: '"FILL" 1' }}>
                    {cap.icon}
                  </span>
                </div>
                <p className="font-mono text-[10px] font-bold tracking-[0.2em] text-[var(--text-muted)]">{cap.label}</p>
                <h3 className="mt-2 text-xl font-extrabold tracking-tight">{cap.title}</h3>
                <p className="mt-3 text-sm leading-relaxed text-[var(--text-muted)]">{cap.text}</p>
              </article>
            ))}
          </div>
        </section>

        {/* ===== SECURITY PILLARS ===== */}
        <section id="security" className="py-28 reveal-up reveal-slow reveal-delay-2">
          <div className="mx-auto mb-16 max-w-3xl text-center">
            <p className="inline-flex items-center gap-2 rounded-full border border-[var(--secondary)]/20 bg-[var(--secondary)]/8 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.18em] text-[var(--secondary)]">
              Security Standards
            </p>
            <h2 className="mt-5 text-5xl font-extrabold tracking-tight md:text-6xl">Hardened For <span className="text-gradient">Resilience</span></h2>
            <p className="mt-5 text-lg text-[var(--text-muted)]">Three pillars keep every election verifiable, private, and attack-resilient.</p>
          </div>

          <div className="grid gap-7 md:grid-cols-3">
            {securityPillars.map((item) => (
              <article
                key={item.title}
                className="group glass-panel ghost-border relative overflow-hidden rounded-3xl p-8 card-hover"
              >
                <div className="pointer-events-none absolute inset-x-0 top-0 h-px bg-gradient-to-r from-transparent via-[var(--primary)]/60 to-transparent opacity-0 transition group-hover:opacity-100" />
                <div className={`mb-8 grid h-16 w-16 place-items-center rounded-2xl ${item.tint} transition group-hover:scale-110 group-hover:rotate-3`}>
                  <span className="material-symbols-outlined text-3xl" style={{ fontVariationSettings: '"FILL" 1' }}>
                    {item.icon}
                  </span>
                </div>
                <p className="font-mono text-[10px] font-bold tracking-[0.2em] text-[var(--text-muted)]">{item.stat}</p>
                <h3 className="mt-2 text-2xl font-extrabold tracking-tight">{item.title}</h3>
                <p className="mt-4 text-base leading-relaxed text-[var(--text-muted)]">{item.text}</p>
              </article>
            ))}
          </div>
        </section>

        {/* ===== HOW IT WORKS ===== */}
        <section className="py-28 reveal-up reveal-slow reveal-delay-2">
          <div className="mx-auto mb-16 max-w-3xl text-center">
            <p className="inline-flex items-center gap-2 rounded-full border border-[var(--tertiary)]/20 bg-[var(--tertiary)]/8 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.18em] text-[var(--tertiary)]">
              The Voting Flow
            </p>
            <h2 className="mt-5 text-5xl font-extrabold tracking-tight md:text-6xl">
              From Ballot to <span className="text-gradient">Public Proof</span>
            </h2>
          </div>

          <div className="relative grid gap-8 md:grid-cols-3">
            <div className="pointer-events-none absolute left-[16%] right-[16%] top-10 hidden h-px bg-gradient-to-r from-[var(--primary)]/40 via-[var(--secondary)]/40 to-[var(--tertiary)]/40 md:block" />
            {steps.map((step) => (
              <div key={step.step} className="relative text-center md:text-left">
                <div className="relative mx-auto grid h-20 w-20 place-items-center rounded-2xl brand-gradient glow-brand md:mx-0">
                  <span className="material-symbols-outlined text-white text-3xl" style={{ fontVariationSettings: '"FILL" 1' }}>
                    {step.icon}
                  </span>
                </div>
                <p className="mt-6 font-mono text-sm font-bold tracking-[0.2em] text-[var(--primary)]">{step.step}</p>
                <h3 className="mt-2 text-2xl font-extrabold tracking-tight">{step.title}</h3>
                <p className="mt-3 text-base leading-relaxed text-[var(--text-muted)]">{step.text}</p>
              </div>
            ))}
          </div>
        </section>

        {/* ===== VERIFY / SAMPLE RECEIPT ===== */}
        <section id="verifier" className="py-28 reveal-up reveal-slow reveal-delay-2">
          <div className="mx-auto max-w-4xl text-center">
            <p className="inline-flex items-center gap-2 rounded-full border border-[var(--primary)]/20 bg-[var(--primary)]/8 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.18em] text-[var(--tertiary)]">
              Public Verifier
            </p>
            <h2 className="mt-5 text-5xl font-extrabold tracking-tight md:text-6xl">
              Trust, But <span className="text-gradient">Verify.</span>
            </h2>
            <p className="mx-auto mt-5 max-w-3xl text-xl text-[var(--text-muted)]">
              Every ballot receipt can be validated through the public verifier route with immutable audit references.
            </p>
          </div>

          <article className="glass-panel border-gradient relative mx-auto mt-12 max-w-4xl rounded-[2.4rem] p-8 md:p-12">
            <div className="absolute -top-4 left-1/2 -translate-x-1/2 rounded-full border border-[var(--primary)]/35 bg-[var(--surface-container)] px-5 py-1.5 font-mono text-[11px] font-bold tracking-[0.16em] text-[var(--tertiary)]">
              PUBLIC_VERIFIER_V2
            </div>

            <div className="space-y-8 text-left">
              <div>
                <label className="text-[11px] font-bold uppercase tracking-[0.18em] text-[var(--text-muted)]">Ballot Receipt ID</label>
                <div className="mt-3 flex flex-col gap-4 md:flex-row">
                  <div className="flex-1 rounded-xl border border-[var(--border-default)] bg-[var(--surface-container)] px-5 py-4 font-mono text-[var(--primary)]">
                    SV-2026-X9F2-K881-LQ82
                  </div>
                  <Link
                    href="/verifier"
                    className="brand-gradient inline-flex items-center justify-center gap-2 rounded-xl px-8 py-4 text-sm font-bold uppercase tracking-[0.1em] text-white shadow-[0_0_30px_rgba(79,110,247,0.4)] transition hover:shadow-[0_0_46px_rgba(79,110,247,0.6)]"
                  >
                    Verify
                    <span className="material-symbols-outlined text-[18px]">qr_code_2</span>
                  </Link>
                </div>
              </div>

              <div className="rounded-2xl border border-[var(--border-default)] bg-[var(--surface-low)]/60 p-6">
                <div className="flex items-center justify-between">
                  <p className="text-sm font-bold">Verification Status</p>
                  <span className="inline-flex items-center gap-1.5 rounded-full border border-emerald-500/25 bg-emerald-500/10 px-3 py-1 text-xs font-bold text-emerald-300">
                    <span className="status-dot h-1.5 w-1.5 rounded-full bg-emerald-400" />
                    Validated
                  </span>
                </div>
                <div className="mt-5 grid gap-4 md:grid-cols-2">
                  <div>
                    <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Block Height</p>
                    <p className="mt-1 font-mono text-sm">18,922,104</p>
                  </div>
                  <div>
                    <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Merkle Proof</p>
                    <p className="mt-1 font-mono text-sm">0x88e1...f22a</p>
                  </div>
                </div>
              </div>
            </div>
          </article>
        </section>

        {/* ===== CTA ===== */}
        <section className="relative overflow-hidden rounded-[2.6rem] border border-[var(--border-default)] bg-[var(--surface-low)] px-8 py-20 text-center reveal-up reveal-slow reveal-delay-3">
          <div className="pointer-events-none absolute -left-24 -top-24 h-72 w-72 rounded-full bg-[var(--primary)]/20 blur-[100px]" />
          <div className="pointer-events-none absolute -bottom-24 -right-24 h-72 w-72 rounded-full bg-[var(--secondary)]/20 blur-[100px]" />
          <div className="dot-grid absolute inset-0 opacity-10" />

          <div className="relative">
            <p className="inline-flex items-center gap-2 rounded-full border border-[var(--primary)]/25 bg-[var(--primary)]/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-[var(--tertiary)]">
              <span className="status-dot h-1.5 w-1.5 rounded-full bg-emerald-400" />
              Deploy With Confidence
            </p>
            <h2 className="mx-auto mt-6 max-w-4xl text-5xl font-extrabold leading-tight tracking-tight md:text-6xl">
              Ready to secure your <span className="text-gradient">next election?</span>
            </h2>
            <p className="mx-auto mt-5 max-w-2xl text-lg text-[var(--text-muted)]">
              Stand up a sovereign, auditable voting infrastructure in minutes — and prove every result on-chain.
            </p>
            <div className="mt-10 flex flex-wrap items-center justify-center gap-4">
              <Link
                href="/admin/login"
                className="brand-gradient inline-flex items-center gap-2 rounded-[1.2rem] px-10 py-5 text-lg font-bold uppercase tracking-[0.12em] text-white shadow-[0_0_50px_rgba(79,110,247,0.5)] transition hover:shadow-[0_0_70px_rgba(79,110,247,0.7)]"
              >
                Open Admin Portal
                <span className="material-symbols-outlined text-[22px]">arrow_forward</span>
              </Link>
              <a
                href="#architecture"
                className="rounded-[1.2rem] border border-white/15 bg-white/5 px-10 py-5 text-lg font-bold text-white transition hover:bg-white/10"
              >
                Review Architecture
              </a>
            </div>
          </div>
        </section>
      </div>

      {/* ===== FOOTER ===== */}
      <footer className="relative border-t border-[var(--border-default)] bg-[var(--surface-low)] py-16">
        <div className="mx-auto max-w-7xl px-6 md:px-10">
          <div className="grid gap-12 md:grid-cols-2 lg:grid-cols-5">
            <div className="lg:col-span-2">
              <div className="flex items-center gap-2 text-2xl font-extrabold text-[var(--text-primary)]">
                <div className="brand-gradient grid h-9 w-9 place-items-center rounded-lg">
                  <span className="material-symbols-outlined text-white text-[18px]" style={{ fontVariationSettings: '"FILL" 1' }}>
                    security
                  </span>
                </div>
                SecureVote
              </div>
              <p className="mt-5 max-w-sm text-sm leading-relaxed text-[var(--text-muted)]">
                Cryptographic governance infrastructure for trusted digital elections and accountable institutional voting.
              </p>
              <div className="mt-7 flex items-center gap-3">
                {[
                  { icon: "public", href: "#" },
                  { icon: "alternate_email", href: "#" },
                  { icon: "hub", href: "#" },
                ].map((social) => (
                  <a
                    key={social.icon}
                    href={social.href}
                    className="grid h-10 w-10 place-items-center rounded-full border border-[var(--border-default)] bg-[var(--surface-high)] text-[var(--text-secondary)] transition hover:bg-[var(--surface-highest)] hover:text-[var(--text-primary)]"
                  >
                    <span className="material-symbols-outlined text-[18px]">{social.icon}</span>
                  </a>
                ))}
              </div>
            </div>

            {footerGroups.map((group) => (
              <div key={group.title}>
                <p className="text-sm font-bold uppercase tracking-[0.12em] text-[var(--text-primary)]">{group.title}</p>
                <ul className="mt-4 space-y-3 text-sm text-[var(--text-muted)]">
                  {group.links.map((link) =>
                    link.href.startsWith("/") ? (
                      <li key={link.label}>
                        <Link href={link.href} className="transition hover:text-[var(--text-primary)]">
                          {link.label}
                        </Link>
                      </li>
                    ) : (
                      <li key={link.label}>
                        <a href={link.href} className="transition hover:text-[var(--text-primary)]">
                          {link.label}
                        </a>
                      </li>
                    ),
                  )}
                </ul>
              </div>
            ))}
          </div>

          <div className="mt-12 border-t border-[var(--border-subtle)] pt-6">
            <div className="flex flex-col gap-4 md:flex-row md:items-center md:justify-between">
              <p className="text-[11px] font-bold uppercase tracking-[0.15em] text-[var(--text-muted)]">© 2026 SecureVote Global Systems</p>
              <div className="flex items-center gap-6 text-[11px] font-bold uppercase tracking-[0.12em] text-[var(--text-muted)]">
                <a href="#" className="transition hover:text-[var(--text-primary)]">Privacy Protocol</a>
                <a href="#" className="transition hover:text-[var(--text-primary)]">Terms</a>
                <a href="#" className="transition hover:text-[var(--text-primary)]">Compliance</a>
              </div>
            </div>
            <p className="mt-5 max-w-4xl text-xs leading-relaxed text-[var(--text-secondary)]">
              SecureVote provides election infrastructure and verification tools. Final governance outcomes depend on organizational policy, legal frameworks, and responsible operational controls.
            </p>
          </div>
        </div>
      </footer>
    </main>
  );
}