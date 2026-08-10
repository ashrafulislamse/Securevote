import Link from "next/link";
import { ThemeToggle } from "@/components/theme-toggle";

const controls = [
  {
    title: "End-to-End Ballot Encryption",
    text: "Votes are encrypted at origin and never exposed in plaintext across transport, storage, or tally pipelines.",
    icon: "encrypted",
  },
  {
    title: "Hardware-Backed Key Management",
    text: "Cryptographic keys are isolated with strict rotation policies and tamper-evident access controls.",
    icon: "key",
  },
  {
    title: "Continuous Threat Monitoring",
    text: "Live anomaly detection and risk scoring provide rapid incident response across election windows.",
    icon: "monitoring",
  },
  {
    title: "Zero-Trust Access",
    text: "Administrative actions require layered verification, scoped privileges, and full audit traceability.",
    icon: "admin_panel_settings",
  },
  {
    title: "Independent Verifiability",
    text: "Public receipts and Merkle proofs allow independent verification without disclosing voter identity.",
    icon: "verified_user",
  },
  {
    title: "Immutable Audit Trails",
    text: "Critical election events are recorded in append-only logs for transparent post-election review.",
    icon: "history_toggle_off",
  },
];

const certifications = ["ISO 27001", "SOC 2 Type II", "NIST-Aligned Controls", "Regional Data Residency"]; 

export default function SecurityPage() {
  return (
    <main className="relative min-h-screen overflow-hidden bg-background text-foreground">
      <div className="pointer-events-none absolute -left-24 top-20 h-[460px] w-[460px] rounded-full bg-[var(--primary)]/18 blur-[130px]" />
      <div className="pointer-events-none absolute -right-20 top-[35%] h-[420px] w-[420px] rounded-full bg-[var(--tertiary)]/16 blur-[120px]" />
      <div className="dot-grid absolute inset-0 opacity-20" />

      <header className="fixed inset-x-0 top-0 z-30 border-b border-[var(--border-default)] bg-[var(--surface-overlay)] backdrop-blur-xl">
        <div className="mx-auto flex h-20 max-w-7xl items-center justify-between px-6 md:px-10">
          <div className="flex items-center gap-3">
            <div className="brand-gradient grid h-10 w-10 place-items-center rounded-xl">
              <span className="material-symbols-outlined text-white" style={{ fontVariationSettings: '"FILL" 1' }}>
                shield_lock
              </span>
            </div>
            <p className="text-2xl font-extrabold tracking-tight">SecureVote Security</p>
          </div>

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
            <Link href="/verifier" className="hidden rounded-xl border border-[var(--border-default)] bg-[var(--surface-high)] px-4 py-2 text-xs font-bold uppercase tracking-[0.11em] text-[var(--text-primary)] transition hover:bg-[var(--surface-highest)] md:inline-flex">
              Verify Receipt
            </Link>
            <Link href="/admin/login" className="brand-gradient rounded-xl px-4 py-2 text-xs font-bold uppercase tracking-[0.12em] text-white">
              Open Admin
            </Link>
          </div>
        </div>
      </header>

      <section className="mx-auto max-w-7xl px-6 pb-20 pt-32 md:px-10">
        <div className="mx-auto max-w-4xl text-center reveal-up reveal-slow reveal-delay-1">
          <p className="inline-flex items-center gap-2 rounded-full border border-[var(--primary)]/25 bg-[var(--primary)]/10 px-3 py-1 text-[10px] font-bold uppercase tracking-[0.16em] text-[var(--tertiary)]">
            <span className="h-1.5 w-1.5 rounded-full bg-emerald-400" />
            Security And Compliance Standards
          </p>
          <h1 className="mt-6 text-[2.8rem] font-extrabold leading-[0.98] tracking-[-0.04em] md:text-[4.4rem]">Built For High-Trust Elections</h1>
          <p className="mx-auto mt-5 max-w-3xl text-lg leading-relaxed text-[var(--text-muted)]">
            Our platform applies layered cryptography, resilient infrastructure, and transparent auditing to protect election integrity from setup to publication.
          </p>
        </div>

        <section className="mt-12 grid gap-6 md:grid-cols-2 xl:grid-cols-3 reveal-up reveal-slow reveal-delay-2">
          {controls.map((item) => (
            <article key={item.title} className="glass-panel ghost-border rounded-[1.4rem] p-6 transition hover:bg-white/6">
              <div className="mb-5 grid h-12 w-12 place-items-center rounded-xl bg-[var(--primary)]/12 text-[var(--primary)]">
                <span className="material-symbols-outlined text-[26px]">{item.icon}</span>
              </div>
              <h2 className="text-xl font-extrabold tracking-tight">{item.title}</h2>
              <p className="mt-3 text-sm leading-relaxed text-[var(--text-muted)]">{item.text}</p>
            </article>
          ))}
        </section>

        <section className="mt-10 rounded-[1.8rem] border border-white/10 bg-[var(--surface-container)]/80 p-6 md:p-8 reveal-up reveal-slow reveal-delay-2">
          <p className="text-[11px] font-bold uppercase tracking-[0.16em] text-[var(--text-muted)]">Assurance Profile</p>
          <div className="mt-4 flex flex-wrap gap-3">
            {certifications.map((item) => (
              <span key={item} className="rounded-full border border-[var(--primary)]/25 bg-[var(--primary)]/10 px-4 py-1.5 text-xs font-semibold text-[var(--tertiary)]">
                {item}
              </span>
            ))}
          </div>
          <p className="mt-4 max-w-3xl text-sm leading-relaxed text-[var(--text-muted)]">
            Final compliance posture depends on deployment region, tenant configuration, and election authority policy controls.
          </p>
        </section>

        <section className="mt-12 rounded-[2rem] border border-white/10 bg-black/25 p-7 md:p-10 reveal-up reveal-slow reveal-delay-3">
          <h2 className="text-3xl font-extrabold tracking-tight md:text-4xl">Validate Security Through Public Proofs</h2>
          <p className="mt-4 max-w-3xl text-base leading-relaxed text-[var(--text-muted)]">
            Security is strongest when trust is testable. Use the public verifier to confirm receipt anchoring and proof continuity in the ledger.
          </p>
          <div className="mt-7 flex flex-wrap gap-3">
            <Link href="/verifier" className="brand-gradient rounded-xl px-7 py-3 text-sm font-bold uppercase tracking-[0.1em] text-white">
              Open Verifier
            </Link>
            <Link href="/" className="rounded-xl border border-[var(--border-default)] bg-[var(--surface-high)] px-7 py-3 text-sm font-bold uppercase tracking-[0.1em] text-[var(--text-primary)] transition hover:bg-[var(--surface-highest)]">
              Return Home
            </Link>
          </div>
        </section>
      </section>
    </main>
  );
}
