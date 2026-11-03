---
name: documentation
description: Writing accurate, durable documentation that the user and future AI sessions can rely on, using the Diataxis framework - tutorials, how-to guides, reference, and explanation - plus structure, plain language, verifiability, and maintenance. Load when creating or restructuring guides, READMEs, procedures, runbooks, or reports, or when existing documents mix purposes and are hard to use.
---

# Documentation

Chain: `research-practice` -> `knowledge-capture` -> `decision-making` -> **documentation** -> `review`.

## Purpose
Produce documents that a specific reader (the user, or a future AI session with no memory of this one) can use to do or understand something, each with one clear purpose.

## Inputs
- Source material: notes, findings, decision records, the code or system itself.
- Reader: prior knowledge, and the situation in which they will use the document.
- Goal: what the reader should be able to do or understand afterwards.

## Steps
1. **Identify the reader and goal.** Write: "After reading, <reader> can <outcome>."
2. **Choose the Diataxis type.** One document, one type:
   - Tutorial: learning-oriented; a guided lesson that gets a beginner a working result.
   - How-to guide: task-oriented; steps to achieve a specific goal for someone who knows the basics.
   - Reference: information-oriented; accurate, complete, neutral facts, structured for lookup.
   - Explanation: understanding-oriented; background, reasons, and trade-offs.
3. **Outline first.** Lead with the most important information. Use headings that tell the reader what they will find.
4. **Write plainly.** Short sentences, active voice, concrete words, consistent terms. Define jargon on first use. Numbered lists for sequences, tables for comparisons.
5. **Attribute and date.** Cite sources and decisions; show a last-verified date.
6. **Link, do not duplicate.** Point to the single source of truth for shared content.
7. **Verify.** Run the commands, follow the steps, and check paths and names against the real system; record what was verified.
8. **Maintain.** Set a re-verify trigger (a version change, a milestone); remove or archive outdated documents.

## Output
```markdown
# <Title stating the purpose>
Type: tutorial | how-to | reference | explanation
Reader: <who> | Verified: <YYYY-MM-DD> | Re-verify when: <trigger>

## Summary
<What this covers and what the reader will achieve, 1-3 sentences.>

## Prerequisites
<What the reader needs first.>

## Body
<Type-appropriate structure: numbered steps / lookup tables / narrative sections.>

## Related
- <Link and why>

## Sources
- <Citations, decision records>
```

## Quality checklist
- Single Diataxis type; no tutorial mixed with reference.
- Reader and outcome are stated and met.
- Steps are in order, complete, and were actually run or followed.
- Terms are consistent; jargon defined.
- Verified date, re-verify trigger, and sources are present; links work.

## Anti-patterns
- Explaining background inside a how-to, burying the steps.
- Writing for yourself, with unstated assumptions.
- Wall-of-text pages with no headings.
- Copy-pasted duplicates that drift apart.
- Documents with no re-verify trigger that silently go stale.

## Handoff
- Send the draft to `review` for a checklist pass.
- Return gaps discovered while writing to `research-practice` or `knowledge-capture`.

## See also

Optional, if installed: technical-documentation (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
