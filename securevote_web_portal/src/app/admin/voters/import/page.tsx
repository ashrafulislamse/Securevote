"use client";

import { useMemo, useState } from "react";
import { AdminShell } from "@/components/admin-shell";

type Row = {
  full_name: string;
  email: string;
  phone: string;
  student_id: string;
  faculty: string;
};

const sampleRows: Row[] = [
  { full_name: "Ariyan Kabir", email: "ariyan.kabir@campus.edu", phone: "+880171234111", student_id: "ST-44210", faculty: "Engineering" },
  { full_name: "Sana Yusuf", email: "sana.yusuf@campus.edu", phone: "+880171234222", student_id: "ST-44211", faculty: "Law" },
  { full_name: "Leena Das", email: "leena.das@campus.edu", phone: "+880171234333", student_id: "ST-44212", faculty: "Business" },
];

const requiredFields = ["full_name", "email", "phone", "student_id", "faculty"] as const;

export default function ImportVotersPage() {
  const [step, setStep] = useState<1 | 2 | 3>(1);
  const [fileName, setFileName] = useState("");
  const [rows, setRows] = useState<Row[]>([]);
  const [mapping, setMapping] = useState<Record<string, string>>({
    full_name: "full_name",
    email: "email",
    phone: "phone",
    student_id: "student_id",
    faculty: "faculty",
  });
  const [done, setDone] = useState(false);

  const canReview = fileName.length > 0 && rows.length > 0;
  const mappingReady = useMemo(() => requiredFields.every((field) => mapping[field] && mapping[field].trim() !== ""), [mapping]);

  const status = done ? "Imported" : step === 1 ? "Upload" : step === 2 ? "Map" : "Confirm";

  return (
    <AdminShell active="voters">
      <section className="mx-auto max-w-6xl space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Voters / Bulk Operations</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Import Voters</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Upload CSV, map fields, and import verified voter records into the registry.</p>
          </div>
          <span className="rounded-full bg-[var(--surface-container)] px-4 py-1 text-xs uppercase tracking-[0.1em] text-[var(--text-muted)]">Status: {status}</span>
        </div>

        <div className="grid gap-3 md:grid-cols-3">
          <StepCard title="1. Upload" active={step === 1} done={step > 1 || done} />
          <StepCard title="2. Review & Map" active={step === 2} done={step > 2 || done} />
          <StepCard title="3. Import" active={step === 3} done={done} />
        </div>

        <article className="space-y-5 rounded-xl bg-[var(--surface-container)] p-5">
          {step === 1 ? (
            <>
              <button
                type="button"
                onClick={() => {
                  setFileName("voters_2026_batch_a.csv");
                  setRows(sampleRows);
                }}
                className="w-full rounded-xl border border-dashed border-white/15 bg-[var(--surface-container-low)] p-10 text-center transition hover:border-[var(--primary)]/50"
              >
                <p className="text-lg font-semibold">Drop CSV here or load sample file</p>
                <p className="mt-2 text-sm text-[var(--text-muted)]">Required headers: {requiredFields.join(", ")}</p>
                <p className="mt-4 inline-flex rounded-lg bg-white/10 px-4 py-2 text-sm font-semibold">Load Demo Upload</p>
              </button>

              <div className="flex items-center justify-between rounded-lg bg-[var(--surface-container-low)] px-4 py-3 text-sm">
                <p>{fileName || "No file selected yet"}</p>
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
              <div className="grid gap-3 md:grid-cols-2">
                {requiredFields.map((field) => (
                  <label key={field} className="space-y-1 rounded-lg bg-[var(--surface-container-low)] p-3">
                    <span className="text-[11px] font-semibold uppercase tracking-[0.09em] text-[var(--text-muted)]">{field}</span>
                    <select
                      value={mapping[field]}
                      onChange={(event) => setMapping((prev) => ({ ...prev, [field]: event.target.value }))}
                      className="h-10 w-full rounded-md bg-[var(--surface-container-high)] px-3 text-sm"
                    >
                      <option value="">Select source column</option>
                      <option value="full_name">full_name</option>
                      <option value="email">email</option>
                      <option value="phone">phone</option>
                      <option value="student_id">student_id</option>
                      <option value="faculty">faculty</option>
                    </select>
                  </label>
                ))}
              </div>

              <div className="overflow-x-auto rounded-lg border border-white/8">
                <table className="w-full min-w-[680px] text-left text-sm">
                  <thead className="bg-[var(--surface-container-low)] text-[11px] uppercase tracking-[0.08em] text-[var(--text-muted)]">
                    <tr>
                      <th className="px-3 py-2">Name</th>
                      <th className="px-3 py-2">Email</th>
                      <th className="px-3 py-2">Phone</th>
                      <th className="px-3 py-2">Student ID</th>
                      <th className="px-3 py-2">Faculty</th>
                    </tr>
                  </thead>
                  <tbody>
                    {rows.map((row) => (
                      <tr key={row.student_id} className="border-t border-white/8">
                        <td className="px-3 py-2">{row.full_name}</td>
                        <td className="px-3 py-2">{row.email}</td>
                        <td className="px-3 py-2">{row.phone}</td>
                        <td className="px-3 py-2">{row.student_id}</td>
                        <td className="px-3 py-2">{row.faculty}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>

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
                <p className="text-sm">Ready to import {rows.length} voters from {fileName}.</p>
                <p className="mt-1 text-xs text-[var(--text-muted)]">Invalid rows will be quarantined for manual review.</p>
              </div>

              <div className="flex justify-between">
                <button type="button" onClick={() => setStep(2)} className="rounded-md bg-white/10 px-4 py-2 text-xs font-semibold">
                  Back
                </button>
                <button
                  type="button"
                  onClick={() => setDone(true)}
                  className="rounded-md brand-gradient px-4 py-2 text-xs font-semibold text-white"
                >
                  Confirm Import
                </button>
              </div>

              {done ? <p className="text-sm font-semibold text-emerald-300">Import completed. 3 voters were added to registry.</p> : null}
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
