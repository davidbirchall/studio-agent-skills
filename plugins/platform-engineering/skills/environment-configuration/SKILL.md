---
name: environment-configuration
description: Environment configuration for Node, NestJS, Nuxt and Unity projects - twelve-factor config in the environment, environment parity across local, dev, staging and prod, typed schema-validated config that fails fast at startup, config versus secrets, sane defaults, feature flags, per-environment overrides, .env handling with a committed .env.example, build-time versus runtime config for frontends, and detecting config drift. Load when adding config or env vars, writing a config module, setting up .env files, or debugging environment-specific behavior.
---

# Environment configuration

Credentials are covered in `secrets-management`; image and runtime wiring in `containerization`; promotion across environments in `deployment-patterns`. Verify library APIs against installed versions.

## Principles
- Store config in the environment, not in code. The same build artifact runs in every environment; only config differs.
- Never branch on environment name (`if (env === 'prod')`) in business logic. Branch on a specific setting (`CACHE_TTL_SECONDS`, a flag).
- Keep environments as similar as practical (same runtime, same backing service types, same migrations). Differences must be deliberate and documented.
- Config is data about the deployment; secrets are a restricted subset. Keep them separate (see `secrets-management`).

## Typed, validated config
- Read `process.env` in exactly one module. Parse, coerce and validate once at startup; export a typed immutable object.
- Fail fast: if config is invalid, log which keys are wrong (never their values) and exit non-zero before accepting traffic.
```ts
import { z } from 'zod'

const schema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().positive().default(3000),
  DATABASE_URL: z.string().url(),
  LOG_LEVEL: z.enum(['debug', 'info', 'warn', 'error']).default('info'),
  FEATURE_NEW_CHECKOUT: z.stringbool().default(false),
})

const parsed = schema.safeParse(process.env)
if (!parsed.success) {
  console.error('Invalid config:', Object.keys(parsed.error.flatten().fieldErrors))
  process.exit(1)
}
export const config = Object.freeze(parsed.data)
```
- Booleans from env are strings; never use `Boolean('false')`. Use an explicit parser (verify `z.stringbool` exists in your zod version).
- In NestJS, pass the same schema to the config module's validate hook and inject a typed service; do not read `process.env` in providers.

## Defaults
- Default only what is safe everywhere (port, log level, timeouts). Required values with no safe default (URLs, credentials) have no default.
- Never default a production-affecting value to a development one (for example a local database URL).
- Document every key: type, meaning, default, required or not.

## .env files
- Use `.env` for local development only. Gitignore `.env` and `.env.*.local`; never commit real values.
- Commit `.env.example` listing every key with placeholder values and comments. Update it in the same change that adds a key.
- Do not ship `.env` files in images or rely on them in deployed environments; inject real environment variables.
- Never write or read secrets in shared files; follow Squad `secret-handling`.

## Per-environment overrides
- Layer order, lowest to highest: schema defaults, committed non-secret environment file (for example `config/staging.json`), environment variables.
- Keep overrides small. If staging differs from prod in many keys, parity is eroding.
- Test config uses explicit values set in test setup, not whatever the developer's shell holds.

## Feature flags
- Flags are config with a lifecycle: name, default, removal date. Delete flags once rolled out.
- Evaluate flags through one wrapper so they are testable and loggable. Default to off when the flag service is unreachable.
- Separate release flags (short-lived) from ops kill-switches (long-lived). See `deployment-patterns` for deploy versus release.

## Frontends and clients
- Anything bundled into browser code is public. Only put non-secret values there.
- For Nuxt, use runtime config for values that differ per environment so one build is reusable; verify the public versus private split in current docs.
- For Unity, load environment settings from a versioned config asset or remote config selected at runtime; never embed server credentials in a build.

## Drift
- Compare the key set (not values) between environments in CI against `.env.example` or the schema; fail on missing or unknown keys.
- Manage deployed config through code review or `infrastructure-as-code`, not manual edits in consoles.
- Log the non-secret effective config summary (environment, version, flag states) at startup to aid debugging.
