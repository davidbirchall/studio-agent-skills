# squad-skills-backend

Backend skills for Node.js / NestJS / Fastify / Prisma / TypeScript: Node and NestJS conventions, architecture, API design, validation, database design and data access, caching, authentication and authorization, security, testing, background processing, error handling, observability, plus Fastify, RxJS, OpenAPI/Swagger, and Postman.

Version `0.4.0`, 24 skills.

## Install

```
copilot plugin install ./plugins/backend
```

## Skills

| Skill | Purpose | Load when |
|-------|---------|-----------|
| `api-design` | REST rules, status codes, RFC 9457 errors, pagination, idempotency, versioning | Designing endpoints, responses, or breaking changes |
| `authentication-authorization` | Global guards, JWT and OIDC, refresh tokens, RBAC and ABAC, object-level access, tenant isolation | Adding or changing authentication or access control |
| `backend-architecture` | Modular monolith, module boundaries, domain vs infrastructure, ports and adapters, mapping layers, sync vs async, orchestration layers | Structuring a service, deciding module boundaries, or adding integrations and events |
| `backend-observability` | pino logs, correlation ids, metrics, OpenTelemetry tracing, health checks, SLOs, error tracking | Adding logging, metrics, tracing, or health endpoints |
| `backend-security` | OWASP API Top 10, headers, CORS, rate limiting, SSRF, secrets, supply chain, hardening, security checklist | Reviewing an endpoint or hardening the service |
| `backend-testing` | Vitest with SWC, Nest testing module, Fastify inject e2e, real-database tests, fakes, contract tests | Writing or fixing backend tests |
| `background-processing` | BullMQ queues, retries, idempotent jobs, scheduling, outbox pattern, 202 pattern for long-running work | Moving work off the request path or adding jobs and schedules |
| `caching-patterns` | Cache-aside, HTTP caching, Redis, TTLs, keys, invalidation, stampede protection, performance triage | Adding caching or diagnosing slow endpoints |
| `data-access-patterns` | PrismaService, repositories, select and include, N+1, transactions, concurrency, pools, error mapping | Writing queries or changing the Prisma integration |
| `data-validation` | Validation at every trust boundary, DTOs with class-validator or Zod, whitelisting, uploads, serialization | Writing DTOs or validating any untrusted input |
| `database-design` | Schema modelling, keys and UUID v4 vs v7, constraints, indexes, data types, migrations, tenancy | Designing or changing the schema or migrations |
| `email-notifications` | Transactional email and notifications for NestJS backends - queueing sends through background jobs, outbox and idempotency keys, a provider-neutral... | Sending email, adding notification types, wiring a mail provider, building templates, or handling bounces and user notification preferences |
| `error-handling` | Error taxonomy, global filter, problem+json mapping, logging once, retries, jobs and stream errors | Adding error classes, filters, or failure handling |
| `fastify-adapter` | NestJS on Fastify: bootstrap, plugins, reply handling, inject testing | Setting up or changing the Fastify adapter |
| `file-storage` | File upload and storage for NestJS and Prisma backends - S3-compatible object storage behind an interface with local disk for dev, presigned URL... | Accepting uploads, serving user files, adding image processing, or designing object storage and file metadata |
| `multi-tenancy` | Single-user now, tenancy-ready data isolation for a NestJS and Prisma chat API - always scoping rows by an owner id taken from auth context, one... | Adding tables or queries, scoping data by user, reviewing for cross-user leaks, or planning for organizations and workspaces |
| `nestjs-patterns` | Modules and providers, dynamic modules, scopes, request pipeline order, custom decorators, config, lifecycle, pitfalls | Creating or changing NestJS modules, providers, guards, pipes, interceptors, or filters |
| `nodejs-conventions` | Node runtime and process lifecycle, strict TypeScript, Oxlint and Prettier, server-side axios clients, event-loop rules | Setting up or changing Node/TypeScript config, lint tooling, outbound HTTP calls, or process behaviour |
| `openapi-swagger` | `@nestjs/swagger` setup, decorators, versioning, spec export | Documenting endpoints or changing the contract |
| `postman-api-testing` | Collections from OpenAPI, environments, tests, Newman in CI | Maintaining Postman collections |
| `prisma-patterns` | Prisma with PostgreSQL in NestJS - schema conventions (uuid ids, createdAt/updatedAt, soft delete policy, enums), PrismaService lifecycle, migrate... | Writing or changing schema.prisma, migrations, Prisma queries, transactions, or repository code |
| `rate-limiting-quotas` | Cost and abuse protection for an LLM-backed NestJS API - token and cost budget caps, concurrent stream limits, runaway agent loop guards, leaked key... | Adding throttling, spend or token caps, stream concurrency limits, agent loop limits, or investigating runaway LLM cost or abuse |
| `realtime-streaming` | Token streaming from NestJS on Fastify to a browser client - SSE versus WebSocket decision, @Sse with Observable and raw Fastify reply handling,... | Building or debugging streaming chat responses, SSE endpoints, resumable streams, or LLM token delivery |
| `rxjs` | Observables vs async/await, operators, interceptors, SSE, leaks | Writing interceptors, SSE, or observable code |

## Related plugins

Works well with: shared, data, platform-engineering, ai-engineering. Skills may mention skills from other plugins in a short "See also" note; each skill stands on its own if those plugins are not installed.
