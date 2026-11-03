# squad-skills-data

Data engineering skills distinct from general backend work: SQL conventions, data modelling, database migrations, query optimisation, data integrity, search indexing, and data import and export.

Version `0.1.0`, 7 skills.

## Install

```
copilot plugin install ./plugins/data
```

## Skills

| Skill | Purpose | Load when |
|-------|---------|-----------|
| `data-import-export` | Streaming, row-level errors, idempotent imports, CSV injection | Building imports or exports |
| `data-integrity` | Constraints, transactions, idempotency, reconciliation, backups, PII | Protecting data correctness |
| `data-modelling` | Normalisation, keys, history, multi-tenancy, analytics modelling | Designing schemas |
| `database-migrations` | Forward-only migrations, expand/contract, batched backfills, lock awareness | Changing a live schema |
| `query-optimisation` | EXPLAIN, index design, keyset pagination, N+1, statistics | Diagnosing slow queries |
| `search-indexing` | Postgres full-text vs search engines, sync strategies, reindexing | Adding or maintaining search |
| `sql-conventions` | Naming, formatting, NULLs, timestamps, parameterised queries | Writing or reviewing SQL |

## Related plugins

Works well with: backend, shared, platform-engineering. Skills may mention skills from other plugins in a short "See also" note; each skill stands on its own if those plugins are not installed.
