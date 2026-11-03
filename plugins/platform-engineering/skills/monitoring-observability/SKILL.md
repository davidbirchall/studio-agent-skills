---
name: monitoring-observability
description: Provider-neutral platform monitoring and observability - metrics, logs and traces, golden signals and RED/USE, SLIs, SLOs and error budgets, actionable symptom-based alerts with severity, routing and runbook links, dashboards, log structure and retention, health checks, synthetic checks, alerting to yourself, incident response, blameless postmortems, telemetry cost and cardinality. Load when designing monitoring for services and infrastructure, defining SLOs or alerts, building dashboards, setting up alerting, or running incidents and postmortems.
---

# Monitoring and observability

Builds on `deployment-patterns`, `containerization`, `infrastructure-as-code`, and `release-management`. This skill covers platform-level monitoring; in-code instrumentation is out of scope. Verify query syntax and config against your tool's current docs.

## Signals
- Metrics: cheap numeric trends, good for alerting and dashboards. Logs: discrete events for diagnosis. Traces: request paths across services for latency breakdown.
- Start with metrics for detection, logs and traces for diagnosis. Correlate all three by a shared request or trace id.
- Define the monitoring as code (`infrastructure-as-code`) so dashboards and alerts are reviewed and reproducible.

## What to measure
- Golden signals per service: latency, traffic, errors, saturation.
- RED for request-driven services: rate, errors, duration. USE for resources: utilization, saturation, errors.
- Measure latency as percentiles (p50, p95, p99), never averages alone. Separate successful from failed request latency.
- Cover the stack: hosts and containers, queues, databases, certificates and expiry, DNS, CI pipeline health, AI agent run failures and token or cost budgets.

## SLIs, SLOs, error budgets
- An SLI is a ratio of good events to valid events (for example requests under 300 ms and non-5xx).
- An SLO sets a target over a window, for example 99.9 percent over 30 days. Choose targets from user need, not from current performance.
- Error budget is 1 minus the SLO. When burning too fast, slow risky releases and prioritize reliability work.
- Alert on budget burn rate over multiple windows (fast and slow) rather than raw thresholds.

## Alerts
- Page only on symptoms users feel (error rate, latency, outage), not causes (CPU at 80 percent). Causes go to dashboards or tickets.
- Every alert is actionable, has an owner, a severity, and a runbook link. If no one acts on it, delete it.
- Severity: page now (user impact), ticket within a day (degradation, budget risk), info (no notification).
- Route by service owner and severity; page, chat and ticket channels differ. Group and deduplicate related alerts.
- Add a for-duration to avoid flapping. Review alert noise monthly and prune.
```yaml
alert: HighErrorBudgetBurn
severity: page
condition: error_ratio > 14.4 * (1 - slo_target) over 5m and 1h
runbook: https://wiki.example.com/runbooks/api-errors
```

## Dashboards
- One overview per service: golden signals first, then dependencies, then resources. Put SLO status at the top.
- Show deploy and config change markers on graphs to correlate with regressions.
- Dashboards answer a question; remove panels no one uses. Avoid wall-of-graphs.

## Logs
- Emit structured JSON with timestamp, level, service, environment, version, and trace id. One event per line to stdout; the platform ships them.
- Set retention by value: short for debug (days), longer for audit and security (per policy). Archive cold data cheaply.
- Never log secrets or personal data (`secret-handling`); redact at the collector as a second line of defense.

## Health and synthetic checks
- Liveness says the process is alive; readiness says it can serve (dependencies reachable). Keep liveness shallow to avoid restart loops.
- Run synthetic probes against real user paths from outside the network, including login and a key transaction, plus TLS expiry checks.
- Use heartbeat monitors (dead-man switch) for cron jobs and pipelines that must run.

## Cost and cardinality
- Each unique label combination is a time series. Never label by user id, request id, or raw URL; use route templates and bounded enums.
- Sample traces and drop debug logs in production; set a telemetry budget and watch ingest volume.
- Downsample old metrics; keep high resolution only for recent windows.

## Alerts to yourself and incidents
- Route alerts to yourself (push, SMS or phone) for user-impacting conditions only; send the rest to a digest or ticket. Keep a runbook link in every alert. If you work with others: add a rota with backup and escalation.
- Follow incident-response (shared plugin, if installed), or at minimum: write severity and a timestamped log, mitigate first (rollback, `release-management`), diagnose after.
- Write a blameless postmortem file after significant incidents: timeline, impact, contributing factors, what went well, and tracked action items with dates. Focus on systems.
- Feed findings back into alerts, runbooks, tests (`test-discipline`) and SLOs.
