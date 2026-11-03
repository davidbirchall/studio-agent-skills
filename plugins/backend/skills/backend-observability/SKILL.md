---
name: backend-observability
description: Observability for NestJS backends - structured pino logging with redaction and correlation ids via nestjs-cls, RED and USE metrics with low-cardinality Prometheus labels, OpenTelemetry tracing and context propagation across HTTP and queues, @nestjs/terminus liveness/readiness/startup health, SLIs/SLOs and symptom-based alerting, error tracking with PII scrubbing, audit versus application logs, dashboards and runbooks, tracing LLM and upstream calls, retention, testing, and performance triage. Load when adding logging, health endpoints, metrics, tracing, alerts, or debugging production behaviour.
---

# Backend observability

Builds on `nestjs-patterns` and `fastify-adapter`. Verify package APIs against installed versions; OpenTelemetry packages move quickly.

## Logging
- Structured JSON logs via pino (`nestjs-pino`) as the Nest logger (`bufferLogs: true`, `app.useLogger(...)`). No `console.log` (`nodejs-conventions`).
- One request-scoped log line with method, route template, status, duration, and `requestId`. Include `userId` where available.
- Levels: `error` (needs action), `warn` (unexpected but handled), `info` (lifecycle, request summary), `debug` (off in production).
- Redact secrets and PII: authorization headers, cookies, passwords, tokens, personal data (`redact` paths in pino). Never log request bodies by default; never log prompts or model output by default (`backend-security`, `secret-handling`).
- Log events with stable message strings and structured fields, not interpolated sentences, so they can be queried.

## Correlation
- Accept an incoming `X-Request-Id` (or W3C `traceparent`) or generate a UUID; return it in the response and propagate it on outbound calls.
- Use `AsyncLocalStorage` (`nestjs-cls`) to access it without passing it around; add it to every log line via the pino mixin.
- Carry it into queue jobs and restore it in workers (`background-processing`).

## Metrics
- Services (RED): request Rate, Errors, Duration. Resources (USE): Utilisation, Saturation, Errors, e.g. event-loop lag, CPU, memory, DB pool, Redis.
- Expose Prometheus metrics (`prom-client`) or export via OpenTelemetry: HTTP latency histogram with buckets matched to your SLO, error counts, event-loop lag, DB pool in-use/waiting, queue depth, oldest-job age, failed jobs.
- Keep label cardinality low: route templates, status class, method. Never raw URLs, user ids, request ids, or prompts as labels.
- Use histograms, not averages; read p95/p99.

## Tracing
- OpenTelemetry: initialise the SDK before importing the app (separate `instrumentation.ts` loaded first, e.g. via `--import`/`--require`), auto-instrument HTTP, Fastify, Prisma, Redis, and the queue library where supported; verify each instrumentation against installed versions.
- Context propagates over HTTP via `traceparent`. Across queues, inject trace context into job metadata and extract it in the worker so the job span links to the request.
- Sample in production (head sampling with a ratio, or tail sampling in the collector to keep errors and slow traces). Set `service.name`, version, and environment resource attributes.
- Add spans around business-critical steps, not every function.

## LLM and upstream calls
- Wrap each upstream/LLM call in a span with generic attributes: provider, model, operation, latency, time to first token for streams, input/output token counts, retry count, outcome, and estimated cost. Check the OpenTelemetry GenAI semantic conventions for current attribute names rather than inventing them.
- Record tokens and cost as metrics with low-cardinality labels (provider, model, outcome), not per-user labels.
- Alert on upstream error rate, timeouts, and spend rate. Do not attach prompt or completion text to spans unless explicitly sanctioned and redacted.

## Health
- `@nestjs/terminus` endpoints: `/health/live` (process up, no dependencies), `/health/ready` (DB and critical dependencies, e.g. a Prisma ping, Redis), and a startup probe if boot is slow (migrations, warm-up). A failing dependency must not fail liveness, or restarts cascade.
- Exclude them from auth, rate limiting, and request logs. Wire the orchestrator probes to them; readiness fails during shutdown (`nestjs-patterns` shutdown hooks).

## SLIs, SLOs, alerting
- Define SLIs from the user's view (availability, latency under a threshold, stream completion success), set SLOs, and track the error budget.
- Alert on symptoms (burn rate, error ratio, latency, queue age), not causes (CPU high). Every alert is actionable, has an owner, and links to a runbook.
- Runbooks: what the alert means, how to confirm, mitigations, escalation. Update them after incidents.

## Errors
- The global exception filter logs unexpected errors once with the stack and `requestId`, returns a safe problem response (`error-handling`, `api-design`), and reports to the error tracker (e.g. Sentry) with PII scrubbed (`beforeSend`) and release/environment tags.
- Do not log the same error at every layer. Expected client errors (4xx) are not error-level.

## Audit logs
- Audit logs (who did what to which resource, when, outcome) are separate from application logs: append-only, structured, durable, with stricter access, and exempt from debug sampling (`authentication-authorization`, `backend-security`).
- Never put secrets in them; reference ids.

## Dashboards and retention
- One service dashboard: RED, saturation, dependencies, queues, SLO burn. Link to traces and logs by correlation id.
- Set retention by cost and compliance: short for debug/info logs, longer for audit logs, honouring PII deletion obligations.

## Testing
- Test the hooks that matter: redaction of sensitive fields, correlation id in logs and response, health endpoints reflecting dependency state, and the filter reporting once (`backend-testing`, `test-discipline`).

## Performance triage
- Start from metrics and traces: is the time in the DB, upstream, queue wait, or event loop? Query problems go to `data-access-patterns`; caching decisions to `caching-patterns`; long work to `background-processing`.

## See also

Optional, if installed: monitoring-observability (the platform-engineering plugin) for the broader discipline this skill applies. This skill stands on its own.
