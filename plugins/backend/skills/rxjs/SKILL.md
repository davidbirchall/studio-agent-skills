---
name: rxjs
description: RxJS in NestJS APIs - when to use observables versus async/await, interceptor and microservice patterns, operator choice (map, switchMap, mergeMap, catchError, timeout, retry), subscription leaks, firstValueFrom, SSE, and error handling. Load when writing interceptors, SSE endpoints, HttpService calls, or other observable code.
---

# RxJS in APIs

Builds on `nestjs-patterns`. Verify imports against the installed RxJS version (7+ exports operators from `rxjs`).

## Default to async/await
- Use `async`/`await` for request/response logic. Use RxJS only where the framework gives you an observable: interceptors (`next.handle()`), `@Sse()`, `ClientProxy` microservice calls, `HttpService`, and genuine streams.
- Convert at the boundary: `await firstValueFrom(obs$)` for one value, `lastValueFrom` for the final value. Pass `{ defaultValue }` if the stream may complete empty.

## Operator choice
- `map` transforms values. `tap` is for side effects (logging); never mutate there.
- `switchMap`: cancel the previous inner call (latest wins). `mergeMap`: concurrent (set a concurrency limit). `concatMap`: preserve order.
- `catchError`: return a fallback or rethrow a mapped error (`throwError(() => new X())`). Always return an observable.
- `timeout` for calls that can hang; `retry({ count, delay })` only for idempotent operations (`api-design`).

## Interceptors
```ts
intercept(ctx: ExecutionContext, next: CallHandler): Observable<unknown> {
  const start = Date.now()
  return next.handle().pipe(tap(() => this.log(ctx, Date.now() - start)))
}
```
Keep them small and side-effect focused.

## Leaks and safety
- Never `subscribe()` in a service method and drop the subscription. Return the observable or use `firstValueFrom`.
- Long-lived subscriptions started in `OnModuleInit` must be torn down in `OnModuleDestroy` (`takeUntil` a destroy subject, or keep and unsubscribe).
- Shared streams: use `share()` or `shareReplay({ bufferSize: 1, refCount: true })` deliberately.
- SSE: complete the stream on client disconnect and emit heartbeats if proxies idle out.

## Testing
- Test observable code with `firstValueFrom` in Vitest, or `TestScheduler` for timing (`backend-testing`).

### Marble testing with Vitest
```ts
import { TestScheduler } from 'rxjs/testing'
const scheduler = new TestScheduler((actual, expected) => expect(actual).toEqual(expected))

it('retries once then succeeds', () => {
  scheduler.run(({ cold, expectObservable }) => {
    const src = cold('--a|')
    expectObservable(src.pipe(map((v) => v.toUpperCase()))).toBe('--A|')
  })
})
```
- Inside `run`, time is virtual; do not mix with `vi.useFakeTimers`. Test errors with `#` and completion with `|`.
- For services that call `HttpService`, mock with `of(response)` or `throwError(() => err)`; assert the mapped result and the error path.

## Operator decision table
| Need | Operator | Note |
|---|---|---|
| Latest wins, drop stale work | `switchMap` | Search-as-you-type; unsafe for writes |
| Keep order, one at a time | `concatMap` | Safe default for writes |
| Parallel, order irrelevant | `mergeMap(fn, n)` | Always cap concurrency `n` |
| Ignore new while busy | `exhaustMap` | Submit buttons, token refresh |
| Wait for all, one result | `forkJoin` | Each source must complete |
| Latest of several | `combineLatest` | Emits after all have emitted |

## Error handling and retry
```ts
this.http.get<Dto>(url).pipe(
  timeout(3000),
  retry({ count: 3, delay: (_err, i) => timer(Math.min(200 * 2 ** i, 2000) + Math.random() * 100) }),
  map((r) => r.data),
  catchError((err) => throwError(() => new UpstreamError('catalogue', { cause: err }))),
)
```
- Retry only idempotent calls and only transient errors (network, 502/503/504); filter in `delay` or before `retry`. Add jitter and a cap.
- Put `catchError` inside the inner observable of `mergeMap`/`switchMap` so one failure does not kill the outer stream.
- Map to domain errors at the edge (`error-handling`); do not swallow with `EMPTY` silently.

## Unsubscription
- Prefer completing sources (`take(1)`, `first()`, `firstValueFrom`) over manual unsubscribe. `takeUntil` must be the last operator in the chain to avoid leaks from later operators.
- `firstValueFrom` rejects with `EmptyError` on an empty stream; pass `{ defaultValue }` when that is legitimate.

## Avoid nested subscribes
Bad: `a$.subscribe((a) => b$(a).subscribe(...))`. Good: `a$.pipe(switchMap((a) => b$(a)))`, or convert and await: `const a = await firstValueFrom(a$)`.

## shareReplay pitfalls
- `shareReplay(1)` without `refCount: true` keeps the source subscribed forever, retaining memory and connections. Cached errors replay to later subscribers; reset deliberately.
- For caching a request result, prefer a plain cache (`caching-patterns`) over a hot observable.

## Backpressure
- RxJS has no automatic backpressure. Bound with `mergeMap` concurrency, `bufferTime`/`bufferCount`, `auditTime`/`throttleTime`, or `sampleTime`. For durable work use a queue (`background-processing`).

## Event streams in Nest
- `@nestjs/event-emitter` for in-process events; for microservices `ClientProxy.send()` returns a cold observable (needs a subscriber or `firstValueFrom` to fire), `emit()` is fire-and-forget. Set timeouts on `send`.

## Anti-patterns
- `async` callbacks inside `subscribe` or `tap` (errors are lost). Use `mergeMap(async ...)` or `from(promise)`.
- `toPromise()` (deprecated); `Subject` exposed publicly instead of `asObservable()`.
