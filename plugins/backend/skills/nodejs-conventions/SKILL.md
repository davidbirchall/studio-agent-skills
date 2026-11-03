---
name: nodejs-conventions
description: Node.js and TypeScript conventions for backend services - LTS pinning, ESM vs CJS, config validation at boot, graceful shutdown, process-level error policy, process model and scaling, strict tsconfig and typing rules, Oxlint and Prettier setup, server-side axios clients with timeouts, retries and AbortSignal, event-loop protection, streams, logging, dependency hygiene and project layout. Load when setting up or changing a Node service, tsconfig, lint and format tooling, outbound HTTP clients, or when code may block the event loop.
---

# Node.js conventions

Framework detail lives in `nestjs-patterns`; structure in `backend-architecture`. Verify option and rule names against the installed Node, TypeScript, Oxlint, Prettier, and axios versions.

## Runtime
- Pin an active LTS Node version in `.nvmrc` (or the project's version manager file) and `engines` in `package.json`; use the same version in CI and the Docker base image.
- Use the project's package manager consistently, commit the lockfile, install with the frozen-lockfile mode in CI.
- Choose ESM or CJS once per service. Classic Nest builds commonly use CJS; native ESM needs `NodeNext` resolution and file extensions in imports. Do not mix without a reason.
- Validate env/config at boot with a schema (Zod or Nest `ConfigModule` validation) and fail fast; never read `process.env` outside the config layer, never `process.env.X as string`.
- Scripts: `dev`, `build`, `start`, `lint`, `format`, `format:check`, `typecheck`, `test`, `test:e2e`. Same names in every service.
- Layout: `src/` for code (feature folders, `common/`, `config/`), `test/` for e2e, `dist/` ignored. Keep `main.ts` thin.
- Use the logger (`backend-observability`), never `console`, in application code.

## Process lifecycle
- Handle `SIGTERM`/`SIGINT`: stop accepting requests, drain in-flight work, close DB/queue connections, then exit. In Nest call `app.enableShutdownHooks()` and implement `OnApplicationShutdown`/`OnModuleDestroy`.
- Set a shutdown deadline shorter than the orchestrator's kill timeout.
- On `unhandledRejection` and `uncaughtException`: log with context, then exit non-zero and let the supervisor restart. Process state is unknown after them; do not continue. Policy detail in `error-handling`.
- Scale with container replicas by default; one Node process per container. Use `cluster`/PM2 only on a single host without an orchestrator. Keep instances stateless (`backend-architecture`).

## TypeScript
- `"strict": true`, plus `noUncheckedIndexedAccess` and `noImplicitOverride`; `exactOptionalPropertyTypes` where the friction is acceptable.
- Nest needs `experimentalDecorators` and `emitDecoratorMetadata`. Target `ES2022` or newer per runtime; `module`/`moduleResolution` match how the app is built and run.
- `skipLibCheck`, `forceConsistentCasingInFileNames`, and `isolatedModules` if using SWC/esbuild.
- Path aliases (`@/*`) only if the runtime and test tool resolve them too (`backend-testing`).
- No `any`; use `unknown` and narrow. Use `import type` for type-only imports, but not for classes injected by Nest constructors (metadata needs the runtime import).
- DTOs are classes; internal shapes are `type`/`interface`. Use `readonly` and `as const`; prefer string unions over `enum` unless Prisma or class-validator needs one.
- Derive types from one source: `z.infer`, Prisma generated types, `Pick`/`Omit`. Do not hand-copy. Use `satisfies` to check literals without widening.
- Model expected outcomes with discriminated unions (`error-handling`).
- Run `tsc --noEmit` in CI as the type check, separate from the build.

## Lint and format
- Oxlint finds bugs; Prettier formats. Do not make the linter enforce formatting. Oxlint is not a type checker; floating-promise gaps need `tsc` or a typed lint pass.
- `.oxlintrc.json` at the root: `correctness` as errors, `suspicious` as warnings or errors; enable `typescript`, `import`, `node`, `unicorn` plugins selectively. Ban `typescript/no-explicit-any`, unused vars, and `console`.
- `overrides` for tests and scripts; disable comments need a reason and the narrowest scope.
- `.prettierrc` is the single format config (`singleQuote`, `trailingComma: "all"`, project `printWidth`); `.prettierignore` covers `dist`, `coverage`, generated files, lockfiles, migration SQL.
- Pre-commit runs `oxlint` and `prettier --write` on staged files only. CI runs lint (`--deny-warnings`), `prettier --check`, typecheck, and tests as separate steps.

## Outbound HTTP (axios)
- One axios instance per upstream, built from validated config in a provider (or `@nestjs/axios` `HttpModule.registerAsync`). Never use the global default instance.
- Wrap each upstream in a typed client class returning domain types, not `AxiosResponse`; inject it so tests can replace it.
```ts
const http = axios.create({ baseURL: cfg.baseUrl, timeout: 5_000 })
```
- Always set `timeout`; set `maxRedirects` and `maxContentLength` for untrusted upstreams. Pass `signal` (AbortSignal) for cancellable work; not `CancelToken`.
- Build URLs with `params` and encoded path segments, never string-concatenated user input (SSRF, `backend-security`).
- Interceptors: attach auth and propagate `X-Request-Id`; normalize errors to a project error type and strip secrets from logs.
- Retry only idempotent calls on network errors, 429, and 5xx, with exponential backoff, jitter, a cap, and `Retry-After`. No retry of `POST` without an idempotency key (`api-design`). Boundaries in `error-handling`.
- Generics type the client method but do not validate; validate untrusted payloads (`data-validation`). Use `axios.isAxiosError`; map upstream failures to 502/503/504.

## Event loop
- Never block it: no sync fs/crypto, large `JSON.parse`/`stringify`, regex-heavy or CPU loops in handlers. Offload CPU work to worker threads or a queue and return `202` (`background-processing`).
- Stream large payloads (`StreamableFile`, `pipeline` from `node:stream/promises`) instead of buffering; handle backpressure and stream errors.
- Always `await` or return promises; no floating promises. Bound `Promise.all` fan-out for large lists.
- Put a timeout on every outbound call (`AbortSignal.timeout(ms)`). Watch event-loop lag as a metric.
- Caching and payload tuning: `caching-patterns`; adapter specifics: `fastify-adapter`.

## Dependencies
- Add few, well-maintained packages; prefer Node built-ins. Review new transitive weight and licences.
- Run the audit tool in CI and update regularly. Separate `dependencies` from `devDependencies`. No unpinned `latest`.

## See also

Optional, if installed: typescript-conventions (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
