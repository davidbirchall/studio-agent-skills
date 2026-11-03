---
name: research-practice
description: Structured research for any topic - framing a research question, planning searches, evaluating and triangulating sources, assigning confidence levels, citing sources, and writing up findings with open gaps. Load when asked to investigate, compare options, verify a claim, or gather evidence before capturing notes or making a decision.
---

# Research

Chain: **research-practice** -> `knowledge-capture` -> `decision-making` -> `documentation` -> `review`. This skill is self-contained.

## Purpose
Turn a vague need into a bounded question, gather evidence from evaluated sources, and report findings with explicit confidence. Never present a guess as a fact.

## Inputs
- The need or topic, and what the answer will be used for.
- Constraints: time box, depth, date range, geography, allowed sources.
- Existing knowledge or assumptions to test.

## Steps
1. **Frame the question.** Write one primary question plus 2-4 sub-questions. State scope (in/out), the decision it informs, and what an acceptable answer looks like. Prefer answerable, specific questions ("What did X change between 2020 and 2023?") over topics ("X").
2. **Plan the search.** List source types (primary documents, official data, peer-reviewed work, expert commentary, news, practitioner accounts) and search terms including synonyms. Time-box each pass.
3. **Gather.** Record each source as found: title, author or publisher, date, link or location, access date.
4. **Evaluate sources.** Check authority (who and why qualified), currency, accuracy (verifiable, cited), purpose and bias (who benefits), and relevance. Prefer primary over secondary over tertiary.
5. **Triangulate.** Support each key claim with at least two independent sources. Independent means not citing each other. Note conflicts and explain them (different dates, definitions, methods) rather than averaging them away.
6. **Assign confidence.** High: multiple independent, authoritative sources agree. Medium: one strong source or several weaker agreeing ones. Low: single, indirect, dated, or biased source. Unknown: no evidence found. Say which.
7. **Synthesize.** Answer the question directly first, then support. Separate fact, inference, and opinion. Record gaps and what would close them.

## Output
```markdown
# Research: <question>
Date: <YYYY-MM-DD> | Scope: <in/out> | Informs: <decision or task>

## Answer
<2-4 sentence direct answer>

## Findings
| # | Claim | Confidence | Sources |
|---|-------|------------|---------|
| 1 | ...   | High       | [S1], [S2] |

## Conflicts and gaps
- <disagreement and likely reason; unanswered question and next step>

## Sources
- [S1] Author/Publisher, "Title", date, link (accessed <date>) - type, reliability note
```

## Quality checklist
- Question is specific and bounded; answer addresses it directly.
- Every claim traces to a cited source; no uncited facts.
- Key claims have two or more independent sources, or are flagged as single-source.
- Confidence is stated per finding; gaps are listed.
- Source dates and access dates are recorded.

## Anti-patterns
- Confirmation bias: searching only for support of a preferred answer. Search for disconfirming evidence too.
- Treating repetition across outlets as corroboration when they share one origin.
- Citing a secondary summary when the primary source is available.
- Inventing a source, quote, or number to fill a gap. Report the gap instead.
- Endless searching with no time box or stop condition.

## Handoff
- Pass findings and sources to `knowledge-capture` to store them as durable notes.
- If a choice is pending, pass the findings table to `decision-making` as evidence.
