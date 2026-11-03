---
name: infrastructure-as-code
description: Provider-neutral infrastructure as code - declarative definitions in git, modules and composition, remote state with locking, environment separation, plan-before-apply in CI, drift detection, least-privilege deploy identities, keeping secrets out of code and state, tagging and naming conventions, testing and policy-as-code, small blast radius, importing existing resources, and destroy protections. Load when defining, reviewing or changing infrastructure definitions, structuring modules or state, wiring plan and apply into pipelines, or adopting existing manual resources.
---

# Infrastructure as code

Builds on `ci-cd-workflows`, `environment-configuration`, `secrets-management`, `deployment-patterns`, and `containerization`. Principles are tool-neutral; HCL (Terraform/OpenTofu style) is one illustration. Verify syntax and flags against current tool docs.

## Definitions
- Describe desired state declaratively and keep it in git (`git-workflows`). No change happens by console clicks or ad hoc CLI.
- Review infrastructure changes like code: read the plan output yourself (self-review checklist; optionally an AI pass) before applying.
- Pin tool, provider and module versions; commit the lock file. Upgrade deliberately in its own change.
- Prefer boring, explicit definitions over clever dynamic generation. Readability beats DRY.

## Modules and composition
- A module has one purpose, typed inputs, validated where possible, and explicit outputs. Keep inputs few.
- Compose small modules in a root configuration per deployable unit; do not nest deep module trees.
- Version shared modules (git tag or registry) and consume by pinned version, never a moving branch.
```hcl
module "queue" {
  source      = "git::https://example.com/infra-modules.git//queue?ref=v1.4.0"
  name        = "orders"
  environment = var.environment
}
```

## State
- Use remote state with locking and encryption at rest. Never local state for shared infrastructure; never commit state.
- Split state per environment and per component so a bad apply touches little. Keep state access narrower than code access.
- State can contain secret values; restrict read access and treat it as sensitive.
- Never hand-edit state. Use the tool's state commands for moves, removals and imports.

## Environments
- Same modules for every environment; differences live only in variable files or workspace-level inputs (`environment-configuration`).
- Separate environments by account/project/subscription boundary or equivalent, not just by name suffix.
- Promote by applying the same reviewed code version to the next environment, not by editing copies.

## Pipeline
- On pull request: format check, validate, lint, policy check, and plan. Post the plan to the PR.
- Apply only from the main branch (or tagged release) via the pipeline, using the saved plan that was reviewed.
- Serialize applies per state; rely on locking and a concurrency group in CI.
- Require an explicit confirmation step for production applies and for any plan that destroys or replaces resources: the agent shows the plan summary and asks the user before applying.

## Identities and secrets
- Pipeline identities are least-privilege, scoped per environment, using short-lived federated credentials over static keys.
- Plan identity is read-only; apply identity is separate and only reachable from protected branches.
- No secrets in code, variable files, or outputs; reference a secret store and mark values sensitive (`secrets-management`, `secret-handling`).
- Generate credentials in the platform where possible so state never holds the value.

## Conventions
- Naming: `{project}-{app}-{env}-{resource}` or similar, documented once and enforced by module.
- Tag or label every resource with environment, application, cost center, and managed-by marker (add owner if others share the account).
- Keep a one-line description on every variable and output.

## Testing and policy
- Static checks first: format, validate, lint, security scan of definitions.
- Policy as code (deny public storage, require encryption, require tags, cap instance sizes) runs against the plan in CI.
- Test shared modules with plan-level assertions or an ephemeral apply in a sandbox, then destroy (`test-discipline`).

## Drift and safety
- Run a scheduled plan per state; non-empty plan on main raises an alert and a ticket. Fix by reapplying or by codifying the change.
- Small blast radius: separate stateful (databases, storage, networks) from stateless components; change them independently.
- Enable deletion protection and prevent-destroy lifecycle rules on data stores and DNS zones; back up before risky changes.
- Read plans for replace/destroy markers before applying. A replace of a stateful resource needs a migration plan.

## Adopting existing resources
- Import into state, write matching definitions, and iterate until plan is empty before changing anything.
- Import one component at a time; do not mix import with behavior changes.
- Record the import in the change notes so console reality can be compared with code.

## See also

Optional, if installed: application-security (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
