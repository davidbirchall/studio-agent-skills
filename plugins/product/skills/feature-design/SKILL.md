---
name: feature-design
description: Detail a single feature from a PRD into build-ready form - user stories (INVEST), behaviour rules, edge cases and error states, acceptance criteria in Given/When/Then, analytics, rollout and feedback plan, and a definition of ready. Load when a requirement or story-map slice is approved and needs to be broken down for delivery, or when a feature spec is ambiguous or missing edge cases.
---

# Feature design

## Purpose
Give the builder (the user or the AI) an unambiguous, right-sized specification of one feature so it can be built, tested, released, and measured.

## Inputs
- Approved requirement(s) and success metrics (from `product-definition`).
- Flows and prototype (from `ux-design`).
- Known constraints and dependencies.

## Steps
1. Restate the feature's user goal and the PRD requirement IDs it satisfies.
2. Split into user stories: "As a [user], I want [capability], so that [benefit]." Check each against INVEST (Independent, Negotiable, Valuable, Estimable, Small, Testable). Slice vertically so each story delivers user-visible value, not a technical layer.
3. Specify behaviour: rules, permissions, data shown, copy, and states (empty, loading, error, partial, offline if relevant).
4. Enumerate edge cases and failure modes: invalid input, concurrency, limits, undo, interrupted flows, existing data migration.
5. Write acceptance criteria as Given/When/Then scenarios that a tester could run without asking questions.
6. Define measurement: which events or signals show the feature works, tied to the PRD metric.
7. Plan release: feature flag or staged rollout, support and documentation needs, feedback channel, and rollback or kill criteria.
8. Run a definition-of-ready check before work starts, covering design, build, and test concerns; ask the user one focused question if any item is blocked.

## Output
```
# Feature spec: <name>   (PRD refs: R1, R3)
User goal:
Stories:
- <As a... I want... so that...>
  Acceptance:
  - Given ... When ... Then ...
Behaviour rules and states (empty/loading/error):
Edge cases and decisions:
Measurement: <event/signal -> metric>
Rollout and feedback: <flag, audience, support, rollback criteria>
Out of scope:
Open questions:
Definition of ready: [ ] design [ ] criteria testable [ ] dependencies clear [ ] estimated
```

## Sizing the effort
- Small tweak: one story with three or four acceptance criteria.
- Medium feature: three to six stories, an edge-case list, and an event table.
- Big bet: add a staged rollout, a feature flag plan, and a post-launch review date.

## Story and acceptance format
As a [user], I want [capability], so that [benefit].
Scenario: Reminder sent for an overdue invoice
Given an invoice is 14 days overdue and the client has an email address
When I choose Send reminder and confirm
Then the client receives the message and the invoice shows "Reminded today"
Scenario: Client has no email (failure path)
Given the client has no email address
When I choose Send reminder
Then I am prompted to add an email and no message is sent

## Edge cases and failure paths
Check: empty and maximum data, invalid input, duplicate actions, two people editing at once, lost connection mid-action, permission differences, undo, and existing data. Record a decision for each, even "not supported, show message X".

## Analytics events
| Event | Trigger | Properties | Metric served |
| reminder_sent | Confirm pressed | days_overdue, channel | Reminder adoption |
| reminder_failed | Send error | reason | Guardrail: errors |

## Quality checklist
- Each story is small and independently valuable.
- Acceptance criteria are testable and cover error and empty states.
- Edge cases have explicit decisions, not "TBD".
- Measurement links to the PRD success metric.
- Rollout and rollback are defined.

## Anti-patterns
- Stories sliced by layer ("build the API", "build the UI").
- Acceptance criteria that restate the title.
- Discovering edge cases during testing.
- Shipping with no way to tell whether it worked.
- Listing a flag in the plan with no owner or removal date.

## Rollout and definition of done
Rollout: internal users, then a small percentage, then everyone, with a named owner watching the guardrail metrics at each step. Kill criteria example: "Disable the flag if error rate exceeds 2 percent for an hour." Done means: acceptance criteria pass, edge cases handled, events verified, documentation and support notes ready, flag cleanup scheduled.

## Ready for production planning
- [ ] Stories pass INVEST and carry testable criteria.
- [ ] Edge-case decisions, events, and rollout plan are written.
- [ ] Definition-of-ready checklist passes for design, build, and test concerns.

## Handoff
After release, compare measured results against the PRD metrics. Feed learnings back to `idea` for the next iteration or to `discovery` for new opportunities.

## See also

Optional, if installed: technical-design (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
