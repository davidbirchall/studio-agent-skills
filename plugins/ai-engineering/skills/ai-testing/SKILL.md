---
name: ai-testing
description: Deterministic testing around non-deterministic LLM components in TypeScript with vitest - fake and scripted model clients, recording and replaying provider responses, fixtures, contract tests for tool schemas and structured output, testing orchestration and agent loops with fake models, property and invariant checks, streaming and error-path tests, snapshot cautions, flaky test handling, and keeping cost-aware live tests separate from the default suite. Load when writing tests for chat, agent, tool or RAG code, mocking provider calls, or fixing flaky AI tests.
---

# AI testing

Builds on `llm-integration`, `agent-orchestration`, `tool-integration`, and Squad `test-discipline`. Quality of model answers is measured in `ai-evaluation`; tests here assert that our code is correct given any model output.

## Principle
- Do not assert on live model text in unit tests. Test our code with models replaced by deterministic fakes, and test model quality with evals.
- Put the provider behind an interface (`llm-integration`) so a fake can be injected with Nest DI.

## Fake model
- A scripted fake returns queued responses and records requests, so tests assert both directions.
```ts
class FakeModel implements ChatModel {
  readonly calls: ChatRequest[] = []
  constructor(private script: Array<ChatResponse | Error>) {}
  async complete(req: ChatRequest) {
    this.calls.push(req)
    const next = this.script.shift()
    if (!next) throw new Error('FakeModel script exhausted')
    if (next instanceof Error) throw next
    return next
  }
}
```
- Fail loudly when the script is exhausted; silent defaults hide loops.
- Build response helpers (`textReply`, `toolCall('search', {q})`, `refusal()`) instead of inline literals.

## Orchestration tests
- Script a multi-step run: model asks for a tool, tool returns, model answers. Assert the tool was called with the right arguments, results were fed back, and the final output is correct.
```ts
it('stops at the step limit', async () => {
  const model = new FakeModel(Array(50).fill(toolCall('search', { q: 'x' })))
  await expect(runAgent({ model, tools, maxSteps: 5 })).rejects.toThrow(StepLimitError)
  expect(model.calls).toHaveLength(5)
})
```
- Cover the failure paths: provider timeout, 429 with retry, malformed JSON, unknown tool name, invalid tool arguments, tool throwing, cancelled run, empty response, truncated output.
- Assert budgets, loop limits, and fallbacks (`agent-orchestration`) as code behaviour.

## Record and replay
- For realistic payload shapes, record real provider responses once into fixtures and replay them in tests. Keep fixtures small, reviewed, and scrubbed of secrets, PII, and account ids.
- Store the provider and model version in the fixture; refresh deliberately and review the diff. Never record automatically in CI.
- Prefer hand-built minimal fixtures; recordings go stale when the provider changes shape.

## Contract tests
- Tool schemas: every tool definition validates as JSON Schema, has a description, and rejects bad arguments with a structured error (`tool-integration`).
- Structured output: feed the parser a corpus of valid, malformed, partial, and hostile outputs; assert it either returns a typed value or a typed error, never throws unhandled.
- Parse fixtures from real model outputs into the same schema the app uses (zod or similar) so schema and prompt cannot drift.
- MCP servers: test tool listing and calls against a stub server (`mcp-integration`).

## Property and invariant checks
- Assert invariants that hold for any model output: output always matches schema, no secrets in logs, token budget never exceeded, tool calls only from the allowed set, tenant ids never cross.
- Use property-based generation (fast-check) for message truncation, context packing, and chunking (`context-engineering`): order preserved, size under limit, no message dropped silently.

## Streaming
- Feed a fake stream in chunks split at awkward places (mid-JSON, mid-UTF-8 character, mid-tool-call). Assert reassembly, cancellation cleanup, and error mid-stream.

## Snapshots and flakiness
- Do not snapshot raw model text or whole prompts casually; snapshots get bulk-updated unread. Assert specific parts: required sections, ordering, variables substituted, no unfilled placeholders.
- Prompt template tests: render with fixtures and assert key strings and token length bound.
- Flaky test means hidden nondeterminism: clocks, random ids, ordering, real network. Inject clock and id generators; use `vi.useFakeTimers()`. Do not add retries to hide it.
- Block network in unit tests so a missed mock fails instead of calling a provider.

## Live tests
- Tests that call a real provider live in a separate directory and vitest project, run on demand or nightly, never on every PR.
```ts
// vitest.config.ts: projects: [{ test: { name: 'unit', include: ['src/**/*.spec.ts'] } },
//   { test: { name: 'live', include: ['live/**/*.live.ts'], testTimeout: 60_000 } }]
```
- Skip when the key is absent, cap tokens and cases, use the cheapest adequate model, and assert only loose properties (valid schema, tool chosen). Credentials come from the environment (`secret-handling`).

## See also

Optional, if installed: software-testing-strategy (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
