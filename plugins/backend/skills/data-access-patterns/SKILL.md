---
name: data-access-patterns
description: Data access in NestJS with Prisma and PostgreSQL - PrismaService lifecycle, repository versus direct service access, select and include discipline, N+1 avoidance, cursor pagination, transactions and isolation, optimistic concurrency, idempotent writes and upserts, bulk operations, parameterised raw SQL, soft-delete filtering, connection pools, slow-query logging, Prisma error mapping, testing against a real database, and seeding. Load when writing or reviewing queries, transactions, the Prisma integration, or database performance code.
---

# Data access patterns

Builds on `nestjs-patterns`. Schema, ids, indexes, and migrations are decided in `database-design`. Verify client API, extensions, and generator config against the installed Prisma major version; both change between majors.

## Integration
- A single `PrismaService` (extends or wraps `PrismaClient`) provided by a global `PrismaModule`. Connect in `onModuleInit`, disconnect in `onModuleDestroy`, and enable shutdown hooks.
- One client per process. Never `new PrismaClient()` in services.
- Only services and repositories touch Prisma; controllers never do. Map to response DTOs rather than returning Prisma models (`data-validation`).

## Repository or direct access
- Direct `PrismaService` use in services is fine for simple CRUD. Prisma is already a typed data layer; a pass-through repository adds code, not value.
- Add a repository when queries are complex or reused across services, when you must centralise tenant or soft-delete scoping, or when unit tests need a seam. Keep it returning domain shapes, not leaking `Prisma.*Input` types to callers.

## Queries
- Use `select` (or nested `select`) to return only needed fields. Avoid `include` of whole relations by default.
- Never run unbounded `findMany`; always `take` with a capped maximum.
- Avoid N+1: use nested `select`/`include` or batch with `where: { id: { in } }`, never queries inside loops. Check with query logging.
- Whitelist sort and filter fields from user input; never spread raw query params into `where`.
- Use cursor pagination (`cursor` + `skip: 1` + stable unique `orderBy`, include the id as tie-breaker) per `api-design`. Offset pagination degrades on deep pages.

```ts
this.prisma.order.findMany({
  where: { tenantId },
  orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],
  take: limit + 1,
  ...(cursor && { cursor: { id: cursor }, skip: 1 }),
  select: { id: true, total: true, createdAt: true },
});
```

## Transactions
- `$transaction([...])` (batch) for independent writes that must succeed together. Interactive `$transaction(async tx => ...)` when later steps depend on earlier results; use only `tx` inside.
- Keep them short. No network calls, queue publishes, or slow work inside; do those after commit. Set `timeout`/`maxWait` deliberately.
- Default isolation is the database default (Postgres: read committed). Raise it (`isolationLevel`) only for a specific anomaly, and be ready to retry on serialization failure (`P2034`).
- Lock ordering: touch rows in a consistent order to avoid deadlocks.

## Concurrency and idempotency
- Optimistic concurrency: a `version` integer column; update with `where: { id, version }` and increment; zero rows updated means conflict, return 409.
- Idempotent writes: a unique constraint on the idempotency key or natural key, then catch `P2002` and return the existing result. Use `upsert` only when a unique where exists; it is not atomic on every provider and path, so rely on the unique constraint for correctness.
- Atomic counters and increments use `{ increment: n }`, not read-modify-write.

## Bulk operations
- Use `createMany`, `updateMany`, `deleteMany` instead of loops. Chunk very large sets (hundreds to low thousands per batch) and run long backfills in `background-processing`, not request handlers.
- `createMany` does not return rows on all providers; verify against the installed version.

## Raw SQL
- Only through tagged `$queryRaw` / `$executeRaw` (parameterised). Never `$queryRawUnsafe` or string concatenation with user input (`backend-security`). Type the result and add tests.

## Soft delete and scoping
- If `database-design` chose soft delete, apply the `deletedAt: null` filter in one place: a repository or a Prisma client extension. Verify extension APIs against the installed version; middleware (`$use`) is deprecated or removed in recent majors.
- Apply tenant scoping the same way, so no query can forget it.

## Connections and performance
- Pool size = what the database can serve divided by instance count (Prisma `connection_limit` in the URL or adapter config). Use an external pooler (PgBouncer) for many instances or serverless, following Prisma's pooler guidance for the installed version.
- Enable Prisma query logging (`log` option, or events with durations) outside production or sampled; log slow queries over a threshold with the route and request id, then run `EXPLAIN` (`database-design`). Do not log parameter values containing PII.
- Set statement and lock timeouts at the database for request paths.

## Errors
Map `PrismaClientKnownRequestError` in one place and hand off to `error-handling`: `P2002` unique violation to 409, `P2025` record not found to 404, `P2003` foreign key to 409 or 400. Never leak raw Prisma messages or constraint names.

## Testing and seeding
- Integration-test queries against a real disposable PostgreSQL (container or per-worker schema), migrated with `prisma migrate deploy`, reset between tests (`backend-testing`, `test-discipline`). Do not mock Prisma to test query behaviour; mocks prove nothing about SQL.
- Seed via the `prisma.seed` config; make it idempotent (`upsert`). Keep reference data in migrations or seed, test data in factories.

## See also

Optional, if installed: query-optimisation (the data plugin); data-integrity (the data plugin) for the broader discipline this skill applies. This skill stands on its own.
