---
name: rate-limiting-quotas
description: Cost and abuse protection for an LLM-backed NestJS API - token and cost budget caps, concurrent stream limits, runaway agent loop guards, leaked key containment, token bucket and sliding window rate limits, @nestjs/throttler with Redis storage, reserve-and-settle token accounting, 429 with Retry-After and stable error codes, soft versus hard limits, and a when-you-grow section on per-tenant quotas and plans. Load when adding throttling, spend or token caps, stream concurrency limits, agent loop limits, or investigating runaway LLM cost or abuse.
---

# Rate limiting and quotas

Builds on `nestjs-patterns`, `caching-patterns`, `authentication-authorization`, `error-handling`, `realtime-streaming`, and `secret-handling`. Verify `@nestjs/throttler` option shapes and storage adapters against the installed version.

## Priorities for a solo-user app
The main risk is not other users; it is your own bill. In order:
1. Hard budget caps on tokens/cost.
2. Concurrency limit on streams.
3. Agent and tool loop guards.
4. Leaked-key containment.
5. Basic per-IP and per-user rate limits.

## Budget caps
- Count what costs money: input + output tokens (or credits weighted by model price). Request counts are a poor proxy.
- Set daily and monthly caps (e.g. daily 2x expected use). Hard cap blocks calls; soft cap at 80% logs and warns.
- Reserve then settle: before the call, reserve estimated input plus `max_tokens`; after, settle with actual provider usage, including aborted streams (tokens produced so far).
- Always cap `max_tokens` and input size server-side, regardless of client input. Per-conversation context limits too.
- Source of truth: `usage_events` table (id, ownerId, model, inputTokens, outputTokens, credits, createdAt). Redis counters (`quota:{ownerId}:2026-10-31`, expire after period plus grace) are the fast path; reconcile nightly.
- Also set a spend limit in the LLM provider console as the outer backstop.

## Concurrency
- Limit active streams per user (default 2-3) with a Redis lease (`SET key id NX PX 60000`), renewed on heartbeat and released in `finalize`. Crashed instances self-heal via TTL (`realtime-streaming`).
- Over the limit: 429 with `code: "concurrent_streams"`.

## Runaway loops
- Agent/tool loops: hard `maxSteps` (default 10-15), per-run token budget, and per-run wall-clock timeout (e.g. 2 min). Abort via `AbortSignal`.
- Detect repeated identical tool calls (same name and args 3x) and stop with a clear error.
- Retries: bounded (max 2) with exponential backoff and jitter; never retry after the first streamed token. Do not retry non-idempotent tool calls.
- Background jobs that call LLMs need their own budget check and attempt cap (`background-processing`).

## Leaked keys
- Provider keys live server-side only (`secret-handling`). Use per-environment keys with provider-side limits; rotate on suspicion.
- Alert when spend exceeds 3x the trailing daily average; provide a kill switch (config flag) that disables LLM calls without a deploy.
- App auth tokens: short-lived access tokens, revocable sessions (`authentication-authorization`).

## Rate limits
- Token bucket by default (chat send: capacity 10, refill 1 per 3 s). Sliding window for strict N-per-window, such as login attempts. Avoid fixed windows. Implement atomically in Redis (Lua), never GET then SET.
- Keys: `rl:{route}:{userId}` when authenticated, `rl:{route}:ip:{ip}` otherwise. Behind a proxy, set Fastify `trustProxy` to the exact hop count (`fastify-adapter`).
- Gateway/CDN handles coarse per-IP flood protection; the app handles identity-based limits.
```ts
ThrottlerModule.forRootAsync({
  inject: [ConfigService],
  useFactory: (cfg) => ({
    throttlers: [{ name: 'default', ttl: 60_000, limit: 60 }],
    storage: new ThrottlerStorageRedisService(cfg.getOrThrow('redis.url')),
  }),
})
```
- In-memory throttler storage is per instance; use Redis once more than one instance runs. Register `ThrottlerGuard` via `APP_GUARD`; override `getTracker` to key by user. Verify ttl unit (ms vs s).

## Responses
- 429 with `Retry-After` (seconds). Stable body (`error-handling`, `api-design`):
```json
{ "error": { "code": "rate_limited", "message": "Too many requests", "retryAfterSeconds": 12 } }
```
- Codes: `rate_limited` (retry), `quota_exceeded` (non-retryable until reset), `concurrent_streams`.
- Redis down: fail closed for budget caps, fail open (short local fallback) for plain rate limits.

## When you grow
- Add tenant-level budgets above user budgets so one user cannot drain a workspace (`multi-tenancy`). Keys become `{tenantId}:{userId}`.
- Plans with per-period token or credit allowances, billing-anchored resets, admin overrides in config, overage and degrade-to-cheaper-model policies.
- Escalating abuse penalties: repeated 429s -> longer cooldown -> block -> review.

## Anti-patterns
- Request-count-only limits on LLM routes; in-memory counters across instances.
- No `maxSteps`; reserving tokens and never settling; trusting client `X-Forwarded-For`.
- Retrying mid-stream; no kill switch.

## Checklist
- [ ] Daily/monthly token or cost caps, plus provider-side limit
- [ ] `max_tokens` and input size capped server-side
- [ ] Stream concurrency lease with TTL
- [ ] Agent maxSteps, timeout, repeat detection
- [ ] Spend alert and kill switch
- [ ] Redis-backed atomic rate limits; `trustProxy` correct
- [ ] 429 with Retry-After and stable codes
