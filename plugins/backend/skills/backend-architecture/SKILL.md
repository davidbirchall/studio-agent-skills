---
name: backend-architecture
description: Layered and modular architecture for NestJS and Node services - modular monolith by default, module boundaries and dependency direction, domain vs application vs infrastructure, ports and adapters, DTO/domain/persistence mapping, transaction boundaries, sync vs async communication, events, idempotency, when to split a service, config and feature flags, multi-tenancy, orchestration and BFF layers for chat and AI-style apps, and versioning boundaries. Load when designing service structure, adding a module or integration, deciding sync vs async, or considering splitting a service.
---

# Backend architecture

Framework wiring is in `nestjs-patterns`; runtime in `nodejs-conventions`. Record significant decisions in the project's decision log.

## Default shape
- Start as a modular monolith: one deployable, feature modules with explicit boundaries. Split only for a demonstrated reason.
- Flow is controller -> service -> repository/data access. Controllers do transport (parse, authorize, map, respond). Services hold use-case logic. Data access is hidden behind repositories (`data-access-patterns`).
- Dependencies point inward: infrastructure depends on application, application on domain. Domain logic is plain TypeScript with no Nest, Fastify, HTTP, or Prisma imports.
- Never call a controller from a service, never import a repository from another module's internals.

## Modules
- One module per business capability (`orders/`, `billing/`), not per technical layer. A module exports a small public API (service or facade); everything else stays private.
- No circular module dependencies; fix with a shared lower-level module or an event, not `forwardRef`.
- `common/` holds only cross-cutting, domain-free code. Do not let it grow into a dumping ground.

## Layers
- Domain: entities, value objects, rules, domain errors (`error-handling`).
- Application: use cases, orchestration, transaction boundaries, ports (interfaces).
- Infrastructure: Prisma repositories, HTTP clients, queue producers, cache, implementing the ports.
- Define a port when the dependency is external or likely to be faked in tests (payments, email, LLM provider). Do not add an interface for every class.

## Models and mapping
- Keep three shapes distinct: request/response DTOs (`data-validation`, `api-design`), domain models, and persistence models (Prisma types).
- Map at the boundary: controller maps DTO to command, repository maps persistence to domain. Never return Prisma entities directly from an API (leaks columns, couples the contract to the schema).
- Use hand-written mappers or small pure functions; test them.

## Transactions and consistency
- A transaction belongs to a use case in the application layer, covering one aggregate or a small unit of work. Keep it short and free of network calls.
- Across modules or services use eventual consistency: outbox pattern (write event and state in one transaction, publish afterwards) rather than distributed transactions.
- Make handlers idempotent: idempotency keys on mutating requests (`api-design`), dedupe by message id in consumers.

## Communication
- Synchronous (call or HTTP) when the caller needs the result now and the dependency is reliable. Asynchronous (queue/event) for slow, retryable, or fan-out work (`background-processing`).
- In-process events (`@nestjs/event-emitter`) decouple modules in one deployable but are lost on crash; use a broker or outbox for anything that must not be lost.
- Version event payloads; consumers tolerate unknown fields.

## Orchestration, BFF, and AI-style apps
- A gateway/BFF/orchestration service stays stateless: authenticate, validate, compose upstream calls, stream, and delegate. Business rules stay in the owning modules.
- Chat and LLM flows: stream tokens over SSE or WebSocket, set per-call timeouts and cancel upstream work when the client disconnects (`AbortSignal`), persist conversation state in the database or cache rather than process memory.
- Long-running or heavy work (batch inference, document processing, exports) goes to jobs; return `202` with a status resource.
- Treat model providers as external ports with retries, rate limits, and fallbacks (`error-handling`).

## Configuration and tenancy
- Typed, validated config injected via providers. Feature flags are read through one service, have an owner and removal date, and default to off.
- Multi-tenancy: resolve tenant once per request from the authenticated identity, never from a client-supplied field alone; scope every query by tenant in the repository layer (`database-design`, `authentication-authorization`). Prefer a shared schema with a tenant column unless isolation requirements demand otherwise.

## Splitting and versioning
- Split a service only when you need independent scaling, release cadence, or fault isolation, and the module boundary is already clean. Avoid premature microservices: they add network failure, distributed data, and operational cost.
- Each service owns its data; no shared tables across services.
- Public API versions (`api-design`) are a boundary: a new version maps to the same application layer, with adapters per version rather than duplicated logic. Contracts live in `openapi-swagger`.

## See also

Optional, if installed: software-architecture (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
