---
name: chat-application-architecture
description: End-to-end architecture of a conversational AI application in TypeScript with NestJS, Prisma, PostgreSQL and a Nuxt client - performance first (time-to-first-token, fast thread list and open, coalesced streaming writes, responsive long threads), projects that group conversations with shared instructions and reference files, conversation and message-tree data model with edit/regenerate branching, typed message parts, run records and status lifecycle, idempotent sends, server-owned truth versus optimistic client state, request flow, stop/regenerate/edit/retry semantics, attachments, titles, deletion, per-conversation model selection, and instruction layering. Provider-agnostic. Load when designing or reviewing the data model, API, performance, or request flow of a chat application.
---

# Chat Application Architecture

Builds on `agent-orchestration` and `llm-integration`. Stream wire format is in `streaming-llm-responses`; prompt assembly in `conversation-memory` and `context-engineering`; budgets in `ai-cost-latency-control`.

## Performance first
- Time to first token: do only auth, one transaction, and context assembly before calling the provider. Run retrieval, title, and summaries off or beside the critical path (`ai-cost-latency-control`).
- Thread list: keyset pagination on `(user_id, updated_at DESC, id)`, index to match, select only id/title/updatedAt/projectId. Never load messages for the list.
- Thread open: load the active path (leaf to root) in one query, newest page first, older pages on scroll. Denormalise `activeLeafId` and a path or depth column to avoid recursive CTEs per open; cache the rendered path per conversation in memory or Redis, invalidate on write.
- Streaming writes: coalesce deltas in memory and flush on an interval (about 250-500 ms) or size threshold, one UPDATE of the message row; commit final state once. Never one write per token.
- Long threads: virtualise the message list, memoise rendered Markdown per part, throttle re-render to animation frames, keep streaming text in a separate reactive ref until complete.
- Measure TTFT, list p95, open p95, and writes per response; budget them (`ai-observability`).

## Scope
- Core: projects, conversations, message tree, parts, runs, streaming, stop/regenerate/edit/retry, partial persistence, idempotent sends, title, attachments, a small curated set of external-app connectors.
- Out of scope for now: plugin marketplace or third-party publishing, sharing, artifacts/canvas, org features, moderation pipelines.
- Carry `userId` on every row and route writes through one service so later features are additive.

## Data model
- Project: id, userId, name, instructions, archivedAt, deletedAt. Owns conversations (`projectId` nullable on conversation) and project files.
- Project file: id, projectId, fileId, status (processing, ready, failed), token count, chunk index reference.
- Ownership: every query filters by `userId` in the data layer; a conversation in a project must share its owner. Moving a conversation re-checks both.
- Conversation: id, userId, projectId, title, model, activeLeafId, archivedAt, deletedAt.
- Message is a node in a tree: `parentId` points to the message it answers. Edit and regenerate create siblings, never overwrite.
- `activeLeafId` on the conversation selects the visible branch. The transcript is the path from root to that leaf.
- Message content is an ordered list of parts, not a string. Part kinds: text, reasoning, tool_call, tool_result, attachment, citation.
- Run (one model turn or orchestration): id, conversationId, inputMessageId, outputMessageId, status, model, usage, error, startedAt, endedAt.
- Messages are append-only. Corrections are new messages; soft-delete via `deletedAt`.

```sql
CREATE TABLE message (
  id uuid PRIMARY KEY, conversation_id uuid NOT NULL REFERENCES conversation(id),
  parent_id uuid REFERENCES message(id), role text NOT NULL,
  status text NOT NULL DEFAULT 'completed', seq bigint GENERATED ALWAYS AS IDENTITY,
  parts jsonb NOT NULL, client_request_id text, created_at timestamptz DEFAULT now(),
  UNIQUE (conversation_id, client_request_id)
);
CREATE INDEX ON message (conversation_id, parent_id);
```

```ts
type Part =
  | { type: 'text'; text: string }
  | { type: 'tool_call'; id: string; name: string; args: unknown }
  | { type: 'tool_result'; callId: string; output: unknown; isError?: boolean }
  | { type: 'attachment'; fileId: string; mime: string }
  | { type: 'citation'; sourceId: string; span?: [number, number] };
```
- Version the parts schema. Validate on write and on read.

## Status lifecycle
- queued -> streaming -> completed | failed | cancelled. Transitions are one-way and enforced in one service.
- Persist `streaming` messages with partial parts so a crash or reload shows what exists. Sweep stale `streaming` rows to `failed`.

## Request flow
- Client POST send with `clientRequestId` -> API authenticates, authorises, checks budget -> inserts user message and queued run in one transaction -> orchestrator builds context, calls provider -> normalised events stream to client and are persisted -> final usage and status committed.
- Idempotency: unique `(conversation_id, client_request_id)`. A retried send returns the existing run, never a duplicate.
- Decouple generation from the HTTP connection: run in a worker, clients subscribe to the run stream and can resume by last event id.

## Semantics
- Stop: abort provider call, keep partial output, status `cancelled`. Cancelled partials remain visible.
- Regenerate: new assistant sibling under the same parent; set `activeLeafId` to it.
- Edit: new user sibling with the new content; regenerate beneath it; old branch stays navigable.
- Retry after failure: new run on the same input message; the failed message stays as history.
- Only the last turn is continuable. Do not allow concurrent runs on one branch; reject or queue.

## Server truth vs client state
- Server owns ids, order, status, and usage. Client may show optimistic user messages keyed by `clientRequestId`, reconciled on server echo.

## Instruction and project context layering
- Order: platform rules, user custom instructions, project instructions, conversation overrides, then history. Lower layers cannot remove higher ones.
- Project instructions are injected on every run of its conversations; keep them short and stable so the prefix caches.
- Project files: ingest once (extract, chunk, embed) when uploaded, status `ready` before use. Small files whose total fits a set token cap go in context whole; larger sets go through retrieval scoped to the project's `projectId` (`retrieval-augmented-generation`). Cite file and chunk in `citation` parts.
- Retrieve in parallel with other pre-steps; cap retrieved tokens; never retrieve across projects or users.
- Changing project instructions or files affects new runs only; stored messages are not rewritten. Record the project version on the run.

## Connectors
- A connector is one external-app integration (Figma, Trello, GitHub, Slack, Google Drive): an MCP client when a good server exists, otherwise a thin REST/OAuth adapter with a few typed tools (`tool-integration`, `mcp-integration`). Support a fixed, reviewed list of apps; no marketplace.
- Connection per user: OAuth or API key, encrypted token storage, refresh, revocation on disconnect, least-privilege scopes. UI states: not connected, connected, needs reauth, unavailable.
- Enablement per project or conversation, off by default. Only tools of connected and enabled connectors reach the model that turn.
- Tools are normalised to one internal schema with namespaced names (`trello.create_card`), trimmed results, pagination, size caps.
- Confirm before write: side effects show exact arguments for user approval; the run pauses as `awaiting_approval`.
- Isolation: per-connector rate limit, timeout, retries, circuit breaker; an outage returns "connector unavailable" and chat continues.
- External results are untrusted input (`ai-security`). Audit log: user, connector, tool, redacted args, outcome, run id.

## Other core details
- Model is stored per conversation and recorded per run.
- Keep one `beforeRun` step for authorisation and budget checks (`ai-security`).
- Title: generate asynchronously after first exchange with a small model; never block the reply; user rename wins.
- Attachments: upload separately, store in object storage, reference by `fileId`; check ownership at use time.
- Deletion: soft delete first; hard delete also removes files, chunks, embeddings, and derived summaries. Deleting a project deletes or detaches its conversations by explicit user choice.

## Anti-patterns
- Single `content` string; overwriting on edit; linear message array with truncation on edit.
- Generation tied to the open request so a refresh loses the answer.
- Client-generated ordering or status as source of truth.
- Title generation on the critical path.
- One DB write per streamed token; loading a whole thread to render the sidebar.
- Project files stuffed into every prompt regardless of size.

## Checklist
- [ ] TTFT, list, open, and write-rate budgets measured
- [ ] Keyset-paginated list; path-only thread open; coalesced writes
- [ ] Project ownership enforced; instruction and file layering defined
- [ ] Tree plus active leaf; parts typed and versioned
- [ ] Status machine enforced; stale streams swept
- [ ] Idempotent send; run survives disconnect
- [ ] Stop/edit/regenerate/retry tested
- [ ] Single `beforeRun` hook; userId on every row
- [ ] Deletion cascades to derived data
