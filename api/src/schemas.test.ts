import { describe, it, expect } from "vitest";
import {
  updateCandidateSchema,
  publishElectionSchema,
  createBallotBlockSchema,
  updateBallotBlockSchema,
  createOrganizationSchema,
  updateOrganizationSchema,
  createAlertSchema,
  resolveAlertSchema,
  bulkVoterStatusSchema,
  notifyVotersSchema,
  askAssistantSchema,
} from "./schemas";

describe("updateCandidateSchema", () => {
  it("accepts a single visible flag", () => {
    const r = updateCandidateSchema.safeParse({ visible: false });
    expect(r.success).toBe(true);
  });

  it("accepts verified + visible together", () => {
    const r = updateCandidateSchema.safeParse({ verified: true, visible: true });
    expect(r.success).toBe(true);
  });

  it("rejects an empty object (at least one field required)", () => {
    const r = updateCandidateSchema.safeParse({});
    expect(r.success).toBe(false);
  });

  it("rejects an empty name string", () => {
    const r = updateCandidateSchema.safeParse({ name: "" });
    expect(r.success).toBe(false);
  });
});

describe("publishElectionSchema", () => {
  it("accepts visibility + channels", () => {
    const r = publishElectionSchema.safeParse({
      visibility: "public",
      channels: ["portal", "email"],
    });
    expect(r.success).toBe(true);
  });

  it("accepts an empty object (everything optional)", () => {
    const r = publishElectionSchema.safeParse({});
    expect(r.success).toBe(true);
  });

  it("rejects an invalid visibility value", () => {
    const r = publishElectionSchema.safeParse({ visibility: "secret" });
    expect(r.success).toBe(false);
  });
});

describe("createBallotBlockSchema", () => {
  it("defaults kind to 'position' when omitted", () => {
    const r = createBallotBlockSchema.parse({ title: "President" });
    expect(r.kind).toBe("position");
  });

  it("accepts all three kinds", () => {
    for (const kind of ["position", "yesNo", "info"] as const) {
      const r = createBallotBlockSchema.safeParse({ title: "Block", kind });
      expect(r.success).toBe(true);
    }
  });

  it("rejects an empty title", () => {
    const r = createBallotBlockSchema.safeParse({ title: "" });
    expect(r.success).toBe(false);
  });
});

describe("updateBallotBlockSchema", () => {
  it("rejects an empty object", () => {
    const r = updateBallotBlockSchema.safeParse({});
    expect(r.success).toBe(false);
  });

  it("accepts orderIndex only", () => {
    const r = updateBallotBlockSchema.safeParse({ orderIndex: 5 });
    expect(r.success).toBe(true);
  });
});

describe("createOrganizationSchema", () => {
  it("defaults plan to Professional and status to active", () => {
    const r = createOrganizationSchema.parse({ name: "Acme Corp" });
    expect(r.plan).toBe("Professional");
    expect(r.status).toBe("active");
  });

  it("rejects an empty name", () => {
    const r = createOrganizationSchema.safeParse({ name: "" });
    expect(r.success).toBe(false);
  });
});

describe("updateOrganizationSchema", () => {
  it("rejects an empty object", () => {
    const r = updateOrganizationSchema.safeParse({});
    expect(r.success).toBe(false);
  });

  it("accepts members count", () => {
    const r = updateOrganizationSchema.safeParse({ members: 10 });
    expect(r.success).toBe(true);
  });
});

describe("createAlertSchema", () => {
  it("accepts type + title + severity", () => {
    const r = createAlertSchema.safeParse({
      type: "turnout_anomaly",
      title: "Unusual vote spike",
      severity: "high",
    });
    expect(r.success).toBe(true);
  });

  it("defaults severity to medium", () => {
    const r = createAlertSchema.parse({ type: "test", title: "Test alert" });
    expect(r.severity).toBe("medium");
  });

  it("rejects missing title", () => {
    const r = createAlertSchema.safeParse({ type: "test" });
    expect(r.success).toBe(false);
  });
});

describe("resolveAlertSchema", () => {
  it("accepts status = resolved", () => {
    const r = resolveAlertSchema.safeParse({ status: "resolved" });
    expect(r.success).toBe(true);
  });

  it("accepts status = investigating + assignedTo", () => {
    const r = resolveAlertSchema.safeParse({
      status: "investigating",
      assignedTo: "analyst-1",
    });
    expect(r.success).toBe(true);
  });

  it("rejects an invalid status", () => {
    const r = resolveAlertSchema.safeParse({ status: "closed" });
    expect(r.success).toBe(false);
  });
});

describe("bulkVoterStatusSchema", () => {
  it("accepts a valid ids array + kycStatus", () => {
    const r = bulkVoterStatusSchema.safeParse({
      ids: ["u-1", "u-2"],
      kycStatus: "approved",
    });
    expect(r.success).toBe(true);
  });

  it("rejects an empty ids array", () => {
    const r = bulkVoterStatusSchema.safeParse({ ids: [], kycStatus: "approved" });
    expect(r.success).toBe(false);
  });

  it("rejects more than 500 ids", () => {
    const ids = Array.from({ length: 501 }, (_, i) => `u-${i}`);
    const r = bulkVoterStatusSchema.safeParse({ ids, kycStatus: "approved" });
    expect(r.success).toBe(false);
  });

  it("rejects an invalid kycStatus", () => {
    const r = bulkVoterStatusSchema.safeParse({
      ids: ["u-1"],
      kycStatus: "pending_review",
    });
    expect(r.success).toBe(false);
  });
});

describe("notifyVotersSchema", () => {
  it("accepts ids + title + body", () => {
    const r = notifyVotersSchema.safeParse({
      ids: ["u-1"],
      title: "Election opens soon",
      body: "Voting begins at 8 AM.",
    });
    expect(r.success).toBe(true);
  });

  it("rejects an empty title", () => {
    const r = notifyVotersSchema.safeParse({ ids: ["u-1"], title: "" });
    expect(r.success).toBe(false);
  });
});

describe("askAssistantSchema", () => {
  it("accepts a prompt + optional model", () => {
    const r = askAssistantSchema.safeParse({
      prompt: "Summarize turnout anomalies",
      model: "@cf/meta/llama-3.1-8b-instruct",
    });
    expect(r.success).toBe(true);
  });

  it("accepts a prompt without model", () => {
    const r = askAssistantSchema.parse({ prompt: "Hello" });
    expect(r.model).toBeUndefined();
  });

  it("rejects an empty prompt", () => {
    const r = askAssistantSchema.safeParse({ prompt: "" });
    expect(r.success).toBe(false);
  });
});
