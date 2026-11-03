---
name: caching-patterns
description: Caching for NestJS APIs on Fastify with Redis - when to cache, HTTP caching (Cache-Control, ETag), application caching with @nestjs/cache-manager, cache-aside versus read-through versus write-through, TTLs, key design, invalidation, stampede protection, negative caching, in-memory versus distributed, consistency, Redis memory and eviction, hit-rate observability, testing, plus a short performance triage. Load when adding or debugging a cache, setting HTTP cache headers, or when an endpoint is slow.
---

# Caching patterns

Builds on `nestjs-patterns`, `data-access-patterns`, and `fastify-adapter`. Verify `@nestjs/cache-manager` and Keyv/Redis store APIs (including whether TTL is in seconds or milliseconds) against the installed versions.

## When to cache
- Measure first (`backend-observability`): cache only reads that are slow or hot, tolerate staleness, and are read far more than written. A cache is added complexity and a consistency risk; fix queries and indexes before it.
- Define the acceptable staleness per resource before choosing a TTL.

## HTTP caching
- Set `Cache-Control` explicitly on cacheable GETs (`public, max-age=...` for shared data, `private` for user-specific data, `no-store` for sensitive data).
- Use `ETag` with `If-None-Match` and return 304 to save payload. Use `Vary` for headers that change the response (for example `Accept-Language`, `Accept-Encoding`).
- Never allow shared caches or CDNs to store authenticated per-user responses; mark them `private` or `no-store`.

## Application cache
- Use `@nestjs/cache-manager` with a Redis store for multi-instance deployments. In-memory is acceptable only for single-instance or small per-process data (config, reference data) where instances may briefly disagree.
- Inject the cache into services behind a small wrapper; do not scatter cache calls through controllers. `CacheInterceptor` suits simple whole-response GETs; avoid it for user-specific or parameter-heavy routes unless the key is verified.

## Strategies
- Cache-aside (default): read cache, on miss load from source and store; writes update the source then invalidate.
- Read-through: the cache layer loads on miss; fewer call sites, needs a loader abstraction.
- Write-through: write source and cache together; consistent but slower writes. Avoid write-behind unless loss is acceptable.

```ts
async getProduct(id: string) {
  const key = `v1:tenant:${tenantId}:product:${id}`;
  const hit = await this.cache.get<ProductDto>(key);
  if (hit) return hit;
  const product = await this.repo.find(id);
  await this.cache.set(key, product, ttlMs);
  return product;
}
```

## Keys and TTL
- Keys include everything the response depends on: tenant, user (if per-user), locale, and normalised query parameters. A missing dimension leaks data between users.
- Namespace and version keys (`v1:...`) so a schema or shape change is a prefix bump, not a flush.
- Always set a TTL, even with event invalidation, as a safety net. Match it to tolerated staleness; add jitter so keys do not expire together.
- Never put per-user or tenant-private data in a key space or layer shared without that scoping (`backend-security`).

## Invalidation
- TTL only: simplest, bounded staleness.
- Event-driven: delete or update the key on the write path (or from a domain event) after the transaction commits, not before.
- Version or tag bump: store a version number per entity group in the key; increment to invalidate many keys at once without scanning.
- Do not use `KEYS` in Redis; use `SCAN` with care or prefer version bumps.

## Stampede protection
- On a hot key expiry, many requests hit the source at once. Mitigate with: request coalescing (share one in-flight promise per key per process), a short distributed lock for the loader, stale-while-revalidate (serve stale, refresh in background), and TTL jitter.
- Whatever the lock does must itself have a timeout.

## Negative caching
- Cache "not found" results with a short TTL to absorb repeated misses; invalidate on create. Do not cache errors or transient failures.

## Consistency
- Caches are eventually consistent. Do not use cached data for authorisation decisions with strict revocation needs, or for reads that must follow a write (read-your-writes) unless you invalidate or bypass.
- Treat the cache as disposable: the service must work, more slowly, if Redis is down. Set short Redis timeouts and fail open to the source, with a log and metric.

## Redis basics
- Set `maxmemory` and an eviction policy deliberately: `allkeys-lru` (or lfu) for a pure cache; avoid `noeviction` for caches. Do not share an instance holding queues (`background-processing`) with an evicting cache.
- Keep values small; store only needed fields, serialised consistently. Monitor memory, evictions, and latency.

## Observability and testing
- Emit hit, miss, and error counts per cache name, and load duration (`backend-observability`). Alert on a falling hit rate.
- Test hit, miss, expiry, invalidation, and key isolation between users and tenants against a real Redis or an in-memory store behind the same interface (`backend-testing`, `test-discipline`). Use fake timers for TTL.

## Performance triage
- Measure p95 and p99 per route before changing anything; compare before and after under a production-like load test (k6, autocannon).
- Database first: N+1, missing indexes, over-fetching, pool size (`data-access-patterns`, `database-design`).
- Then the event loop: no sync fs or crypto, large JSON, or heavy loops in handlers; offload CPU work to worker threads or a queue and return 202 (`nodejs-conventions`, `background-processing`).
- Then payloads: compress text responses (`@fastify/compress`), stream large downloads (`StreamableFile`), return only needed fields, paginate.
- Run independent awaits with bounded `Promise.all`; set timeouts on every outbound call; scale horizontally with stateless instances.

## See also

Optional, if installed: performance-engineering (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
