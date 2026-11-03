---
name: backend-testing
description: Testing NestJS APIs on Fastify with Vitest - backend test pyramid, SWC config for decorator metadata, Test.createTestingModule with provider overrides, Fastify inject e2e with a shared configureApp, disposable database strategy with Prisma, test data builders, fakes for clock, ids, mail, queues and HTTP upstreams, OpenAPI contract tests, background job tests, auth, validation and error-shape tests, flaky-test rules, and coverage as a signal. Load when writing or fixing API tests, configuring Vitest, setting up test databases, or deciding what level to test at.
---

# Backend testing

Builds on `nestjs-patterns` and `test-discipline`. Write tests first where practical (red, green, refactor). Verify config options and library APIs against installed versions.

## Pyramid
- Unit: services, guards, pipes, filters, pure logic. Fast, no I/O, many.
- Integration: modules against a real database (`data-access-patterns`). Query logic is only proven by a real DB; do not mock Prisma for it.
- E2E and contract: HTTP through the real app, real pipes and filters, against the OpenAPI contract. Fewer, focused on journeys and error shapes.
- Pick the lowest level that can fail for the risk you care about.

## Vitest config
Vitest uses esbuild, which does not emit decorator metadata. Nest DI needs it, so use SWC:
```ts
// vitest.config.ts
import swc from 'unplugin-swc'
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: { globals: false, root: './', environment: 'node' },
  plugins: [swc.vite({ module: { type: 'es6' } })],
})
```
- Keep `experimentalDecorators` and `emitDecoratorMetadata` on in `tsconfig` (`nodejs-conventions`).
- Separate unit (`*.spec.ts`), integration, and e2e (`*.e2e-spec.ts`) by config or project, each with its own script.
- Import `describe`, `it`, `expect`, `vi` explicitly.

## Unit tests
- `Test.createTestingModule({ providers: [Service, { provide: Dep, useValue: fake }] })`. Fake at the provider boundary.
- `vi.fn()`, `vi.mocked`, and `vi.restoreAllMocks()` in `afterEach`.
- Assert outputs and effects, not call order, unless the call is the contract.
- Test guards, pipes, filters, and interceptors directly with a fake `ExecutionContext`.

## E2E with Fastify inject
```ts
const moduleRef = await Test.createTestingModule({ imports: [AppModule] })
  .overrideProvider(MailService).useValue(fakeMail)
  .compile()
app = moduleRef.createNestApplication<NestFastifyApplication>(new FastifyAdapter())
configureApp(app) // same function main.ts calls
await app.init()
await app.getHttpAdapter().getInstance().ready()
const res = await app.inject({ method: 'GET', url: '/posts' })
expect(res.statusCode).toBe(200)
```
- Extract `configureApp(app)` (global pipes, filters, versioning, prefix, helmet) and call it from both `main.ts` and tests, otherwise tests miss real behaviour.
- Use `inject` on Fastify; `supertest` only on the Express adapter (`fastify-adapter`).

## Database strategy
- Real disposable database: a container or dedicated schema per run or worker. Run `prisma migrate deploy` once in global setup.
- Reset per test or file: truncate tables or roll back a transaction. Do not share rows across tests.
- Keep the test DB engine identical to production.

## Test data
- Builders or factories with sensible defaults and per-test overrides: `buildUser({ role: 'admin' })`. Create only what the test needs; make the relevant field visible in the test.
- No shared mutable fixtures or hard-coded ids that tests depend on implicitly.

## Fakes and boundaries
- Inject a clock and an id generator; use `vi.useFakeTimers` for time logic, never real sleeps.
- Fake mail, payment, and storage providers as in-memory implementations of the same interface.
- HTTP upstreams: intercept at the network layer with msw or nock-style tools (verify which fits your HTTP client and Node version) rather than mocking the client. Assert request shape and simulate timeouts, 5xx, and malformed bodies (`error-handling`).
- Queues: use an in-memory fake for unit tests; test real wiring in integration.

## Contract tests
- Export the OpenAPI spec from the running app (`openapi-swagger`) and validate responses against it with a schema validator (choose one; verify support for your spec version). Fail on spec drift in CI.
- `postman-api-testing` collections run the same spec against a deployed environment as a smoke and contract check. They supplement, not replace, these tests.

## Background jobs
- Test the handler as a plain function or provider with fakes; call it directly instead of waiting for the queue.
- Assert idempotency (run twice, same result), retry behaviour on failure, and that enqueueing happens with the right payload (`background-processing`).

## What to cover on HTTP
- Auth: no credentials 401, wrong permission 403, other user's object 404/403 (`authentication-authorization`).
- Validation: invalid and extra fields 400 with the standard error shape (`data-validation`, `api-design`).
- Not found 404, conflicts 409, and the stable error body (`error-handling`). Pagination bounds.

## Rules
- Independent, order-agnostic tests; no shared mutable state; parallel safe.
- Flaky tests: no real time, network, or random without seeding; await conditions instead of sleeping; fix or quarantine with an owner and issue, never retry-and-ignore.
- Coverage is a signal, not a goal; assertions must fail on realistic regressions (`test-discipline`).

## See also

Optional, if installed: software-testing-strategy (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
