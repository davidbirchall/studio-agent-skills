---
name: data-import-export
description: Bulk data import and export for Node and PostgreSQL - CSV, JSON and NDJSON formats, streaming instead of buffering, row-level validation with error reports, idempotent re-runnable imports, staging tables with merge or upsert, batch sizes and transactions, encoding, locale and timezone pitfalls, large files, deduplication, mapping and transform layers, dry-run mode, progress and resumability, export pagination and consistency, PII in exports, signed download links, and CSV formula injection protection. Load when building file imports or exports, bulk loading data, migrating data between systems, or debugging bad or partial loads.
---

# Data import and export

Builds on `sql-conventions`, `data-modelling`, `data-integrity`, and `query-optimisation`. Verify library and PostgreSQL feature details against current docs.

## Formats
- NDJSON for machine pipelines and large data: one record per line, streamable, easy to resume. JSON arrays force whole-file parsing; avoid for large data.
- CSV for human and spreadsheet exchange: require a header row, a documented column list, UTF-8, and RFC 4180 quoting. Use a real parser, never `split(',')`.
- Version the file schema; reject unknown versions and unexpected columns explicitly.

## Streaming
- Never read a whole file into memory. Pipe a read stream through parser and transform to a writer with `stream/promises` `pipeline`, so backpressure and errors propagate.
```ts
await pipeline(createReadStream(path), parse({ columns: true }), validateStage, batchWriter)
```
- Enforce limits: max file size, row count, field length. Accept uploads to object storage first and process in a background job, not in the request.

## Validation and errors
- Validate every row against a schema before writing; check types, ranges, enums, and referential existence.
- Collect row-level errors as `{ row, column, code, message }` and produce a downloadable error report. Decide up front: all-or-nothing, or import valid rows and report the rest.
- Never echo secrets or full PII in error reports or logs (`secret-handling`).

## Idempotent and re-runnable
- Define a natural or external key per record. Re-running the same file must produce the same end state, with no duplicates.
- Record each import run (id, file hash, status, counts) and reject or flag a repeated file hash.
- Deduplicate within the file and against existing data using the key; define which row wins.

## Staging and merge
- Load raw rows into a staging table (or `UNLOGGED` table), validate and transform in SQL, then merge:
```sql
INSERT INTO products (sku, name, price_cents)
SELECT sku, name, price_cents FROM staging_products WHERE run_id = $1
ON CONFLICT (sku) DO UPDATE SET name = EXCLUDED.name, price_cents = EXCLUDED.price_cents
WHERE (products.name, products.price_cents) IS DISTINCT FROM (EXCLUDED.name, EXCLUDED.price_cents);
```
- Use `COPY` for large loads and multi-row inserts otherwise; avoid one query per row. Prisma `createMany` suits moderate batches; verify its behaviour on conflicts.
- Drop or defer expensive indexes only for very large initial loads and rebuild afterwards (`query-optimisation`).

## Batches, progress, resumability
- Commit in batches (hundreds to a few thousand rows; measure) so a failure loses little and locks stay short. Keep each batch idempotent.
- Persist a checkpoint (last row or byte offset, run status) so a failed run resumes instead of restarting. Expose progress counts: read, valid, written, skipped, failed.
- Dry run: execute parsing, validation, and merge planning in a rolled-back transaction or against staging, and return the counts and errors without changing live tables.

## Encoding, locale, time
- Detect and reject BOM surprises and non-UTF-8 input, or convert explicitly. Strip a BOM when present.
- Parse numbers and dates with an explicit format, never the server locale (`1.234,5` vs `1,234.5`; `03/04/2024`). Prefer ISO 8601.
- Timestamps carry an offset or an agreed timezone; store UTC in `timestamptz`. Preserve leading zeros by treating identifiers as strings.
- Normalise whitespace and case where the key is matched; treat empty string and null distinctly and document it.

## Mapping layer
- Keep a declarative mapping from source columns to target fields with per-field transforms, separate from persistence code. Unit test it with fixtures including bad rows (`test-discipline`).

## Export
- Stream results with a cursor or keyset pagination (`query-optimisation`); do not use deep `OFFSET`. Run large exports as background jobs and notify when done.
- For consistency, export from a single snapshot (one transaction at `REPEATABLE READ`) or filter on a fixed `updated_at` cutoff, and state which in the file metadata.
- Deliver files via short-lived signed URLs to private storage, scoped to the requester; never public links. Expire and delete files.
- Apply authorisation and column selection to exports as strictly as to the API; exclude or mask PII not needed, and audit who exported what (`data-integrity`).
- CSV injection: for cells beginning with `=`, `+`, `-`, `@`, tab, or carriage return, prefix with a single quote or otherwise neutralise, and apply it to every user-controlled text field.

## See also

Optional, if installed: application-security (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
