// CORS configuration — locked to known origins in production.
// Allows the Next.js portal + Flutter web builds.

const ALLOWED_ORIGINS = [
  "http://localhost:3000",
  "http://localhost:5173",
  "http://localhost:8080",
  "https://securevote.pages.dev",
  "https://securevote-web.vercel.app",
  "https://securevote-web.founder-fb4.workers.dev",
  "https://securevote-api.founder-fb4.workers.dev",
];

export function corsHeaders(origin: string | null): Record<string, string> {
  const allowed = origin && ALLOWED_ORIGINS.includes(origin) ? origin : "";
  return {
    "Access-Control-Allow-Origin": allowed || ALLOWED_ORIGINS[0]!,
    "Access-Control-Allow-Methods": "GET,POST,PATCH,PUT,DELETE,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Access-Control-Max-Age": "86400",
    "Vary": "Origin",
  };
}