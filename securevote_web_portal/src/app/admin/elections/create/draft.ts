import type { ElectionType } from "@/lib/api-client";

export type ElectionDraft = {
  title: string;
  description: string;
  organization: string;
  type: ElectionType;
  startsAt: number;
  endsAt: number;
};

const DRAFT_KEY = "securevote_election_draft";

export function loadDraft(): ElectionDraft {
  if (typeof window === "undefined") {
    return defaultDraft();
  }
  try {
    const raw = window.sessionStorage.getItem(DRAFT_KEY);
    if (!raw) return defaultDraft();
    return { ...defaultDraft(), ...(JSON.parse(raw) as Partial<ElectionDraft>) };
  } catch {
    return defaultDraft();
  }
}

export function saveDraft(draft: ElectionDraft): void {
  if (typeof window === "undefined") return;
  try {
    window.sessionStorage.setItem(DRAFT_KEY, JSON.stringify(draft));
  } catch {
    // Ignore storage errors — draft is best-effort.
  }
}

export function clearDraft(): void {
  if (typeof window === "undefined") return;
  try {
    window.sessionStorage.removeItem(DRAFT_KEY);
  } catch {
    // Ignore storage errors.
  }
}

export function defaultDraft(): ElectionDraft {
  return {
    title: "",
    description: "",
    organization: "",
    type: "single",
    startsAt: 0,
    endsAt: 0,
  };
}