"use client";

import { FormEvent, useRef, useState } from "react";
import { AdminShell } from "@/components/admin-shell";
import { askAssistant } from "@/lib/api-client";

type Message = {
  id: string;
  role: "assistant" | "user";
  text: string;
};

const suggestedPrompts = [
  "Summarize current election risk posture",
  "Compare turnout anomalies by district",
  "Draft incident response for suspicious vote spike",
  "Predict final turnout by 8 PM",
];

const MODEL_OPTIONS = [
  { label: "Llama 3.1 8B Instruct", value: "@cf/meta/llama-3.1-8b-instruct" },
  { label: "Llama 3.3 70B Instruct", value: "@cf/meta/llama-3.3-70b-instruct-fp8-fast" },
  { label: "Mistral 7B Instruct", value: "@cf/mistral/mistral-7b-instruct-v0.2" },
];

export default function AiAssistantPage() {
  const [input, setInput] = useState("");
  const [messages, setMessages] = useState<Message[]>([
    {
      id: "m-1",
      role: "assistant",
      text: "AI assistant online. Ask for anomaly summaries, turnout forecasts, or audit drafting. Responses are grounded in live dashboard data.",
    },
  ]);
  const [model, setModel] = useState(MODEL_OPTIONS[0].value);
  const [sending, setSending] = useState(false);
  const idCounter = useRef(2);

  const send = async (text: string) => {
    if (!text.trim() || sending) return;

    idCounter.current += 1;
    const userMessage: Message = {
      id: `u-${idCounter.current}`,
      role: "user",
      text,
    };

    setMessages((prev) => [...prev, userMessage]);
    setInput("");
    setSending(true);

    try {
      const result = await askAssistant(text, model);
      idCounter.current += 1;
      const assistantMessage: Message = {
        id: `a-${idCounter.current}`,
        role: "assistant",
        text: result.reply,
      };
      setMessages((prev) => [...prev, assistantMessage]);
    } catch {
      idCounter.current += 1;
      const assistantMessage: Message = {
        id: `a-${idCounter.current}`,
        role: "assistant",
        text: "Could not reach the AI assistant backend. Please try again in a moment.",
      };
      setMessages((prev) => [...prev, assistantMessage]);
    } finally {
      setSending(false);
    }
  };

  const onSubmit = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    void send(input);
  };

  return (
    <AdminShell active="elections">
      <section className="mx-auto max-w-6xl space-y-6">
        <div className="flex flex-wrap items-end justify-between gap-4">
          <div>
            <p className="text-xs text-[var(--text-muted)]">Operations / AI Intelligence</p>
            <h1 className="mt-2 text-3xl font-bold tracking-tight">Smart AI Assistant</h1>
            <p className="mt-1 text-sm text-[var(--text-muted)]">Ask for live operational insights, incident summaries, and strategy recommendations.</p>
          </div>
          <div className="flex items-center gap-3 rounded-lg bg-[var(--surface-container)] px-3 py-2 text-xs">
            <span className="h-2 w-2 rounded-full bg-emerald-400" />
            <select value={model} onChange={(event) => setModel(event.target.value)} className="bg-transparent font-semibold">
              {MODEL_OPTIONS.map((option) => (
                <option key={option.value} value={option.value}>{option.label}</option>
              ))}
            </select>
          </div>
        </div>

        <div className="grid gap-5 lg:grid-cols-[0.75fr,1.25fr]">
          <aside className="space-y-4 rounded-xl bg-[var(--surface-container)] p-5">
            <p className="text-[11px] uppercase tracking-[0.09em] text-[var(--text-muted)]">Prompt Library</p>
            <div className="space-y-2">
              {suggestedPrompts.map((prompt) => (
                <button
                  type="button"
                  key={prompt}
                  onClick={() => void send(prompt)}
                  className="w-full rounded-lg bg-[var(--surface-container-low)] px-3 py-3 text-left text-sm transition hover:bg-[var(--surface-container-high)]"
                >
                  {prompt}
                </button>
              ))}
            </div>
            <div className="rounded-lg border border-white/8 bg-[var(--surface-container-low)] p-3 text-xs text-[var(--text-muted)]">
              Responses are grounded in live dashboard data via Workers AI.
            </div>
          </aside>

          <article className="flex min-h-[560px] flex-col rounded-xl bg-[var(--surface-container)] p-5">
            <div className="mb-4 flex items-center justify-between">
              <p className="text-[11px] uppercase tracking-[0.09em] text-[var(--text-muted)]">Conversation</p>
              <span className="rounded-full bg-[var(--surface-container-low)] px-3 py-1 text-[10px] uppercase tracking-[0.08em] text-[var(--text-muted)]">{model}</span>
            </div>

            <div className="flex-1 space-y-3 overflow-y-auto rounded-lg bg-[var(--surface-container-low)] p-4">
              {messages.map((message) => (
                <div key={message.id} className={`max-w-[88%] rounded-lg px-3 py-2 text-sm ${message.role === "assistant" ? "bg-[var(--surface-container-high)]" : "ml-auto bg-[var(--primary)]/20"}`}>
                  <p className="text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--text-muted)]">{message.role}</p>
                  <p className="mt-1 whitespace-pre-line leading-relaxed">{message.text}</p>
                </div>
              ))}
              {sending ? (
                <div className="max-w-[88%] rounded-lg bg-[var(--surface-container-high)] px-3 py-2 text-sm">
                  <p className="text-[11px] font-semibold uppercase tracking-[0.08em] text-[var(--text-muted)]">assistant</p>
                  <p className="mt-1 leading-relaxed text-[var(--text-muted)]">Thinking...</p>
                </div>
              ) : null}
            </div>

            <form onSubmit={onSubmit} className="mt-4 flex gap-2">
              <input
                value={input}
                onChange={(event) => setInput(event.target.value)}
                className="h-11 flex-1 rounded-md bg-[var(--surface-container-low)] px-3 text-sm"
                placeholder="Ask AI for risk analysis, prediction, or action plan"
              />
              <button type="submit" className="h-11 rounded-md brand-gradient px-4 text-sm font-semibold text-white">
                Send
              </button>
            </form>
          </article>
        </div>
      </section>
    </AdminShell>
  );
}