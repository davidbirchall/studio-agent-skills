---
name: conversation-memory
description: Store and assemble branch-aware chat history, summaries, pinned instructions, and explicit editable user memories with token budgets, invalidation, deletion, and consent. Load when chats must remember, summarise, personalise, or recover context over time.
---

# Conversation Memory

Builds on `context-engineering` (budgets, ordering) and `chat-application-architecture` (message tree). Retrieval over documents is `retrieval-augmented-generation`; privacy controls overlap `ai-security`.

## Scope: core now vs add later
- Core now: window assembly from the active branch, token budgeting, truncation, rolling summary with branch-aware invalidation, pinned instructions.
- Add later: long-term user memory, memory UI, memory retrieval, consent and conflict handling, memory evaluation.
- Messages stay canonical; summaries and memories are derived and rebuildable.

## Context assembly (now)
- Build per request from stored state, never from client-sent history. Walk the active branch from leaf to root.
- Order: pinned instructions, long-term memories, summary of older turns, recent turns verbatim, retrieved documents, current user message. Keep the stable prefix first for caching (`ai-cost-latency-control`).
- Budget in tokens, not messages. Reserve output tokens first, then fixed parts, then fill history newest-first.
- Count with the provider tokenizer or a conservative estimate plus margin. Verify against current provider docs.
- Keep tool call and tool result pairs together; drop or keep both. An orphaned result is a provider error.

```ts
const budget = model.contextWindow - maxOutput - safetyMargin;
const fixed = tokens(system) + tokens(memories);
let room = budget - fixed - tokens(userMsg);
const recent = takeNewestWhile(branch, m => (room -= tokens(m)) >= 0);
const older = branch.slice(0, branch.length - recent.length);
const summary = older.length ? await getOrBuildSummary(convId, older) : null;
```

## Truncation vs summarisation (now)
- Truncate first: cheap, deterministic, no drift. Drop oldest whole turns, large tool results first (replace with a stub).
- Summarise when old content matters. Use rolling summaries: summary = f(previous summary, newly evicted turns). Trigger at a threshold (for example 70 percent of budget), not every turn.
- Summaries state facts, decisions, open tasks, user preferences. Do not paraphrase code or numbers; keep identifiers verbatim.
- Run summarisation with a small model, asynchronously, with its own cost record.

## Summary storage and invalidation (now)
- Store: conversationId, leafMessageId covered, coveredMessageIds hash, model, promptVersion, tokens.
- Key by branch path. Editing or regenerating a message at or before the covered range invalidates summaries that include it; rebuild lazily.
- Never reuse a summary across branches that diverge inside its covered range.

## Long-term user memory (add later)
- Do not build until summaries work and users ask for persistence across chats. Reserve a slot in assembly so it slots in without reordering.
- Save only on explicit user intent or visible confirmation ("Remember that ..."). Show a notice when saved.
- Store as short atomic statements with id, tenantId, userId, source message id, createdAt, updatedAt. No raw transcripts.
- Users can list, edit, delete, and disable memory. Deletion is hard delete and removes embeddings.
- Scope every query by user (and tenant once orgs exist). Never share across users or tenants.
- Inject a bounded number of memories (top-k by relevance, token cap). Label them as user-provided context, not instructions.
- Memory is personal facts and preferences; RAG is shared or large document knowledge with citations. Do not put documents in memory.
- Conflicts: newer explicit statement supersedes older; mark old one superseded, keep audit. Ask when ambiguous.

## Never store (enforce once any memory exists)
- Secrets, credentials, API keys (`secret-handling`), payment data, government ids, health or other sensitive categories unless a reviewed requirement exists.
- Inferred sensitive traits. Content from untrusted tool output or retrieved documents (injection persistence risk).
- Anything from a conversation the user marked temporary or deleted.

## Privacy
- Document what is stored, why, and retention. Provide export and delete. Honour tenant policy that disables memory.
- Redact PII from summaries where not needed. Do not log memory contents in traces by default (`ai-observability`).

## Evaluating
- Now: fact recall after eviction, summary invalidated after edit, tool pairs intact (`ai-evaluation`, `test-discipline`).
- Later: preference applied, stale fact superseded, deleted memory absent, cross-user leak absent.
- Track summary faithfulness, memory precision (saved facts that were correct), and tokens per turn.

## Anti-patterns
- Sending full history until the provider errors; client-supplied history.
- Auto-saving every user statement; invisible memory.
- Summary of a summary of a summary with no source of truth; messages remain canonical.
- Memory injected as system instructions.

## Checklist
- [ ] Token budget with reserved output
- [ ] Tool pairs kept intact
- [ ] Summaries keyed by branch and invalidated on edit
- [ ] Later: memory explicit, visible, editable, deletable, scoped
- [ ] Later: never-store list enforced in code
