---
name: secrets-management
description: Secrets management principles for Node, container and AI-agent stacks - classifying secrets, using a dedicated secret store or manager, runtime injection instead of build-time baking, rotation, least privilege, short-lived and federated credentials, keeping secrets out of git, images, logs and error output, secret scanning and pre-commit detection, incident response for a leaked secret (revoke first, then clean up), access auditing, and handling API keys for AI agents and CI. Load when adding credentials or API keys, wiring secrets into deployments or CI, setting up secret scanning, or responding to a suspected leak.
---

# Secrets management

Builds on Squad `secret-handling` (never read `.env` files or write secrets to committed files); non-secret config is in `environment-configuration`. Related: `ci-cd-workflows`, `containerization`, `monitoring-observability`.

## Classify
- Secret: anything that grants access or proves identity (passwords, API keys, tokens, private keys, signing keys, connection strings with credentials, webhook secrets).
- Not secret: hostnames, ports, feature flags, log levels, public client IDs. Keep these in config, not the secret store.
- Rate by blast radius (production data, billing, signing) to decide rotation period and access scope.

## Storage
- Use a dedicated secret store or manager (cloud-native, Vault-style, or the CI platform's secret store). Choose by capability: encryption at rest, access control, audit log, versioning, rotation support.
- One source of truth per secret. Do not copy values between stores by hand.
- Never store secrets in git (including private repos), wikis, tickets, chat, container images, or frontend bundles.
- Encrypted-in-repo approaches are acceptable only with managed keys held outside the repo.

## Injection
- Inject at runtime as environment variables or mounted files; never at build time. Build args and `ENV` lines persist in image layers.
- Prefer mounted files for multi-line material such as private keys; restrict file mode.
- Applications read secrets through the typed config module and never print them. See `environment-configuration`.
- For builds that need a credential (private registry), use the builder's secret mount mechanism, not `ARG` (verify syntax in current docs).

## Least privilege and lifetime
- One credential per service per environment. Never share prod and non-prod credentials.
- Grant the minimum scope (read-only, single resource, single action).
- Prefer short-lived credentials: workload identity, OIDC federation from CI, expiring tokens, over static long-lived keys.
- Developers and AI agents get scoped, revocable, non-production credentials by default.

## Rotation
- Rotate on a schedule proportional to risk, and immediately on suspected exposure, or vendor breach.
- Design for rotation: support two valid versions during overlap, reload without redeploy where feasible.
- Test the rotation procedure before you need it in an incident.

## Keeping them out of output
- Redact known secret keys in loggers (`authorization`, `password`, `token`, `apiKey`, `cookie`). Never log request bodies wholesale.
- Error messages and validation failures report key names, not values.
- Do not put secrets in URLs or query strings; they land in access logs.

## Detection
- Run a secret scanner in a pre-commit hook and again in CI on every push; scan full history when adopting.
- Add `.env`, key files and credential exports to `.gitignore`; commit only `.env.example`.
- Treat scanner findings as real until proven otherwise; allowlist with a documented reason.
- Pre-commit is advisory (can be skipped); CI and server-side push protection are the enforcement.

## Leak response
1. Revoke or rotate the credential immediately. Do this before cleanup; history rewriting does not un-leak.
2. Assess exposure: where it was visible, for how long, and what the credential could access.
3. Review audit logs for use of the credential during the window.
4. Issue replacement through the normal injection path; redeploy consumers.
5. Remove from git history and caches only after revocation, and only as hygiene.
6. Record a short incident note: cause, impact, and the control added to prevent recurrence.

## Audit
- Enable access logging on the secret store; alert on unusual reads and on use from unexpected locations.
- Check who and what can read each secret on each rotation; remove stale access.
- Inventory secrets with scope, rotation date and consumers in a file (names only, never values).

## See also

Optional, if installed: application-security (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
