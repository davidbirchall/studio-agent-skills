---
name: error-handling
description: Error handling for Node and NestJS backends - operational vs programmer errors, domain vs transport errors, custom error classes with codes, one global exception filter, RFC 9457 problem+json mapping, mapping domain, Prisma and upstream errors to HTTP statuses, logging once with correlation id, retries, timeouts and circuit breakers, errors in jobs, streams and SSE, process-level handlers, transaction rollback, Result-style returns, error code catalogue, and testing error paths. Load when adding failure paths, writing exception filters or error classes, mapping errors to responses, or debugging unhandled errors.
---

# Error handling

Response shape is defined in `api-design`; filter wiring in `nestjs-patterns`. Verify Prisma error codes and Nest class names against installed versions.

## Taxonomy
- Operational errors are expected runtime failures (not found, conflict, upstream timeout, invalid input). Handle them and return a mapped response.
- Programmer errors are bugs (TypeError, broken invariant). Do not catch-and-continue; log, return a generic 500, fix the code.
- Domain errors describe business rule failures and know nothing of HTTP. Transport errors (HTTP exceptions) are produced only at the edge.

## Error classes
- A base `AppError` with a stable `code`, `message`, and optional `cause` and `details`; subclasses per category.
```ts
export class AppError extends Error {
  constructor(readonly code: string, message: string, options?: { cause?: unknown; details?: unknown }) {
    super(message, options)
    this.name = new.target.name
  }
}
export class NotFoundError extends AppError {}
export class ConflictError extends AppError {}
```
- Domain and application code throw `AppError` subclasses, never `HttpException`. Preserve `cause` when wrapping.
- Throw `Error` instances only; never strings or plain objects.

## One global filter
- A single exception filter (`@Catch()`) turns every error into `application/problem+json` with `type`, `title`, `status`, `detail`, `code`, `traceId`.
- Mapping in the filter: `NotFoundError` 404, `ConflictError` 409, rule violations 422, auth errors 401/403, rate limit 429, upstream failures 502/503/504, everything else 500.
- Map Prisma known request errors explicitly: unique violation (`P2002`) to 409, record not found (`P2025`) to 404, foreign key (`P2003`) to 409 or 422. Do this in the repository or the filter, not controllers. Never return Prisma messages.
- Validation failures return 400 or 422 (pick one, `api-design`) with an `errors[]` array of `{ field, code, message }` (`data-validation`).
- Never leak stack traces, SQL, file paths, upstream bodies, or internal ids. 5xx `detail` is generic.

## Logging
- Log an error once, at the boundary that handles it (the filter or job runner), with stack, `code`, request/correlation id, and user or tenant id where safe (`backend-observability`). Do not log and rethrow at every layer.
- Log 4xx at info/warn without stacks; 5xx at error with stacks. Redact secrets and PII (`secret-handling`, `backend-security`).

## Expected failures
- For outcomes callers must branch on, return a discriminated union instead of throwing:
```ts
type Result<T, E extends AppError = AppError> = { ok: true; value: T } | { ok: false; error: E }
```
- Throw for exceptional or cross-layer failures, Result for local expected branches. Do not mix both for the same case.

## Resilience boundaries
- Every outbound call has a timeout (`nodejs-conventions`). Retry only idempotent operations on transient failures with backoff, jitter, and a cap; never blind-retry non-idempotent writes.
- Retry at one layer only, to avoid multiplied attempts.
- Add a circuit breaker around unstable upstreams so failures fail fast; return 503 with `Retry-After` when shedding. Provide fallbacks only when the degraded result is acceptable.

## Async, jobs, streams, SSE
- Await or handle every promise; a floating rejection becomes an unhandled rejection.
- Jobs: classify failures as retryable or permanent; permanent ones go to a dead-letter queue, with attempts and backoff configured (`background-processing`). Handlers must be idempotent.
- Streams: attach error handlers or use `pipeline`; destroy upstream on failure and on client disconnect.
- SSE and streaming: once headers are sent the status cannot change. Emit an error event with a code and close; log server-side. Validate and authorize before starting the stream.

## Process level
- On `unhandledRejection` and `uncaughtException`: log with context, start graceful shutdown, exit non-zero, and let the supervisor restart (`nodejs-conventions`). Do not swallow them.
- Fail fast at boot on invalid config or unreachable critical dependencies.

## Transactions
- Throwing inside a Prisma `$transaction` callback rolls it back; let domain errors propagate out. Do not catch inside and continue with half-applied state. Side effects (emails, events) run after commit (`backend-architecture`).

## Error code catalogue
- Keep one catalogue (`errors/codes.ts` or a documented table): `code`, HTTP status, meaning, retryable. Codes are stable, documented in OpenAPI responses (`openapi-swagger`), and never reused or repurposed.

## Testing
- Unit test the domain error thrown for each rule. Test the filter with each error type and assert status, `code`, problem shape, and that no internals leak.
- Integration and e2e tests cover 400/401/403/404/409/5xx paths, upstream timeouts, and job failure and retry (`backend-testing`, `test-discipline`). Assert the contract, not message text.

## See also

Optional, if installed: debugging (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
