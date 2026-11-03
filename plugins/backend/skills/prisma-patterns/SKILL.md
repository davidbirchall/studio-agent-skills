---
name: prisma-patterns
description: Prisma with PostgreSQL in NestJS - schema conventions (uuid ids, createdAt/updatedAt, soft delete policy, enums), PrismaService lifecycle, migrate dev versus deploy workflow, interactive versus batch transactions, N+1 and select/include discipline, cursor pagination, raw query safety, error mapping (P2002, P2025), real-database testing, indexes, JSON columns for message parts, DTO mapping instead of exposing models, and connection pool sizing. Load when writing or changing schema.prisma, migrations, Prisma queries, transactions, or repository code.
---

# Prisma patterns

Builds on `database-design`, `data-access-patterns`, `nestjs-patterns`, and `backend-testing`. Verify client APIs, generator name, and extension APIs against the installed Prisma version.

## Schema conventions
- Ids: `id String @id @default(uuid()) @db.Uuid`. Use UUIDv7 (`@default(uuid(7))`, or `uuid` v7 in app code) when index locality matters on large tables; verify support in the installed version.
- Every model has `createdAt DateTime @default(now())` and `updatedAt DateTime @updatedAt`. Use `@db.Timestamptz(3)`.
- Enums for closed sets (`Role`, `MessageStatus`). Adding values is a migration; use a string column with validation for sets that change often.
- Map names: `@@map("messages")`, `@map("created_at")`; models PascalCase singular, tables snake_case plural.
- Declare `onDelete` explicitly on every relation. Default: `Cascade` for owned children, `Restrict` for references.
- Soft delete (`deletedAt`) only where users need undo or audit (conversations). Otherwise hard delete. Soft-deleted rows must be filtered centrally (extension), never ad hoc.

## Chat model hints
- Store message content as `parts Json` (array of typed parts: text, tool_call, tool_result, attachment). Validate with Zod on write and read (`data-validation`); never query inside JSON for hot paths.
- Promote anything you filter or sort on (role, status, tokens, model) to real columns.
- Index for access paths: `@@index([conversationId, createdAt])` for message lists; `@@index([userId, updatedAt(sort: Desc)])` for conversation lists.

## PrismaService
```ts
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  async onModuleInit() { await this.$connect() }
  async onModuleDestroy() { await this.$disconnect() }
}
```
- One instance, exported from a global `PrismaModule`. Never `new PrismaClient()` elsewhere or per request.
- Call `app.enableShutdownHooks()` in `main.ts`.
- Pool: `connection_limit` in the URL (Rust-engine clients; default `num_cpus * 2 + 1`) or the driver adapter's pool options (default differs, e.g. `pg` max 10); verify for the installed major. Budget `instances * limit < Postgres max_connections` minus headroom; use PgBouncer (`?pgbouncer=true` on engine clients) for many instances. Streaming does not hold a connection; never keep a transaction open while streaming.

## Migrations
- Dev: `pnpm prisma migrate dev --name add_x`; commit the SQL. Review generated SQL for drops and renames (Prisma emits drop+create).
- Prod/CI: `pnpm prisma migrate deploy` only, as a release step before app start. Never `migrate dev` or `db push` against shared databases.
- Destructive changes use expand/contract: add, backfill, switch reads, drop in a later release.
- Never edit an applied migration. Create indexes on big tables with hand-edited `CONCURRENTLY` migrations.

## Queries
- Always `select` explicit fields for API paths; use `include` only for small, known relations. No unbounded `findMany`: always `take`.
- N+1: no queries inside loops or `Promise.all(items.map(...))`. Use `include`, `where: { id: { in } }`, or `relationLoadStrategy: 'join'` (verify availability).
- Cursor pagination: `take: n + 1, cursor: { id }, skip: 1, orderBy: [{ createdAt: 'desc' }, { id: 'desc' }]`. The order must be total and indexed. Offset only for small admin lists.
- Use `upsert` / unique constraints for idempotency, not read-then-write.

## Transactions
- Batch `$transaction([a, b])` for independent writes. Interactive `$transaction(async (tx) => ...)` only when later steps depend on earlier reads.
- Keep interactive transactions under ~1 s with explicit `timeout`/`maxWait`. No network or LLM calls inside.
- Use `tx`, not `this.prisma`, inside the callback. Pass `tx` into helpers.
- Use `isolationLevel: Serializable` only with retry on `P2034`.

## Raw SQL
- `$queryRaw` tagged template only; parameters are bound. Never `$queryRawUnsafe` or string-concatenated SQL with user input (`backend-security`).
- Type results explicitly and keep raw SQL in repositories.

## Errors
- Map `PrismaClientKnownRequestError` in one place: `P2002` unique -> 409, `P2025` not found -> 404, `P2003` foreign key -> 409 or 422, `P2034` -> retry. Do not leak `meta.target` or SQL to clients (`error-handling`).

## Boundaries
- Controllers never touch Prisma. Never return Prisma models directly; map to response DTOs so schema changes and internal columns (`deletedAt`, `tenantId`) do not leak (`api-design`).
- Services call repositories or a thin data layer; Prisma types stop there for large codebases.

## Testing
- Test against real PostgreSQL (container) with `migrate deploy`; no mocked Prisma for query logic (`test-discipline`).
- Isolate with a schema per worker or truncate between tests. Run Vitest with `pool: 'forks'` or one DB per worker.

## Anti-patterns
- `findMany` without `take`; offset pagination on feeds; `include` of deep trees.
- Long interactive transactions; `$queryRawUnsafe`; many `PrismaClient` instances.
- `db push` in production; JSON for fields you filter on.

## Checklist
- [ ] uuid ids, timestamps, explicit `onDelete`
- [ ] Indexes match list queries
- [ ] Single PrismaService, shutdown hooks, pool budgeted
- [ ] Select-only DTO mapping; no models in responses
- [ ] Cursor pagination with total order
- [ ] P2002/P2025 mapped centrally
- [ ] Migrations reviewed; `deploy` in prod
- [ ] Tests run on real Postgres
