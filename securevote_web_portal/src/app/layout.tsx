import type { Metadata } from "next";
import "./globals.css";

import { AuthProvider } from "@/context/auth-context";

export const metadata: Metadata = {
  title: "SecureVote Web Portal",
  description: "SecureVote admin, verifier, and public web experience.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="h-full antialiased" data-theme="dark" suppressHydrationWarning>
      <body className="min-h-full flex flex-col bg-background text-foreground">
        <AuthProvider>{children}</AuthProvider>
      </body>
    </html>
  );
}
