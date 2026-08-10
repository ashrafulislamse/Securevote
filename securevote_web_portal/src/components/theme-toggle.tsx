"use client";

import { Moon, Sun } from "lucide-react";
import { useSyncExternalStore } from "react";

import { useTheme } from "@/hooks/use-theme";

export function ThemeToggle() {
  const { theme, toggle } = useTheme();
  const hydrated = useSyncExternalStore(
    () => () => {},
    () => true,
    () => false,
  );

  const effectiveTheme = hydrated ? theme : "dark";
  const nextTheme = effectiveTheme === "dark" ? "light" : "dark";

  return (
    <button
      type="button"
      onClick={toggle}
      aria-label={`Switch to ${nextTheme} mode`}
      title={`Switch to ${nextTheme} mode`}
      className="relative inline-flex h-8 w-12 items-center rounded-full border border-[var(--border-default)] bg-[var(--surface-high)] px-1 transition hover:border-[var(--border-strong)]"
    >
      <span
        className={`absolute top-1 grid h-6 w-6 place-items-center rounded-full bg-[var(--surface)] text-[var(--text-secondary)] shadow-[0_2px_10px_rgba(0,0,0,0.25)] transition-all ${effectiveTheme === "dark" ? "left-1" : "left-5"}`}
      >
        {effectiveTheme === "dark" ? <Moon className="h-3.5 w-3.5" /> : <Sun className="h-3.5 w-3.5" />}
      </span>
    </button>
  );
}
