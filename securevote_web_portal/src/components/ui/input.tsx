import * as React from "react";

import { cn } from "@/lib/utils";

export type InputProps = React.InputHTMLAttributes<HTMLInputElement>;

const Input = React.forwardRef<HTMLInputElement, InputProps>(({ className, type = "text", ...props }, ref) => {
  return (
    <input
      type={type}
      className={cn(
        "flex h-10 w-full rounded-md border border-[var(--border-default)] bg-[var(--surface-container-high)] px-3 py-2 text-sm text-[var(--foreground)] placeholder:text-[var(--text-muted)] outline-none transition focus-visible:border-[var(--primary)]/60 focus-visible:ring-2 focus-visible:ring-[var(--primary)]/35",
        className,
      )}
      ref={ref}
      {...props}
    />
  );
});
Input.displayName = "Input";

export { Input };
