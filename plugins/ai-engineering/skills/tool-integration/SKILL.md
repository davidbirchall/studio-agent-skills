---
name: tool-integration
description: Designing tools (function calling) that LLM agents invoke in a TypeScript/Node/NestJS backend - schema design, naming and descriptions, input validation, idempotency, error results the model can act on, permissions and authorisation, side-effect classification, confirmation for destructive tools, result size limits, parallel tool calls, and timeouts. Provider-agnostic. Load when defining, reviewing, or debugging tools an agent or chat model can call.
---

# Tool Integration

Builds on `llm-integration` and `prompt-engineering`; used by `agent-design`. For tools served over a protocol see `mcp-integration`; for injection and abuse see `ai-security`.

## Schema and naming
- One tool, one job. Verb-noun names (`search_orders`, `create_ticket`) that are distinct from each other.
- Description says what it does, when to use it, when not to, and what it returns. This is prompt text; test it (`ai-evaluation`).
- Few, flat parameters. Use enums over free strings, describe each field, mark required, give formats and units.
- Define schema once (zod or JSON Schema) and derive both the provider tool definition and the validator from it. Verify the exact tool-definition shape against your provider SDK.

```ts
const SearchOrders = z.object({
  customerId: z.string().describe('Customer id, e.g. "c_123"'),
  status: z.enum(['open', 'shipped', 'cancelled']).optional(),
  limit: z.number().int().min(1).max(50).default(10),
});
```

## Validate and authorise
- Model arguments are untrusted input. Parse with the schema on every call; reject, never coerce silently.
- Authorise in code using the caller's identity from the run context, not from model arguments. The model must not choose whose data to access.
- Pass identity and tenant via an execution context object the model cannot see or alter.
- Apply least privilege: expose each agent only the tools its job needs.

## Side-effect classes
- Read: no state change. Auto-run.
- Write, reversible: creates or updates with an undo. Auto-run within limits, log it.
- Write, irreversible or external (send email, pay, delete): require confirmation from a human or policy check in code, showing exact arguments (`agent-design`).
- Tag each tool with its class in code; the runner enforces policy from the tag, not from the prompt.

## Idempotency
- Mutating tools accept or derive an idempotency key (run id + step + call id). Retries and resumed runs must not duplicate effects.
- Prefer upserts and "ensure" semantics over blind creates.

## Results the model can act on
- Return structured results. Errors are results, not thrown exceptions, with a stable code and a hint.

```ts
return { ok: false, error: { code: 'NOT_FOUND', message: 'No order o_9', hint: 'Call search_orders to find valid ids' } };
```
- Distinguish invalid input (model can fix), not permitted (do not retry), transient (retry later), and internal (stop). Do not leak stack traces or secrets (`secret-handling`).
- Cap result size: truncate, paginate, or summarise, and say so in the result (`truncated: true`, `nextCursor`). Return only fields the model needs.
- Treat tool output as untrusted data; it may contain injected instructions (`ai-security`).

## Execution
- Per-tool timeout and AbortSignal. Return a timeout error result, do not hang the loop.
- Parallel calls: run independent read tools concurrently with a limit; run writes sequentially unless proven independent. Return results matched by call id.
- Limit calls per step and per run. Log tool name, duration, outcome, and redacted arguments (`ai-observability`).

## Registry
- Keep tools in a typed registry: name, schema, side-effect class, timeout, handler. The runner looks up by name and rejects unknown names the model invents.
- Load only the tools relevant to the current turn; large tool lists degrade selection and cost tokens (`context-engineering`).

## Connectors to external apps
- A connector is one external-app integration (Figma, Trello, GitHub, Slack, Google Drive) that lets the chat act on the user's account. Implement it as an MCP client when a good server exists (`mcp-integration`), otherwise as a thin REST/OAuth adapter exposing a few typed tools. Fixed, reviewed list; nothing third parties publish to.
- Normalise every app's tools into this internal schema: namespaced name (`trello.create_card`), zod input, side-effect class, timeout, result mapper. MCP and REST tools look identical to the runner.
- Trim results to the fields the model needs; paginate with `nextCursor`; hard-cap bytes and items and set `truncated: true`.
- Connection flow per user: OAuth (or API key) with least-privilege scopes, tokens encrypted at rest, refreshed before expiry, revoked on disconnect. Handlers fetch the token by user and connector; the model never sees it (`secret-handling`). Expired or revoked tokens return a `NEEDS_REAUTH` result the UI can act on.
- Per turn, expose only tools of connectors the user connected and enabled for this project or conversation, then narrow to a handful by intent. Never offer all tools every time: it costs context, hurts selection, and widens injection risk.
- Separate read tools (auto-run) from write tools (creating a card, editing a Figma file). Writes pause for user confirmation showing exact arguments.
- Per-connector rate limit, timeout, bounded retries with jitter, and circuit breaker. Failure returns "connector unavailable"; the turn continues without it.
- External content is untrusted input and can carry injected instructions (`ai-security`). Log every call: user, connector, tool, redacted args, outcome, run id.

## Testing
- Unit test each tool without a model: valid, invalid, unauthorised, timeout, oversized cases (`test-discipline`).
- Regression-test tool selection with fixed prompts and a fake or recorded model (`ai-testing`).
