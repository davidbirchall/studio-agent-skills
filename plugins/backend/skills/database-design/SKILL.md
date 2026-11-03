---
name: database-design
description: Relational schema and data modelling for backend services - entity modelling, normalisation versus deliberate denormalisation, key and id strategy (UUID v4 versus v7 versus sequences), constraints, foreign keys with explicit onDelete, indexing strategy, data types (timestamptz, money, enums, JSONB), soft versus hard delete and audit tables, multi-tenancy models, naming, migrations as the schema change process (expand/contract), seed data, retention and PII classification, and scaling levers. Load when designing or changing tables, ids, indexes, constraints, or migrations.
---

# Database design

PostgreSQL is assumed; Postgres-specific points are marked. Query and client code lives in `data-access-patterns`. Verify Prisma attributes against the installed major version.

## Modelling
- Model the domain first: one table per entity, one row per fact, relationships as foreign keys. Many-to-many uses an explicit join table (add columns to it when the relationship has attributes).
- Normalise to third normal form by default. Denormalise deliberately, only for a measured read problem, and record the decision and how the copy is kept consistent. Prefer a cache (`caching-patterns`) before duplicating data.
- Do not store derived values that can be computed cheaply. Do not use one table for unrelated entity types.

## Keys and ids
- Every table has a primary key. Public ids are UUIDs: opaque, non-guessable, generatable in application code. Do not expose sequential integers.
- v4 (random) is the default. Prefer v7 (time-ordered) for large, write-heavy tables: better B-tree locality and sortable. v7 leaks creation time; avoid where that matters. Do not use v1. Use v5 only for deterministic ids from a namespace and name.
- Pick one scheme per project and record it. UUIDs identify; they never authorise and are not secrets (`backend-security`).
- Use the native `uuid` type (16 bytes), not `varchar(36)`. Prisma: `id String @id @default(uuid()) @db.Uuid`.
- `crypto.randomUUID()` gives v4. For v7 use Prisma `@default(uuid(7))`, PostgreSQL 18+ `uuidv7()`, or the `uuid` package (also v5, `validate`, `version`); verify against the installed versions. Prefer generating v7 in app code behind an injected id-generator provider so tests can stub it.
- Validate ids at the edge (`data-validation`): 400 for malformed, 404 for unknown.

## Constraints
- Enforce integrity in the database, not only in code: `NOT NULL` by default (nullable only when absence is meaningful), `UNIQUE`, `CHECK` for ranges and state rules, foreign keys everywhere a relationship exists.
- State `onDelete` explicitly on every relation: `Restrict` by default, `Cascade` only for true ownership (children meaningless without parent), `SetNull` for optional links.
- Unique constraints that apply to a subset (for example live rows only) use a partial unique index.

## Indexing
- Index every foreign key and every column used for frequent filters, joins, and sorts. Postgres does not index FKs automatically.
- Composite index order: equality columns first, then range or sort column. An index on (a, b) serves queries on `a` and on `a, b`, not on `b` alone.
- Use partial indexes for hot subsets (`WHERE deleted_at IS NULL`) and covering indexes (`INCLUDE`, Postgres) to enable index-only scans.
- Every index costs writes and storage. Remove unused ones. Verify with `EXPLAIN (ANALYZE, BUFFERS)` on production-sized data, not guesses.
- Create indexes on large live tables with `CREATE INDEX CONCURRENTLY` (Postgres), written by hand into the migration.

## Data types
- Timestamps: `timestamptz`, stored and exchanged in UTC; format at the edge. Avoid timestamp-without-zone. Keep `createdAt` and `updatedAt` on every table.
- Money: integer minor units (cents) plus a currency code, or `numeric(p,s)`. Never floating point.
- Enums: a native enum or a lookup table plus check. Native enums are hard to remove values from; prefer a lookup table for values that change often.
- JSONB (Postgres): for genuinely schemaless or sparse attributes only. Fields you filter, join, or constrain on become columns. Index with GIN when queried. Validate its shape in code.
- Text: use `text` with a check when a length limit is a rule; do not pick arbitrary `varchar(n)` sizes.

## Delete, history, audit
- Default to hard delete unless there is a recovery, legal, or reference need. Soft delete (`deletedAt`) adds a filter to every query (`data-access-patterns`) and complicates unique constraints; use partial unique indexes.
- Audit and history: an append-only table (who, what, when, before/after) written in the same transaction as the change. Never update or delete audit rows.

## Multi-tenancy
- Choose per requirement: shared schema with a `tenantId` column (default; index it, lead composite indexes with it, include it in unique constraints), schema per tenant, or database per tenant (strongest isolation, highest operational cost).
- With shared schema, consider Postgres row-level security as defence in depth; scoping in the data layer is still required.

## Naming
- Pick one convention and keep it: snake_case plural tables and snake_case columns in the database, mapped with `@@map`/`@map` in Prisma; PascalCase models and camelCase fields in code. Name constraints and indexes consistently.

## Migrations
- Schema changes ship only as reviewed, versioned migrations committed with the code. Never edit an applied migration; add a new one. Never change shared schemas by hand or with `db push`.
- Read the generated SQL. Watch for table rewrites, long locks, and data loss (column renames generated as drop and add).
- Use expand/contract across releases: add nullable or defaulted column, deploy code writing both, backfill in batches, switch reads, then drop. Adding `NOT NULL` or a foreign key on a large table needs a staged approach (for example add constraint `NOT VALID`, then validate, in Postgres).
- Old and new code run together during deploys; every migration must be compatible with the previous release.

## Reference data, retention, PII
- Reference data (statuses, countries) lives in migrations or an idempotent seed, not manual inserts. Seed data for dev and tests is separate from reference data.
- Classify columns containing PII and sensitive data. Minimise what is stored, encrypt or hash where required, never store secrets in plain text (`secret-handling`).
- Define retention per table and implement it (scheduled purge or partition drop in `background-processing`). Back up on a schedule, and test restores; an untested backup is not a backup.

## Scaling levers (decision level)
- In order: fix queries and indexes, cache (`caching-patterns`), size connection pools, add read replicas (accept replication lag; route only tolerant reads), then partition large append-heavy tables by time or tenant, then shard. Do not take a later step without evidence the earlier ones are exhausted.

## See also

Optional, if installed: data-modelling (the data plugin) for the broader discipline this skill applies. This skill stands on its own.
