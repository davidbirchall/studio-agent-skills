---
name: software-architecture
description: Technology-neutral software architecture discipline - architectural drivers and quality attributes, boundaries with high cohesion and low coupling, dependency direction, choosing between layered, modular monolith and services (default to simplest), separation of concerns, interfaces and seams, evolutionary architecture and fitness functions, trade-off analysis, avoiding premature abstraction, C4 diagrams at the right level, and lightweight in-repo decision records. Load when shaping or reviewing system structure, drawing module boundaries, choosing a deployment style, introducing an abstraction, or recording an architectural decision.
---

# Software architecture

Builds on `technical-design` for the design process, `software-testing-strategy` for verifying structure, and `technical-documentation` for diagrams and docs. Frontend, backend, ai-engineering and game-development plugins apply this discipline to their stacks.

## Start from drivers
- List the quality attributes that matter for this system: latency, throughput, availability, security, modifiability, testability, cost, operability, time to market.
- Rank them and make each measurable ("p95 under 300 ms", "deploy without downtime"). Unranked drivers produce unfocused designs.
- Capture constraints separately: team size and skills, existing systems, compliance, budget, deadlines.
- Architecture is the set of decisions that are expensive to change. Spend design effort there, and defer the rest.

## Boundaries
- Draw boundaries around things that change together (high cohesion) and expose narrow, stable contracts to the rest (low coupling).
- Split by business capability or domain concept, not by technical type alone.
- A module owns its data. Others access it through its interface, never its storage.
- Signs of a wrong boundary: a change touches many modules; two modules must deploy together; modules share mutable state; circular imports.

## Dependency direction
- Depend toward stable, abstract, high-value code: domain logic does not import UI, framework, database or network code.
- Details (frameworks, drivers, vendors) depend on policy, not the reverse. Wire them at the edge (composition root).
- Forbid cycles. Enforce direction with tooling, not convention (see fitness functions).

## Choose the simplest structure
- Default to a single deployable with clear internal modules (modular monolith). Move to separate services only for a proven reason: independent scaling, independent team ownership, fault isolation, differing runtime needs.
- Layers help when rules are simple; modules by capability scale better. Do not add layers that only forward calls.
- Distribution adds latency, partial failure, versioning and operational cost. Count that cost before splitting.

## Interfaces and seams
- Put an interface where variation or testing needs a seam: external systems, clock, randomness, storage, model providers, platform APIs.
- Do not abstract on the first use. Wait for a second real case (rule of three), then extract the shared shape.
- A wrong abstraction costs more than duplication. Prefer duplication until the pattern is clear.
```ts
interface PaymentGateway { charge(req: ChargeRequest): Promise<ChargeResult> }
```

## Separation of concerns
- Keep I/O, business rules, presentation and orchestration in distinct units. Pure logic is easy to test; side effects live at the edges.
- Cross-cutting concerns (auth, logging, config) have one home and are applied uniformly, not re-implemented per feature.

## Evolve with fitness functions
- Encode architectural rules as automated checks in CI: no import cycles, forbidden layer imports, bundle or build size budgets, latency budgets, dependency allow-lists.
- Review the checks when drivers change. A rule nobody enforces is a wish.
- Prefer small reversible steps (strangler pattern, feature flags, parallel run) over big-bang rewrites.

## Trade-off analysis
- For each significant choice, compare at least two options against the ranked drivers. State what is gained and what is given up.
- Name the reversibility: cheap to undo, or a one-way door. Spend more analysis on one-way doors.
- Beware resume-driven choices and fashion. The simplest option that meets the drivers wins.

## Diagrams
- Use C4 levels only as deep as the audience needs: context (system and actors), containers (deployables and stores), components (inside one container). Code level is rarely worth drawing.
- Keep diagrams as text in the repo (see `technical-documentation`) and label every arrow with intent and protocol.

## Decision records
- Record each significant decision in the repo, for example `docs/decisions/0007-use-event-queue.md`, numbered and never rewritten; supersede instead.
```md
# 0007. Use a queue for order events
Status: accepted | superseded by 0012
Context: forces, drivers, constraints.
Decision: what we chose, in one or two sentences.
Consequences: gains, costs, follow-ups.
```
- Write it when the decision is hard to reverse or will be questioned later; this log is how future sessions learn why.

## Review checklist
- Which driver does this serve? What is the simplest alternative? Which way do dependencies point? Is there a seam where tests and change need one? See also `performance-engineering`, `application-security` and `code-review`.
