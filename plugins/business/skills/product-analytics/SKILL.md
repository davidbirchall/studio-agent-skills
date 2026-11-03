---
name: product-analytics
description: Product analytics for a solo maker of software and games - events as a typed schema with naming conventions, what to measure first (activation, retention, core-action rate; for games session length, level funnel, D1 and D7 retention), identity and anonymous ids, privacy-preserving defaults, event pipeline from client to your own endpoint or a provider, sampling and cost, dashboards that answer questions instead of vanity counts, A/B experiment basics with sample-size reality for tiny audiences, analysis with SQL, data quality tests, and tying metrics to decisions logged in a decision file. Load when adding analytics, defining events or metrics, building a dashboard, running an experiment, or deciding what to build next from usage data.
---

# Product analytics

Privacy rules live in `privacy-and-data-retention`; consent for non-essential analytics may be required (verify for your jurisdiction). Conversion and price tests tie to `pricing-and-monetisation`; purchase events must match `payments-and-billing`. Not legal advice; flag consent and children's-data questions to a qualified professional. Verify any provider's current terms, retention, and pricing.

## Start from questions
- Write 3-5 questions the next decision depends on, before instrumenting. Example: "Do new users reach first success within 10 minutes?" An event with no question behind it is not added.
- Each metric has an owner action: "if below X, I will do Y".

## First metrics
| Area | Measure |
|------|---------|
| Activation | share of new users completing the first-value action within N minutes/days |
| Core action rate | users doing the key action per week / active users |
| Retention | users returning on day 1, 7, 30 (or week 1, 4) |
| Revenue | trial-to-paid, churn, refund rate, cost per active user |
| Games | session length, sessions per day, level/stage funnel drop-off, D1/D7 retention, tutorial completion, crash-free sessions |
- Games rough anchors vary by genre; compare against your own previous build, not published averages.
- Activation and retention beat page views and downloads. Ignore vanity totals.

## Event schema
- Typed and versioned in one file (JSON Schema or TypeScript types); the code and the pipeline both validate against it.
- Names: `object_action` in snake_case, past tense: `level_completed`, `project_created`, `checkout_started`. No spaces, no dynamic names.
- Common envelope: `event`, `schema_version`, `ts` (UTC ISO), `anon_id`, `user_id` (optional), `session_id`, `app_version`, `platform`.
- Properties: low-cardinality enums and numbers; never free text, emails, or full URLs with tokens.
```
level_completed { level_id: string, attempts: int, duration_ms: int, outcome: "win"|"fail" }
```
- Adding a property is compatible; renaming or changing a type means a new event or version.
- Keep the event count small (under about 30 early on).

## Identity
- Generate a random `anon_id` on first run; store locally; no device fingerprinting. On login, link `anon_id` to `user_id` server-side once; do not send email as an id.
- Reset the id on user request and on account deletion; delete events by id when a deletion request arrives.
- Sessions: new session after 30 minutes of inactivity.

## Privacy defaults
- Collect the minimum, truncate or drop IP, no precise location, respect do-not-track and consent choices, and offer opt-out. Children's products: avoid analytics identifiers entirely unless reviewed.
- Scrub PII before send and on ingest; reject events with unexpected properties.

## Pipeline
- Client batches events and posts to a single endpoint (yours or a provider's). Own endpoint: validate schema, write to an append-only table or file store; cheapest and most private for a small audience. Provider: faster dashboards, but a processor to list and a cost curve to watch.
- Add retry with a bounded offline queue; drop oldest on overflow. Analytics failure must never affect the app.
- Sampling: keep 100% of low-volume events (purchases, errors); sample only high-volume ones (frame stats, ticks) at a recorded rate and store the rate on the event.
- Set a monthly event budget and an alert at 80%.

## Dashboards
- One screen per question: title is the question, the chart is the answer, and the threshold line is the action trigger.
- Show cohorts (by signup week or build version), not just totals. Show counts next to percentages; 3 of 5 is not 60%.

## Experiments
- Rough sample size to detect a change: for a baseline conversion near 10%, a 20% relative lift needs on the order of 3,000-4,000 users per arm; smaller lifts need far more. Verify with a calculator.
- Under a few hundred users, do not A/B; ship the change, compare to the prior cohort, and gather qualitative feedback.
- Fix the metric, duration, and sample size before starting. No peeking and stopping on first significance. One change at a time.
- Randomise by `anon_id` consistently; log the assignment as an event.

## Analysis with SQL
- Land events in one table; model views: `daily_active`, `first_seen`, `funnel_steps`.
```
SELECT d1.cohort, count(*) AS users,
       count(r.anon_id) * 1.0 / count(*) AS d1_retention
FROM first_seen d1
LEFT JOIN events r ON r.anon_id = d1.anon_id AND r.day = d1.day + 1
GROUP BY d1.cohort;
```
- Exclude your own test traffic with a flag, not by memory.

## Data quality
- Tests run daily: no events with unknown names or schema_version, no null `anon_id`, timestamps not in the future, volume within 50% of the 7-day average, duplicate rate near 0. Follow `test-discipline` so assertions prove contracts.
- Instrument check in CI: each declared event is emitted by a test path.

## Decision log
- Record in the decision file: date, question, metric and result, decision, and follow-up date. Metrics that never change a decision get deleted.

## Anti-patterns
- Tracking everything "to look at later".
- Dashboards of totals that always rise.
- Free-text or identifying properties.
- Declaring a winner from tiny samples.

## Checklist
- [ ] Questions and action thresholds written
- [ ] Typed schema with naming convention and version
- [ ] Random anon id, no fingerprinting; deletion path
- [ ] PII-free events; consent handled
- [ ] Pipeline failure-safe; budget and sampling recorded
- [ ] Quality tests scheduled; decisions logged
