import * as React from "react";

import { cn } from "@/lib/utils";

export function Badge({ className, ...props }: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        "inline-flex items-center rounded-full border border-[var(--primary)]/25 bg-[var(--primary)]/10 px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-[0.14em] text-[var(--tertiary)]",
        className,
      )}
      {...props}
    />
  );
}
