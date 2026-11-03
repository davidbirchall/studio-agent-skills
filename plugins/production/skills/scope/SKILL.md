---
name: scope
description: Defining and defending project scope - in-scope and out-of-scope lists, deliverables, acceptance criteria, definition of done, assumptions, scope creep control, and change requests. Load when fixing what a project will and will not deliver, when requests keep expanding, or when asked to write a scope statement, set boundaries, or assess a change request.
---

# Scope

Follows `planning`; feeds `prioritisation`.

## Purpose
Draw an explicit boundary around the work so "done" is unambiguous and changes are deliberate, not accidental.

## Inputs
- Goal, success criteria, constraints, and WBS from `planning`.
- Requests and wishes from the user, raw and unfiltered.
- Fixed deadline, budget, or your available focused hours.

## Steps
1. Collect candidate features, deliverables, and requests into one list.
2. Trace each item to the goal. If it does not serve a success criterion, mark it out of scope or deferred.
3. Write an explicit out-of-scope list. Naming what is excluded prevents the most arguments.
4. Give each deliverable acceptance criteria: observable, testable statements (Given/When/Then works well).
5. Write a definition of done: the checks every deliverable passes (tested, self-reviewed against a checklist, documented), distinct from per-item acceptance criteria.
6. Use the project management triangle: when scope, time, and resources are all fixed, quality absorbs the pressure. Decide which one flexes and state it.
7. Set a change-control rule: any addition names what it displaces or what extra time or cost it adds, and the user decides whether to accept it; log the decision.
8. Record assumptions and dependencies that scope relies on.

## Output
```
# Scope: <name>   v<n>
In scope (deliverable | acceptance criteria):
Out of scope (explicit):
Deferred / later:
Definition of done:
Flexible dimension (scope | time | resources):
Assumptions and dependencies:
Change control: who approves, what must be traded
Change log: <date> | <change> | <impact> | <decision>
```

## Worked example (Lanternfall and a chat app)
```
Item: Lantern oil refill
In scope: refill at oil stations in District 1.
  Given the player holds an empty lantern, when they interact with a station for 2 s,
  then oil returns to 100 percent and the station is disabled for 30 s.
Out of scope: crafting oil, oil upgrades, controller rumble on refill.
Deferred: second district stations (after the vertical slice review).
Definition of done: playable on target device, no new console errors, tuning values in data file, reviewed, build uploaded.
```
Chat-app feature "typing indicators": in scope is 1:1 chats on web; out of scope is group chats, mobile push, and read receipts; acceptance is "the indicator shows within 500 ms and clears 3 s after the last keystroke".

## Appetite and change rules
- Set appetite first (for example, 2 weeks for one person), then shape scope to fit it. Do not estimate an open-ended wish and then negotiate the date.
- Fixed date and fixed capacity: scope is the flexible dimension. Say so in writing.
- A change request must state: what it adds, what it displaces or the extra days. No displacement named means it waits.
- A change worth more than about 10 percent of remaining effort is a re-plan trigger, not a quiet addition.
- Keep the deferred list; "later" items with no home are how scope creeps back.

## Quality checklist
- Out-of-scope list exists in the scope file.
- Each deliverable has testable acceptance criteria.
- Definition of done is short enough to apply every time.
- Changes are logged and decided by the user.
- Every item traces to a success criterion.

## Anti-patterns
- Scope creep: small additions accepted one by one with no impact check.
- Vague criteria such as "feels good" or "works well" with no test.
- Treating "nice to have" as in scope by omission.
- Fixing scope, date, and budget while expecting quality to hold.
- Verbal agreements not recorded in the change log.
- A single definition of done that is so long nobody applies it.
- "Phase 2" lists that grow forever with no review date.
- Scoping by feature name ("add inventory") instead of by observable behaviour.

## Ready for prioritisation
- [ ] Every in-scope item traces to a success criterion.
- [ ] Out-of-scope and deferred lists exist in the scope file.
- [ ] Each item has testable acceptance criteria.
- [ ] The flexible dimension is named and changes go in the change log.
- [ ] Definition of done fits on five lines or fewer.

## Handoff
Send the agreed in-scope items to `prioritisation` for ordering. Acceptance criteria inform `estimation` and the go/no-go criteria in `release`.
