---
name: release
description: Preparing and executing a release or launch - go/no-go criteria, release checklist, staged rollout, rollback plan, release notes, personal launch-window plan, and post-release monitoring. Load when shipping, launching, publishing, or delivering a deliverable, when deciding whether something is ready, or when asked for a release plan, launch checklist, or rollback plan.
---

# Release

Follows `milestones`; feeds `retrospective`.

## Purpose
Move finished work to its audience safely and predictably, with a prior decision on what "ready" means and how to undo the release if it goes wrong.

## Inputs
- Final milestone, scope freeze, and exit criteria from `milestones`.
- Definition of done and acceptance criteria from `scope`.
- Audience, channels, and any fixed launch date.
- Known issues and open risks.

## Steps
1. Set go/no-go criteria in advance, before pressure builds: required checks passed, no open blocking defects, rollback ready. The agent evaluates the checks and reports met/not met; the user makes the go call.
2. Triage known issues: ship, fix first, or ship with a documented workaround. Record the decision for each.
3. Build a release checklist covering build or master verified, final acceptance, documentation and notes, assets and access, and secrets scan. Tick it in the file; do not rely on memory.
4. Write a rollback plan: the trigger (what observable failure causes a rollback), the steps, and how long it takes. Where undoing is impossible (print runs, announced dates, migrations), define a mitigation plan instead and raise the bar of the go/no-go.
5. Prefer staged exposure where possible: yourself first, then a small audience, then everyone, with a check between stages.
6. Produce release notes or a changelog entry, including known issues and the failure-case steps (how to roll back, where the previous build is).
7. Plan the launch window for one person: release when you are available to watch it, with alerts routed to you and a runbook for the rollback steps.
8. Monitor after release against defined signals for an agreed period, then close the release in the log.

## Output
```
# Release: <name>   <version/date>
Go/no-go criteria (met?):
Known issues and decisions:
Checklist: [ ] item
Rollout stages and gates:
Rollback or mitigation: trigger | steps | time
Release notes / changelog entry:
Launch-window plan: when you are available | alerts to you | runbook link
Post-release signals and watch period:
Decision: GO / NO-GO   (user)   <time>
```

## Worked example (Lanternfall demo and chat app)
```
Go/no-go: [ ] no crash in 3 full playthroughs  [ ] 60 fps on target device  [ ] zero blocker bugs  [ ] release notes written  [ ] previous build kept
Known issues: shadow flicker on room 4 -> ship with workaround.
Rollout: own device -> 5 testers -> public itch.io page. Gate: no crash reports for 24 h between stages.
Rollback: trigger = crash rate above 2 percent of sessions; steps = unpublish new build, restore previous; 15 min.
```
Chat-app feature: ship behind a flag at 5 percent, then 25, then 100. Rollback trigger: delivery success below 99 percent or p95 latency over 2 s for 10 minutes; action: flag off, no deploy needed.

## Decision rules
- Staged exposure: 1-5 percent, then 25, then 100, with at least one full usage cycle (often 24 h) per gate for software; for games, a small build group before the public.
- Any blocker defect or unrehearsed rollback is automatically no-go. A single exception needs a logged reason.
- Do not release in the last day before leave or on Fridays unless rollback is a one-step toggle.
- Irreversible releases (store submission queues, announced dates, data migrations): require a rehearsal and an AI fresh-eyes pass over the checklist.
- Watch period: at least 24-72 hours with named signals (crash rate, error rate, latency, support volume), with alerts delivered to you.
- Write the checklist even though you are the only releaser; the person releasing is the person most likely to forget a step.

## Quality checklist
- Criteria were written before the go/no-go decision.
- Rollback or mitigation was written and rehearsed where feasible.
- Release notes cover known issues and the failure path.
- Post-release watch period and exit are defined.

## Anti-patterns
- Launching because the date is fixed, not because criteria are met.
- No rollback thinking until something breaks.
- Late-night, last-day-before-leave releases.
- Unticked checklist items at go time.
- Declaring done at launch with no monitoring.
- Shipping keys, tokens, or debug settings in the build; check against `secret-handling` before upload.
- Skipping verification on the real target device or a production-like environment; apply `test-discipline` to the release checks.

## Ready for retrospective
- [ ] The release is formally closed after the watch period.
- [ ] Incidents and workarounds are logged.
- [ ] Signals versus targets are recorded.
- [ ] The go/no-go record and checklist are saved.

## Handoff
Send outcomes, incidents, and decision records to `retrospective`.

## See also

Optional, if installed: release-management (the platform-engineering plugin) for the broader discipline this skill applies. This skill stands on its own.
