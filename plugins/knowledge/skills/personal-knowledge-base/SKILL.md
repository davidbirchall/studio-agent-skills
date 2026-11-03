---
name: personal-knowledge-base
description: Structuring a durable plain-Markdown personal knowledge base that one user and AI sessions can both query - folder layout (inbox, notes by topic, decisions, references, glossary), note anatomy (title, summary line, date, source, status, links), naming conventions, atomic notes versus long documents, linking, index and map-of-content files, minimal tagging, retrieval-friendly writing (front-loaded summaries, stable headings, short files), maintenance (prune, merge, mark stale, last-verified dates), repo notes versus the knowledge base, keeping secrets out, and git versioning. Load when creating, reorganizing, searching, or maintaining a personal notes folder, or deciding where a piece of knowledge should live.
---

# Personal knowledge base

Note-writing technique (atomic notes, provenance) is in `knowledge-capture`; this skill covers the container: layout, retrieval, upkeep. Summaries of sources use `source-summarisation`; choices go to `decision-making`.

## Layout
- Plain Markdown in one git repo. No database, no app-specific syntax required.
- Start with six folders; add more only when one holds over 30 files.
```text
kb/
  README.md        # what this is, conventions, how to search
  index.md         # top-level map: one line per topic folder
  inbox/           # unprocessed captures; empty weekly
  notes/<topic>/   # atomic notes, one folder per topic
  decisions/       # dated choices with reasons
  references/      # source summaries, one per source
  glossary.md      # term -> one-line definition
```
- Max two folder levels. Use links, not deeper nesting.

## Naming
- Lowercase kebab-case, ASCII, no spaces: `retry-with-backoff.md`.
- Name by the idea, not the date. Exception: decisions `2026-03-14-adopt-pnpm.md` and inbox items.
- Names are stable. Rename only with a link fix across the repo.

## Note anatomy
- Line 1 is the title. Line 3 is a one-sentence summary that answers the question the note exists for.
- Put metadata directly under the summary, in a fixed order.
```markdown
# Retry with backoff
Use exponential backoff with jitter for idempotent calls; cap at 5 tries.

Date: 2026-03-14 | Verified: 2026-03-14 | Status: current
Source: references/aws-retry-guidance.md

## Details
...
## Links
- [Idempotency keys](idempotency-keys.md) - required before retrying writes
```
- Status values only: `draft`, `current`, `stale`, `superseded`.
- Every claim traces to a source or is marked as own experience.

## Atomic vs long
- One idea per note; target 100-400 words. Above 800 words, split.
- Long material (a guide, a course) becomes a hub note linking atomic notes, not one file.
- Do not create a note under 3 sentences unless it is a glossary entry or decision.

## Linking and indexes
- Every note has at least one outbound link and is linked from an index. No orphans.
- Use relative Markdown links, not wiki-only syntax, so any tool resolves them.
- Each topic folder gets an `index.md` (map of content): one line per note, `link - summary`. Keep under 50 entries; split by subtopic beyond that.
- Tags: at most 2 per note, from a list in `README.md`. Prefer folders and links to tags.

## Retrieval for AI
- Front-load: title, summary, status before any detail. Agents often read only the first 20 lines.
- Stable headings (`Details`, `Links`, `Source`) so grep and section reads work.
- Keep files short; a session should load one note, not a chapter.
- Use the user's own terms and list synonyms in the summary or glossary.
- Search order for a session: `index.md`, grep on titles and summaries, then open the note.
- Put the question the note answers in the summary ("How many retries?"), not only the topic.

## Repo notes vs the knowledge base
- Repo (`docs/`, ADRs): facts about this codebase that change with it and must ship with it. See `documentation`.
- Knowledge base: knowledge that outlives any one project, or spans several.
- Link across; never copy. One home per fact.

## Maintenance
- Weekly: empty the inbox (file, merge, or delete). Over 20 inbox items means the process failed.
- Quarterly: sample 10 notes; re-verify and update `Verified`, or mark `stale`.
- Merge duplicates; delete what you would not miss (git keeps history).
- Commit small and often: `kb: add retry-with-backoff`.

## Secrets and privacy
- Never store passwords, tokens, keys, or personal identifiers. Store where they live ("in the password manager, item X"). See `secret-handling`.
- Add a pre-commit secret scan if the repo is ever pushed to a remote.

## Anti-patterns
- One giant `notes.md` or per-day journals as the only structure.
- Folders by file type or by date instead of topic.
- Copying whole articles instead of summarising with a source link.
- Tag sprawl; a tag used by one note.
- Notes with no summary line or no verified date.
- Rewriting history of decisions instead of superseding them.

## Checklist
- Summary line, date, verified date, status, source present.
- Linked from an index; one outbound link minimum.
- Under 800 words; one idea.
- No secrets; name follows convention.
- Inbox empty; stale items marked.
