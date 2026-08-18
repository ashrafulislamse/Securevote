// Zod validation schemas for all API request bodies.

import { z } from "zod";

export const emailSchema = z
  .string()
  .email("invalid email")
  .max(254);

export const passwordSchema = z
  .string()
  .min(8, "password must be at least 8 characters")
  .max(128)
  .regex(/[a-z]/, "password must contain a lowercase letter")
  .regex(/[A-Z]/, "password must contain an uppercase letter")
  .regex(/[0-9]/, "password must contain a digit");

export const registerSchema = z.object({
  email: emailSchema,
  password: passwordSchema,
  fullName: z.string().min(2, "full name required").max(120),
  phone: z.string().max(30).optional(),
});

export const verifyOtpSchema = z.object({
  email: emailSchema,
  otp: z.string().regex(/^\d{6}$/, "otp must be 6 digits"),
});

export const loginSchema = z.object({
  email: emailSchema,
  password: z.string().min(1, "password required"),
});

export const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

export const changePasswordSchema = z.object({
  currentPassword: z.string().min(1),
  newPassword: passwordSchema,
});

export const roleSchema = z.enum(["voter", "admin", "verifier"]);

export const updateProfileSchema = z.object({
  fullName: z.string().min(2).max(120).optional(),
  phone: z.string().max(30).nullable().optional(),
});

const electionFields = {
  title: z.string().min(3).max(200),
  description: z.string().max(2000).optional(),
  organization: z.string().max(200).optional(),
  type: z.enum(["single", "multi", "ranked"]).default("single"),
  startsAt: z.number().int().positive(),
  endsAt: z.number().int().positive(),
};

export const createElectionSchema = z
  .object(electionFields)
  .refine((d) => d.endsAt > d.startsAt, {
    message: "endsAt must be after startsAt",
    path: ["endsAt"],
  });

export const updateElectionSchema = z.object(electionFields).partial();

export const createCandidateSchema = z.object({
  name: z.string().min(1).max(200),
  party: z.string().max(200).optional(),
  bio: z.string().max(2000).optional(),
  manifesto: z.string().max(4000).optional(),
  ballotOrder: z.number().int().min(0).optional(),
});

export const updateCandidateSchema = z
  .object({
    name: z.string().min(1).max(200).optional(),
    party: z.string().max(200).nullable().optional(),
    bio: z.string().max(2000).nullable().optional(),
    manifesto: z.string().max(4000).nullable().optional(),
    ballotOrder: z.number().int().min(0).optional(),
    visible: z.boolean().optional(),
    verified: z.boolean().optional(),
  })
  .refine((d) => Object.keys(d).length > 0, {
    message: "at least one field required",
  });

export const castVoteSchema = z.object({
  electionId: z.string().min(1),
  selections: z
    .array(
      z.object({
        blockId: z.string().min(1),
        candidateId: z.string().min(1),
      }),
    )
    .min(1, "at least one selection required"),
});

export const kycSubmitSchema = z.object({
  docType: z.enum(["id", "selfie"]).default("id"),
  // The actual document is uploaded as binary via form-data; this is metadata.
  fileName: z.string().max(255).optional(),
});

export const kycReviewSchema = z.object({
  decision: z.enum(["approve", "reject"]),
  note: z.string().max(500).optional(),
});

export const importVotersSchema = z.object({
  voters: z
    .array(
      z.object({
        email: emailSchema,
        fullName: z.string().min(1).max(200),
        phone: z.string().max(50).optional(),
      }),
    )
    .min(1, "at least one voter required")
    .max(1000, "max 1000 voters per import"),
});

export const updateVoterSchema = z
  .object({
    fullName: z.string().min(1).max(200).optional(),
    phone: z.string().max(50).nullable().optional(),
    status: z.enum(["active", "suspended"]).optional(),
    notes: z.string().max(2000).nullable().optional(),
  })
  .refine((d) => Object.keys(d).length > 0, {
    message: "at least one field required",
  });

export const publishResultsSchema = z.object({
  channels: z.array(z.enum(["portal", "email", "apiWebhook"])).optional(),
});

// Election publish: visibility + distribution channels (set on status -> published)
export const publishElectionSchema = z.object({
  visibility: z.enum(["public", "participants", "internal"]).optional(),
  channels: z.array(z.enum(["portal", "email", "apiWebhook"])).optional(),
});

// Ballot blocks CRUD
export const createBallotBlockSchema = z.object({
  title: z.string().min(1).max(200),
  kind: z.enum(["position", "yesNo", "info"]).default("position"),
  orderIndex: z.number().int().min(0).optional(),
});

export const updateBallotBlockSchema = z
  .object({
    title: z.string().min(1).max(200).optional(),
    kind: z.enum(["position", "yesNo", "info"]).optional(),
    orderIndex: z.number().int().min(0).optional(),
  })
  .refine((d) => Object.keys(d).length > 0, {
    message: "at least one field required",
  });

// Organizations CRUD
export const createOrganizationSchema = z.object({
  name: z.string().min(1).max(200),
  plan: z.enum(["Starter", "Professional", "Enterprise"]).default("Professional"),
  members: z.number().int().min(0).optional(),
  status: z.enum(["active", "paused"]).default("active"),
});

export const updateOrganizationSchema = z
  .object({
    name: z.string().min(1).max(200).optional(),
    plan: z.enum(["Starter", "Professional", "Enterprise"]).optional(),
    members: z.number().int().min(0).optional(),
    status: z.enum(["active", "paused"]).optional(),
  })
  .refine((d) => Object.keys(d).length > 0, {
    message: "at least one field required",
  });

// Anomaly / fraud alerts
export const createAlertSchema = z.object({
  type: z.string().min(1).max(80),
  severity: z.enum(["low", "medium", "high", "critical"]).default("medium"),
  target: z.string().max(200).optional(),
  title: z.string().min(1).max(200),
  body: z.string().max(2000).optional(),
  metadata: z.record(z.unknown()).optional(),
});

export const resolveAlertSchema = z.object({
  status: z.enum(["open", "investigating", "resolved"]),
  assignedTo: z.string().max(200).optional(),
});

// Bulk voter status update
export const bulkVoterStatusSchema = z.object({
  ids: z.array(z.string().min(1)).min(1, "at least one voter id required").max(500),
  kycStatus: z.enum(["pending", "approved", "rejected"]),
});

// Notify selected voters (in-app notification)
export const notifyVotersSchema = z.object({
  ids: z.array(z.string().min(1)).min(1, "at least one voter id required").max(500),
  title: z.string().min(1).max(200),
  body: z.string().max(2000).optional(),
});

// AI assistant
export const askAssistantSchema = z.object({
  prompt: z.string().min(1).max(2000),
  model: z.string().max(100).optional(),
});

export const forgotPasswordSchema = z.object({
  email: emailSchema,
});

export const resetPasswordSchema = z.object({
  token: z.string().min(1).max(200),
  newPassword: passwordSchema,
});

export const resendOtpSchema = z.object({
  email: emailSchema,
});