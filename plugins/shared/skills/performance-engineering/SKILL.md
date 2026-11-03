---
name: performance-engineering
description: Technology-neutral performance discipline - measuring before optimising, budgets and SLOs, profiling to find the real bottleneck (CPU, memory, IO, network, rendering), algorithmic complexity versus constant factors, caching and batching principles, latency percentiles, load testing basics, regression guards in CI, trade-offs against maintainability, avoiding premature optimisation, and writing up findings. Load when something is slow, when setting performance targets, when planning load tests, or when reviewing a change that claims a performance benefit.
---

# Performance Engineering

Builds on `software-architecture` and `debugging`. Use `software-testing-strategy` for where benchmarks and load tests sit. Frontend, backend, AI, and game plugins apply this to their runtimes.

## Measure first
- No optimisation without a measurement before and after. Intuition about hot spots is usually wrong.
- Define the metric, workload, environment, and acceptance threshold before changing code.
- Measure on realistic data and hardware. Warm up, repeat runs, report variance, not a single number.
- Change one thing at a time so the effect is attributable.

## Budgets and SLOs
- State targets as numbers: p95 latency under 200 ms, frame time under 16.6 ms, bundle under 250 KB, memory under 512 MB.
- Derive budgets from user experience or business need, then split across components.
- Alert on SLO burn, not on raw averages.

## Find the bottleneck
- Profile, do not guess. Use sampling profilers, tracing, flame graphs, query plans, and browser or engine profilers.
- Classify the limit: CPU, memory and allocation, disk or database IO, network round trips, lock contention, rendering or GPU.
- Fix the largest contributor first; re-profile because the bottleneck moves.
- A fast component behind a slow dependency is not the problem. Follow the critical path.

## Algorithms before constants
- Check complexity first: an O(n^2) loop or N+1 query beats any micro-tuning.
- Then reduce work: avoid repeated computation, unnecessary allocation, and over-fetching.
- Only then tune constants (data layout, vectorisation, pooling).

```ts
// N+1: one query per order
for (const o of orders) o.user = await users.find(o.userId);
// batched: one query
const byId = await users.findMany(orders.map(o => o.userId));
```

## Caching and batching
- Cache only after measuring a repeated, expensive, tolerably stale computation.
- Define key, TTL, size bound, and invalidation up front. Unbounded caches are memory leaks.
- Guard against stampedes (request coalescing, jittered expiry).
- Batch round trips, writes, and renders; stream large results rather than buffering them.

## Latency
- Report percentiles (p50, p95, p99), never averages alone. Tail latency dominates user experience at scale.
- Watch queueing: latency rises sharply near saturation. Keep headroom.

## Load testing
- Model realistic traffic mix, think time, data volume, and ramp-up. Test in a production-like environment.
- Find the knee point and failure mode: does it degrade gracefully or collapse?
- Never load test shared or production systems without agreement and safeguards.

## Regression guards
- Track key benchmarks and budgets in CI; fail or warn on regression beyond a tolerance.
- Keep benchmarks deterministic and small enough to run routinely; run heavier suites on a schedule.

## Trade-offs
- Do not optimise code that is not on a measured hot path. Clarity wins elsewhere.
- Document why an optimisation exists and what it costs in complexity; keep the simple version in a comment or test as the reference.
- Remove optimisations that no longer pay off.

## Write up
- Record: symptom, measurement method, root cause, change, before/after numbers, and remaining risk. Put it in the PR or `technical-documentation`.
