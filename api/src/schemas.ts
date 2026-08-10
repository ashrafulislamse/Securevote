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
  url: z.string().url(), // presigned R2 URL of the CSV
});

export const publishResultsSchema = z.object({
  channels: z.array(z.enum(["portal", "email", "apiWebhook"])).optional(),
});