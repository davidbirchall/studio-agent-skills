---
name: agent-orchestration
description: Orchestrating multiple LLM agents and steps in a TypeScript/Node/NestJS backend - sequential, parallel, router, orchestrator-workers, evaluator-optimiser, and handoff patterns; shared state; typed message contracts between agents; concurrency limits; durable and resumable execution; timeouts and cancellation; cost control; preventing runaway loops; and preferring deterministic code over LLM routing. Provider-agnostic. Load when coordinating more than one agent or model call, designing handoffs, or making multi-step runs durable and bounded.
---

# Agent Orchestration

Builds on `agent-design`, `llm-integration`, and `tool-integration`. Tracing of runs is in `ai-observability`; evaluating pipelines in `ai-evaluation`.

## Pick the pattern
- Sequential (chain): fixed steps, each output feeds the next. Add validation gates between steps.
- Parallel: independent subtasks (sectioning) or the same task run several times (voting). Merge in code.
- Router: classify input, dispatch to a specialised path. Use code or rules first; use a small model only when rules cannot decide.
- Orchestrator-workers: a planner decomposes dynamically, workers execute, orchestrator synthesises. Use when subtasks are unknown ahead.
- Evaluator-optimiser: generator then critic, loop until criteria pass or max rounds. Needs a clear, checkable criterion.
- Handoff: one agent transfers the conversation to another with a context package. Exactly one agent owns the turn at a time.
- Start with the simplest pattern; add agents only when a single agent measurably fails.

## Deterministic over LLM
- Route and branch in code when the decision is derivable from fields, enums, or regex. Reserve LLM routing for ambiguous natural language.
- Validate every LLM routing result against an allowed set; unknown value goes to a fallback path.

## Message contracts
- Agents exchange typed, schema-validated messages, not free text. Validate at every boundary (zod or equivalent).

```ts
const Handoff = z.object({
  runId: z.string(),
  from: z.string(), to: z.enum(['billing', 'support', 'human']),
  goal: z.string(),
  facts: z.array(z.string()),
  artifacts: z.array(z.object({ id: z.string(), kind: z.string() })),
  schemaVersion: z.literal(1),
});
```
- Pass the minimum context needed. Do not forward whole transcripts by default.
- Version contracts; reject unknown versions explicitly.

## Shared state
- One run record owns state: inputs, step outputs, status, cost. Agents read their slice and return results; the orchestrator writes.
- Parallel workers write to separate keys, merged deterministically. No shared mutable objects.
- Treat outputs from one agent as untrusted input to the next (`ai-security`).

## Concurrency
- Bound parallelism with a limiter (for example p-limit) and honour provider rate limits (`llm-integration`).
- Use `Promise.allSettled`; define per-branch whether failure is fatal or skippable.
- Pass an `AbortSignal` into every call so cancelling a run cancels its children.

## Durable execution
- Persist the run after each step: step id, input hash, output, status. Resume from the last completed step.
- Make steps idempotent or record an idempotency key so replay does not repeat side effects.
- For long or approval-gated runs, use a queue or workflow engine (BullMQ, Temporal, or similar) rather than an open HTTP request. Verify its delivery guarantees.
- Run workers are stateless; all state lives in the store.

## Limits and cost
- Timeout per step and per run. Total run budget: max steps, tokens, cost, and depth of delegation.
- Cap agent-to-agent hops and evaluator rounds. Detect cycles (same agent, same input hash) and stop.
- Use cheaper models for routing, extraction, and critics; stronger ones where measured necessary.
- Cache deterministic subresults. Record cost per step and per run; alert on outliers.
- On limit hit, return partial results with a reason code, never loop silently.

## See also

Optional, if installed: technical-design (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
