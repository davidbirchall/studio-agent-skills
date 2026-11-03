---
name: ship-web-feature
description: Recipe for taking a web feature from idea to production on a Nuxt 3 frontend and NestJS backend - discovery and scope, technical design, contract-first API, schema and migration, backend implementation and tests, frontend implementation with states, accessibility and tests, security and performance check, CI and flagged deployment, observation, and retrospective. Names the skills to apply at each step, the exit check, and what to hand forward. Load when asked to build, ship, or deliver a full-stack feature end to end.
---

# Ship web feature

An ordered recipe, not a reference. Each named skill is optional: if its plugin is not installed, do the step anyway using general good practice. Do not copy skill content here; apply the skill and record only the output.

## When to use / when not to
- Use for a feature that touches UI, API, and data, and will be released to real users.
- Not for a one-file fix (use debugging and code-review), a pure refactor, or an infrastructure-only change.

## Steps
1. Discover and scope.
   - Goal: a named user problem and a bounded change.
   - Apply: discovery (product plugin), feature-design (product plugin), scope and prioritisation (production plugin).
   - Exit: one-paragraph outcome, in/out list, success metric. Hand on: the scope list.
2. Technical design.
   - Goal: decide the shape before code.
   - Apply: software-architecture and technical-design (shared plugin), frontend-architecture (frontend plugin).
   - Exit: short design note listing components, data flow, risks, rollout plan. Hand on: the note.
3. Contract first.
   - Goal: agree the API before either side builds.
   - Apply: api-design, openapi-swagger, data-validation (backend plugin).
   - Exit: OpenAPI spec self-checked against the design note, error shapes defined, example payloads written. Hand on: the spec (frontend can mock it).
4. Schema and migration.
   - Goal: safe data change.
   - Apply: database-design (backend plugin), prisma-patterns (backend plugin), database-migrations and data-integrity (data plugin).
   - Exit: migration applies and rolls back on a copy of realistic data; expand-then-contract if live data exists. Hand on: schema and migration id.
5. Backend implementation and tests.
   - Goal: endpoints that match the spec.
   - Apply: nestjs-patterns, authentication-authorization, error-handling, backend-testing (backend plugin).
   - Exit: tests pass for success, validation, authorization, and failure paths; the spec and implementation agree. Hand on: running API.
6. Frontend implementation.
   - Goal: UI built on the contract with every state handled.
   - Apply: nuxt-project-patterns, api-client-patterns, state-management, form-handling, frontend-a11y-check, frontend-testing (frontend plugin).
   - Exit: loading, empty, error, and success states exist; keyboard and screen reader pass; component tests green. Hand on: working vertical flow.
7. Security and performance check.
   - Goal: catch the expensive problems before users do.
   - Apply: application-security, performance-engineering, code-review (shared plugin); backend-security, frontend-security, frontend-performance.
   - Exit: input, authorization, and data-exposure review done; slow queries and bundle growth checked against a stated budget. Hand on: findings fixed or logged as tasks.
8. CI and flagged deploy.
   - Goal: reach production with a fast off switch.
   - Apply: ci-cd-workflows, deployment-patterns, environment-configuration (platform-engineering plugin); release (production plugin).
   - Exit: pipeline green, flag defaults off, rollback path written, staged enablement planned.
9. Observe.
   - Goal: know whether it works for real users.
   - Apply: backend-observability (backend plugin), monitoring-observability (platform-engineering plugin).
   - Exit: error rate, latency, and the success metric from step 1 are visible; flag raised in stages while watching them.
10. Retrospective.
   - Goal: keep what was learned.
   - Apply: retrospective (production plugin), technical-documentation (shared plugin).
   - Exit: two or three changes to the process, docs updated, flag removed or scheduled for removal.

## Skip rules
- Small change, solo dev: merge steps 1 and 2 into a five-line note; skip the retrospective unless something went wrong.
- No schema change: skip step 4. No new endpoint: skip step 3.
- A flag is optional for low-risk, easily reverted changes; keep a rollback plan regardless.
- Never skip authorization checks, validation, or migration rehearsal.

## Common failure modes
- Starting UI before the contract, then reworking both sides.
- Happy-path-only frontend with no empty or error state.
- Migration that locks a large table or cannot be reversed.
- Flag left on forever, or no way to turn it off quickly.
- Shipping with no metric, so success is a guess.
- Review of the diff but not of authorization.

## Checklist
- [ ] Outcome, scope, and metric written.
- [ ] Design note self-reviewed against a checklist (fresh-eyes pass).
- [ ] OpenAPI spec written before implementation.
- [ ] Migration rehearsed, with rollback.
- [ ] Backend tests cover authorization and failure paths.
- [ ] Frontend states and accessibility verified.
- [ ] Security and performance findings resolved.
- [ ] Pipeline green, flag and rollback ready.
- [ ] Dashboards watched during rollout.
- [ ] Retro notes and docs saved.
