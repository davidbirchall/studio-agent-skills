---
name: incident-response
description: Provider-neutral incident response for a solo operator - severity levels, the lifecycle from detection to resolution, a one-person runbook, a first-15-minutes checklist, mitigating before root-causing with rollback, feature flags or scaling, evidence preservation, a written timeline, blameless solo postmortems with impact, root cause, contributing factors and tracked action items, runbooks, personal on-call plan with alerts to yourself, error budgets, and tracking actions to completion. Load when handling a production incident, setting up alerting, writing a runbook or postmortem, or defining severity and escalation.
---

# Incident response

Builds on `debugging` for investigation, `software-testing-strategy` for regression coverage, and `application-security` when an incident is a breach (also follow `secret-handling` and rotate exposed credentials). Fixes go through `code-review`; write-ups follow `technical-documentation`.

## Severity
- Define levels by user impact, not by cause. Example:
  - SEV1: outage, data loss, or security breach affecting most users. Respond immediately, any hour.
  - SEV2: major feature broken or large subset degraded. Respond immediately in working hours, page out of hours.
  - SEV3: minor degradation with a workaround. Next business day.
- Declare early and downgrade later. Over-declaring costs minutes; under-declaring costs hours.
- Declare by writing the severity at the top of the incident log; no permission needed.

## Lifecycle
- Detect, triage, mitigate, resolve, review. Detection should be by alert, not by user report; count every user-found incident as a monitoring gap.
- Resolved means impact ended and is verified by metrics, not that a fix was deployed.
- Keep one incident log file per incident, named by date and short summary (for example incidents/2026-10-31-login-errors.md).

## One-person operation
- You are commander, operator and scribe. Do one thing at a time; only one change to production at a time.
- The written timeline and the checklist below replace a second pair of hands. Append a timestamped line before each action and after each observation.
- When blocked on a real decision (for example accept downtime vs risk data loss), ask the user one focused question with the options and your recommendation.
- If the user is unreachable and the action is reversible, take the safest reversible mitigation and log it.

## First 15 minutes
- Acknowledge the alert and write the severity in the log.
- Open the incident log.
- Check dashboards, error rates, and the last deploys, flags, config, and infrastructure changes.
- Record what is known, what is not, and the next check time.
- Pick the fastest safe mitigation and start it; investigation continues in parallel.
- Keep the timestamped log of actions and observations.

## Mitigate first
- Stop the bleeding before finding the cause. Order of preference: roll back the last change, disable via feature flag, shed load or scale up, fail over, block the bad traffic, then hotfix.
- Prefer reversible actions. Log each change before making it.
- Do not deploy untested fixes under pressure; a hotfix still needs a self-review (`code-review`) and a minimal diff.
- Keep the failing state's evidence before restarting everything (see below).

## Evidence
- Capture before mitigating where cheap: logs, metrics screenshots, heap or thread dumps, request samples, config and versions, and the deploy list.
- Copy to the incident log folder; logs rotate. Redact secrets and personal data.
- Keep broken instances aside for analysis when safe and cheap.
- Security incidents: preserve evidence, restrict access, rotate credentials, and check legal or privacy notification duties.

## Status page
- If users depend on the service, post status (investigating, mitigating, monitoring, resolved) with impact and facts only; no speculation. Automate this where possible.
- Record the resolution and a link to the postmortem.

## Runbooks
- One page per alert: what it means, impact, how to confirm, mitigation steps with exact commands, and a last-reviewed date.
- Every alert links to its runbook. An alert without an action should be deleted or downgraded.
- Update the runbook during each incident that used it. Test them by rehearsing a rollback or restore.

## Personal on-call plan
- Alert yourself only on user-impacting, actionable conditions (push notification, SMS or phone alert); everything else is a ticket or a daily digest. Review noisy alerts regularly.
- Write down what you will respond to and when (for example SEV1 any hour, SEV2 working hours), and what you will not.
- Automate rollback, keep a one-command deploy and restore, and keep the runbook where you can reach it from a phone.
- If you work with others: add a named backup and an escalation path.
- Track alerts per week as a health metric.

## Error budgets
- Set an availability target per service (for example 99.9 percent over 30 days); the budget is the allowed failure.
- When the budget is spent, prioritise reliability work over features until it recovers.
- Budget burn, not raw error counts, drives alert urgency.

## Postmortem
- Blameless: ask how the system allowed the error. Write it within a few days of SEV1 and SEV2, while the log is fresh, as a file in the repo so future sessions can read it.
- Template:
  - Summary: two sentences.
  - Impact: users, duration, data, money.
  - Timeline: copy from the incident log; timestamps in one timezone for detection, declaration, key actions, mitigation, resolution.
  - Root cause: the technical mechanism, found by repeated "why".
  - Contributing factors: missing alerts, unclear docs, risky deploy process.
  - What went well, what went badly, where you got lucky.
  - Action items: each with a due date and a tracked issue or TODO; prefer prevention and detection (alerts, tests, automation) over "be more careful".
- Run the checklist below against the finished document; no meeting needed.

## Learning and follow-up
- Periodically scan past incident files for patterns across causes, detection gaps, and time to mitigate.
- Track action items in the issue tracker or a TODO file; list overdue ones at the start of each work session. An incident is not closed until its high-priority actions are done or consciously rejected (log the reason).
- Add a regression test or alert for every root cause.

## Anti-patterns
- Debugging for an hour before rolling back.
- Postmortems naming individuals, or with no tracked actions.
- Alerts nobody acts on.

## Checklist
- Severity written, incident log open.
- Recent changes checked; mitigation chosen and logged.
- Evidence captured; timeline kept.
- Resolution verified by metrics.
- Postmortem written; actions dated and tracked.
