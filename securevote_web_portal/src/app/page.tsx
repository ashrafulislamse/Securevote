import Link from "next/link";
import { ThemeToggle } from "@/components/theme-toggle";

const securityPillars = [
  {
    title: "Military Grade Security",
    text: "Hardened cryptographic controls protect vote integrity from submission through final publication.",
    icon: "shield_lock",
    tint: "bg-[var(--primary)]/12 text-[var(--primary)]",
  },
  {
    title: "Real-Time Operations",
    text: "Active telemetry and anomaly watch keep election teams aware of suspicious patterns in real time.",
    icon: "monitoring",
    tint: "bg-[var(--secondary)]/12 text-[var(--secondary)]",
  },
  {
    title: "Public Auditability",
    text: "Receipts and verification workflows make trust measurable for every participant and observer.",
    icon: "verified_user",
    tint: "bg-[var(--tertiary)]/12 text-[var(--tertiary)]",
  },
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

export default function HomePage() {
  return (
    <main className="relative min-h-screen overflow-hidden bg-background text-foreground">
      <div className="pointer-events-none absolute -left-32 top-20 h-[520px] w-[520px] rounded-full bg-[var(--primary)]/18 blur-[140px]" />
      <div className="pointer-events-none absolute -right-24 top-[28%] h-[440px] w-[440px] rounded-full bg-[var(--secondary)]/18 blur-[130px]" />
      <div className="pointer-events-none absolute bottom-[-80px] left-[28%] h-[380px] w-[380px] rounded-full bg-[var(--tertiary)]/12 blur-[120px]" />
      <div className="dot-grid absolute inset-0 opacity-20" />

      <header className="fixed inset-x-0 top-0 z-40 border-b border-[var(--border-default)] bg-[var(--surface-overlay)] backdrop-blur-xl">
        <div className="mx-auto flex h-20 max-w-7xl items-center justify-between px-6 md:px-10">
          <div className="flex items-center gap-3">
            <div className="brand-gradient flex h-10 w-10 items-center justify-center rounded-xl">
              <span className="material-symbols-outlined text-white" style={{ fontVariationSettings: '"FILL" 1' }}>
                security
              </span>
            </div>
            <p className="text-2xl font-extrabold tracking-tight">SecureVote</p>
          </div>

          <nav className="hidden items-center gap-8 md:flex">
            {platformLinks.map((item) => (
              item.href.startsWith("/") ? (
                <Link key={item.label} href={item.href} className="text-[11px] font-bold uppercase tracking-[0.15em] text-[var(--text-muted)] transition hover:text-[var(--text-primary)]">
                  {item.label}
                </Link>
              ) : (
                <a key={item.label} href={item.href} className="text-[11px] font-bold uppercase tracking-[0.15em] text-[var(--text-muted)] transition hover:text-[var(--text-primary)]">
                  {item.label}
                </a>
              )
            ))}
          </nav>

          <div className="flex items-center gap-3">
            <ThemeToggle />
            <Link href="/verifier" className="hidden rounded-xl border border-[var(--border-default)] bg-[var(--surface-high)] px-4 py-2 text-xs font-bold uppercase tracking-[0.11em] text-[var(--text-primary)] transition hover:bg-[var(--surface-highest)] md:inline-flex">
              Verify Receipt
            </Link>
            <Link href="/admin/login" className="brand-gradient rounded-xl px-4 py-2 text-xs font-bold uppercase tracking-[0.12em] text-white">
              Open Admin
            </Link>
          </div>
        </div>
      </header>

      <div className="relative mx-auto max-w-7xl px-6 pb-16 pt-28 md:px-10">
        <section className="grid min-h-[calc(100vh-7rem)] gap-14 py-10 lg:grid-cols-[1.2fr,0.8fr] lg:items-center">
          <div className="reveal-up reveal-slow reveal-delay-1">
            <p className="mb-6 inline-flex items-center gap-2 rounded-full border border-[var(--primary)]/25 bg-[var(--primary)]/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-[var(--tertiary)]">
              <span className="h-1.5 w-1.5 rounded-full bg-emerald-400" />
              Sovereign Vault Online
            </p>
            <h1 className="text-[3.2rem] font-extrabold leading-[0.98] tracking-[-0.04em] md:text-[4.9rem]">
              The Sovereign Vault
              <br />
              of Digital Democracy
            </h1>
            <p className="mt-7 max-w-2xl text-xl leading-relaxed text-[var(--text-muted)]">
              Secure, immutable, and transparent election infrastructure for institutions that demand operational clarity and cryptographic trust.
            </p>
            <div className="mt-10 flex flex-wrap gap-4">
              <Link href="/admin/login" className="brand-gradient rounded-2xl px-8 py-4 text-sm font-bold uppercase tracking-[0.12em] text-white">
                Explore the Network
              </Link>
              <Link href="/verifier" className="rounded-2xl border border-white/15 bg-white/6 px-8 py-4 text-sm font-bold uppercase tracking-[0.12em] text-white transition hover:bg-white/10">
                Verify Receipt
              </Link>
            </div>
          </div>

          <div className="relative mx-auto h-[420px] w-full max-w-[460px] reveal-up reveal-slow reveal-delay-2">
            <div className="absolute inset-0 rounded-full border border-[var(--primary)]/30 animate-[spin_28s_linear_infinite]" />
            <div className="absolute inset-9 rounded-full border border-[var(--secondary)]/20 animate-[spin_24s_linear_infinite_reverse]" />
            <div className="absolute inset-20 rounded-full border border-white/10" />

            <div className="absolute inset-0 grid place-items-center">
              <div className="glass-panel ghost-border relative w-[250px] rounded-[2.25rem] p-8 text-center">
                <div className="pointer-events-none absolute -right-4 -top-4 grid h-12 w-12 place-items-center rounded-full brand-gradient shadow-[0_0_26px_rgba(79,110,247,0.6)]">
                  <span className="material-symbols-outlined text-white">check_circle</span>
                </div>
                <span className="material-symbols-outlined text-[88px] text-[var(--primary)]" style={{ fontVariationSettings: '"FILL" 1' }}>
                  shield_lock
                </span>
                <p className="mt-5 font-mono text-[11px] font-bold tracking-[0.24em] text-[var(--tertiary)]">ENCRYPT_SHA256</p>
              </div>
            </div>
          </div>
        </section>

        <section id="architecture" className="py-28 reveal-up reveal-slow reveal-delay-1">
          <div className="mx-auto mb-14 max-w-3xl text-center">
            <p className="text-[11px] font-bold uppercase tracking-[0.2em] text-[var(--tertiary)]">Core Infrastructure</p>
            <h2 className="mt-4 text-5xl font-extrabold tracking-tight">The Architecture of Trust</h2>
            <p className="mt-4 text-lg text-[var(--text-muted)]">The ballot box is rebuilt as a distributed cryptographic primitive with end-to-end assurance.</p>
          </div>

          <div className="grid gap-8 lg:grid-cols-2">
            <article className="glass-panel ghost-border rounded-[2rem] p-8">
              <div className="mb-8 grid h-[280px] place-items-center rounded-[1.6rem] border border-white/10 bg-[var(--surface-container)]">
                <div className="grid place-items-center">
                  <span className="material-symbols-outlined text-[66px] text-[var(--primary)]">lock</span>
                  <p className="mt-3 rounded-lg border border-[var(--primary)]/25 bg-[var(--primary)]/10 px-3 py-1 font-mono text-[11px] font-bold tracking-[0.18em] text-[var(--tertiary)]">AES-256 GCM</p>
                </div>
              </div>
              <h3 className="text-3xl font-bold">E2E Encryption</h3>
              <p className="mt-4 text-lg leading-relaxed text-[var(--text-muted)]">Every vote remains private from device to tally with layered cryptographic wrapping.</p>
            </article>

            <article className="glass-panel ghost-border rounded-[2rem] p-8">
              <div className="mb-8 grid h-[280px] place-items-center rounded-[1.6rem] border border-white/10 bg-[var(--surface-container)]">
                <div className="grid gap-3 text-center">
                  <div className="mx-auto grid w-[180px] grid-cols-2 gap-3">
                    <div className="h-12 rounded-xl border border-white/10 bg-white/5" />
                    <div className="h-12 rounded-xl border border-white/10 bg-white/5" />
                  </div>
                  <div className="mx-auto h-8 w-px bg-gradient-to-b from-[var(--primary)]/60 to-transparent" />
                  <p className="mx-auto rounded-xl brand-gradient px-4 py-2 font-mono text-[11px] font-bold tracking-[0.16em] text-white">ROOT HASH</p>
                </div>
              </div>
              <h3 className="text-3xl font-bold">Merkle Immutability</h3>
              <p className="mt-4 text-lg leading-relaxed text-[var(--text-muted)]">Tampering with one record breaks proof integrity across the chain, making manipulation detectable.</p>
            </article>
          </div>
        </section>

        <section id="security" className="py-28 reveal-up reveal-slow reveal-delay-2">
          <div className="mx-auto mb-14 max-w-3xl text-center">
            <p className="text-[11px] font-bold uppercase tracking-[0.2em] text-[var(--tertiary)]">Security Standards</p>
            <h2 className="mt-4 text-5xl font-extrabold tracking-tight">Hardened For Resilience</h2>
          </div>

          <div className="grid gap-6 md:grid-cols-3">
            {securityPillars.map((item) => (
              <article key={item.title} className="glass-panel ghost-border rounded-[1.6rem] p-8 transition hover:bg-white/6">
                <div className={`mb-8 grid h-14 w-14 place-items-center rounded-xl ${item.tint}`}>
                  <span className="material-symbols-outlined text-3xl">{item.icon}</span>
                </div>
                <h3 className="text-2xl font-extrabold tracking-tight">{item.title}</h3>
                <p className="mt-4 text-base leading-relaxed text-[var(--text-muted)]">{item.text}</p>
              </article>
            ))}
          </div>
        </section>

        <section id="verifier" className="py-28 reveal-up reveal-slow reveal-delay-2">
          <div className="mx-auto max-w-4xl text-center">
            <h2 className="text-5xl font-extrabold tracking-tight">Trust, But Verify.</h2>
            <p className="mx-auto mt-5 max-w-3xl text-xl text-[var(--text-muted)]">
              Every ballot receipt can be validated through the public verifier route with immutable audit references.
            </p>
          </div>

          <article className="glass-panel ghost-border relative mx-auto mt-12 max-w-4xl rounded-[2.4rem] p-8 md:p-12">
            <div className="absolute -top-4 left-1/2 -translate-x-1/2 rounded-full border border-[var(--primary)]/35 bg-[var(--surface-container)] px-5 py-1.5 font-mono text-[11px] font-bold tracking-[0.16em] text-[var(--tertiary)]">
              PUBLIC_VERIFIER_V2
            </div>

            <div className="space-y-8 text-left">
              <div>
                <label className="text-[11px] font-bold uppercase tracking-[0.18em] text-[var(--text-muted)]">Ballot Receipt ID</label>
                <div className="mt-3 flex flex-col gap-4 md:flex-row">
                  <div className="flex-1 rounded-xl border border-white/10 bg-[var(--surface-container)] px-5 py-4 font-mono text-[var(--primary)]">SV-2026-X9F2-K881-LQ82</div>
                  <Link href="/verifier" className="brand-gradient rounded-xl px-8 py-4 text-center text-sm font-bold uppercase tracking-[0.1em] text-white">
                    Verify
                  </Link>
                </div>
              </div>

              <div className="rounded-2xl border border-white/10 bg-black/25 p-6">
                <div className="flex items-center justify-between">
                  <p className="text-sm font-bold">Verification Status</p>
                  <span className="rounded-full border border-emerald-500/25 bg-emerald-500/10 px-3 py-1 text-xs font-bold text-emerald-300">Validated</span>
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

        <section className="py-28 text-center reveal-up reveal-slow reveal-delay-3">
          <h2 className="mx-auto max-w-4xl text-5xl font-extrabold leading-tight tracking-tight md:text-6xl">Ready to secure your next election?</h2>
          <div className="mt-10 flex flex-wrap items-center justify-center gap-4">
            <Link href="/admin/login" className="brand-gradient rounded-[1.2rem] px-10 py-5 text-lg font-bold uppercase tracking-[0.12em] text-white">
              Contact Operations
            </Link>
            <a href="#architecture" className="rounded-[1.2rem] border border-white/15 bg-white/5 px-10 py-5 text-lg font-bold text-white transition hover:bg-white/10">
              Review Architecture
            </a>
          </div>
        </section>
      </div>

      <footer className="relative border-t border-[var(--border-default)] bg-[var(--surface-low)] py-16">
        <div className="mx-auto max-w-7xl px-6 md:px-10">
          <div className="grid gap-12 md:grid-cols-2 lg:grid-cols-5">
            <div className="lg:col-span-2">
              <div className="flex items-center gap-2 text-2xl font-extrabold text-[var(--text-primary)]">
                <span className="material-symbols-outlined text-[var(--primary)]">security</span>
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
                  {group.links.map((link) => (
                    <li key={link.label}>
                      {link.href.startsWith("/") ? (
                        <Link href={link.href} className="transition hover:text-[var(--text-primary)]">
                          {link.label}
                        </Link>
                      ) : (
                        <a href={link.href} className="transition hover:text-[var(--text-primary)]">
                          {link.label}
                        </a>
                      )}
                    </li>
                  ))}
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
