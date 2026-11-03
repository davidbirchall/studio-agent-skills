---
name: ai-observability
description: Observability for LLM chat and agent systems - tracing model calls, tool calls and agent steps as spans, token, cost, latency and error metrics, logging prompts and completions with redaction, correlation ids across agent runs and conversations, quality feedback signals, sampling, dashboards and alerts, replaying runs from traces, and retention and privacy. Load when instrumenting LLM calls or agent loops, debugging a bad answer or runaway run, tracking cost, or deciding what to log and keep.
---

# AI observability

Builds on `llm-integration`, `agent-orchestration`, and `tool-integration`; redaction rules follow `ai-security` and `secret-handling`. Traces feed `ai-evaluation` datasets and online scoring. Verify attribute names against the current OpenTelemetry GenAI semantic conventions (a separate OpenTelemetry repository, status Development, so names may change), and against your tracing backend.

## Trace structure
- One trace per user request or agent run. Child spans for each step: model call, tool call, retrieval, guardrail check, sub-agent run.
- Wrap the provider client once, in the `llm-integration` layer, so every call is traced without per-call code.
```ts
return tracer.startActiveSpan('chat.completion', async (span) => {
  try {
    const res = await model.complete(req)
    span.setAttributes({ 'gen_ai.response.model': res.model, 'gen_ai.usage.input_tokens': res.usage.input, 'gen_ai.usage.output_tokens': res.usage.output })
    return res
  } catch (e) {
    span.recordException(e as Error); span.setStatus({ code: SpanStatusCode.ERROR }); throw e
  } finally { span.end() }
})
```
- Prefer the standard GenAI attribute names where they exist rather than inventing your own.
- Record on spans: model and provider, prompt version, token counts (input, output, cached), finish reason, retry count, latency, time to first token for streams, tool name, tool success, and error class.

## Correlation
- Propagate ids: `traceId`, plus `conversationId`, `runId`, `stepIndex`, `userId` (or hashed), `tenantId`. Put them on every log line and span.
- Use async context (AsyncLocalStorage in Nest) so ids reach tool calls and background jobs. Pass trace context through queues and to sub-agents so a run stays one trace.
- Return the trace or run id to support staff and to the client for bug reports.

## Metrics
- Counters and histograms: requests, tokens by direction, cost estimate, latency (p50/p95/p99), time to first token, tool calls, tool errors, retries, rate limits, refusals, steps per run, runs hitting limits.
- Keep label cardinality low: model, route, agent, outcome. Never label by user id, prompt text, or conversation id.
- Compute cost from token counts and a versioned price table; attribute it to tenant, feature, and agent so spend is explainable.

## Logging prompts and completions
- Full prompts and completions are the most useful debug data and the most sensitive. Decide per environment: capture full content in dev, redacted or sampled in production.
- Redact before writing, not after: secrets, tokens, emails, phone numbers, and domain-specific PII. Apply the same redactor to tool arguments and results.
```ts
span.addEvent('llm.prompt', { content: redact(JSON.stringify(messages)) })
```
- Store large payloads in a separate access-controlled store and reference them by id from the span.
- Never log credentials or full retrieved documents from restricted sources. Log chunk ids and scores for retrieval, not entire chunks.

## Quality signals
- Capture thumbs up/down, edits, retries, regenerations, abandonment, escalation to human, and task completion; attach them to the trace id.
- Add online judge scores on a sampled subset (`ai-evaluation`) as span events or separate score records linked to the trace.
- Route low-scoring and flagged traces into a review queue; promote reviewed ones into eval datasets.

## Sampling
- Always keep: errors, slow runs, runs hitting limits, negative feedback, and guardrail triggers. Sample the rest (tail-based sampling where the backend supports it).
- Sample content capture independently of span capture; metrics are never sampled.

## Dashboards and alerts
- Dashboards: cost per day and per tenant, latency percentiles per model, error and retry rates, token usage, tool failure rate, quality score trend, step count distribution.
- Alert on symptoms: error or rate-limit spike, p95 latency regression, cost per request jump, runaway runs, drop in feedback or judge score, provider outage. Link each alert to a runbook.
- Track changes (prompt version, model id, config) as annotations so regressions map to a cause.

## Replay and debugging
- Persist enough to replay a run: input, prompt template version, model and parameters, tool results, retrieved chunk ids. Replay against a fake model or fixed tool outputs to reproduce a failure (`ai-testing`).
- Version prompts and record the version on each span.

## Retention and privacy
- Set retention per data class: metrics long, traces short, full content shortest. Enforce deletion jobs.
- Honour user deletion requests across traces, logs, and datasets. Restrict who can read content and audit access.
- Check provider and backend data residency before exporting conversation content.

## See also

Optional, if installed: monitoring-observability (the platform-engineering plugin) for the broader discipline this skill applies. This skill stands on its own.
