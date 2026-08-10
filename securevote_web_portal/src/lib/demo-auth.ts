// Compatibility shim for the demo admin flow.
//
// Authentication now routes through the real backend API via `@/context/auth-context`
// (`useAuth()`). The login page and admin shell no longer use this module.
//
// These helpers are retained so the forgot/reset password demo pages continue to work:
//   - src/app/admin/forgot-password/page.tsx  -> requestReset
//   - src/app/admin/reset-password/page.tsx   -> completeReset
//
// Demo operator credentials (must exist in the backend for login to succeed):
//   email:    admin@securevote.io
//   password  SecureVote@2026
//   2FA / OTP: 492000  (login uses email + password only; the OTP field is disabled)

const DEMO_USER = {
  email: "admin@securevote.io",
  password: "SecureVote@2026",
  otp: "492000",
  name: "Alex Sterling",
  role: "Super Admin",
  org: "City University Malaysia",
};

export function demoCredentials() {
  return {
    email: DEMO_USER.email,
    password: DEMO_USER.password,
    otp: DEMO_USER.otp,
  };
}

export function demoUser() {
  return {
    email: DEMO_USER.email,
    name: DEMO_USER.name,
    role: DEMO_USER.role,
    org: DEMO_USER.org,
  };
}

const RESET_REQUEST_KEY = "securevote_demo_reset_request";

export function requestReset(email: string): { ok: boolean; message: string } {
  const cleanEmail = email.trim().toLowerCase();
  if (!cleanEmail.includes("@")) {
    return { ok: false, message: "Enter a valid admin email." };
  }

  if (typeof window !== "undefined") {
    window.localStorage.setItem(
      RESET_REQUEST_KEY,
      JSON.stringify({
        email: cleanEmail,
        requestedAt: Date.now(),
      }),
    );
  }

  return { ok: true, message: "Reset link issued (demo)." };
}

export function completeReset(password: string, confirmPassword: string): { ok: boolean; message: string } {
  if (password.length < 10) {
    return { ok: false, message: "Password must be at least 10 characters." };
  }

  if (password !== confirmPassword) {
    return { ok: false, message: "Passwords do not match." };
  }

  return { ok: true, message: "Password updated in demo mode." };
}