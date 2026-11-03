---
name: ai-cost-latency-control
description: Controlling cost and latency of LLM features in a TypeScript/NestJS chat backend - budgets per user, tenant, and request, token accounting from provider usage fields, prompt caching and stable prefixes, model routing between small and large models, max output tokens, timeouts, fallbacks, retries with jitter and idempotency, time-to-first-token as the primary UX metric, parallel tool calls, semantic and response caching caveats, cost dashboards and alerts, and degradation modes. Provider-agnostic. Load when estimating or capping spend, reducing response latency, adding retries or fallbacks, or setting up cost monitoring.
---

# AI Cost and Latency Control

Builds on `llm-integration` and `agent-orchestration`. Metrics plumbing is in `ai-observability`; prompt layout in `context-engineering`.

## Scope: core now vs add later
- Core now: per-request caps, token accounting, prompt caching, model routing, timeouts and bounded retries, TTFT tracking.
- Add later: per-user and per-tenant budgets, cost dashboards and alerts, semantic caching, formal degradation modes.
- Record `userId` and `feature` on every usage row now so later budgets are a query, not a migration.

## Budgets
- Now: per-request caps on max input, max output, and max tool steps. Reject or trim before the call.
- Later: user (daily and monthly) and tenant (monthly, soft and hard) limits. Check before the call using an estimate; reserve then settle to avoid concurrent overspend.
- Soft limit warns and degrades; hard limit blocks with a clear error code and message.
- Budget in money and tokens. Keep a price table per model with an effective date; verify against current provider docs.

## Token accounting
- Record usage from the provider response (input, output, cached input, reasoning tokens where reported), not local estimates. Field names vary; verify against current provider docs.
- Store per run and per step: model, usage, computed cost, tenant, user, feature. Aggregate from these rows.
- Streaming: usage arrives at stream end; handle missing usage after abort by falling back to an estimate, flagged `estimated` (`streaming-llm-responses`).

```ts
interface UsageRecord {
  runId: string; stepId: string; model: string; tenantId: string; feature: string;
  inputTokens: number; cachedInputTokens: number; outputTokens: number;
  costMicros: number; estimated: boolean;
}
```

## Prompt caching
- Providers cache stable prefixes. Put system prompt, tools, and pinned instructions first; volatile content (memories, retrieved text, timestamps) last.
- Keep tool definitions and ordering deterministic. Do not inject the current time or random ids early in the prompt.
- Measure cached-token ratio per feature. Minimum prefix size and expiry are provider-specific; verify against current provider docs.

## Model routing
- Small model: titles, classification, moderation triage, summaries, query rewriting. Large model: multi-step reasoning, code, final answers.
- Route in code by feature first; escalate by a measured signal (failed validation, low confidence), not guesses. Evaluate quality per route (`ai-evaluation`).
- Let users pick a model only from a tenant allow-list with per-model limits.

## Output and time limits
- Always set max output tokens per feature. Size it from observed p95 plus margin.
- Set connect, time-to-first-token, and total timeouts separately. Pass `AbortSignal` everywhere.
- Fallback chain: same model retry, then alternate model or provider. Keep prompts compatible; record which model served.

## Retries
- Retry only transient failures: 429, 5xx, network resets. Never retry 4xx validation or content-policy errors.
- Exponential backoff with full jitter; honour `Retry-After`; cap attempts and total elapsed time.
- Retry before first token only. After tokens streamed, recover via `streaming-llm-responses`, not a silent restart.
- Tool calls with side effects need idempotency keys (`tool-integration`).

## Latency
- Time to first token (TTFT) is the key UX metric; track p50 and p95 by model and feature, plus tokens per second.
- Cut TTFT: shorter prompts, cached prefixes, smaller model, no blocking pre-steps. Run moderation, retrieval, and memory lookup in parallel.
- Execute independent tool calls concurrently with a limiter; stream text while tools run.
- Move titles, summaries, and analytics off the critical path.

## Caching responses (add later)
- Exact-match cache for deterministic, non-personalised calls only; key on model, prompt version, full input hash.
- Semantic caches risk wrong or leaked answers across users. If used, scope by tenant, exclude personalised or tool-using flows, set high thresholds and TTLs, and measure false hits.

## Monitoring and degradation (add later; log usage and TTFT now)
- Dashboards: cost by tenant, feature, model; cached ratio; TTFT; retry and fallback rate. Alert on spend rate anomalies and budget thresholds.
- Degradation order: shorter history, smaller model, fewer tools, lower max output, queue or reject. Surface it to the user.

## Anti-patterns
- Estimating cost from character counts only; no per-request caps; unbounded agent loops.
- Retrying inside every layer (retry storms); retrying after partial output.
- Timestamps at the top of the system prompt.

## Checklist
- [ ] Per-request caps now; reserve-and-settle user/tenant budgets later
- [ ] Usage persisted from provider fields
- [ ] Stable prefix; cached ratio tracked
- [ ] Max output and three timeouts set
- [ ] Jittered, bounded, pre-token-only retries
- [ ] TTFT logged now; dashboards, alerts, degradation later
