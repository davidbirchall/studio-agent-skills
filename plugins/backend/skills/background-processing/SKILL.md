---
name: background-processing
description: Background work for NestJS backends - deciding what leaves the request path, 202 plus status resource/webhook/SSE, BullMQ queues via @nestjs/bullmq on Redis, queue/worker separation, small idempotent jobs, retries with backoff and jitter, dead-letter handling, concurrency, rate limits, priorities, delayed and repeatable jobs versus @nestjs/schedule cron, the outbox pattern, graceful worker shutdown, queue observability, testing, and worker threads. Load when adding queues, scheduled jobs, long-running or LLM calls, retries, fan-out, or reliable event publishing.
---

# Background processing

Builds on `nestjs-patterns`, `error-handling`, and `backend-observability`. Verify package names, option names, and APIs against installed versions (`bullmq`, `@nestjs/bullmq`, `@nestjs/schedule`).

## What leaves the request path
- Move work off the request when it is CPU-heavy, calls slow or flaky upstreams, fans out to many calls, runs on a schedule, or is a long-running LLM/orchestration call whose duration is unbounded.
- Return `202 Accepted` with a job/resource id and a `Location` to a status resource. Offer one completion channel: polling the status resource, a webhook, or SSE/streaming for incremental output (`api-design`).
- Keep short, bounded, user-blocking work inline. A queue adds latency, failure modes, and operations cost.
- Streaming a model response to a waiting client can stay on the request (SSE); persist the final result and enforce timeouts and cancellation on the upstream call.

## Queues (BullMQ on Redis)
- Use `@nestjs/bullmq` with `bullmq`: `BullModule.forRoot` for the connection, `registerQueue` per queue, `@Processor` classes extending `WorkerHost` with `process(job)`.
- Separate producers from workers. Run workers as a distinct process/entrypoint (a Nest application context without HTTP) so they scale and deploy independently of the API.
- Redis for queues must not evict keys (`maxmemory-policy noeviction`); keep it separate from the cache Redis (`caching-patterns`).
- Configure connection and queue names from validated config (`nestjs-patterns`); prefix queue names per environment.

## Jobs
- Payloads are small and serialisable: ids and parameters, never entities, class instances, or large blobs. Load fresh state in the handler.
- Never put secrets or raw PII in payloads; Redis and job dashboards expose them (`secret-handling`, `backend-security`).
- Name jobs by intent (`conversation.summarise`) and validate the payload on entry (`data-validation`).
- Set a deterministic `jobId` where duplicates must collapse (e.g. one summary per conversation version).

## Idempotency and delivery
- Delivery is at-least-once: a job can run twice (retry, stalled-job recovery, redeploy). Every handler must be idempotent: upsert, unique constraint, or a processed-marker checked inside the same DB transaction as the side effect.
- Pass an idempotency key on non-idempotent upstream calls and external side effects (payments, emails).
- Check state before acting, and treat "already done" as success.

## Retries and failures
- Set `attempts` and `backoff: { type: 'exponential', delay }` in `defaultJobOptions`. Built-in backoff supports a `jitter` option (0 to 1, default 0 means none); set it, or use a custom backoff strategy, to avoid retry stampedes against a recovering upstream.
- Retry only transient errors (timeouts, 429, 5xx, connection resets). Throw `UnrecoverableError` for permanent failures (validation, 4xx) so they skip retries; classify per `error-handling`.
- Set `removeOnComplete` and `removeOnFail` with age/count limits so Redis does not grow unbounded; keep failed jobs long enough to inspect.
- Dead-letter: after attempts are exhausted, move the job to a dedicated DLQ queue (BullMQ has no built-in DLQ; implement in the `failed` handler), alert on it, and document a replay path.
- Poison messages (always crash the worker or exceed memory) must not loop forever: cap attempts and handle stalled jobs (`maxStalledCount`).
- Bound each job with a timeout and an `AbortSignal` passed to HTTP/LLM clients.

## Throughput
- Set worker `concurrency` deliberately; match it to the upstream's limits and DB pool size, not "as high as possible".
- Use the worker `limiter` for upstream rate limits (e.g. LLM provider requests per minute); verify the option shape for the installed version.
- Use `priority` for interactive over batch work; use separate queues if batch load can starve interactive jobs.
- Long-running jobs: report progress (`job.updateProgress`), and split large fan-out into child jobs or flows rather than one giant job.

## Scheduling
- Delayed jobs (`delay`) for one-off future work; repeatable jobs / job schedulers (verify the API for the installed BullMQ) for recurring work. They are registered in Redis, so they run once across all instances.
- `@nestjs/schedule` `@Cron` runs in every instance. In multi-instance deployments guard with a distributed lock (Redis lock with TTL, or a Postgres advisory lock), or enqueue a deduplicated job from the cron and let one worker run it.
- Scheduled handlers must be idempotent and tolerate overlap and missed runs.

## Outbox pattern
- To publish an event or enqueue a job only if a DB change commits, write an `outbox` row in the same transaction (`data-access-patterns`), then have a relay poll (`FOR UPDATE SKIP LOCKED`) and publish, marking rows sent.
- Do not enqueue inside the transaction directly: the job may run before commit, or the commit may fail. Consumers deduplicate by event id.

## Shutdown and operations
- Enable shutdown hooks; on `SIGTERM` close workers gracefully (`worker.close()` waits for active jobs). Keep the orchestrator grace period longer than the longest job, or make jobs resumable.
- Observe queues (`backend-observability`): depth, oldest-job age, active, failed/DLQ counts, processing duration, retry rate. Alert on age and DLQ growth, not depth alone.
- Propagate the correlation id and trace context in job metadata and restore them in the worker so logs and traces link to the originating request.

## CPU work
- Do not block the event loop in a worker either. Use `worker_threads` or a thread pool for CPU-bound tasks (`nodejs-conventions`); a queue distributes work, it does not make it non-blocking.

## Testing
- Unit test handlers by calling `process` with a fake job; assert idempotency by running it twice.
- Integration test with real Redis/Postgres (Testcontainers); assert retry, unrecoverable, and DLQ behaviour (`backend-testing`, `test-discipline`).
- Test the outbox relay for duplicate publication and a crash between publish and mark-sent.

## See also

Optional, if installed: deployment-patterns (the platform-engineering plugin) for the broader discipline this skill applies. This skill stands on its own.
