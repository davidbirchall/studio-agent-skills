---
name: data-integrity
description: Data integrity for PostgreSQL and Prisma in Node services - database constraints (NOT NULL, UNIQUE, CHECK, foreign keys) as source of truth, transactions and isolation levels, idempotency keys, optimistic vs pessimistic locking, race conditions and unique-violation handling, referential actions, app vs database validation layers, orphan detection, reconciliation jobs, backups and restore testing, PII handling, retention and deletion, audit trails, and data quality checks. Load when designing constraints, handling concurrent writes, adding idempotency, planning backups or deletion, or investigating inconsistent data.
---

# Data integrity

Builds on `sql-conventions`, `data-modelling`, `database-migrations`, and `query-optimisation`. Verify behaviour against the installed PostgreSQL and Prisma versions.

## Constraints are the source of truth
- Enforce every invariant that can be expressed in the database: `NOT NULL`, `UNIQUE`, `CHECK`, foreign keys. Application code may be bypassed by scripts, other services, and bugs.
- Express rules in the schema, not only in validators:
```sql
ALTER TABLE orders ADD CONSTRAINT orders_total_nonneg CHECK (total_cents >= 0);
CREATE UNIQUE INDEX users_email_lower_key ON users (lower(email)) WHERE deleted_at IS NULL;
```
- Prisma cannot declare `CHECK` or partial/expression indexes in the schema; add them in raw SQL migrations (`database-migrations`).
- Add constraints to existing data in two steps: `NOT VALID`, clean up, then `VALIDATE CONSTRAINT`.

## Validation layers
- App validation gives fast, friendly errors; database constraints give the guarantee. Keep both, and map constraint violations to domain errors.
- Never rely on check-then-insert in app code; it races.

## Transactions and isolation
- Wrap multi-statement invariants in one transaction; keep it short and free of network calls.
- Default `READ COMMITTED` is fine for most work. Use `REPEATABLE READ` or `SERIALIZABLE` for read-then-write invariants, and retry on serialization failure (SQLSTATE `40001`) and deadlock (`40P01`).
```ts
await prisma.$transaction(async (tx) => { /* reads and writes */ }, { isolationLevel: 'Serializable' })
```
- Run side effects (email, events) after commit, or via an outbox row written in the same transaction.

## Races and unique violations
- Let the unique constraint decide the winner, then handle the violation (Prisma `P2002`) as "already exists", not as a 500.
- Prefer atomic statements: `INSERT ... ON CONFLICT`, `UPDATE ... WHERE balance >= $1`, over read-modify-write.
- Optimistic locking: a `version` column; `UPDATE ... WHERE id = $1 AND version = $2`; zero rows updated means conflict (409). Use when conflicts are rare.
- Pessimistic locking: `SELECT ... FOR UPDATE` (or `SKIP LOCKED` for queues) inside a transaction. Use when conflicts are frequent; lock rows in a consistent order to avoid deadlocks.

## Idempotency
- Accept a client `Idempotency-Key` on non-idempotent writes. Store key, request hash, and response under a unique constraint; replay the stored response, and reject the same key with a different payload.
- Consumers of queues and webhooks dedupe on a unique message id.

## Referential actions
- Choose per relation deliberately: `RESTRICT` by default, `CASCADE` only for true ownership (children meaningless alone), `SET NULL` for optional links. Never leave it implicit.
- Index every foreign key column (`query-optimisation`).
- Prefer soft delete only where history is needed, and make uniqueness constraints aware of it (partial index above).

## Detection and reconciliation
- Run scheduled checks for orphans, duplicates, and broken invariants:
```sql
SELECT c.id FROM child c LEFT JOIN parent p ON p.id = c.parent_id WHERE p.id IS NULL;
```
- Reconcile derived or external data (balances, counters, third-party state) against the source on a schedule; alert on drift, repair idempotently, and log each fix.
- Data quality checks: null rates, range and enum validity, row-count deltas, freshness. Fail loudly and report counts, not just pass/fail.

## Backups and restore
- Automate backups with point-in-time recovery; define RPO and RTO.
- A backup is untested until restored: restore to a scratch environment on a schedule, run integrity checks and a smoke test, and record the time taken.
- Encrypt backups and restrict access (`secret-handling`).

## PII, retention, deletion
- Inventory PII columns; collect the minimum, and mark them in the schema docs.
- Define retention per table and enforce it with a job. Deletion requests must cover replicas, search indexes (`search-indexing`), exports, and backups expiry.
- Never log or seed PII; use masked or synthetic data outside production.
- Encrypt sensitive fields where required; keep keys outside the database.

## Audit trails
- Record who, what, when, and old/new values for sensitive changes, in an append-only table written in the same transaction (trigger or app layer).
- Restrict update and delete on audit tables; do not store secrets or full PII in them.

## Testing
- Test constraints against a real PostgreSQL, not mocks: assert violations are raised and mapped, and concurrent writers produce one winner (`test-discipline`).
