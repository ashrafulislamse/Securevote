"use client";

import { useMemo, useRef, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import { importVoters } from "@/lib/api-client";

type ParsedRow = {
  fullName: string;
  email: string;
  phone: string;
};

const REQUIRED_FIELDS = ["fullName", "email"] as const;

/** Parse CSV text into rows. Handles quoted fields and commas inside quotes. */
function parseCsv(text: string): Record<string, string>[] {
  const lines = text.split(/\r?\n/).filter((line) => line.trim().length > 0);
  if (lines.length < 2) return []; // need header + at least 1 row
  const splitLine = (line: string): string[] => {
    const result: string[] = [];
    let current = "";
    let inQuotes = false;
    for (let i = 0; i < line.length; i++) {
      const ch = line[i];
      if (ch === '"' && line[i + 1] === '"') {
        current += '"';
        i++;
      } else if (ch === '"') {
        inQuotes = !inQuotes;
      } else if (ch === "," && !inQuotes) {
        result.push(current);
        current = "";
      } else {
        current += ch;
      }
    }
    result.push(current);
    return result;
  };
  const headers = splitLine(lines[0]).map((h) => h.trim());
  return lines.slice(1).map((line) => {
    const values = splitLine(line);
    const row: Record<string, string> = {};
    headers.forEach((header, idx) => {
      row[header] = (values[idx] ?? "").trim();
    });
    return row;
  });
}

/** Normalize header names: lowercase, replace spaces/special with underscore. */
function normalizeHeader(header: string): string {
  return header.toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_|_$/g, "");
}

/** Try to auto-map a target field name to a CSV header. */
function autoDetectColumn(headers: string[], candidates: string[]): string {
  const normalized = headers.map(normalizeHeader);
  for (const candidate of candidates) {
    const idx = normalized.indexOf(candidate);
    if (idx >= 0) return headers[idx];
  }
  return "";
}

export default function ImportVotersPage() {
  const [step, setStep] = useState<1 | 2 | 3>(1);
  const [fileName, setFileName] = useState("");
  const [rawRows, setRawRows] = useState<Record<string, string>[]>([]);
  const [headers, setHeaders] = useState<string[]>([]);
  const [mapping, setMapping] = useState<Record<string, string>>({
    fullName: "",
    email: "",
    phone: "",
  });
  const [done, setDone] = useState(false);
  const [confirming, setConfirming] = useState(false);
  const [result, setResult] = useState<{ created: number; skipped: string[] } | null>(null);
  const [error, setError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const mappedRows = useMemo<ParsedRow[]>(() => {
    return rawRows.map((row) => ({
      fullName: row[mapping.fullName] ?? "",
      email: row[mapping.email] ?? "",
      phone: row[mapping.phone] ?? "",
    }));
  }, [rawRows, mapping]);

  const validRows = useMemo(
    () => mappedRows.filter((r) => r.fullName && r.email.includes("@")),
    [mappedRows],
  );

  const canReview = fileName.length > 0 && rawRows.length > 0;
  const mappingReady = REQUIRED_FIELDS.every((field) => mapping[field] && mapping[field].trim() !== "");
  const status = done ? "Imported" : step === 1 ? "Upload" : step === 2 ? "Map" : "Confirm";

  const handleFile = (file: File) => {
    setFileName(file.name);
    setError(null);
    const reader = new FileReader();
    reader.onload = (e) => {
      const text = String(e.target?.result ?? "");
      const rows = parseCsv(text);
      if (rows.length === 0) {
        setError("CSV file is empty or has no data rows.");
        setRawRows([]);
        setHeaders([]);
        return;
      }
      setRawRows(rows);
      setHeaders(Object.keys(rows[0]));
      // Auto-detect column mappings
      const headerList = Object.keys(rows[0]);
      setMapping({
        fullName: autoDetectColumn(headerList, ["full_name", "fullname", "name", "full name"]),
        email: autoDetectColumn(headerList, ["email", "email_address", "e_mail"]),
        phone: autoDetectColumn(headerList, ["phone", "phone_number", "mobile", "contact"]),
      });
    };
    reader.onerror = () => setError("Failed to read the file.");
    reader.readAsText(file);
  };

  const handleConfirm = async () => {
    setConfirming(true);
    setError(null);
    try {
      const payload = validRows.map((r) => ({
        email: r.email,
        fullName: r.fullName,
        phone: r.phone || undefined,
      }));
      const res = await importVoters(payload);
      setResult({ created: res.created, skipped: res.skipped });
      setDone(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Import failed.");
    } finally {
      setConfirming(false);
    }
  };

  const reset = () => {
    setStep(1);
    setFileName("");
    setRawRows([]);
    setHeaders([]);
    setMapping({ fullName: "", email: "", phone: "" });
    setDone(false);
    setResult(null);
    setError(null);
  };

  return (
    <AdminShell active="voters">
      <section className="mx-auto max-w-6xl space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Voters / Bulk Operations</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Import Voters</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Upload a CSV file, map fields, and bulk-create voter accounts.</p>
          </div>
          <span className="rounded-full bg-[var(--surface-container)] px-4 py-1 text-xs uppercase tracking-[0.1em] text-[var(--text-muted)]">Status: {status}</span>
        </div>

        <div className="grid gap-3 md:grid-cols-3">
          <StepCard title="1. Upload" active={step === 1} done={step > 1 || done} />
          <StepCard title="2. Review & Map" active={step === 2} done={step > 2 || done} />
          <StepCard title="3. Import" active={step === 3} done={done} />
        </div>

        {error ? (
          <p className="flex items-center gap-2 rounded-lg border border-rose-500/30 bg-rose-500/10 px-3 py-2 text-xs text-rose-300">
            <span className="material-symbols-outlined text-sm">error</span>
            {error}
          </p>
        ) : null}

        <article className="space-y-5 rounded-xl bg-[var(--surface-container)] p-5">
          {step === 1 ? (
            <>
              <input
                ref={fileInputRef}
                type="file"
                accept=".csv,text/csv"
                className="hidden"
                onChange={(e) => {
                  const file = e.target.files?.[0];
                  if (file) handleFile(file);
                }}
              />
              <button
                type="button"
                onClick={() => fileInputRef.current?.click()}
                className="w-full rounded-xl border border-dashed border-white/15 bg-[var(--surface-container-low)] p-10 text-center transition hover:border-[var(--primary)]/50"
              >
                <span className="material-symbols-outlined text-3xl text-[var(--text-muted)]">upload_file</span>
                <p className="mt-2 text-lg font-semibold">Click to select a CSV file</p>
                <p className="mt-1 text-sm text-[var(--text-muted)]">Required columns: full_name (or name), email. Optional: phone.</p>
              </button>

              <div className="flex items-center justify-between rounded-lg bg-[var(--surface-container-low)] px-4 py-3 text-sm">
                <p>{fileName ? `${fileName} — ${rawRows.length} rows detected` : "No file selected yet"}</p>
                <button
                  type="button"
                  disabled={!canReview}
                  onClick={() => setStep(2)}
                  className={`rounded-md px-4 py-2 text-xs font-semibold ${canReview ? "brand-gradient text-white" : "bg-white/10 text-white/40"}`}
                >
                  Continue
                </button>
              </div>
            </>
          ) : null}

          {step === 2 ? (
            <>
              <div className="grid gap-3 md:grid-cols-3">
                {(["fullName", "email", "phone"] as const).map((field) => (
                  <label key={field} className="space-y-1 rounded-lg bg-[var(--surface-container-low)] p-3">
                    <span className="text-[11px] font-semibold uppercase tracking-[0.09em] text-[var(--text-muted)]">
                      {field === "fullName" ? "Full Name" : field === "email" ? "Email" : "Phone (optional)"}
                      {field !== "phone" ? " *" : ""}
                    </span>
                    <select
                      value={mapping[field]}
                      onChange={(event) => setMapping((prev) => ({ ...prev, [field]: event.target.value }))}
                      className="h-10 w-full rounded-md bg-[var(--surface-container-high)] px-3 text-sm"
                    >
                      <option value="">Select source column</option>
                      {headers.map((header) => (
                        <option key={header} value={header}>{header}</option>
                      ))}
                    </select>
                  </label>
                ))}
              </div>

              {mappedRows.length > 0 ? (
                <div className="overflow-x-auto rounded-lg border border-white/8">
                  <table className="w-full min-w-[480px] text-left text-sm">
                    <thead className="bg-[var(--surface-container-low)] text-[11px] uppercase tracking-[0.08em] text-[var(--text-muted)]">
                      <tr>
                        <th className="px-3 py-2">Name</th>
                        <th className="px-3 py-2">Email</th>
                        <th className="px-3 py-2">Phone</th>
                        <th className="px-3 py-2">Valid</th>
                      </tr>
                    </thead>
                    <tbody>
                      {mappedRows.slice(0, 20).map((row, idx) => (
                        <tr key={idx} className="border-t border-white/8">
                          <td className="px-3 py-2">{row.fullName || "—"}</td>
                          <td className="px-3 py-2">{row.email || "—"}</td>
                          <td className="px-3 py-2">{row.phone || "—"}</td>
                          <td className="px-3 py-2">
                            {row.fullName && row.email.includes("@") ? (
                              <span className="text-emerald-300">✓</span>
                            ) : (
                              <span className="text-rose-300">✗</span>
                            )}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                  {mappedRows.length > 20 ? (
                    <p className="border-t border-white/8 px-3 py-2 text-xs text-[var(--text-muted)]">Showing first 20 of {mappedRows.length} rows. {validRows.length} valid rows will be imported.</p>
                  ) : (
                    <p className="border-t border-white/8 px-3 py-2 text-xs text-[var(--text-muted)]">{validRows.length} of {mappedRows.length} rows are valid and will be imported.</p>
                  )}
                </div>
              ) : null}

              <div className="flex justify-between">
                <button type="button" onClick={() => setStep(1)} className="rounded-md bg-white/10 px-4 py-2 text-xs font-semibold">
                  Back
                </button>
                <button
                  type="button"
                  disabled={!mappingReady}
                  onClick={() => setStep(3)}
                  className={`rounded-md px-4 py-2 text-xs font-semibold ${mappingReady ? "brand-gradient text-white" : "bg-white/10 text-white/40"}`}
                >
                  Proceed to Import
                </button>
              </div>
            </>
          ) : null}

          {step === 3 ? (
            <>
              <div className="rounded-lg bg-[var(--surface-container-low)] p-4">
                <p className="text-sm">Ready to import {validRows.length} voter{validRows.length === 1 ? "" : "s"} from {fileName}.</p>
                <p className="mt-1 text-xs text-[var(--text-muted)]">Each voter gets a random password and pending KYC status. Existing emails will be skipped.</p>
              </div>

              {done && result ? (
                <div className="space-y-3">
                  <div className="rounded-lg border border-emerald-500/30 bg-emerald-500/10 p-4">
                    <p className="text-sm font-bold text-emerald-300">Import completed</p>
                    <p className="mt-1 text-sm text-[var(--text-muted)]">{result.created} voter{result.created === 1 ? "" : "s"} created.</p>
                    {result.skipped.length > 0 ? (
                      <p className="mt-1 text-sm text-[var(--text-muted)]">{result.skipped.length} email(s) already existed and were skipped: {result.skipped.slice(0, 5).join(", ")}{result.skipped.length > 5 ? "..." : ""}</p>
                    ) : null}
                  </div>
                  <button type="button" onClick={reset} className="rounded-md bg-white/10 px-4 py-2 text-xs font-semibold">
                    Import Another File
                  </button>
                </div>
              ) : (
                <div className="flex justify-between">
                  <button type="button" onClick={() => setStep(2)} className="rounded-md bg-white/10 px-4 py-2 text-xs font-semibold">
                    Back
                  </button>
                  <button
                    type="button"
                    onClick={handleConfirm}
                    disabled={confirming || validRows.length === 0}
                    className="rounded-md brand-gradient px-4 py-2 text-xs font-semibold text-white disabled:opacity-60"
                  >
                    {confirming ? "Importing..." : `Confirm Import (${validRows.length})`}
                  </button>
                </div>
              )}
            </>
          ) : null}
        </article>
      </section>
    </AdminShell>
  );
}

function StepCard({ title, active, done }: { title: string; active: boolean; done: boolean }) {
  return (
    <div className={`rounded-xl border px-4 py-3 ${active ? "border-[var(--primary)]/45 bg-[var(--primary)]/8" : "border-white/8 bg-[var(--surface-container)]"}`}>
      <p className="text-sm font-semibold">{title}</p>
      <p className={`mt-1 text-xs ${done ? "text-emerald-300" : "text-[var(--text-muted)]"}`}>{done ? "Completed" : active ? "In Progress" : "Waiting"}</p>
    </div>
  );
}
