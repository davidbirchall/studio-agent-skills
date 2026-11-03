---
name: deployment-patterns
description: Provider-neutral deployment patterns - rolling, blue/green and canary strategies, feature-flag and dark launches, immutable deploys, expand/contract database migrations, health and readiness gating, zero-downtime rollouts, rollback strategy, separating deploy from release, progressive delivery, environment promotion of a single artifact, and runbook basics. Load when choosing a rollout strategy, planning a risky or schema-changing deploy, designing rollback, setting up promotion between environments, or writing a deploy runbook.
---

# Deployment patterns

Artifacts come from `containerization` and `ci-cd-workflows`; versioning and notes in `release-management`; infra definitions in `infrastructure-as-code`; signals in `monitoring-observability`; flags in `environment-configuration`.

## Foundations
- Deploy is moving an artifact into an environment. Release is exposing behavior to users. Keep them separate; flags bridge the gap.
- Build once, promote the same immutable artifact (image digest) through dev, staging, prod. Never rebuild per environment.
- Immutable deploys: replace instances, never patch them in place. Config and secrets are injected, not baked in.
- Every deploy is traceable: artifact version, commit, who or what triggered it, and when.
- Small, frequent deploys are safer than large, rare ones.

## Strategies
- Rolling: replace instances gradually. Simple and cheap; old and new versions run together, so both must be compatible with shared data and APIs.
- Blue/green: stand up the full new environment, verify, switch traffic, keep the old one for fast rollback. Needs double capacity during the switch.
- Canary: send a small traffic share to the new version, compare error rate and latency against baseline, then widen. Best for risky changes with good metrics.
- Recreate (stop then start): only for workloads that tolerate downtime or cannot run two versions.
- Choose by risk, capacity, statefulness, and quality of your signals; do not canary without metrics that can detect failure.

## Health gating
- Gate traffic on readiness, not process start. A new instance receives requests only after dependencies are reachable and warm-up completes.
- Gate rollout progress on health: halt automatically on failing readiness, elevated error rate, or latency regression.
- Drain connections on shutdown and give in-flight requests time to finish; the instance must handle `SIGTERM` (see `containerization`).
- Run a smoke test against the new version before shifting traffic and after.

## Database migrations
- Old and new code run simultaneously, so schema changes must be backward compatible. Use expand/contract.
- Expand: add nullable columns, new tables, new indexes; deploy code that writes both and reads new with fallback.
- Migrate: backfill data in batches, outside the request path.
- Contract: after all code uses the new shape and rollback is no longer needed, drop old columns in a later release.
- Never rename or drop a column in the same deploy that stops using it.
- Run migrations as a separate, idempotent step before the app rollout; not on every instance start.
- Destructive migrations need a verified backup and a documented restore path.

## Progressive delivery and flags
- Ship code dark behind a flag, enable for staff, then a percentage, then everyone. Roll back by turning the flag off.
- Tie each flag to a removal date. Remove after full rollout.
- Automate promotion and rollback from metrics where trust is established; keep a human gate for irreversible steps.

## Rollback
- Decide the rollback path before deploying: redeploy previous artifact, switch traffic back, or disable a flag.
- Rollback must be fast, rehearsed and not depend on a new build.
- Data changes are the hard part: prefer roll-forward fixes when a migration has already altered data; design migrations so the previous version still works.
- Define rollback triggers up front (error rate threshold, failed health checks, failed smoke test).

## Environment promotion
- Promotion order is fixed and automated: dev, staging, prod. Each stage has entry criteria (tests pass, smoke passes, approvals if needed).
- Staging mirrors prod topology and config shape. See `environment-configuration`.
- Production deploys avoid peak hours and unattended windows unless fully automated and safe.

## Runbook basics
- Document per service: how to deploy, verify, roll back, and who to contact.
- List dashboards and alerts to watch during rollout and the expected values.
- Include known failure modes with first actions, and the migration order.
- After incidents, update the runbook and add the missing automation or check.
