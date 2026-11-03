---
name: sql-conventions
description: SQL conventions for PostgreSQL-backed TypeScript services - snake_case naming, singular vs plural tables, key and index naming, formatting, explicit column lists and no SELECT *, explicit joins, CTE usage, NULL handling, timestamptz in UTC, parameterised queries only, text vs varchar, enums vs lookup tables, schema comments, and transaction and isolation basics. Load when writing or reviewing SQL, naming schema objects, using raw SQL from Prisma, or choosing column types.
---

# SQL conventions

Foundation for `data-modelling`, `database-migrations`, and `query-optimisation`. PostgreSQL is the default dialect; verify behaviour against the installed version.

## Naming
- Use `snake_case` for tables, columns, indexes, constraints. Unquoted lowercase identifiers only; never rely on quoted mixed case.
- Pick one table-name rule (plural `users` or singular `user`) and apply it everywhere. Avoid reserved words such as `user` and `order` by choosing plural or a prefix.
- Primary key `id`; foreign key `<referenced_singular>_id` (`customer_id`). Booleans read as predicates (`is_active`); timestamps end in `_at`, dates in `_on`.
- Name constraints and indexes explicitly: `pk_<table>`, `fk_<table>_<col>`, `uq_<table>_<cols>`, `ix_<table>_<cols>`, `ck_<table>_<rule>`. Stable names make migrations and error handling predictable.
- With Prisma, map camelCase fields to snake_case with `@map` and `@@map` so raw SQL and the schema agree.

## Formatting
- Keywords uppercase, one clause per line, one selected column per line, trailing commas avoided, consistent indentation.
- List columns explicitly. Never `SELECT *` in application code or views; it breaks on schema change and defeats covering indexes. `INSERT` always names its columns.
- Use explicit `JOIN ... ON`; never comma joins. Qualify every column with a table alias once more than one table is involved.
```sql
SELECT o.id, o.placed_at, c.email
FROM orders AS o
JOIN customers AS c ON c.id = o.customer_id
WHERE o.status = $1
ORDER BY o.placed_at DESC;
```

## CTEs and subqueries
- Use CTEs to name steps and improve readability; keep each small and single-purpose. Whether a CTE is inlined or materialised depends on version and flags, so check with `EXPLAIN` (`query-optimisation`).
- Do not use CTEs as an optimisation fence by habit. Prefer `EXISTS` over `IN (subquery)` for existence checks.
- Recursive CTEs need a termination condition and a depth guard.

## NULL handling
- `NULL` means unknown. Use `IS NULL` and `IS NOT NULL`; `= NULL` never matches. Use `IS DISTINCT FROM` for null-safe comparison.
- Declare `NOT NULL` by default and add a `DEFAULT` where sensible. Allow NULL only when absence is meaningful.
- `NOT IN` with a subquery that can return NULL yields no rows; use `NOT EXISTS`. Use `COALESCE` at the edge, not to hide modelling gaps.
- Aggregates skip NULLs; `COUNT(*)` and `COUNT(col)` differ.

## Types
- Timestamps: `timestamptz`, stored and compared in UTC; convert to local time only at presentation. Avoid `timestamp without time zone`. Use `date` for calendar dates.
- Text: use `text`; use `varchar(n)` or a `CHECK` only when the limit is a real business rule. Other engines differ, so verify.
- Money: `numeric(p,s)` or integer minor units, never `float`. Identifiers: `uuid` or `bigint` (`data-modelling`).
- Enums vs lookup tables: native enums or `CHECK` for small, stable sets; a lookup table with a foreign key when values change, carry attributes, or are managed by users. Adding enum values is easy, removing or renaming is hard (`database-migrations`).
- Comment non-obvious objects: `COMMENT ON TABLE`, `COMMENT ON COLUMN` for units, meaning, and ownership.

## Parameterised queries
- Pass values only as bound parameters (`$1`, `$2`); never concatenate or template user input into SQL. Identifiers cannot be parameters: allowlist them.
- Prisma raw escape hatch: use the tagged template (`$queryRaw`) so values are bound; never `$queryRawUnsafe` with user input. Type the result explicitly.
```ts
const rows = await prisma.$queryRaw<{ id: string }[]>`SELECT id FROM orders WHERE status = ${status}`
```
- Never log parameter values that may hold secrets or PII (`secret-handling`).

## Transactions and isolation
- Group statements that must succeed together in one transaction; keep it short, with no network calls or user waits inside.
- PostgreSQL defaults to read committed: each statement sees data committed before it started. Use repeatable read or serializable for read-then-write invariants, and be ready to retry on serialization failure.
- Use `SELECT ... FOR UPDATE` (with `SKIP LOCKED` for queues) for explicit row locks. Acquire locks in a consistent order to avoid deadlocks.
- Enforce rules with constraints, not only application checks (`data-integrity`).
