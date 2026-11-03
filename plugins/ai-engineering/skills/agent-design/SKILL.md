---
name: agent-design
description: Designing a single LLM agent in a TypeScript/Node/NestJS backend - deciding between a single call, a fixed workflow, and an agent; the agent loop; goals and explicit stop conditions; step, token, time, and cost budgets; state and memory; planning; human-in-the-loop approval; failure handling; single-responsibility agents; and autonomy levels. Provider-agnostic. Load when deciding whether to build an agent, designing an agent loop, setting limits, or adding approvals and recovery.
---

# Agent Design

Builds on `llm-integration`, `prompt-engineering`, and `tool-integration`. Multi-agent coordination is in `agent-orchestration`; memory contents and trimming in `context-engineering`.

## Agent, workflow, or single call
- Single call: one input, one output, no decisions (classify, extract, summarise). Default.
- Workflow: steps known in advance, LLM used inside steps. Code decides control flow. Prefer when the path is predictable.
- Agent: the model chooses the next action from tools because the path cannot be known ahead. Accept higher cost, latency, and variance.
- Move up one level only when the simpler one fails on measured cases (`ai-evaluation`).

## The loop
- Loop: build context, call model, execute requested tools, append results, check stop, repeat.
- Keep the loop in plain code you own. Model and tools sit behind interfaces so the loop is testable with a fake model (`ai-testing`).

```ts
for (let step = 0; step < limits.maxSteps; step++) {
  budget.assertWithin(); signal.throwIfAborted();
  const turn = await model.generate(state.messages, { tools });
  state.append(turn);
  if (turn.toolCalls.length === 0) return finish(turn, 'completed');
  state.append(await runTools(turn.toolCalls, ctx));
}
return finish(state.last(), 'step_limit');
```

## Goals and stop conditions
- State the goal and a done-criterion in the system prompt. "Done" is a verifiable condition, not a feeling.
- Stop reasons are an enum: completed, step_limit, budget_exceeded, timeout, cancelled, needs_human, failed. Return it to the caller.
- Always set hard limits in code: max steps, max tokens, wall-clock timeout, max cost. Prompts are not limits.
- Detect no-progress: same tool call with same arguments repeated, or no new information across N steps. Stop or escalate.

## State and memory
- Separate run state (messages, scratchpad, step count) from long-term memory (user facts, past outcomes).
- Run state is serialisable JSON so a run can be persisted and resumed. No class instances or closures in state.
- Long-term memory is written deliberately by a tool or post-run step, scoped per user or tenant, and has a retention policy.
- Summarise or trim old turns by rule (`context-engineering`). Never silently drop the goal or constraints.

## Planning
- Use a plan step only for multi-step tasks. Keep the plan as structured data (steps with status) in state.
- Allow replanning when a step fails. Cap replans.
- Cheap alternative: a fixed plan template in code that the model fills in.

## Human in the loop
- Require approval before irreversible or high-impact actions (`tool-integration` side-effect classes).
- Approval pauses the run: persist state, emit an approval request, resume on the decision. Do not hold a request open.
- Approval payload shows the exact action and arguments, not a summary.
- Rejection returns a result the model can act on, not a crash.

## Failure handling
- Tool errors go back to the model as results; allow bounded retries with changed arguments.
- Retry transient provider errors with backoff in `llm-integration`, not inside the loop logic.
- Malformed output: one repair attempt, then fail the step.
- On any failure, return partial progress and the stop reason.

## Scope and autonomy
- One agent, one responsibility, a small tool set (aim for under about 10). Split roles rather than grow a prompt.
- Least privilege per agent: tools and data scopes allowed for its job only (`ai-security`).
- Autonomy levels: suggest only, act with approval, act then report, fully autonomous within limits. Choose per action class, start lowest, raise on evidence.
- Log each step with run id, step, tool, latency, tokens (`ai-observability`).

## See also

Optional, if installed: software-architecture (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
