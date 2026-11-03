---
name: authentication-authorization
description: Authentication and authorization for NestJS APIs on Fastify - secure-by-default global guard with @Public(), session vs JWT tradeoffs, OIDC/OAuth2 via an IdP, JWT validation and JWKS key rotation, short-lived access and rotating hashed refresh tokens, argon2id password hashing, MFA hooks, API keys and service-to-service auth, cookie and CSRF settings, logout and revocation, RBAC vs ABAC, default-deny guards with Reflector, object-level authorization (BOLA/IDOR), tenant isolation, WebSocket and SSE auth, and 401 vs 403 testing. Load when adding login or tokens, writing guards, changing access control, or reviewing who can reach which data.
---

# Authentication and authorization

Builds on `nestjs-patterns`, `data-validation`, and `backend-security`. Follow `secret-handling` for keys and secrets. Verify package APIs against installed versions.

## Authentication: default posture
- Secure by default: register a global guard (`APP_GUARD`) and mark open routes with `@Public()`, read through `Reflector`. Never guard route by route.
```ts
@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private reflector: Reflector, private auth: AuthService) {}
  async canActivate(ctx: ExecutionContext) {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC, [ctx.getHandler(), ctx.getClass()])
    if (isPublic) return true
    const req = ctx.switchToHttp().getRequest()
    req.user = await this.auth.verify(req) // throws UnauthorizedException
    return true
  }
}
```
- Prefer an IdP (OIDC/OAuth2 authorization code with PKCE) over hand-rolled login. The API then only validates tokens.
- Session vs JWT: server sessions (opaque id, store in Redis) revoke instantly and suit first-party web apps. JWTs suit stateless service and mobile clients but cannot be revoked before expiry, so keep them short-lived. Pick one per client type; do not mix casually.

## Tokens
- Validate signature, pinned algorithm (reject `none` and unexpected algs), `exp`, `iss`, and `aud`. Fetch keys from the IdP JWKS endpoint, cache them, and handle rotation by refetching on unknown `kid`.
- Access tokens short-lived. Refresh tokens are rotated on use, revocable, and stored hashed server-side; reuse of a rotated token revokes the family.
- Never put secrets or excess PII in token claims. Never log tokens or credentials.

## Passwords and MFA
- If you must store passwords, hash with argon2id (tuned parameters; verify against installed library defaults). Rate limit login (`backend-security`) and return one generic failure message.
- Leave MFA hooks: the auth flow returns a step-up state, and sensitive routes can require a recent-MFA claim. Prefer the IdP's MFA.

## API keys and service-to-service
- API keys: random, high entropy, shown once, stored hashed, scoped, with an owner, expiry, and rotation. Compare in constant time.
- Service-to-service: OAuth2 client credentials with narrow scopes, or mTLS inside the mesh. No shared static admin tokens.

## Cookies, CSRF, logout
- Cookie auth: `HttpOnly`, `Secure`, `SameSite` (Lax or Strict), narrow path and domain. CSRF protection is required for cookie auth (verify the Fastify CSRF plugin for your version); bearer-header APIs are not CSRF-exposed.
- Logout destroys the session or revokes the refresh token family. Offer revoke-all on password change or compromise.

## Authorization
- Default deny. Declare requirements with decorators and enforce in a guard:
```ts
export const Roles = (...roles: Role[]) => SetMetadata(ROLES_KEY, roles)
// guard: roles = reflector.getAllAndOverride<Role[]>(ROLES_KEY, [handler, class]); no metadata on a non-public route => decide explicitly
```
- RBAC for coarse roles. Use permissions or ABAC (owner, tenant, attributes) when rules depend on the resource. Do not explode roles to encode resource rules.
- Roles and permissions come from the verified token or server-side store, never from request body, query, or headers the client controls.

## Object-level authorization (BOLA/IDOR)
- Role checks are not enough. Scope every resource query to the caller in services:
```ts
const post = await this.prisma.post.findFirst({ where: { id, ownerId: user.id } })
if (!post) throw new NotFoundException()
```
- Tenant isolation: carry `tenantId` from the verified identity into every query (`data-access-patterns`); no query without a tenant filter. Consider database row-level security as defense in depth.
- Return 404 where revealing existence is itself a leak; otherwise 403. Never accept `ownerId`, `role`, or `tenantId` from DTOs (`data-validation`).
- Lists, exports, bulk operations, and nested relations need the same scoping as single reads.

## WebSocket and SSE
- Authenticate at connection time (handshake token, not query string if avoidable) and re-check authorization per message or subscription. Close on token expiry. Apply guards to gateways explicitly; HTTP global guards do not cover them automatically (verify for your setup).

## Testing (`backend-testing`)
- For each protected route test: no credentials -> 401, valid credentials without permission -> 403, another user's resource -> 404/403, and the happy path.
- Test the guard and `@Public()` default, expired and wrong-audience tokens, and refresh reuse.

## See also

Optional, if installed: application-security (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
