---
name: fastify-adapter
description: Running NestJS on Fastify with @nestjs/platform-fastify - bootstrap, Fastify plugin registration (helmet, cors, multipart, compress), Express vs Fastify differences, typed request and reply, serialization, and testing with inject. Load when setting up or changing the Fastify adapter or using Fastify-specific features in a Nest app.
---

# Fastify adapter

Builds on `nestjs-patterns`. Verify package names and plugin versions against the installed Nest and Fastify majors; Fastify plugins must match the Fastify major.

## Bootstrap
```ts
const app = await NestFactory.create<NestFastifyApplication>(
  AppModule,
  new FastifyAdapter({ trustProxy: true }),
  { bufferLogs: true },
)
await app.listen({ port: config.port, host: '0.0.0.0' })
```
- Bind `host: '0.0.0.0'` in containers; Fastify defaults to localhost.
- Set `trustProxy` only behind a known proxy (affects client IP and rate limiting).
- Use the Nest logger (`backend-observability`), not a second Fastify logger, unless you intentionally share pino.

## Plugins, not Express middleware
- Use Fastify plugins (`@fastify/helmet`, `@fastify/cors` or `app.enableCors()`, `@fastify/compress`, `@fastify/multipart`, `@fastify/cookie`) via `app.register(...)`.
- Express packages (`helmet`, `cookie-parser`, `multer`, `express-session`) do not work with this adapter. Do not mix them in.
- Prefer guards and interceptors over raw middleware; middleware receives raw Node `req`/`res`.

## Request and reply
- Type with `FastifyRequest` and `FastifyReply`. Use `@Res({ passthrough: true })` when you need headers or status but still want Nest to serialize the return value. Without `passthrough` you must send the reply yourself.
- Express-only APIs (`res.json`, `res.cookie`) differ; use `reply.header`, `reply.code`, `reply.send`.

## Limits
- Set `bodyLimit` and `connectionTimeout` deliberately in `FastifyAdapter` options.
- Nest serializes responses with its own interceptors; do not assume Fastify JSON-schema serialization is active.

## Testing
- `await app.init()` then `await app.getHttpAdapter().getInstance().ready()`, then `app.inject({ method, url, payload })` (`backend-testing`).
- Call the shared `configureApp(app)` so tests include the real plugins, pipes, and filters. Assert `res.statusCode`, `res.headers`, and `res.json()`.

## Registering plugins
```ts
await app.register(helmet)                                  // @fastify/helmet (`backend-security`)
await app.register(multipart, { limits: { fileSize: 5 * 1024 * 1024, files: 3 } })
await app.register(rateLimit, { max: 100, timeWindow: '1 minute' })
app.enableCors({ origin: config.corsOrigins })              // explicit allowlist, no '*' with credentials
```
- Register before `app.listen`. Prefer `@nestjs/throttler` when you want Nest guards and per-route decorators; do not run both for the same limit.
- Multipart: validate type and size server-side (`data-validation`); consume or discard every file stream or the request hangs.
- Swagger UI under helmet may need a relaxed CSP on its path only (`openapi-swagger`).

## Express differences to remember
- No `app.use(express.json())`; body parsing is built in. Raw `req`/`res` live at `request.raw` / `reply.raw`.
- Middleware gets Node `IncomingMessage`; `req.originalUrl`, `req.ip` behave differently. Route wildcards and path syntax differ from Express; verify against installed Nest and Fastify versions.
- Responses are not sent until the handler returns or `reply.send` is called; do not write to `reply.raw` directly except for streaming you manage yourself.

## Raw body
- Webhook signature checks need the exact bytes: `NestFactory.create(..., { rawBody: true })`, then read `req.rawBody` (verify option and type name in the installed `@nestjs/platform-fastify`). Apply only to webhook routes and keep `bodyLimit` tight.

## Hooks vs Nest lifecycle
- Nest guards, interceptors, pipes, and filters cover request logic (`nestjs-patterns`). Use Fastify hooks (`onRequest`, `onSend`, `onClose`) only for transport concerns that must run before Nest routing, e.g. request id header, connection-level limits. Hooks bypass DI unless you resolve providers from `app.get`.
- Shutdown: `app.enableShutdownHooks()` and let Nest call `fastify.close()`; in-flight requests drain, then `OnApplicationShutdown` closes DB and queues. Set the orchestrator grace period above your slowest request.

## Serialization
- Nest serializes with `JSON.stringify` via its interceptors (`ClassSerializerInterceptor` for `@Exclude`). Fastify response schemas are not used unless you add route `schema` options through the adapter; if you do, they strip unknown fields, which can hide bugs. Choose one strategy and document it.
- BigInt, Date, and Prisma Decimal need explicit conversion in DTOs.

## Logging with pino
- Fastify embeds pino. Recommended: `bufferLogs: true` and `nestjs-pino` as the Nest logger (`backend-observability`); disable Fastify's own `logger` option to avoid duplicate lines, or share one instance deliberately.
- Redact `authorization` and `cookie` headers in the logger config; honour or generate `X-Request-Id`.

## Performance notes
- Fastify's gain disappears with heavy middleware, sync work, or large JSON. Compress at the edge when a proxy exists; otherwise `@fastify/compress`.
- Set `keepAliveTimeout` above the load balancer idle timeout to prevent sporadic 502s. Measure with load tests before tuning.

## Common pitfalls
- Plugin version mismatch with the Fastify major: startup error about plugin version.
- Using `res.send()` inside handlers with `@Res()` and also returning a value: double send.
- Forgetting `host: '0.0.0.0'` in Docker; forgetting `.ready()` before `inject`.
- Express-typed decorators or `@types/express` imports in Fastify code.

## See also

Optional, if installed: performance-engineering (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
