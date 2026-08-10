"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import {
  Bell,
  CheckCircle2,
  FileWarning,
  Gauge,
  ListChecks,
  ShieldCheck,
  Vote,
  X,
} from "lucide-react";

import {
  getNotifications,
  getUnreadNotificationCount,
  markAllNotificationsRead,
  markNotificationRead,
  type Notification,
  type NotificationType,
} from "@/lib/api-client";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { ScrollArea } from "@/components/ui/scroll-area";
import { cn } from "@/lib/utils";

const POLL_INTERVAL_MS = 30_000;

const ICON_FOR_TYPE: Record<NotificationType, React.ComponentType<{ className?: string }>> = {
  kyc_approved: ShieldCheck,
  kyc_rejected: FileWarning,
  vote_recorded: Vote,
  election_opened: ListChecks,
  election_closed: ListChecks,
  election_published: Gauge,
  info: CheckCircle2,
};

const TONE_FOR_TYPE: Record<NotificationType, string> = {
  kyc_approved: "text-emerald-400",
  kyc_rejected: "text-rose-400",
  vote_recorded: "text-[var(--tertiary)]",
  election_opened: "text-[var(--primary)]",
  election_closed: "text-white/70",
  election_published: "text-[var(--tertiary)]",
  info: "text-emerald-400",
};

function formatRelative(ts: number): string {
  const diff = Date.now() - ts;
  if (diff < 60_000) return "Just now";
  if (diff < 3_600_000) return `${Math.floor(diff / 60_000)}m ago`;
  if (diff < 86_400_000) return `${Math.floor(diff / 3_600_000)}h ago`;
  return new Date(ts).toLocaleDateString();
}

export function NotificationBell() {
  const [open, setOpen] = useState(false);
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [unread, setUnread] = useState(0);
  const [loading, setLoading] = useState(false);
  const inFlight = useRef(false);

  const refresh = useCallback(async () => {
    if (inFlight.current) return;
    inFlight.current = true;
    try {
      const [items, count] = await Promise.all([
        getNotifications(),
        getUnreadNotificationCount(),
      ]);
      setNotifications(items);
      setUnread(count);
    } catch {
      // Best-effort: keep last known state on failure.
    } finally {
      inFlight.current = false;
    }
  }, []);

  // Initial load + polling.
  useEffect(() => {
    void refresh();
    const id = setInterval(() => {
      void refresh();
    }, POLL_INTERVAL_MS);
    return () => clearInterval(id);
  }, [refresh]);

  // Refresh on open so the count is fresh when the user clicks the bell.
  useEffect(() => {
    if (open) {
      setLoading(true);
      void refresh().finally(() => setLoading(false));
    }
  }, [open, refresh]);

  const handleMarkRead = useCallback(
    async (id: string) => {
      setNotifications((prev) =>
        prev.map((n) => (n.id === id ? { ...n, read: true } : n)),
      );
      setUnread((c) => Math.max(0, c - 1));
      try {
        await markNotificationRead(id);
      } catch {
        // Re-sync on failure.
        void refresh();
      }
    },
    [refresh],
  );

  const handleMarkAll = useCallback(async () => {
    setNotifications((prev) => prev.map((n) => ({ ...n, read: true })));
    setUnread(0);
    try {
      await markAllNotificationsRead();
    } catch {
      void refresh();
    }
  }, [refresh]);

  const items = useMemo(() => notifications.slice(0, 10), [notifications]);

  return (
    <DropdownMenu open={open} onOpenChange={setOpen}>
      <DropdownMenuTrigger asChild>
        <Button
          variant="outline"
          size="icon"
          aria-label="Open notifications menu"
          className="relative"
        >
          <Bell className="h-4 w-4" />
          {unread > 0 ? (
            <span
              className="absolute -right-1 -top-1 inline-flex min-h-[18px] min-w-[18px] items-center justify-center rounded-full bg-rose-500 px-1 text-[10px] font-bold leading-none text-white shadow-[0_0_0_2px_var(--surface-glass)]"
              aria-label={`${unread} unread notifications`}
            >
              {unread > 9 ? "9+" : unread}
            </span>
          ) : null}
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-80 p-0">
        <div className="flex items-center justify-between px-4 py-3">
          <div className="flex items-center gap-2">
            <DropdownMenuLabel className="p-0">Notifications</DropdownMenuLabel>
            {unread > 0 ? (
              <Badge className="bg-rose-500/20 text-rose-200">{unread} new</Badge>
            ) : null}
          </div>
          {unread > 0 ? (
            <button
              type="button"
              onClick={() => void handleMarkAll()}
              className="text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--primary)] transition hover:text-white"
            >
              Mark all read
            </button>
          ) : null}
        </div>
        <DropdownMenuSeparator className="my-0" />
        <ScrollArea className="max-h-[360px]">
          {loading && items.length === 0 ? (
            <div className="p-4 text-xs text-[var(--text-muted)]">Loading…</div>
          ) : items.length === 0 ? (
            <div className="p-6 text-center text-xs text-[var(--text-muted)]">
              No notifications yet.
            </div>
          ) : (
            items.map((n) => {
              const Icon = ICON_FOR_TYPE[n.type as NotificationType] ?? CheckCircle2;
              const tone = TONE_FOR_TYPE[n.type as NotificationType] ?? "text-[var(--tertiary)]";
              return (
                <DropdownMenuItem
                  key={n.id}
                  onSelect={(event) => {
                    event.preventDefault();
                    if (!n.read) {
                      void handleMarkRead(n.id);
                    }
                  }}
                  className={cn(
                    "flex items-start gap-3 rounded-none px-4 py-3",
                    !n.read && "bg-[var(--primary)]/8",
                  )}
                >
                  <Icon className={cn("mt-0.5 h-4 w-4 shrink-0", tone)} />
                  <div className="min-w-0 flex-1">
                    <div className="flex items-start justify-between gap-2">
                      <p className="truncate text-sm font-semibold text-white">
                        {n.title}
                      </p>
                      {!n.read ? (
                        <span
                          className="mt-1 h-2 w-2 shrink-0 rounded-full bg-rose-400"
                          aria-label="Unread"
                        />
                      ) : null}
                    </div>
                    {n.body ? (
                      <p className="mt-0.5 line-clamp-2 text-xs text-[var(--text-muted)]">
                        {n.body}
                      </p>
                    ) : null}
                    <p className="mt-1 text-[10px] uppercase tracking-[0.08em] text-[var(--text-muted)]">
                      {formatRelative(n.createdAt)}
                    </p>
                  </div>
                </DropdownMenuItem>
              );
            })
          )}
        </ScrollArea>
        {items.length > 0 ? (
          <>
            <DropdownMenuSeparator className="my-0" />
            <div className="flex items-center justify-between px-4 py-2 text-[11px] text-[var(--text-muted)]">
              <span>Showing latest {items.length}</span>
              <button
                type="button"
                onClick={() => void refresh()}
                className="inline-flex items-center gap-1 font-semibold text-[var(--primary)] transition hover:text-white"
              >
                <X className="h-3 w-3" /> Refresh
              </button>
            </div>
          </>
        ) : null}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
