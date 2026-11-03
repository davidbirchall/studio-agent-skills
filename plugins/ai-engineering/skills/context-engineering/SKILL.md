---
name: context-engineering
description: Context engineering for chat and agent systems - context window budgeting, deciding what to include, ordering and placement, conversation history trimming, summarisation and compaction, memory tiers (working, session, long-term), tool result truncation, prompt caching friendly layout, avoiding context rot and distraction, per-request context assembly in TypeScript, and measuring context quality. Load when a conversation grows long, an agent loses track or degrades, token cost or latency is high, or when designing how history, memory, tools and retrieved data are assembled into a prompt.
---

# Context engineering

Builds on `prompt-engineering` for prompt wording, `llm-integration` for token budgets, and `retrieval-augmented-generation` for fetched knowledge. Context limits and caching behaviour are provider and model dependent; verify against the provider docs.

## Principles
- Context is a scarce budget, not storage. Include the smallest set of tokens that makes the next step correct.
- More context is not better: irrelevant, stale or contradictory content degrades accuracy even within the limit (context rot). Measure, do not assume.
- Assemble context per request from sources in one function, not scattered string building.

## Budgeting
- Allocate a token budget per section and enforce it before calling the model.
```ts
const budget = { system: 1500, tools: 2000, memory: 1000, retrieved: 4000, history: 6000, reserveOutput: 1500 }
```
- Total = model window minus reserved output. Take window size from verified model config, never a guess.
- Count tokens with the provider tokenizer or a conservative estimate; leave a safety margin.
- When over budget, cut in a fixed priority order: oldest history, low-ranked retrieval, verbose tool output, then memory. Never cut the system prompt or the current user message.

## What to include
- Include: task, constraints, current user turn, recent turns, relevant facts, tool schemas needed for this step, state of the plan.
- Exclude: resolved tangents, duplicate content, raw logs, full documents when an excerpt works, tools unrelated to the step.
- Load tools per task or agent role rather than all tools always (`tool-integration`, `agent-design`).

## Ordering
- Stable content first (system prompt, tool definitions, fixed instructions), variable content after. This also maximises prompt cache hits.
- Put the current question and key constraints near the end; models attend unevenly to the middle of long contexts.
- Place retrieved documents before the question, labelled with ids and sources. Keep section delimiters consistent.

## History management
- Keep the last N turns verbatim, plus a rolling summary of older turns. Trim by tokens, not message count.
- Never split a tool call from its result; drop or keep the pair together. Keep system and pinned messages.
- Summarise with a dedicated prompt that preserves decisions, entities, open questions, user preferences and unresolved errors. Version and test it (`ai-evaluation`).
- Compact when a threshold (for example 70 percent of budget) is hit, before failure. Store the original transcript separately; the summary is lossy.
- Re-summarising a summary drifts; summarise from source turns where possible and keep key facts in structured state.

## Memory tiers
- Working: current turn and scratch state, discarded after the step.
- Session: summary, plan, task state for this conversation, persisted in the database.
- Long-term: durable user or project facts, stored as discrete entries with source, timestamp and owner; retrieved by relevance, not dumped in full.
- Write memory deliberately (explicit rule or reviewed extraction), allow deletion, scope by user and tenant (`ai-security`). Do not store secrets or unneeded PII (`secret-handling`).

## Tool results
- Truncate and shape tool output before it enters context: select fields, cap rows and characters, and say when truncated with how to fetch more.
- Store large results outside context (file, object store) and pass a handle plus a summary; give the agent a tool to read slices.
- Strip markup, boilerplate and repeated headers. Never inject untrusted tool output as instructions (`ai-security`).

## Prompt caching
- Keep the prefix byte-stable: no timestamps, ids or reordered tools in the cached portion. Put dynamic values after it.
- Verify whether and how the provider caches, minimum prefix sizes and expiry in its docs; record cached token counts (`ai-observability`).

## Agents and long runs
- Give sub-agents only the context they need and have them return concise results (`agent-orchestration`).
- Keep an explicit plan or notes file updated; restate goals after compaction so objectives survive.

## Verification
- Log per-section token counts for each request. Alert on budget overruns and truncation frequency.
- Test long-conversation cases: facts planted early are recalled after compaction; trimmed history never breaks tool pairs (`ai-testing`).
