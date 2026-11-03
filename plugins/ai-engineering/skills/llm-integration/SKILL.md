---
name: llm-integration
description: Integrating LLM providers into a TypeScript/NestJS backend - provider-agnostic abstraction, streaming to clients, structured output with schema validation and repair, timeouts, cancellation, retries with backoff and jitter, rate limit handling, fallbacks across models and providers, token and cost budgets, usage accounting, API key handling, idempotency, and error mapping. Load when adding or changing a model call, wiring a new provider, handling streaming responses, or debugging flaky, slow or expensive LLM requests.
---

# LLM integration

Builds on `prompt-engineering` for prompt content and `context-engineering` for what goes into the window. Verify limits, parameters, structured-output and caching features against the provider docs; they change by provider and version.

## Provider abstraction
- Define one narrow port owned by the app; provider SDKs live only in adapters.
```ts
export interface ChatModel {
  complete(req: ChatRequest, opts: CallOptions): Promise<ChatResult>
  stream(req: ChatRequest, opts: CallOptions): AsyncIterable<ChatChunk>
}
export interface CallOptions { signal: AbortSignal; timeoutMs: number; idempotencyKey?: string }
```
- Normalise messages, tool calls, finish reasons, usage and errors into app types. Never leak SDK types past the adapter.
- Select model by config (name per use case), not hard-coded strings in call sites. Keep model ids in one registry.
- Capability flags per model (tools, JSON mode, vision, max context) come from config verified against provider docs.

## Timeouts and cancellation
- Every call has a timeout and an `AbortSignal`. Combine the client-disconnect signal with the timeout using `AbortSignal.any`.
- Set separate limits for time-to-first-token and total duration on streams.
- On abort, stop reading, release the connection, and record partial usage.

## Streaming
- Stream tokens to clients over SSE or WebSocket; forward the abort when the client leaves.
- Accumulate the full text server-side for persistence and validation; persist even if the client dropped.
- Send a terminal event with finish reason and usage. Map mid-stream errors to an error event, not a silent close.
- Never parse partial JSON as final; validate only after the stream completes.

## Structured output
- Prefer the provider's native structured-output or tool-call mode where available; verify support per model.
- Always validate the result with a schema (zod or equivalent) regardless of provider guarantees.
```ts
const parsed = Answer.safeParse(JSON.parse(text))
if (!parsed.success) return repairOnce(req, text, parsed.error)
```
- Repair at most once or twice: feed the validation error back, then fail with a typed error. Do not loop.
- Treat refusals, truncation (length finish reason) and empty output as distinct failures.

## Retries and rate limits
- Retry only transient failures: timeouts, 429, 5xx, connection resets. Never retry 400, 401, 403 or content-policy errors.
- Exponential backoff with full jitter, capped attempts and a total deadline. Honour `Retry-After` when present.
- Retry only idempotent calls or those made with an idempotency key. Do not retry after side-effecting tool calls have run.
- Limit concurrency per provider with a semaphore or queue; shed or queue load instead of hammering 429s.
- Add a circuit breaker per provider/model so an outage fails fast.

## Fallbacks
- Order fallbacks explicitly: same model other region, then comparable model, then degraded response. Log every fallback with reason.
- Re-run prompts through `ai-evaluation` on fallback models; prompts are not portable by default.
- Do not fall back on validation or policy failures that would recur.

## Cost and token budgets
- Count input tokens before sending (provider tokenizer or estimate) and set an explicit max output limit per use case.
- Record input, output and cached tokens per call with user, tenant, feature and model (`ai-observability`). Prices come from config, not code.
- Enforce per-request, per-user and per-tenant budgets; reject or degrade when exceeded. Cap agent loop iterations and total tokens per run (`agent-orchestration`).
- Use cheaper models for classification, routing and summarising; reserve large models for hard steps.

## Keys and security
- Keys come from the secret store or env, injected via config; never logged, committed or sent to clients (`secret-handling`). Rotate per environment.
- Call providers server-side only. Redact keys and user content in logs; see `ai-security` for prompt injection and data-leak controls.

## Errors and testing
- Map provider errors to app errors: rate limited, timeout, context too long, content filtered, unavailable. Return generic messages to users.
- Test with a fake `ChatModel` that scripts chunks, errors and delays; assert retry, abort and validation paths (`ai-testing`, `test-discipline`). Keep live-provider tests out of the default suite.
