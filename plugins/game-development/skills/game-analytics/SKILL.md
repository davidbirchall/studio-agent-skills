---
name: game-analytics
description: Game telemetry in Unity - event schema (session, level, economy, tutorial, error events), typed event classes and naming, batching and offline queue, sampling and cost, privacy (consent gate, no PII, children's data caution), funnels, D1/D7/D30 retention cohorts, difficulty and balance metrics, economy health, crash and performance telemetry, dev-build versus release gating, analysing with SQL or spreadsheets, feeding results into logged balance decisions, and testing the pipeline. Load when adding telemetry to a game, designing events, analysing player behaviour, or tuning difficulty and economy from data.
---

# Game analytics

Telemetry exists to answer decisions. SDK names, package APIs, and platform privacy rules change; verify against current docs/installed version. General analytics method (questions first, metrics, experiments) is in the product-analytics skill of the business plugin; this skill covers game specifics.

## Start from questions
- Write 3-7 questions before any event: "Where do players quit the tutorial?", "Which level has fail rate above 60%?", "Is gold inflating?".
- Every event must map to a question. No question, no event.

## Event schema
- Envelope on every event: `event_name`, `schema_version`, `session_id`, `player_id` (pseudonymous), `build_version`, `platform`, `timestamp_utc`, `seq` (per-session counter), `is_dev_build`.
- Core events: `session_start`, `session_end`, `tutorial_step` (step_id, result), `level_start`, `level_complete` (duration_s, score, attempts), `level_fail` (cause, duration_s), `economy_source` / `economy_sink` (currency, amount, reason, balance_after), `purchase`, `error`, `perf_sample`.
- Names: snake_case, noun_verb or scope_action, stable forever. Never rename; add a new event and bump `schema_version`.
- Parameters: small typed set, enums over free text, cap string length (64), at most ~10 parameters per event.
- Keep ids stable and data-driven (`level_id` from the level asset, not scene name or display text).

## Typed event classes in Unity
- One immutable class or struct per event, constructed only through a factory; callers never pass raw strings.
- A single `Analytics.Track(IGameEvent)` facade; gameplay code never touches the vendor SDK (`unity-architecture`). Swap backends behind one interface.
- Raise events from game-state transitions (`game-state-management`), not from UI scripts.

## Batching and offline
- Queue in memory; flush at 20-50 events or every 30-60 s, and on pause/quit (mobile: `OnApplicationPause(true)`).
- Persist the queue to disk (`save-load-systems`) so a crash or offline session loses nothing; cap at e.g. 5 MB, drop oldest first.
- Send with retry and exponential backoff plus jitter; dedupe server-side on `session_id` + `seq`.
- Never block the main thread or a frame on network or disk; do I/O off-thread or async.

## Sampling and cost
- Gameplay events: send all. High-frequency data (frame samples, positions, per-hit damage): aggregate client-side or sample (1 in 10-100 sessions).
- Budget: bytes per session and cost per 1k DAU; alert when above plan.

## Privacy
- Consent gate: no events leave the device until consent is recorded; honour revocation immediately and clear the queue. Region rules (GDPR, CCPA, platform store labels) change; verify current requirements.
- No PII: no names, emails, free-text chat, precise location, or device identifiers beyond a resettable random id. Hash is not anonymisation.
- Children's data: if the audience may include children, assume strictest rules (COPPA, age-appropriate design codes); default to minimal or no telemetry and get a legal review before shipping.
- Data minimisation and retention: state how long raw events are kept; provide a delete path keyed by player id.
- Never put API keys or secrets in event code or repos (`secret-handling`).

## Funnels
- Tutorial: ordered `tutorial_step` events; report unique players reaching each step, drop-off per step, median time per step. Investigate any step losing more than 10% of entrants.
- Level funnel: `level_start` -> `level_complete` per `level_id`; count unique players, not events.

## Retention
- Cohort by install date. D1, D7, D30 = share of the cohort with a `session_start` on exactly day N (or N or later; state which).
- Read cohorts only when size is large enough (n >= ~100); otherwise report as anecdotal.

## Difficulty and balance
- Per level: fail rate (fails / attempts), attempts to first win, median time to complete, quit-without-result rate.
- Flags: fail rate over 60% or under 5%, attempts-to-win p90 over 8, completion time over 2x design target, sharp rise from the previous level.
- Use medians and percentiles; means are skewed by AFK sessions (cap duration, drop sessions idle over 5 min).

## Economy health
- Track source versus sink per currency per day, median and p90 balance per player, and share of players at zero or cap.
- Inflation: median balance rising each week. Starvation: many players blocked at zero. Fix source/sink rates, not individual prices first.
- Every grant and spend must carry a `reason` enum; unreasoned changes are bugs.

## Crash and performance
- Report crashes through the platform or a crash reporter with build id and scene; keep symbol files per build (`unity-build-release`).
- `perf_sample` per scene or minute: frame-time p50/p95/p99 (ms), hitch count over 33 ms, load time per scene, managed memory peak, device model and tier. Deep investigation uses `game-profiling`.
- Aggregate on the client; never emit per-frame events.

## Dev versus release
- Dev builds: set `is_dev_build`, route to a separate project or dataset, verbose logging allowed, consent gate still tested.
- Release: only schema-approved events, no debug fields, remote kill switch for the whole pipeline.
- Exclude editor and QA sessions from analysis by filtering `is_dev_build` and internal ids.

## Analysing
- Land events in a warehouse or export to CSV; keep one tidy events table. Example: fail rate = `SUM(event='level_fail') / NULLIF(SUM(event='level_start'),0)` grouped by `level_id`, `build_version`.
- Spreadsheet pivots are fine below ~1M rows. State sample size and date range with every number.

## Close the loop
- Each balance change records in the project decisions file: question, metric and baseline, change made, expected effect, review date, result.
- Change one lever per build; compare same-size cohorts before and after; revert if the metric does not move.

## Test the pipeline
- Unit tests: event factories, serialiser, queue ordering, cap and drop-oldest, consent gate blocks send (`unity-testing`, `test-discipline`).
- Integration: play a scripted run in a dev build, assert the expected event sequence reaches the dev dataset with correct counts and no duplicates.
- Test offline: airplane mode, kill the app, relaunch, confirm queued events arrive once.

## Anti-patterns
- Tracking everything "just in case"; raw strings at call sites; renaming events; sending before consent; per-frame events; averaging skewed durations; changing several levers then claiming a cause.

## Checklist
- [ ] Questions listed; each event maps to one
- [ ] Envelope, versioned schema, typed events behind one facade
- [ ] Batched, persisted, non-blocking, deduped
- [ ] Consent gate, no PII, children's rules checked
- [ ] Dev/release separation and kill switch
- [ ] Funnels, retention, fail rate, economy views defined
- [ ] Pipeline tested offline and end to end
- [ ] Balance changes logged in decisions file
