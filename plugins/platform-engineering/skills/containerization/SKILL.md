---
name: containerization
description: Containerization for Node and NestJS services with Docker and OCI images - multi-stage Dockerfiles, slim pinned base images, non-root users, .dockerignore, layer caching, lockfile-based pnpm installs, health checks, signal handling and graceful shutdown, one process per container, image scanning and SBOMs, small images, compose for local development, resource limits, and read-only filesystems. Load when writing or reviewing a Dockerfile or compose file, shrinking or hardening an image, debugging container startup or shutdown, or preparing a service for deployment.
---

# Containerization

Build pipeline context in `build-systems` and `ci-cd-workflows`; runtime config in `environment-configuration`; credentials in `secrets-management`; rollout in `deployment-patterns`. Verify base image tags and flags against current docs.

## Dockerfile for Node
- Use multi-stage builds: a build stage with dev dependencies and compiler, a final stage with only production dependencies and built output.
- Pin the base image to a specific version tag, ideally with a digest; never `latest`. Update pins deliberately through reviewed changes.
- Prefer slim or minimal runtime bases; compare size and debuggability before choosing distroless-style images.
```dockerfile
FROM node:<version>-slim AS build
WORKDIR /app
RUN corepack enable
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build && pnpm prune --prod

FROM node:<version>-slim
ENV NODE_ENV=production
WORKDIR /app
COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/dist ./dist
COPY --from=build --chown=node:node /app/package.json ./
USER node
EXPOSE 3000
CMD ["node", "dist/main.js"]
```
- Install from the lockfile only (`--frozen-lockfile`, or `npm ci`) so builds are reproducible.
- In monorepos, copy only the needed workspace manifests first, then sources; see `monorepo-management`.

## Layer caching
- Order layers from least to most frequently changed: base, manifests and lockfile, install, sources, build.
- Copy manifests before sources so dependency layers cache across code edits.
- Use a cache mount for the package store where the builder supports it (verify syntax in current docs).

## .dockerignore
- Exclude `.git`, `node_modules`, `dist`, `.env*`, test output, docs and local tooling folders. This speeds builds and keeps secrets out of the build context.

## Security
- Run as a non-root user; never `USER root` in the final stage.
- No secrets in `ENV`, `ARG`, `COPY` or layers; they persist in the image history. See `secrets-management`.
- Scan images in CI for known vulnerabilities and fail on agreed severity; rescan stored images on a schedule.
- Generate an SBOM per build and store it with the image; sign or attest images if your registry supports it.
- Run with a read-only root filesystem; mount a tmpfs or volume only for paths that must be writable.
- Drop unneeded capabilities and disable privilege escalation in the runtime configuration.

## Runtime behavior
- One process per container. Run workers, schedulers and web as separate containers from the same image with different commands.
- Start Node directly (`CMD ["node", ...]`), not via `npm start`, so signals reach the process. Use an init process only if you spawn children.
- Handle `SIGTERM`: stop accepting connections, finish in-flight work, close pools, exit before the orchestrator's kill timeout.
```ts
process.on('SIGTERM', async () => { await app.close(); process.exit(0) })
```
- In NestJS call `app.enableShutdownHooks()`.
- Log to stdout/stderr, structured; no log files in the container. See `monitoring-observability`.
- Expose distinct liveness (process is alive) and readiness (dependencies reachable, can serve) endpoints. Do not make liveness depend on downstream services.

## Resource limits
- Set memory and CPU limits and requests. Tune Node heap relative to the memory limit (verify the flag in current Node docs).
- Load test to find the limit; an OOM kill with no heap setting is a config bug.

## Local development with compose
- Use compose for the app plus backing services (database, cache). Pin service image tags.
- Mount source for hot reload in a dev-only override file; keep the production image path separate.
- Load env from a gitignored `.env`; commit `.env.example`. Never commit real credentials.
- Healthchecks and `depends_on` conditions prevent start-order races.

## Review checklist
- Reproducible build, pinned base, non-root, no secrets, small final image, `.dockerignore` present, SIGTERM handled, health endpoints defined, limits set.
