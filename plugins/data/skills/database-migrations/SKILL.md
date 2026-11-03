---
name: database-migrations
description: Safe schema migrations for PostgreSQL - versioned forward-only migrations, one change per migration, expand/contract for zero-downtime deploys, batched backfills, lock awareness (concurrent index creation, NOT NULL and default adds), reversible vs roll-forward policy, testing on production-sized data, ordering and conflicts in teams, seed vs migration data, never editing applied migrations, and Prisma migrate workflow notes. Load when changing a schema, writing a migration, planning a backfill, adding indexes or constraints to live tables, or resolving migration conflicts.
---

# Database migrations

Builds on `sql-conventions` and `data-modelling`. Verify lock behaviour and Prisma commands against the installed versions.

## Principles
- Every schema change ships as a versioned migration file in the repo, applied in order by tooling, never by hand on a shared database.
- Never edit or delete an applied migration. Fix forward with a new one.
- One logical change per migration so failures are easy to diagnose and revert.
- Migrations are forward-only by default: roll forward with a corrective migration. Write a down script only when it is tested and truly safe (adding a nullable column); never for data loss.
- Run migrations as a separate deploy step with a privileged role, before the new app version starts, with a lock timeout.

## Expand and contract
Deploys overlap old and new code, so every step must work with both.
1. Expand: add the new nullable column, table, or index. Old code is unaffected.
2. Dual write: new code writes both shapes and reads the old one or the new with fallback.
3. Backfill existing rows in batches.
4. Switch reads to the new shape; verify.
5. Contract: in a later release, drop the old column or table.
- Rename = add, copy, switch, drop. Never rename or drop in the same release that stops using the old name.

## Lock awareness
- Take `ACCESS EXCLUSIVE` locks briefly. Set `lock_timeout` (and `statement_timeout`) so a blocked migration fails rather than queuing all traffic behind it.
- Create indexes on live tables with `CREATE INDEX CONCURRENTLY`. It cannot run inside a transaction block, so it needs its own migration; a failed run leaves an invalid index to drop and retry.
- Adding a `NOT NULL` column needs a default or backfill. Recent versions make constant defaults cheap, older ones rewrite the table; verify. Safer path: add nullable, backfill, add `CHECK (col IS NOT NULL) NOT VALID`, `VALIDATE CONSTRAINT`, then set `NOT NULL`.
- Add foreign keys and checks as `NOT VALID`, then `VALIDATE CONSTRAINT` separately (lighter lock).
- Changing a column type often rewrites the table; use expand and contract instead.
- Never run long data updates in the same transaction as DDL.

## Backfills
- Batch by primary key range (for example 1,000 to 10,000 rows), commit each batch, pause between batches, and make the job idempotent and resumable.
```sql
UPDATE orders SET total_minor = total_cents
WHERE id IN (SELECT id FROM orders WHERE total_minor IS NULL ORDER BY id LIMIT 5000);
```
- Run backfills as a script or job, not inside the schema migration, and monitor replication lag and locks.

## Testing
- Run every migration against a copy of production-sized data (or generated equivalent) and record duration and locks taken. A migration fast on 100 rows can block for minutes on 100 million.
- In CI, apply all migrations to an empty database and compare the result with the declared schema; fail on drift (`test-discipline`).
- Rehearse the backfill and the contract step, not only the expand step.

## Branches and ordering
- Timestamp-prefixed migration names order by creation. Two branches adding migrations will conflict on content, not names: rebase, regenerate or reorder before merge, and re-run on a fresh database.
- Merge schema changes quickly; long-lived branches with migrations cause conflicts. Never renumber applied migrations.

## Seed vs migration data
- Reference data the application requires (roles, lookup values) goes in migrations, written idempotently (`INSERT ... ON CONFLICT DO NOTHING`).
- Dev and demo data goes in a separate seed script, never run in production. No secrets or real personal data in either (`secret-handling`).

## Prisma notes
- `prisma migrate dev` generates and applies migrations locally and may reset the dev database; `prisma migrate deploy` applies pending migrations in CI and production. Never run `dev` or `db push` against production.
- Review generated SQL before committing; Prisma will emit a plain `CREATE INDEX` and potentially destructive drops. Edit the SQL by hand for `CONCURRENTLY`, `NOT VALID`, or batched steps; use `--create-only` to edit first.
- Do not modify applied migration files; checksums are recorded and drift is reported. Use `migrate resolve` only to reconcile a known failed or manually applied state.

## See also

Optional, if installed: deployment-patterns (the platform-engineering plugin) for the broader discipline this skill applies. This skill stands on its own.
