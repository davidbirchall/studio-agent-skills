---
name: source-summarisation
description: Summarising documents, articles, transcripts, code, and discussion threads into reusable notes - purpose-first framing, a fixed structure of claims, evidence, numbers, caveats and open questions, keeping faithful and interpretive layers separate, exact quotes with citations (source, location, date), compression ratios, chunking and merging long sources, contradiction flags, no invented details, a verification pass against the source, output templates (brief, detailed, comparison table), and staleness dating. Load when asked to summarise, digest, extract, or compare sources, or when turning raw material into a note that later work will rely on.
---

# Source summarisation

A summary is a lossy copy that later work will trust. Make the loss deliberate and visible. Filing goes through `personal-knowledge-base` and `knowledge-capture`; source quality through `research-practice`.

## 1. Purpose first
- Before reading, write one line: what decision or task will this feed? "Choose a queue library", not "summarise this".
- The purpose sets what is kept. Without one, default to the author's main claims.
- If the user gave no purpose and the choice changes the output, state your assumed purpose at the top.

## 2. Structure
Extract into fixed slots, in this order:
- Claims: what the source asserts, one per line.
- Evidence: what supports each claim (data, example, authority, none).
- Numbers: figures with units, scope, and date.
- Caveats: limits, conditions, author bias, sample size.
- Open questions: what the source does not answer.
- Omit slots that are empty; never pad.

## 3. Two layers
- Faithful layer: what the source says, no opinion. Label `Source says`.
- Interpretive layer: your reading, relevance, doubts. Label `Assessment`.
- Never mix. A reader must tell the author's claim from yours at a glance.

## 4. Quotes and citations
- Quote only when wording matters (definitions, requirements, numbers, contentious claims). Reproduce exactly, in quotation marks; mark any edit with `[...]`.
- Keep quotes under 3 sentences; paraphrase the rest.
- Cite every claim: source title, author or owner, location (page, section, timestamp `12:40`, file and line `src/queue.ts:88`, comment number), publication date, access date.
- Paraphrase must preserve strength: "may" stays "may", "all" stays "all".

## 5. Compression
- Target: brief 5-10 percent of source length, detailed 15-25 percent. Cap a brief at 150 words regardless of size.
- Code: summarise behaviour, inputs, outputs, side effects, and invariants; not line-by-line narration.
- Transcripts: drop filler; keep decisions, owners, dates, and disagreements with speaker names.
- Threads: capture the question, proposals, the outcome, and dissent, in order of resolution.

## 6. Long sources
- Over about 3,000 words or 10 pages: split by the source's own sections, not by size.
- Summarise each chunk with the same template, then merge: dedupe claims, keep section pointers, resolve or flag conflicts.
- Merge from chunk summaries only after each is verified; errors compound otherwise.
- State what was not read ("appendices skipped").

## 7. Contradictions
- If two parts or sources disagree, list both with locations. Do not average or pick silently.
- Mark: `CONFLICT: A (p.4) says 30 days; B (p.9) says 14 days.` Note any resolving evidence.

## 8. No invention
- Do not fill gaps with plausible details: names, dates, numbers, causes.
- Missing info is written as `not stated`.
- Distinguish "source does not say" from "source says no".

## 9. Verify
- After drafting, re-check against the source: each number, name, date, and quote is matched character for character.
- Spot-check 3 random claims for strength and context.
- Fix, or mark `unverified`. Record `Verified: <date>`.

## Templates
```markdown
# <Source title> - brief
Purpose: <task> | Source: <author, link/path> | Published: <date> | Read: <date>
Source says:
- <claim> (<location>)
Numbers: <value unit, scope> (<location>)
Caveats: <...>
Assessment: <relevance, confidence>
Open: <...>
```
```markdown
| Source (date) | Claim | Evidence | Numbers | Caveat |
|---|---|---|---|---|
| A (2025-06) | ... | benchmark | 120 ms p95 | single machine |
```
- Detailed template: the brief plus a section per source chunk, each with claims, evidence, and quotes.

## Staleness
- Record the publication date and a review-by hint ("re-check after next major release"). Fast-moving topics: 6-12 months.
- Undated sources get `Published: unknown`, and lower confidence.

## Anti-patterns
- Summarising without a purpose; abstract-copying.
- Blending opinion into the source's claims.
- Dropping numbers, units, or caveats.
- Quotes without location; paraphrases stronger than the source.
- Merging chunk summaries unchecked.

## Checklist
- Purpose stated; slots filled; layers separate.
- Every claim cited with location and date.
- Quotes exact; conflicts flagged; gaps marked `not stated`.
- Verification pass done and dated.
