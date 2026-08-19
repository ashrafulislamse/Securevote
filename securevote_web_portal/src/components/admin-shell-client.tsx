"use client";

import Link from "next/link";
import { ReactNode, useEffect, useMemo, useState } from "react";
import { usePathname, useRouter } from "next/navigation";
import {
  CheckCircle2,
  ChevronDown,
  Bot,
  Building2,
  PanelLeftClose,
  PanelLeftOpen,
  ClipboardList,
  FileWarning,
  Gauge,
  History,
  LayoutDashboard,
  ListChecks,
  LogOut,
  Menu,
  Monitor,
  ShieldCheck,
  SlidersHorizontal,
  Upload,
  UserCircle2,
  Users,
  Vote,
  WalletCards,
} from "lucide-react";

import { useAuth } from "@/context/auth-context";
import { cn } from "@/lib/utils";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
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
import { NotificationBell } from "@/components/notification-bell";
import { Separator } from "@/components/ui/separator";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { ThemeToggle } from "@/components/theme-toggle";

type NavItem = {
  href: string;
  label: string;
  match: string[];
  icon: React.ComponentType<{ className?: string }>;
  legacyActive?: "dashboard" | "elections" | "voters";
};

type NavSection = {
  title: string;
  items: NavItem[];
};

const navSections: NavSection[] = [
  {
    title: "Core",
    items: [
      {
        href: "/admin/dashboard",
        label: "Dashboard",
        match: ["/admin/dashboard"],
        icon: LayoutDashboard,
        legacyActive: "dashboard",
      },
      {
        href: "/admin/organizations",
        label: "Organizations",
        match: ["/admin/organizations"],
        icon: Building2,
      },
      {
        href: "/admin/ai-assistant",
        label: "AI Assistant",
        match: ["/admin/ai-assistant"],
        icon: Bot,
      },
    ],
  },
  {
    title: "Elections",
    items: [
      {
        href: "/admin/elections",
        label: "Election List",
        match: ["/admin/elections"],
        icon: Vote,
        legacyActive: "elections",
      },
      {
        href: "/admin/elections/overview",
        label: "Election Overview",
        match: ["/admin/elections/overview"],
        icon: Gauge,
      },
      {
        href: "/admin/elections/create/basic-info",
        label: "Election Builder",
        match: [
          "/admin/elections/create/basic-info",
          "/admin/elections/create/schedule",
          "/admin/elections/create/eligibility",
        ],
        icon: SlidersHorizontal,
      },
      {
        href: "/admin/elections/create/review",
        label: "Review and Publish",
        match: ["/admin/elections/create/review"],
        icon: ClipboardList,
      },
      {
        href: "/admin/elections/candidates",
        label: "Candidates",
        match: ["/admin/elections/candidates"],
        icon: Users,
      },
      {
        href: "/admin/elections/ballot-builder",
        label: "Ballot Builder",
        match: ["/admin/elections/ballot-builder"],
        icon: ListChecks,
      },
    ],
  },
  {
    title: "Security",
    items: [
      {
        href: "/admin/live-monitoring",
        label: "Live Monitoring",
        match: ["/admin/live-monitoring"],
        icon: Monitor,
      },
      {
        href: "/admin/anomaly-fraud-alerts",
        label: "Fraud Alerts",
        match: ["/admin/anomaly-fraud-alerts"],
        icon: FileWarning,
      },
      {
        href: "/admin/audit-log",
        label: "Audit Log",
        match: ["/admin/audit-log"],
        icon: History,
      },
      {
        href: "/admin/results/dashboard",
        label: "Results Dashboard",
        match: ["/admin/results/dashboard"],
        icon: Gauge,
      },
      {
        href: "/admin/results/publish",
        label: "Publish Results",
        match: ["/admin/results/publish"],
        icon: WalletCards,
      },
    ],
  },
  {
    title: "Voters",
    items: [
      {
        href: "/admin/voters",
        label: "Voter List",
        match: ["/admin/voters"],
        icon: Users,
        legacyActive: "voters",
      },
      {
        href: "/admin/voters/kyc-verification",
        label: "KYC Verification",
        match: ["/admin/voters/kyc-verification"],
        icon: ShieldCheck,
      },
      {
        href: "/admin/voters/import",
        label: "Import Voters",
        match: ["/admin/voters/import"],
        icon: Upload,
      },
      {
        href: "/admin/voters/profile",
        label: "Voter Profile",
        match: ["/admin/voters/profile"],
        icon: UserCircle2,
      },
    ],
  },
];

function NavContent({
  isCollapsed,
  activeHref,
  onNavigate,
}: {
  isCollapsed: boolean;
  activeHref: string;
  onNavigate?: () => void;
}) {
  const allItems = navSections.flatMap((section) => section.items);

  if (isCollapsed) {
    return (
      <div className="space-y-1.5 px-1 py-1">
        {allItems.map((item) => {
          const Icon = item.icon;
          const isActive = item.href === activeHref;
          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={onNavigate}
              title={item.label}
              className={cn(
                "mx-auto flex h-10 w-10 items-center justify-center rounded-lg transition",
                isActive ? "bg-[var(--primary)]/20 text-[var(--primary)]" : "text-[var(--text-muted)] hover:bg-[var(--surface-container-high)] hover:text-[var(--text-primary)]",
              )}
            >
              <Icon className="h-4.5 w-4.5" />
            </Link>
          );
        })}
      </div>
    );
  }

  return (
    <div className="space-y-5 px-1 py-1">
      {navSections.map((section) => (
        <div key={section.title}>
          <p className="px-2 pb-2 text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">{section.title}</p>
          <div className="space-y-1">
            {section.items.map((item) => {
              const Icon = item.icon;
              const isActive = item.href === activeHref;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={onNavigate}
                  className={cn(
                    "flex items-center gap-2.5 rounded-lg px-3 py-2.5 text-[13px] font-semibold transition",
                    isActive
                      ? "bg-[var(--primary)]/18 text-[var(--primary)]"
                      : "text-[var(--text-muted)] hover:bg-[var(--surface-container-high)] hover:text-[var(--text-primary)]",
                  )}
                >
                  <Icon className="h-4.5 w-4.5" />
                  <span className="truncate">{item.label}</span>
                </Link>
              );
            })}
          </div>
        </div>
      ))}
    </div>
  );
}

export function AdminShellClient({
  children,
  active = "dashboard",
}: {
  children: ReactNode;
  active?: "dashboard" | "elections" | "voters";
}) {
  const router = useRouter();
  const pathname = usePathname();
  const { user, loading: authLoading, logout } = useAuth();
  const [collapsed, setCollapsed] = useState(false);

  const allNavItems = useMemo(() => navSections.flatMap((section) => section.items), []);

  const activeHref = useMemo(() => {
    let bestHref = "";
    let bestMatchLength = -1;

    allNavItems.forEach((item) => {
      item.match.forEach((prefix) => {
        const matched = pathname === prefix || pathname.startsWith(`${prefix}/`);
        if (matched && prefix.length > bestMatchLength) {
          bestMatchLength = prefix.length;
          bestHref = item.href;
        }
      });
    });

    if (!bestHref) {
      const fallback = allNavItems.find((item) => item.legacyActive === active);
      return fallback?.href ?? "/admin/dashboard";
    }

    return bestHref;
  }, [active, allNavItems, pathname]);

  const pageLabel = useMemo(() => {
    const item = allNavItems.find((entry) => entry.href === activeHref);
    return item?.label ?? "Dashboard";
  }, [activeHref, allNavItems]);

  useEffect(() => {
    if (authLoading) {
      return;
    }

    if (!user) {
      router.replace("/admin/login");
    }
  }, [authLoading, user, router]);

  const handleSignOut = () => {
    logout();
    router.replace("/admin/login");
  };

  const currentYear = new Date().getFullYear();

  if (authLoading || !user) {
    return (
      <div className="grid min-h-screen place-items-center bg-background text-foreground">
        <div className="text-center">
          <p className="text-sm uppercase tracking-[0.14em] text-[var(--text-muted)]">Authorizing</p>
          <p className="mt-2 text-2xl font-bold">SecureVote Admin</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background text-foreground">
      <aside
        className={cn(
          "fixed inset-y-0 left-0 z-30 hidden border-r border-[var(--border-default)] bg-[var(--surface-container-low)] lg:flex lg:flex-col",
          collapsed ? "w-16 px-2 py-3" : "w-60 px-3 py-4",
        )}
      >
        <div className={cn("mb-3 flex items-center", collapsed ? "justify-center" : "justify-between px-1")}>
          {collapsed ? (
            <div className="flex h-8 w-8 items-center justify-center rounded-md bg-[var(--surface-container-high)]">
              <ShieldCheck className="h-4.5 w-4.5 text-[var(--tertiary)]" />
            </div>
          ) : (
            <div>
              <p className="text-xl font-bold tracking-tight text-[var(--text-primary)]">SecureVote</p>
              <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Admin Console</p>
            </div>
          )}
          <Button variant="ghost" size="icon" onClick={() => setCollapsed((v) => !v)} aria-label="Toggle sidebar">
            {collapsed ? <PanelLeftOpen className="h-4 w-4" /> : <PanelLeftClose className="h-4 w-4" />}
          </Button>
        </div>

        <Separator className="mb-2" />

        <ScrollArea className="flex-1 pr-1">
          <NavContent isCollapsed={collapsed} activeHref={activeHref} />
        </ScrollArea>

        <Separator className="mt-2" />

        <div className={cn("pt-2", collapsed ? "px-0" : "px-1")}> 
          {collapsed ? (
            <div className="flex flex-col items-center gap-2">
              <Avatar>
                <AvatarFallback>
                  <UserCircle2 className="h-4.5 w-4.5" />
                </AvatarFallback>
              </Avatar>
              <Button variant="outline" size="icon" onClick={handleSignOut} aria-label="Sign out">
                <LogOut className="h-4 w-4" />
              </Button>
            </div>
          ) : (
            <div className="flex items-center justify-between gap-2">
              <div className="flex min-w-0 items-center gap-2">
                <Avatar>
                  <AvatarFallback>
                    <UserCircle2 className="h-4.5 w-4.5" />
                  </AvatarFallback>
                </Avatar>
                <div className="min-w-0">
                  <p className="truncate text-sm font-semibold">{user.fullName}</p>
                  <p className="truncate text-[11px] text-[var(--tertiary)]">{user.role}</p>
                </div>
              </div>
              <Button variant="outline" size="icon" onClick={handleSignOut} aria-label="Sign out">
                <LogOut className="h-4 w-4" />
              </Button>
            </div>
          )}
        </div>
      </aside>

      <main className={cn("min-h-screen transition-all duration-300", collapsed ? "lg:ml-16" : "lg:ml-60")}>
        <header className="sticky top-0 z-20 border-b border-[var(--border-default)] bg-[var(--surface-glass)] px-4 py-2 backdrop-blur-xl md:px-6 lg:px-8">
          <div className="flex min-h-[3.75rem] items-center justify-between gap-3">
            <div className="flex min-w-0 items-center gap-2.5">
              <Sheet>
                <SheetTrigger asChild>
                  <Button variant="outline" size="icon" className="lg:hidden" aria-label="Open navigation">
                    <Menu className="h-4 w-4" />
                  </Button>
                </SheetTrigger>
                <SheetContent>
                  <div className="mb-3">
                    <p className="text-lg font-bold text-[var(--text-primary)]">SecureVote</p>
                    <p className="text-[11px] font-bold uppercase tracking-[0.14em] text-[var(--text-muted)]">Admin Console</p>
                  </div>
                  <Separator className="mb-2" />
                  <ScrollArea className="h-[calc(100vh-11rem)] pr-1">
                    <NavContent isCollapsed={false} activeHref={activeHref} />
                  </ScrollArea>
                </SheetContent>
              </Sheet>

              <div className="min-w-0">
                <p className="truncate text-xs font-bold uppercase tracking-[0.14em] text-[var(--tertiary)]">{pageLabel}</p>
                <p className="truncate text-xs text-[var(--text-muted)]">{user.email}</p>
              </div>
              <Badge className="hidden md:inline-flex">Live</Badge>
            </div>

            <div className="flex items-center gap-2">
              <ThemeToggle />
              <NotificationBell />

              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <button
                    type="button"
                    className="flex items-center gap-2 rounded-md border border-[var(--border-default)] bg-[var(--surface-container-high)] px-2 py-1.5 text-left transition hover:bg-[var(--surface-container-highest)]"
                    aria-label="Open profile menu"
                  >
                    <Avatar className="h-7 w-7">
                      <AvatarFallback>
                        <UserCircle2 className="h-4.5 w-4.5" />
                      </AvatarFallback>
                    </Avatar>
                    <span className="hidden max-w-[120px] truncate text-xs font-semibold lg:block">{user.fullName}</span>
                    <ChevronDown className="h-3.5 w-3.5 text-[var(--text-muted)]" />
                  </button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" className="w-56">
                  <DropdownMenuLabel>
                    <p className="font-semibold text-[var(--foreground)]">{user.fullName}</p>
                    <p className="mt-1 text-[11px] font-medium tracking-[0.06em] text-[var(--text-muted)]">{user.role}</p>
                  </DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem onSelect={() => router.push("/admin/dashboard")}>Dashboard</DropdownMenuItem>
                  <DropdownMenuItem onSelect={() => router.push("/admin/organizations")}>Organization Settings</DropdownMenuItem>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem onSelect={handleSignOut}>
                    <LogOut className="mr-2 h-4 w-4" />
                    Sign Out
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </div>
          </div>
        </header>

        <div className="p-4 md:p-6 lg:p-8">{children}</div>

        <footer className="border-t border-[var(--border-default)] bg-[var(--surface-glass)] px-4 py-4 md:px-6 lg:px-8">
          <div className="flex flex-col gap-2 text-xs text-[var(--text-muted)] sm:flex-row sm:items-center sm:justify-between">
            <p>SecureVote Admin Platform © {currentYear}</p>
            <div className="flex items-center gap-4">
              <Link href="/admin/audit-log" className="transition hover:text-[var(--text-primary)]">
                Audit Trail
              </Link>
              <Link href="/verifier" className="transition hover:text-[var(--text-primary)]">
                Public Verification
              </Link>
              <Link href="/" className="transition hover:text-[var(--text-primary)]">
                Main Site
              </Link>
            </div>
          </div>
        </footer>
      </main>
    </div>
  );
}
