---
name: software-testing-strategy
description: Technology-neutral testing strategy - test pyramid and trophy, deciding what to test at which level, risk-based testing, unit vs integration vs end-to-end vs contract tests, judgement on test doubles, determinism and flakiness, test data, coverage as a signal not a goal, testing non-deterministic systems, CI feedback speed, definition of done, regression tests for bugs, and mutation and property-based testing. Load when planning how a feature will be tested, choosing test levels, fixing flaky tests, setting coverage or CI policy, or testing non-deterministic or AI-driven behavior.
---

# Software testing strategy

Builds on Squad's `test-discipline` (assertions that prove the contract), `technical-design` for the test plan, and `debugging` for turning bugs into tests. Frontend, backend, ai-engineering and game-development plugins apply it with their own tools.

## Goals
- Tests exist to give fast, trustworthy confidence that behavior still works so change stays cheap. Optimize for confidence per minute of run time and maintenance.
- A test that cannot fail for a realistic regression is waste. A test that fails for harmless refactors is a tax.

## Levels
- Unit: pure logic, branching, calculations, parsing, state machines. Milliseconds, no I/O.
- Integration: a module with its real collaborators (database, queue, filesystem, framework wiring). Catches mapping, query and configuration bugs that units cannot.
- Contract: the agreed shape between a consumer and a provider (API schema, event payload). Run on both sides so independent deploys stay safe.
- End-to-end: a few critical user journeys through the real system. Slow and brittle, so keep them few and stable.
- Shape: many unit tests, a solid middle of integration tests, a thin e2e layer. Where most bugs live in glue code (UI, services), weight toward integration (trophy).
- Test each behavior at the lowest level that can show it fails. Do not repeat the same assertion at three levels.

## Risk-based choices
- Rank by likelihood times impact: money, security, data loss, core journeys, complex logic, code that changes often.
- High risk gets deep tests at several levels; low risk gets a smoke check or nothing.
- Do not test framework behavior, trivial getters, or constants.

## Test doubles
- Prefer real collaborators when they are fast and deterministic. Use fakes (working in-memory versions) for slow or remote systems.
- Stub for canned answers, mock only to assert an interaction that is itself the contract (an email is sent).
- Double only at architectural seams you own: network, clock, randomness, filesystem. Mocking internals couples tests to structure.
- Verify fakes against the real thing with a shared contract test.

## Determinism and flakiness
- Control time, randomness, ordering, network and concurrency. Inject clocks and seeds; never sleep for fixed durations, wait on conditions.
- Isolate state: each test creates and cleans up its own data; no order dependence; parallel-safe.
- Treat a flaky test as a bug. Quarantine with an owner and a deadline, then fix or delete. Never retry-until-green silently.

## Test data
- Build data with small factories or builders that set only what the test cares about; defaults are valid.
- Keep data minimal and readable inline. Avoid giant shared fixtures that hide the cause of a failure.
- Never use real personal or production data; see `secret-handling` and `application-security`.

## Non-deterministic systems
- When output varies (models, agents, simulations, physics, timing), test properties and invariants, not exact strings: schema validity, bounds, safety rules, tool-call correctness, monotonic metrics.
- Pin seeds and stub the non-deterministic source for logic tests. Use evaluation sets with scored thresholds and tracked trends for quality, run separately from the fast gate.
- Assert on the decision or outcome, not on wording.

## Coverage
- Coverage shows what is untested; it does not show what is well tested. Use it to find blind spots, never as a target to hit.
- Review uncovered risky code. Mutation testing (injecting small faults and checking tests fail) measures real strength; use it on critical modules.
- Property-based testing generates inputs against invariants (round trip, idempotence, ordering); use it for parsers, serializers and algorithms.

## CI and feedback speed
- Order the pipeline fast to slow: lint and types, unit, integration, contract, e2e. Fail early.
- Keep the pre-merge suite under about ten minutes; move slow suites to nightly with clear ownership.
- Run tests the same way locally and in CI. A red main is fixed or reverted first.

## Done and regressions
- A change is done when risk-relevant tests pass at the right levels, new behavior has tests, and failure paths are covered.
- Every bug fix starts with a failing test that reproduces it, then the fix (`debugging`). Name it for the behavior, not the ticket.
- Delete or rewrite tests that no longer protect behavior; keep the suite small enough to trust. Review tests as code (`code-review`).
