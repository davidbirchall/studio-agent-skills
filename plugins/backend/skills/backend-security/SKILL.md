---
name: backend-security
description: Non-auth security for NestJS APIs on Fastify - OWASP API Top 10 mapping, security headers with @fastify/helmet, CORS allowlist, TLS at the edge, rate limiting with @nestjs/throttler and Redis, trustProxy, body and time limits, injection, SSRF, mass assignment, file uploads, secrets management and rotation, log and PII redaction, dependency and supply-chain hygiene, container hardening, SAST/DAST in CI, error message hygiene, and a per-endpoint review checklist. Load when hardening an API, adding uploads or outbound calls, configuring headers or limits, or reviewing an endpoint for security.
---

# Backend security

Builds on `nestjs-patterns`, `data-validation`, and `fastify-adapter`. Authentication and access control live in `authentication-authorization`. Follow `secret-handling` for secrets. Verify package APIs against installed versions.

## OWASP API Top 10 mapping
- Broken object/function-level authorization, broken authentication: `authentication-authorization`.
- Broken object property level authorization and mass assignment: whitelisted DTOs and explicit response DTOs (`data-validation`).
- Unrestricted resource consumption: rate limits, size and time caps, pagination caps (below).
- SSRF, security misconfiguration, improper inventory, unsafe consumption of upstream APIs: below, plus keep the OpenAPI spec (`openapi-swagger`) current and retire old versions.

## Transport and headers
- Terminate TLS at the edge; redirect or reject plain HTTP; HSTS via helmet.
- `@fastify/helmet` registered at bootstrap (`fastify-adapter`). If Swagger UI needs relaxed CSP, relax it only for that path.
- CORS: `app.enableCors({ origin: allowlist, credentials })` with explicit origins from config. Never `*` with credentials, never reflect arbitrary `Origin`.

## Abuse protection
- `@nestjs/throttler` globally, stricter on login, token, password reset, and expensive routes. Use a Redis-backed store when running multiple instances (verify the storage package for your version).
- Set `trustProxy` to match the real proxy chain, otherwise all clients share one IP or the header is spoofable.
- Cap body size (`bodyLimit`), pagination `limit`, upload size and count, and set request and upstream timeouts. Bound batch sizes and query complexity.

## Injection
- Parameterised queries only (`data-access-patterns`). No `$queryRawUnsafe` or string-built SQL with user input; use the tagged `$queryRaw` form.
- Never pass user input to shell commands, `eval`, dynamic `require`, or template engines. Validate against enums and allowlists for sort and filter fields.

## SSRF
- For user-supplied URLs: allowlist schemes and hosts, resolve DNS and block private, loopback, and link-local ranges (including cloud metadata addresses), disable or re-validate redirects, set timeouts and size caps (`nodejs-conventions`).

## File uploads
- Enforce size and count limits, check magic bytes and not only the extension or client MIME, generate server-side file names, never serve from the app path, store outside the web root or in object storage with private ACLs, scan if content is shared, and serve with `Content-Disposition` and a safe type.

## Secrets
- Follow `secret-handling`. Load from the environment or a secret manager, validated at startup (`nodejs-conventions`). Never commit, never log, never return in responses.
- Rotate on schedule and on exposure; support overlapping old and new keys during rotation. Separate secrets per environment.

## Logging and errors
- Redact tokens, passwords, cookies, authorization headers, and PII in logs (`backend-observability`). Configure redaction paths in the logger, not per call site.
- Generic client messages; no stack traces, SQL, or internal paths in responses (`error-handling`). Do not leak whether an account exists.

## Supply chain and runtime
- Commit the lockfile, install with `npm ci`/`pnpm install --frozen-lockfile`, run the audit in CI, enable Renovate or Dependabot, minimise dependencies, review new ones.
- Containers: minimal base image, multi-stage build, non-root user, read-only filesystem where feasible, no secrets in image layers, pinned image versions, handle SIGTERM for graceful shutdown.

## Security testing
- CI: dependency scan, SAST (CodeQL or equivalent), secret scanning. DAST against an ephemeral deployment on a schedule or before release.
- Write tests for abuse cases: forbidden fields rejected, oversized body rejected, throttle returns 429, error bodies contain no internals (`backend-testing`).

## Per-endpoint checklist
- Authenticated or explicitly `@Public()`? Authorised at object level (`authentication-authorization`)?
- Input validated and whitelisted, response shaped by DTO?
- Rate limited and size capped? Queries parameterised and tenant scoped?
- Outbound URLs allowlisted? Secrets and PII kept out of logs and errors?
- Abuse and 401/403 tests present?

## See also

Optional, if installed: application-security (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
