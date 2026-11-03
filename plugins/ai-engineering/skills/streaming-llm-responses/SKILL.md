---
name: streaming-llm-responses
description: Implement provider-to-server LLM token streaming, event normalisation, partial tool-call arguments, cancellation, persistence, reconnects, resume IDs, ordering, and stream tests. Load when model output arrives incrementally or users need stop, resume, retry, or live tool-call updates.
---

# Streaming LLM Responses

Builds on `llm-integration` and `chat-application-architecture`. Cost and retries in `ai-cost-latency-control`; testing discipline in `ai-testing` and `test-discipline`.

## Normalise at the edge
- One adapter per provider converts raw chunks into your own event schema. Nothing downstream sees provider shapes.
- Chunk formats, field names, and finish reasons differ; verify against current provider docs.

```ts
type StreamEvent =
  | { id: number; runId: string; type: 'run.started' }
  | { id: number; runId: string; type: 'text.delta'; partId: string; text: string }
  | { id: number; runId: string; type: 'tool.call.started'; callId: string; name: string }
  | { id: number; runId: string; type: 'tool.call.completed'; callId: string; args: unknown }
  | { id: number; runId: string; type: 'tool.result'; callId: string; output: unknown }
  | { id: number; runId: string; type: 'usage'; input: number; output: number; cached?: number }
  | { id: number; runId: string; type: 'run.finished'; status: 'completed' | 'cancelled' | 'failed'; reason: string };
```
- Map provider finish reasons to a small enum (stop, length, tool_calls, content_filter, error). Unknown value becomes `error` with the raw value logged.

## Parsing
- SSE: split on blank lines, handle multi-line `data:` fields, ignore comments and keep-alives, stop on the provider terminator. Buffer partial lines across network chunks; decode with a streaming UTF-8 decoder.
- Accumulate deltas per part keyed by index or id. Never assume one chunk equals one token or one whole character.
- Tool-call arguments arrive as string fragments. Concatenate by call index; parse JSON only when the call is complete. Do not execute on partial arguments.
- For partial display of JSON, use a tolerant parser for UI only; the persisted and executed value is the strictly validated final JSON (zod).
- Handle multiple tool calls and interleaved text in one response.

## Ordering and idempotency
- Each run has a monotonically increasing event `id`, assigned by the server in one place. Clients ignore ids at or below the last seen.
- Reconnect with `Last-Event-ID`; server replays from a short-lived event buffer (Redis stream or table), else sends a snapshot of the message then continues.
- Events are idempotent: applying one twice yields the same state.

## Cancellation
- Stop button calls a cancel endpoint (not just closing the socket). Server aborts the provider request via `AbortController`, which propagates to tool calls and child runs.
- Client disconnect alone should not kill the run unless policy says so (`chat-application-architecture`); make this explicit.
- After abort, flush persisted partial text, mark `cancelled`, emit `run.finished`.

```ts
const ac = new AbortController();
runs.set(runId, ac);
try { for await (const ev of adapter.stream(req, ac.signal)) await sink.emit(ev); }
catch (e) { if (!ac.signal.aborted) throw e; }
finally { runs.delete(runId); }
```

## Errors and recovery
- Mid-stream failure: keep text received, mark message `failed`, emit an error event with a stable code and a retryable flag. Offer continue or retry as a new run.
- Do not silently restart a stream that already emitted tokens; the user would see duplicated or changed text.
- Idle timeout: if no chunk arrives within N seconds, abort and fail. Send heartbeats to clients and verify proxy buffering and timeouts (disable response buffering, set long read timeouts).
- Backpressure: do not buffer unboundedly for slow clients; drop to snapshot-on-reconnect.

## Persistence
- Persist partial output periodically (for example every 500 ms or N chars) and at finish, in the same message row. A crash leaves a readable partial.
- Commit final parts, status, and usage atomically at stream end.
- Usage usually arrives in the last chunk, sometimes only when requested via an option; verify against current provider docs. If absent after abort, record an estimate flagged as such.

## Testing
- Record real streams as fixtures (sanitised, no secrets; see `secret-handling`). Replay them through the adapter and assert the normalised events.
- Build a fake provider that emits scripted chunks with controllable delays, splits mid-UTF-8 and mid-JSON, drops the connection, and returns errors.
- Cases: fragmented tool args, parallel tool calls, abort mid-text, abort mid-tool-call, mid-stream 5xx, duplicate and out-of-order events, reconnect replay, missing usage.
- Assert on final persisted state and event sequence, not on chunk counts.

## Anti-patterns
- Parsing provider JSON in the controller or the Vue component.
- `JSON.parse` on each fragment; executing tools before arguments complete.
- Cancel implemented only client-side; provider keeps generating and billing.
- Rendering Markdown by naive re-parse of the whole text on every delta without throttling.

## Checklist
- [ ] Provider adapter emits only your schema
- [ ] Ordered, idempotent event ids; resumable
- [ ] Server-side cancel with AbortSignal propagation
- [ ] Partial output persisted; failures keep text
- [ ] Usage captured or estimated and flagged
- [ ] Fixture and fake-provider tests cover abort, fragments, errors
