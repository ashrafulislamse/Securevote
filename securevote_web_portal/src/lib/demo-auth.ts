export type DemoSession = {
  email: string;
  name: string;
  role: string;
  org: string;
  issuedAt: number;
};

const SESSION_KEY = "securevote_demo_session";
const RESET_REQUEST_KEY = "securevote_demo_reset_request";

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

export function signInDemo(input: { email: string; password: string; otp: string }): { ok: boolean; message: string } {
  const email = input.email.trim().toLowerCase();
  const otp = input.otp.trim();

  if (email !== DEMO_USER.email) {
    return { ok: false, message: "Admin email not recognized." };
  }

  if (input.password !== DEMO_USER.password) {
    return { ok: false, message: "Incorrect password." };
  }

  if (otp !== DEMO_USER.otp) {
    return { ok: false, message: "Invalid 2FA code." };
  }

  const session: DemoSession = {
    email: DEMO_USER.email,
    name: DEMO_USER.name,
    role: DEMO_USER.role,
    org: DEMO_USER.org,
    issuedAt: Date.now(),
  };

  if (typeof window !== "undefined") {
    window.localStorage.setItem(SESSION_KEY, JSON.stringify(session));
  }

  return { ok: true, message: "Authenticated." };
}

export function getSession(): DemoSession | null {
  if (typeof window === "undefined") {
    return null;
  }

  const raw = window.localStorage.getItem(SESSION_KEY);
  if (!raw) {
    return null;
  }

  try {
    return JSON.parse(raw) as DemoSession;
  } catch {
    return null;
  }
}

export function signOutDemo() {
  if (typeof window !== "undefined") {
    window.localStorage.removeItem(SESSION_KEY);
  }
}

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
