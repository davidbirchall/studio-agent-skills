---
name: query-optimisation
description: Diagnose PostgreSQL slowness with measured plans, EXPLAIN ANALYZE, indexes, joins, N+1 queries, pagination, pooling, and statistics before changing code. Load when a query, endpoint, report, or database is slow or when designing indexes.
---

# Query optimisation

Builds on `sql-conventions` and `data-modelling`. Index creation on live tables follows `database-migrations`. Verify settings and plan node names against the installed version.

## Measure first
- Find the real offenders before changing anything: slow query log (`log_min_duration_statement`) and `pg_stat_statements` ordered by total time, not just worst single call.
- Reproduce with production-like data volume and statistics; plans on tiny tables mislead.
- Change one thing at a time and compare before and after plans and timings.

## Reading plans
- `EXPLAIN (ANALYZE, BUFFERS)` executes the query; wrap writes in a transaction you roll back.
- Compare estimated rows with actual rows per node. Large gaps mean stale or insufficient statistics, or correlated columns.
- Watch for: `Seq Scan` on large tables with selective filters, `Rows Removed by Filter` high, sorts spilling to disk, nested loops with large loop counts, high `shared read` versus `shared hit`.
- Cost is relative; judge by actual time and buffers.

## Index design
- Index columns used in `WHERE`, `JOIN`, and `ORDER BY`, in that order of importance, and every foreign key you join on.
- Composite order: equality columns first, then range or sort column. `(tenant_id, status, created_at)` serves `WHERE tenant_id = $1 AND status = $2 ORDER BY created_at`. A leading column unused by the query makes the index unusable for it.
- Partial indexes for hot subsets: `CREATE INDEX ix_jobs_pending ON jobs (run_at) WHERE status = 'pending'`.
- Covering indexes with `INCLUDE` enable index-only scans for hot reads; they need a vacuumed visibility map.
- Low-selectivity columns (booleans) alone are poor indexes; combine or make partial. Every index slows writes and uses space: drop unused ones (`pg_stat_user_indexes`).
- Other types (GIN for JSONB and arrays, BRIN for huge ordered tables, GiST) fit specific shapes; see `search-indexing` for text.

## Sargable predicates
- Do not wrap indexed columns in functions or casts: `WHERE lower(email) = $1` ignores an index on `email`. Index the expression, or store normalised data.
- Avoid leading-wildcard `LIKE '%x'`, implicit type mismatches, and `OR` across different columns when `UNION ALL` or separate indexes serve better.
- Use `EXISTS` instead of counting to test presence; select only needed columns.

## N+1 and batching
- One query per row in a loop is the usual cause of slow endpoints. Fetch related rows with a join, `WHERE id = ANY($1)`, or an ORM include/batching loader; confirm in query logs that the count is constant.
- Batch inserts and updates (multi-row `INSERT`, `COPY` for bulk, `data-import-export`) instead of per-row round trips. Chunk large `IN` lists.

## Pagination
- Offset pagination scans and discards skipped rows, so cost grows with page depth and results shift under writes. Use only for small, bounded sets.
- Keyset pagination: filter on the last seen sort key with a unique tiebreaker and a matching index.
```sql
SELECT id, created_at FROM events
WHERE (created_at, id) < ($1, $2)
ORDER BY created_at DESC, id DESC
LIMIT 50;
```
- Avoid exact `COUNT(*)` on large tables per request; use estimates or drop totals.

## Joins, statistics, vacuum
- The planner picks nested loop, hash, or merge join by estimates; fix bad estimates (`ANALYZE`, higher statistics target on skewed columns, extended statistics) before forcing hints.
- Autovacuum reclaims dead tuples and updates statistics. Tune per hot table rather than disabling; watch bloat, long-running transactions, and idle-in-transaction sessions that block cleanup.

## Connections
- Postgres connections are costly. Size the app pool small (roughly cores-driven, not request-driven) and put a pooler such as PgBouncer in front for many instances or serverless. Transaction-mode pooling can break session features and prepared statements; check client compatibility (Prisma needs pooler-specific settings).
- Set `statement_timeout` and `idle_in_transaction_session_timeout`; keep transactions short.

## Caching last
- Cache only after queries and indexes are fixed. Define invalidation and staleness limits, key by tenant, and handle stampedes. Prefer materialised views or summary tables for expensive aggregates.

## See also

Optional, if installed: performance-engineering (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
