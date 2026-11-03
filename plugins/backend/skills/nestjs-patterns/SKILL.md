---
name: nestjs-patterns
description: conventions for NestJS APIs - module and provider design, dynamic modules, custom providers and injection tokens, provider scopes, typed ConfigModule configuration, lifecycle and shutdown hooks, the request pipeline (middleware, guards, interceptors, pipes, filters) and when to use each, custom decorators, event emitter, CQRS only when justified, circular dependency avoidance, testing-friendly design, versioning, nest-cli plugins, and common pitfalls. Load when creating or changing NestJS modules, controllers, services, providers, decorators, or cross-cutting request pipeline pieces.
---

# NestJS patterns

Builds on `nodejs-conventions`, `data-validation`, `openapi-swagger`, `fastify-adapter`, `rxjs`, and `backend-testing`. Verify decorator and option names against the installed `@nestjs/*` version.

## Structure
- One feature module per domain (`posts/`): `posts.module.ts`, `posts.controller.ts`, `posts.service.ts`, `dto/`, `*.spec.ts` beside the code.
- `common/` holds shared guards, filters, interceptors, pipes, and decorators. `config/` holds typed configuration.
- Modules export only what other modules need. No deep imports into another module's internals; import its module and use its exported provider.
- Use `@Global()` only for true infrastructure (config, logger, database). Never for feature modules.

## Controllers and providers
- Controllers are thin: parse the request (DTOs), call one service method, return the result. No business logic, no Prisma calls.
- Services hold business logic, are stateless, and use default singleton scope.
- Constructor injection with `private readonly`. Every provider class carries `@Injectable()`; a missing one fails at runtime with an unresolved-dependency error.
- Throw HTTP exceptions or domain errors mapped by a filter (`error-handling`). Do not return error objects.

## Custom providers and tokens
```ts
export const CLOCK = Symbol('CLOCK')
providers: [
  { provide: CLOCK, useValue: { now: () => new Date() } },
  { provide: PaymentsClient, useFactory: (cfg: ConfigService) => new PaymentsClient(cfg.getOrThrow('payments.url')), inject: [ConfigService] },
  { provide: Mailer, useClass: process.env.NODE_ENV === 'test' ? FakeMailer : SmtpMailer },
]
```
- Inject interfaces and third-party clients by token (`@Inject(CLOCK)`); use `Symbol` or a class as the token, not bare strings.
- `useFactory` may be async; Nest awaits it before dependents resolve. Handle failures so boot fails fast.
- Inject by token wherever a swap is plausible: clients, clocks, id generators.

## Dynamic modules
- Expose `forRoot(options)` and `forRootAsync({ imports, inject, useFactory })` for configurable infrastructure modules. Provide options through an options token.
- Use `ConfigurableModuleBuilder` to generate these when the installed version supports it; otherwise hand-write them.
- Keep `forRoot` for the root module only; feature modules use `forFeature` or plain imports.

## Scopes
- Default singleton. `Scope.REQUEST` bubbles up to every dependent, creates instances per request, and hurts performance and testability.
- Pass request context as arguments, or use `nestjs-cls` (AsyncLocalStorage) for ambient context such as request id or tenant.
- `Scope.TRANSIENT` only for stateful helpers that must not be shared.

## Configuration
- `ConfigModule.forRoot({ isGlobal: true, validate })`; validate env at boot (Zod or class-validator) and fail fast (`data-validation`).
- Typed config via `registerAs('db', () => ({...}))` and `ConfigType<typeof dbConfig>`; use `getOrThrow`, not raw `process.env`.
- Never read or commit `.env` secrets (`secret-handling`).

## Request pipeline
Order: middleware, guards, interceptors (before), pipes, handler, interceptors (after), exception filters.
- Middleware: framework-level raw request work (request id, raw body). Under Fastify it receives raw req/res; prefer hooks or interceptors (`fastify-adapter`).
- Guards: authN/authZ only (`authentication-authorization`). Return boolean or throw.
- Pipes: validation and transformation (`data-validation`); register globally in `main.ts`, and use `APP_PIPE` in a module so DI works.
- Interceptors: logging, timing, response mapping, caching, timeouts, written with RxJS operators (`rxjs`). No business logic.
- Exception filters: one global filter maps errors to the project error shape (`error-handling`, `api-design`).
- Global enhancers registered via `APP_GUARD`, `APP_INTERCEPTOR`, `APP_FILTER`, `APP_PIPE` get dependency injection; `app.useGlobal*` does not.

## Custom decorators
- Param data: `createParamDecorator((data, ctx) => ctx.switchToHttp().getRequest().user)`. Use `getRequest` with the Fastify request type.
- Metadata: `SetMetadata` or `Reflector.createDecorator()` (when available), read with `Reflector.getAllAndOverride` in a guard or interceptor.
- Compose with `applyDecorators` (for example route + `ApiTags` + `UseGuards`).

## Events and CQRS
- Use `@nestjs/event-emitter` for in-process, fire-and-forget side effects. Listeners must not be required for correctness; durable work belongs in a queue (`background-processing`).
- Adopt `@nestjs/cqrs` only when there are many commands/handlers, sagas, or separate read models. Otherwise plain services.

## Circular dependencies
- Treat a cycle as a design defect. Extract the shared logic into a third provider or module, or use an event.
- `forwardRef` is a last resort and hides the problem.

## Lifecycle
- `app.enableShutdownHooks()` so `OnModuleDestroy` / `OnApplicationShutdown` close Prisma, queues, and other connections.
- Do not block boot with slow `OnModuleInit` work. Readiness belongs to health checks (`backend-observability`).

## Versioning and tooling
- URI versioning via `app.enableVersioning({ type: VersioningType.URI })` and `@Version()`; follow `api-design` for deprecation policy.
- `nest-cli.json` plugins: enable `@nestjs/swagger` plugin to infer DTO docs (`openapi-swagger`). Verify plugin options against the installed version; builds that bypass nest-cli (SWC, Vitest) need the metadata generated separately.

## Testing
- Design providers for `Test.createTestingModule` with overridden providers (`overrideProvider`), per `backend-testing` and `test-discipline`.
- Global pipes set with `app.useGlobalPipes` are not applied in testing modules; apply the same pipe in test setup or use `APP_PIPE`.

## Pitfalls
- Missing `@Injectable()` or missing provider in `providers`/`exports`.
- Async providers not awaited by consumers who read state in constructors; use factories or `onModuleInit`.
- Importing a service from another module without importing that module.
- Business logic in controllers or guards.
- Request-scoped provider silently making a whole dependency chain request-scoped.

## See also

Optional, if installed: software-architecture (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
