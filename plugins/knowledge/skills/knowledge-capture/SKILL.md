---
name: knowledge-capture
description: Capturing and organizing knowledge as durable, atomic, linked notes - fleeting vs literature vs permanent notes (Zettelkasten), one idea per note, source attribution, linking, tagging, and periodic review. Load when turning research, reading, or experience into reusable notes, or when a note collection is hard to search or has gone stale.
---

# Knowledge capture

Chain: `research-practice` -> **knowledge-capture** -> `decision-making` -> `documentation` -> `review`.

## Purpose
Convert raw findings and experiences into notes you can find, trust, and reuse months later without the original context.

## Inputs
- Raw material: research output, session notes, readings, observations.
- The existing note collection (naming, tags, folders) if any.
- Who will reuse the notes (the user, future AI sessions) and for what.

## Steps
1. **Capture fast (fleeting notes).** Jot ideas in any form; they are temporary. Process them within a day or two or discard.
2. **Write literature notes.** For each source, summarize in your own words, keep the citation (author, title, date, link), and mark direct quotes with page or location. Paraphrasing forces understanding.
3. **Make permanent notes (Zettelkasten).** One idea per note (atomic), written as a complete statement that makes sense standing alone. Title it as the claim, not the topic ("Pre-mortems surface risks earlier than post-mortems", not "Pre-mortems").
4. **Link.** Add at least one link to a related note and say why they relate. Links carry more value than folders. Create a hub or index note for each major theme.
5. **Tag sparingly.** Use a small controlled vocabulary for status (draft, verified, stale) and domain. Avoid tags that duplicate titles.
6. **Record provenance and confidence.** Each note names its source(s), date captured, and confidence (high, medium, low) as in `research-practice`.
7. **Re-check on a trigger.** Monthly, or when a related note changes: merge duplicates, split notes holding two ideas, mark stale items, fix broken links (a link-check script can do the last).

## Output
```markdown
# <Claim-style title>
Type: permanent | literature | fleeting
Captured: <YYYY-MM-DD> | Confidence: <high|medium|low> | Status: <draft|verified|stale>
Tags: <domain>, <status>

<One idea in 3-8 sentences, in your own words.>

## Why it matters
<Where it applies or what it changes.>

## Links
- Related: [[Other note]] - <why related>

## Source
<Author, title, date, link, location>
```

## Quality checklist
- One idea per note; title states the idea.
- Understandable without the original source open.
- Source and date present; quotes marked as quotes.
- At least one meaningful link; reachable from a hub.
- Status and confidence set; no orphan notes.

## Anti-patterns
- Copy-pasting passages without rewriting (collecting, not understanding).
- Topic-titled dumping-ground notes holding many ideas.
- Deep folder hierarchies instead of links.
- Tag sprawl with near-duplicate tags.
- Never reviewing, so stale claims keep appearing as current.

## Handoff
- Supply the relevant permanent notes and their confidence to `decision-making` when a choice is needed.
- Supply hub notes and source lists to `documentation` when writing durable documents.
