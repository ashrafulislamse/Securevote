"use client";

import { useEffect, useState } from "react";

export type Theme = "dark" | "light";

const STORAGE_KEY = "sv-theme";

function getSystemTheme(): Theme {
  if (typeof window === "undefined") {
    return "dark";
  }
  return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

export function useTheme() {
  const [theme, setTheme] = useState<Theme>(() => {
    if (typeof window === "undefined") {
      return "dark";
    }
    const stored = window.localStorage.getItem(STORAGE_KEY) as Theme | null;
    return stored ?? "dark";
  });

  useEffect(() => {
    document.documentElement.setAttribute("data-theme", theme);
  }, [theme]);

  const setAndPersistTheme = (next: Theme) => {
    setTheme(next);
    document.documentElement.setAttribute("data-theme", next);
    window.localStorage.setItem(STORAGE_KEY, next);
  };

  const toggle = () => {
    const next = theme === "dark" ? "light" : "dark";
    setAndPersistTheme(next);
  };

  return { theme, toggle, setTheme: setAndPersistTheme };
}
