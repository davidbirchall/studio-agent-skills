---
name: multi-tenancy
description: Enforce owner-scoped data isolation across NestJS, Prisma, caches, queues, files, and exports; derive scope from trusted auth context, keep the design tenancy-ready for later, and test cross-user leaks. Load when adding ownership checks, workspaces, tenant IDs, or reviewing whether one user's data can reach another's.
---

# Multi-tenancy (single-user now, tenancy-ready)

Builds on `backend-architecture`, `prisma-patterns`, `authentication-authorization`, `backend-security`, `caching-patterns`, and `background-processing`. Verify Prisma `$extends` and `nestjs-cls` APIs against installed versions.

## Now: rules
- Every user-owned table has `ownerId String @db.Uuid` (FK to `User`). Name it the same everywhere. Ids are uuid.
- Derive `ownerId` from the verified auth context only. Never from body, query, or headers (`authentication-authorization`).
- All reads and writes go through one seam: a Prisma extension that injects `ownerId`. Controllers and services never hand-write the filter.
- Do NOT build orgs, workspaces, memberships, roles, or per-tenant settings yet. `ownerId` is the migration path: it later becomes the personal-workspace id.
- Composite indexes start with `ownerId`; uniques include it (`@@unique([ownerId, slug])`).
- Resource ids from URLs are looked up with the owner filter, not fetched then compared. Foreign-owner resources return 404, never 403.

## The seam
```ts
export const forOwner = (prisma: PrismaClient, ownerId: string) =>
  prisma.$extends({
    query: {
      $allModels: {
        async $allOperations({ model, operation, args, query }) {
          if (!OWNED_MODELS.has(model)) return query(args)
          if (operation === 'create') return query({ ...args, data: { ...args.data, ownerId } })
          if (operation === 'createMany') return query(withOwner(args, ownerId))
          return query({ ...args, where: { ...args.where, ownerId } })
        },
      },
    },
  })
```
- Inject a request-scoped client from context (below); the raw client is exported only as `prismaAdmin` for migrations and system jobs.
- Unique-where operations (`findUnique`, `update`, `delete`) are weakly typed for extra filters. Prefer `findFirst`, `updateMany`, `deleteMany`, or composite uniques including `ownerId`; verify behavior against the installed version.
- Raw SQL bypasses extensions. Every `$queryRaw` includes `WHERE owner_id = ${ownerId}` (`prisma-patterns`).
- Strip `ownerId` from input DTOs (`data-validation`). Throw if context is missing; never run unscoped.

## Request context
- Use AsyncLocalStorage (`nestjs-cls`, `ClsModule.forRoot({ middleware: { mount: true } })`), set once in the auth guard: `cls.set('ownerId', req.user.id)`. No `Scope.REQUEST` providers (`nestjs-patterns`).
- Context stops at process boundaries. Put `ownerId` in queue payloads and re-establish it in the worker, which verifies the entity belongs to that owner (`background-processing`).
- Streams that outlive the request capture `ownerId` before detaching (`realtime-streaming`).

## Keys and storage
- Prefix cache keys `u:{ownerId}:...` and wrap the cache client so prefixing is automatic (`caching-patterns`).
- Object storage paths start with `users/{ownerId}/`; signed URLs are short-lived (minutes) and owner-checked.
- Logs and traces carry `ownerId`, never message content (`backend-observability`).

## Export and deletion
- Build `exportUserData(ownerId)` and `deleteUserData(ownerId)` early: conversations, messages, files, caches, vector indexes, provider-side data.
- Deletion is soft with a grace period, then idempotent hard delete in a background job. Test that no rows remain for the owner.

## Leak tests
- Seed users A and B. For every route, call as A with B's ids; expect 404 and no data. Iterate over the route list so new routes fail without coverage (`test-discipline`, `backend-testing`).
- Test the extension per model and operation, including `include` of related rows and raw queries. Test that A cannot read B's cache keys or event streams.

## When you grow
- Add `Workspace` and `Membership (workspaceId, userId, role)`; migrate `ownerId` to `workspaceId` (personal workspace per user). Roles live on membership.
- Resolve the workspace from a client-selected id, but verify membership on every request; never trust it unverified.
- Isolation: default shared schema with enforced scoping. Add Postgres RLS (`SET LOCAL app.tenant_id` inside the transaction) as defense in depth; check PgBouncer pooling mode. Schema or database per tenant only for regulated or enterprise customers, as a deployment concern.
- Add a `TenantSettings` row (plan, quotas, allowed models, retention) cached by tenant, and tenant-level limits (`rate-limiting-quotas`).

## Anti-patterns
- Owner id from client input; hand-written `where: { ownerId }` scattered in services; fetch-then-compare.
- Unscoped raw SQL or global caches without an owner prefix; admin client in request paths.
- Request context stored in module-level variables.
- Building workspaces "just in case".

## Checklist
- [ ] ownerId on every owned table, in indexes and uniques
- [ ] ownerId from auth context only
- [ ] Single Prisma extension seam; raw client isolated
- [ ] ALS context; passed explicitly to jobs and detached streams
- [ ] Cache, queue, storage keys owner-prefixed
- [ ] Export and delete paths exist
- [ ] Cross-user tests cover every route
