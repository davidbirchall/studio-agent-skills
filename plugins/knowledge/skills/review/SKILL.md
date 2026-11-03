---
name: review
description: Reviewing any written work, research, plan, code, or decision with a checklist and producing actionable findings - agreeing scope and criteria, separating blocking from non-blocking issues, tying findings to evidence, and re-checking fixes. Works as self-review or an AI fresh-eyes pass after a cooling-off gap. Load when asked to review, critique, proofread, fact-check, or check a document, finding, or decision record.
---

# Review

Chain: `research-practice` -> `knowledge-capture` -> `decision-making` -> `documentation` -> **review**.

## Purpose
Improve the work and the confidence in it, by finding real problems and recording them so they can be fixed and re-checked.

## Inputs
- The artifact under review and its purpose and future readers (the user, future AI sessions).
- Review type: fact-check, logic, clarity, completeness, or all.
- Criteria: a checklist, standard, or the original brief.
- Independence: review work after a gap or in a fresh context, not in the same pass that produced it.

## Steps
1. **Agree scope and criteria.** Confirm purpose, readers, and depth. Review against the stated goal, not personal preference.
2. **Read once for the whole.** Does it achieve its purpose for its readers? Note overall impressions before details.
3. **Check with the checklist.** Accuracy (claims match sources; numbers recomputed), logic (conclusions follow from evidence), completeness (gaps, missing options, unstated assumptions), clarity (structure, terms, length), and consistency (names, dates, formatting).
4. **Verify sources.** Spot-check citations against the originals; flag uncited claims and single-source claims presented as certain.
5. **Classify each finding.** Blocking (must fix: wrong, misleading, missing essential), important (should fix), minor or nit (optional). Note what works so it is kept.
6. **Write actionable findings.** Each names the location, the issue, why it matters, and a suggested fix or question. Critique the work, not the author. If a finding needs a user decision, ask one focused question.
7. **Close the loop.** Give an overall verdict, confirm which items are blocking, apply fixes, and re-check them.

## Output
```markdown
# Review: <artifact>
Reviewer: self-review or AI pass | Date: <YYYY-MM-DD> | Verdict: approve | approve with changes | revise

## Summary
<Overall assessment against purpose, 2-4 sentences.>

## Strengths
- <What to keep>

## Findings
| # | Location | Severity | Issue and why it matters | Suggested fix |
|---|----------|----------|--------------------------|---------------|
| 1 | Sec. 2   | Blocking | Claim X has no source    | Cite or remove |

## Open questions
- <Questions to resolve with the user or by further checking>
```

## Quality checklist
- Reviewed against stated purpose and criteria.
- Every finding has location, severity, reason, and a suggested fix or question.
- Blocking items are clearly separated from nits.
- At least one strength noted when warranted.
- Facts and sources were actually checked, not assumed.

## Anti-patterns
- Vague comments ("unclear", "needs work") with no direction.
- Rewriting to personal style instead of reviewing against criteria.
- Burying one blocking issue among many nits.
- Reviewing in the same pass that produced the work, so the same blind spots remain.
- Approving without verifying sources or numbers.

## Handoff
- Apply fixes to the artifact; send factual gaps back to `research-practice`.
- Capture recurring lessons as notes via `knowledge-capture`.
- If a review challenges a choice, reopen it in `decision-making` and supersede the record.

## See also

Optional, if installed: code-review (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
