---
name: ux-design
description: UX design process - turn research into user flows, information architecture, story maps, wireframes, and usability-tested prototypes, guided by Nielsen's usability heuristics and inclusive design. Load when research findings need to become concrete experience designs, when mapping end-to-end user journeys or flows, or when reviewing a design for usability.
---

# UX design

## Purpose
Translate validated user needs into an experience that people can understand and complete tasks with, before committing to detailed requirements.

## Inputs
- Research insights, journeys, and priority pain points (from `user-research`).
- Chosen opportunity and outcome (from `discovery`).
- Constraints: platforms, brand, accessibility targets, existing design system.

## Steps
1. Define primary tasks as user goals ("pay an invoice"), with the entry point and success state of each.
2. Build a user story map (Jeff Patton): backbone of user activities left to right, detailed steps beneath, then slice horizontally into a thin end-to-end release and later slices.
3. Draft the information architecture: content groups, navigation, labels in the users' own words. Validate with card sorting or tree testing when labels are uncertain.
4. Sketch flows including error, empty, loading, and permission states, not only the happy path.
5. Produce low-fidelity wireframes first; raise fidelity only after the structure works.
6. Test with 5 representative users on realistic tasks (think-aloud). Record task success, time, errors, and confusion points; fix the top issues and retest.
7. Review against Nielsen's 10 heuristics (visibility of system status, match with real world, user control, consistency, error prevention, recognition over recall, flexibility, minimalist design, error recovery, help) and accessibility basics (WCAG: contrast, keyboard use, labels, text alternatives).

## Output
```
# UX design brief: <area>
Primary tasks and success states:
Story map: Activities > Steps > Release slices
Flows: <name: entry -> steps -> exit, with error/empty states>
IA / navigation and labels:
Wireframes/prototype link:
Usability findings: <issue | severity | fix | status>
Accessibility notes:
Design decisions and rationale:
Open questions:
```

## Sizing the effort
- Small tweak: a quick flow sketch and a heuristic review by two people.
- Medium feature: flows, low-fidelity wireframes, and one round of 5 test sessions.
- Big bet: IA validation, a clickable prototype, and two or more test rounds.

## Flows before screens
Draw the flow first: entry point, decisions, system responses, exit. Example: Send reminder: invoice list > select overdue invoice > preview message > send > confirmation. Branches: no email on file (prompt to add), send fails (retry, keep draft), already reminded today (warn).

## Fidelity ladder
Paper or whiteboard sketch (structure) > low-fidelity wireframe (layout, labels) > clickable prototype (interaction) > high fidelity (visual detail). Move up only when the lower rung passes testing.

## Required states
For every screen list: empty (first use, with guidance), loading, partial, error (what happened and how to recover), success, and no permission.

## Accessibility early
Check from the first wireframe: logical heading and focus order, full keyboard use, contrast of at least 4.5:1 for body text, visible focus, labelled inputs, text alternatives, no colour-only meaning, and touch targets large enough.

## Usability test plan
Goal and tasks (realistic scenarios, no hints), 5 participants per round from the target segment, think-aloud, measures (task success, time, errors, confidence). Severity: blocker, major, minor. Fix blockers and majors, then retest.

## Design review checklist
- [ ] Flow matches a research-backed task.
- [ ] Heuristics reviewed and issues triaged.
- [ ] All states designed.
- [ ] Accessibility checks pass.
- [ ] Rationale for key decisions is written.

## Quality checklist
- Every flow maps to a research-backed user task.
- Non-happy-path states are designed.
- Labels use user vocabulary.
- Usability tested with real target users.
- Accessibility considered from the start.

## Anti-patterns
- Designing screens before understanding tasks.
- Polishing high-fidelity visuals before testing structure.
- Testing with colleagues instead of users.
- Hiding decisions in design files with no written rationale.
- Treating accessibility as a late audit instead of a design input.

## Ready for product-definition
- [ ] Story map has a thin end-to-end first slice.
- [ ] Prototype passed testing with no open blockers.
- [ ] Open design questions are logged with owners.

## Handoff
Give the story map, flows, and tested prototype to `product-definition` to become scoped, prioritised requirements.
