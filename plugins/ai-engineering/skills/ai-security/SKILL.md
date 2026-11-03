---
name: ai-security
description: Security for LLM chat apps and agent systems - direct and indirect prompt injection, untrusted content boundaries, least-privilege tool permissions, output handling and sanitisation, data exfiltration channels, PII and secrets in prompts and logs, tenant isolation in RAG, jailbreaks and abuse, rate and cost abuse, human approval for risky actions, and red-teaming with regression cases. Load when exposing tools to a model, ingesting external or user documents, designing agent permissions, handling model output, or reviewing an AI feature for risk.
---

# AI security

Builds on `agent-design`, `tool-integration`, `retrieval-augmented-generation`, and Squad `secret-handling`. Attack cases become regression evals in `ai-evaluation` and tests in `ai-testing`. Check the current OWASP Top 10 for LLM Applications for category names and numbering; verify against the current version.

## Threat model
- The model cannot reliably separate instructions from data. Treat every model output as untrusted input, and every token in the context window as potentially attacker-influenced.
- Direct injection: the user tries to override instructions. Indirect injection: instructions hidden in retrieved documents, web pages, emails, tool results, or file contents.
- Design so a fully compromised model turn causes bounded damage. Prompts are not a security boundary; code is.

## Untrusted content
- Mark external content as data, with delimiters and an explicit statement that it contains no instructions. This reduces risk but does not eliminate it.
```ts
const block = `<document source="${escapeAttr(src)}" trust="untrusted">\n${text}\n</document>`
```
- Strip or neutralise delimiter look-alikes inside content. Limit size and strip hidden text, markup, and zero-width characters where possible.
- Do not let untrusted content and sensitive capabilities meet in one context: reading the web and sending email in the same agent is the dangerous combination. Split into agents with separate privileges (`agent-orchestration`).

## Tool permissions
- Least privilege: each agent gets only the tools it needs, with narrowly scoped credentials. Prefer read-only tools.
- Authorise in the tool implementation against the calling user's permissions, never the model's claim. Pass user and tenant identity from the session, not from model-generated arguments.
- Validate every argument server-side with a schema; allowlist hosts, paths, and commands. No arbitrary shell, SQL, or URL fetch without sandboxing and allowlists (SSRF).
- MCP servers and plugins are third-party code: pin versions, review tool descriptions (they enter the prompt), and restrict scopes (`mcp-integration`).

## Human approval
- Require explicit confirmation for irreversible, costly, external-facing, or privilege-changing actions (send, delete, pay, deploy, share).
- Show the user the exact action and arguments being approved, not the model's description of them. Approval is bound to that call and expires.
- Default deny when the policy is unclear. Log every approval and denial.

## Output handling
- Never pass model output to `eval`, shells, SQL, or templates. Parameterise queries and validate structured output against a schema.
- Escape model text before rendering as HTML; sanitise markdown with an allowlist. Block or proxy auto-loaded images and links, a common exfiltration route (data encoded in a URL).
- Validate URLs and tool-call targets against allowlists before following or rendering.

## Data protection
- Send the minimum data to providers. Redact PII and secrets before prompts, logs, traces, and eval datasets (`ai-observability`). Never place credentials in prompts or context; the model can repeat them.
- Do not put secrets in system prompts expecting them to stay hidden; assume the system prompt can leak.
- Check provider terms for retention and training use; choose zero-retention options for sensitive data.
- Scan output for secrets and PII patterns before returning when policy demands.

## Tenant isolation in RAG
- Enforce tenant and ACL filters in the retrieval query itself, using identity from the authenticated session. Do not filter after retrieval or rely on the prompt.
- Per-tenant namespaces or indexes for strict isolation. Apply the same rule to caches, memory stores, and conversation history; key by tenant.
- Test cross-tenant leakage explicitly with canary documents.

## Abuse and cost
- Rate limit per user and tenant by requests and tokens; cap max input size, output tokens, steps, and tool calls per run.
- Set budget alarms and hard spend caps; detect loops and runaway agents (`agent-orchestration`).
- Detect jailbreak and abuse patterns with a moderation or classifier step where the product needs it; do not rely on it alone.

## Red-teaming
- Maintain an attack corpus: direct and indirect injections, exfiltration attempts, tool misuse, cross-tenant probes, encoded and multilingual payloads.
- Run it in CI against the real pipeline with fake tools that record calls; assert no forbidden tool call or leaked canary, not on refusal wording.
- Add every real incident as a case. Re-run on prompt, model, and tool changes.

## See also

Optional, if installed: application-security (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
