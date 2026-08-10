/// <reference types="@opennextjs/cloudflare" />

interface Env {
  NEXT_PUBLIC_API_URL: string;
}

declare global {
  type CloudflareEnv = Env;
}

export {};
