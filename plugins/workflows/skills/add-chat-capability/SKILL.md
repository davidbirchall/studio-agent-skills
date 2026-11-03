---
name: add-chat-capability
description: Recipe for adding a capability to a conversational AI application, such as a new connector, a project feature, or a new model behaviour - user-visible behaviour, data model change, context assembly impact, backend orchestration and streaming events, frontend rendering and stream handling, evaluation set and regression tests, cost and latency budget, security, and observability. Names the skills to apply at each step, the exit check, and the handoff. Load when extending chat features end to end or planning a change to how the assistant behaves.
---

# Add chat capability

An ordered recipe, not a reference. Each named skill is optional: if its plugin is not installed, do the step anyway using general good practice. Apply the skills; do not restate them here.

## When to use / when not to
- Use for a new connector or tool, a project-level feature (instructions, files, memory), or a change in how the model behaves or responds.
- Not for a UI-only restyle, a prompt typo fix, or a pure infrastructure change.

## Steps
1. Define the user-visible behaviour.
   - Goal: say what the user sees and when it should not happen.
   - Apply: feature-design (product plugin), scope (production plugin).
   - Exit: three example conversations, including a failure case, and a success measure. Hand on: the examples (they seed the evaluation set).
2. Data model change.
   - Goal: store what the capability needs without breaking history.
   - Apply: chat-application-architecture and conversation-memory (ai-engineering plugin), database-design and prisma-patterns (backend plugin), database-migrations (data plugin).
   - Exit: new message part types or project fields defined, old messages still render, migration rehearsed. Hand on: schema.
3. Context assembly impact.
   - Goal: know what enters the prompt and what it displaces.
   - Apply: context-engineering, prompt-engineering, and retrieval-augmented-generation when files or search are involved (ai-engineering plugin).
   - Exit: token budget per section, ordering, and truncation rule written. Hand on: assembly spec.
4. Backend orchestration and streaming events.
   - Goal: run the capability and emit events the client can follow.
   - Apply: llm-integration, tool-integration or mcp-integration, streaming-llm-responses, agent-design if multi-step (ai-engineering plugin); realtime-streaming and error-handling (backend plugin).
   - Exit: event types listed (start, delta, part, error, done), cancellation and partial failure behave. Hand on: event contract.
5. Frontend rendering and stream handling.
   - Goal: render every new part and survive reconnects.
   - Apply: chat-ui-patterns, streaming-client, state-management, frontend-a11y-check (frontend plugin).
   - Exit: partial, failed, and stopped states render; screen reader announcements not noisy; old threads load. Hand on: working flow.
6. Evaluation and regression tests.
   - Goal: prove behaviour before shipping.
   - Apply: ai-evaluation and ai-testing (ai-engineering plugin), backend-testing and frontend-testing.
   - Exit: an evaluation set built from step 1 with pass thresholds, plus a regression set of existing key conversations; both run in CI or a repeatable script.
7. Cost and latency budget.
   - Goal: stay within an agreed price and speed.
   - Apply: ai-cost-latency-control (ai-engineering plugin), rate-limiting-quotas (backend plugin).
   - Exit: tokens, calls, time-to-first-token, and cost per conversation measured against the budget; limits set.
8. Security.
   - Goal: assume hostile content.
   - Apply: ai-security (ai-engineering plugin), application-security (shared plugin), authentication-authorization.
   - Exit: prompt injection through tool results and files considered, connector scopes minimal, per-user isolation tested, secrets kept server side.
9. Observability and rollout.
   - Goal: see behaviour in real use.
   - Apply: ai-observability (ai-engineering plugin), backend-observability, release (production plugin).
   - Exit: traces show prompt, tool calls, and cost per request without leaking private content; flagged rollout and rollback ready.

## Skip rules
- Behaviour-only change with no schema: skip step 2.
- No new tools or files: shorten steps 3 and 8 to a quick check, but never skip the evaluation set.
- Solo dev: ten to twenty evaluation cases is enough; a spreadsheet budget is fine.

## Common failure modes
- Changing the prompt with no evaluation, so regressions go unseen.
- New message part types that break old thread rendering.
- Tool output trusted as instructions.
- Connector granted broad scopes for convenience.
- Capability silently crowds out history from the context window.
- Cost measured on one demo prompt, not on typical long threads.
- Stream errors dropped, leaving a spinner forever.

## Checklist
- [ ] Example conversations and success measure written.
- [ ] Schema change rehearsed; old data still renders.
- [ ] Context budget and truncation rule documented.
- [ ] Event contract defined; cancellation tested.
- [ ] All new states rendered and accessible.
- [ ] Evaluation and regression sets pass thresholds.
- [ ] Cost and latency within budget.
- [ ] Injection and scope checks done.
- [ ] Traces and rollback in place.
