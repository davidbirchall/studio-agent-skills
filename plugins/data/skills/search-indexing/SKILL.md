---
name: search-indexing
description: Search design and indexing for Node and PostgreSQL systems - choosing database search vs a dedicated engine (OpenSearch, Meilisearch, Typesense), Postgres full-text basics (tsvector, GIN), the index as derived data with the database as source of truth, sync strategies (dual-write pitfalls, outbox, CDC, batch reindex), analysers, tokenisation and language, relevance tuning, facets and filters, typo tolerance, zero-downtime reindex with aliases, consistency lag, permission-aware search, and monitoring index drift. Load when adding search, choosing a search engine, building or syncing an index, tuning relevance, or debugging missing or stale results.
---

# Search indexing

Builds on `sql-conventions`, `data-modelling`, `query-optimisation`, and `data-integrity`. Verify features and APIs against current docs for the engine and version in use.

## Database or engine
- Start with Postgres when data is small to moderate, queries are keyword-based, and results must be transactionally fresh. No extra infrastructure, no sync.
- Move to a dedicated engine when you need typo tolerance, fuzzy ranking, rich facets, autocomplete, multi-language analysis, or load that hurts the primary database.
- Choose on requirements and operating cost, not fashion. Keep the engine behind an interface so it can be swapped.

## Postgres full-text
- Store a `tsvector`, index it with GIN, query with `@@`:
```sql
ALTER TABLE articles ADD COLUMN search tsvector GENERATED ALWAYS AS
  (setweight(to_tsvector('english', title), 'A') || setweight(to_tsvector('english', body), 'B')) STORED;
CREATE INDEX articles_search_idx ON articles USING GIN (search);
SELECT id FROM articles WHERE search @@ websearch_to_tsquery('english', $1)
ORDER BY ts_rank(search, websearch_to_tsquery('english', $1)) DESC LIMIT 20;
```
- Pick the text search configuration per language; do not mix languages in one column without a language column.
- Use `websearch_to_tsquery` for user input; never build tsquery strings by concatenation.
- Prisma lacks first-class tsvector support; add columns and indexes in raw SQL migrations and query with `$queryRaw` using parameters (`database-migrations`).
- Trigram indexes (`pg_trgm`) cover substring and basic fuzzy matching.

## Index is derived data
- The database is the source of truth; the index must be rebuildable from it at any time. Never write data only to the index.
- Index a denormalised document shaped for search, with the entity id, a version or `updated_at`, and only the fields needed. Fetch full records from the database by id.

## Sync strategies
- Avoid naive dual write (write DB, then write index): either step can fail and the two diverge silently.
- Prefer a transactional outbox: write an outbox row in the same transaction, a worker publishes it to the index with retries; handlers are idempotent and use the entity version so older events never overwrite newer ones.
- Change data capture (logical replication) is an alternative when you cannot touch application writes.
- Keep a batch reindex path for backfills and repair; run it in pages by id, rate limited.
- Deletes must propagate; test them.

## Analysis and relevance
- Analysers decide matching: tokenisation, lowercase, accent folding, stemming, stop words, synonyms. Choose per field and per language, and use the same analysis at index and query time unless deliberate.
- Tune with a fixed set of real queries and expected results; change one thing at a time and measure.
- Boost titles over bodies, use recency or popularity as bounded signals, and avoid large unexplained boosts.
- Typo tolerance: allow edit distance scaled to term length, none for very short terms or identifiers (SKUs, ids): exact fields get exact matching.
- Facets and filters belong on keyword or numeric fields, not analysed text; cap facet cardinality.

## Zero-downtime reindex
- Build a new versioned index (`items_v2`) alongside the live one, backfill, apply ongoing changes to both, verify counts and sample queries, then switch an alias atomically. Keep the old index until confident; then drop it.
- Mapping changes that cannot be applied in place require this path; plan for it from the start.

## Consistency and permissions
- Search is eventually consistent. Show the user's own writes from the database, or accept and document the lag; monitor lag as a metric.
- Enforce authorisation in the query: store tenant, owner, or ACL fields in the document and always apply them as filters. Never filter after retrieval; counts and facets leak.
- Revoking access must update the index promptly; treat it as a high-priority event.

## Monitoring
- Track index lag, outbox backlog, failed events, query latency, and zero-result rate.
- Run a scheduled drift check: compare counts and sampled ids/versions between database and index, and repair via reindex. Alert on thresholds.
- Test with a real engine or Postgres in integration tests (`test-discipline`).
