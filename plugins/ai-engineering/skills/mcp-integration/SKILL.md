---
name: mcp-integration
description: Using and building Model Context Protocol (MCP) servers and clients from a TypeScript/Node/NestJS backend - tools, resources, and prompts; stdio versus HTTP transports; authentication and least privilege; server trust, pinning, and review; tool-description injection risk; schema and spec versioning; connection lifecycle; testing servers; and deciding between an MCP server and a plain in-process tool. Provider-agnostic; verify protocol details against the current spec. Load when connecting an agent to MCP servers, writing an MCP server, or assessing the risk of a third-party server.
---

# MCP Integration

Builds on `tool-integration` and `agent-design`; trust and injection concerns are in `ai-security`. The protocol and official SDKs change between revisions: verify message shapes, transports, auth flow, and SDK APIs against the current MCP specification and SDK docs before coding.

## When MCP, when a plain tool
- Plain in-process tool: your own app's logic, or a thin REST/OAuth adapter for an app with no good MCP server. Default when you own the code and the auth.
- MCP client: prefer when a good, maintained server already exists for the external app (Figma, GitHub, Slack, Trello, Google Drive), or a capability must be reused by several hosts.
- MCP adds a process or network hop, a trust boundary, and a lifecycle. Do not adopt it for a single internal function.
- Connector = one external app, implemented by either path. Both present the same internal tool schema to the orchestrator: namespaced names (`figma.get_file`), trimmed results, size limits, pagination (`tool-integration`). Keep a fixed, reviewed list of supported servers with version pins and allowlisted tools; no user-supplied server URLs and nothing third parties publish to.
- Per-user auth: each user connects their own account (OAuth where the server supports it; verify against the current spec). Store tokens encrypted per user and server; one client session per user.
- Per turn, expose only tools from servers the user connected and enabled for this project or conversation, filtered to the allowlist. Never list-and-forward every MCP tool.
- Treat server results as untrusted input. If a server is down, return "connector unavailable" and continue the turn.

## Primitives
- Tools: model-invoked actions. Resources: data the host or user attaches as context. Prompts: user-selected templates.
- Pick by who controls it: model-controlled is a tool, application-controlled is a resource, user-controlled is a prompt.
- Tool design rules from `tool-integration` apply unchanged: narrow, validated, idempotent, bounded results.

## Transports
- stdio: client launches the server as a local subprocess. Simple, no network auth, runs with the client's privileges. Suits local and dev use.
- HTTP-based (check the spec for the current streamable HTTP transport and any legacy SSE form): for remote, multi-client, multi-tenant servers. Needs authentication, TLS, and rate limits.
- Never write logs to stdout on a stdio server; stdout carries protocol messages. Log to stderr or a file.

## Auth and least privilege
- Remote servers: use the auth mechanism the current spec defines (OAuth-based in recent revisions; verify). Validate tokens, audience, and scopes on the server.
- Do not pass the end user's broad credentials through. Use per-user, narrowly scoped tokens; never put secrets in tool arguments or prompts (`secret-handling`).
- Expose to each agent only an allowlist of tools from each server, not everything the server lists.
- Authorise on the server per call; never trust the client's claim about the user.

## Trust and pinning
- Treat every third-party server as untrusted code and untrusted text. Review source or vendor, and run stdio servers with minimal OS permissions or in a container.
- Pin server package versions and lock files; no `latest`. Re-review on upgrade.
- Tool names, descriptions, and results enter the model context and can carry injected instructions, or change after approval ("rug pull"). Hash or snapshot tool definitions at approval and alert on drift.
- Namespace tools by server to avoid name collisions and shadowing.
- Require confirmation for destructive tools regardless of server claims; annotations from servers are hints, not guarantees.

## Client lifecycle
- Initialise, negotiate capabilities and version, list tools, call, close. Reconnect with backoff; re-list tools after reconnect.
- Apply timeouts and AbortSignal to every call; cap result size and count of tools loaded into context (`context-engineering`).
- One client per server per tenant or session as the trust model requires. Close processes on shutdown (NestJS `OnModuleDestroy`).

```ts
const allowed = new Set(['search_docs', 'get_page']);
const tools = (await client.listTools()).tools.filter(t => allowed.has(t.name));
assertMatchesPinnedHashes(tools);
```

## Building a server
- Validate inputs with a schema, return structured errors, keep tools stateless where possible.
- Version tool schemas: additive changes only within a version; rename or remove via a new tool name with a deprecation period.
- Test with an MCP client in-process or the official inspector tooling (verify availability), plus contract tests for each tool's schema and error cases (`ai-testing`, `test-discipline`).
- Log calls with caller, tool, duration, and outcome, redacting arguments (`ai-observability`).

## Review checklist
- Which tools does the agent actually need, and are they allowlisted?
- Is the server version pinned and its tool definitions hashed?
- What credentials does it hold, and what is the worst action they permit?
- What happens on timeout, disconnect, and oversized results?
- Does a fake MCP server exist for tests so CI never calls live servers?
