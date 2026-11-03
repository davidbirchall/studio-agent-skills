---
name: application-security
description: Technology-neutral application security discipline - lightweight threat modelling (assets, actors, trust boundaries, STRIDE), OWASP Top 10 categories, input validation and output encoding, authentication and authorisation principles, least privilege, secure defaults, injection, XSS, CSRF, SSRF, logging without sensitive data, defence in depth, fail-closed behaviour, security review checklist, and vulnerability handling and disclosure. Load when designing, building, or reviewing any feature that handles user input, identity, data access, external calls, or secrets.
---

# Application Security

Builds on `software-architecture` and `technical-design`. Defers to `secret-handling` for credentials and `dependency-management` for third-party risk. Frontend, backend, AI, and game plugins apply these rules to their stacks.

## Threat model first
- List assets (data, money, accounts, availability), actors (anonymous, user, admin, service, attacker), and trust boundaries (browser to server, service to service, server to database, tool or model output to action).
- Apply STRIDE-lite at each boundary: Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege.
- Record top threats and mitigations in the design doc. Revisit when a boundary or asset changes.
- Treat everything crossing a boundary as untrusted: request data, headers, files, webhooks, client-side state, LLM output, save files, mod content.

## OWASP Top 10
- Use the current OWASP Top 10 as a vocabulary and checklist; verify the current edition (Top 10:2025 is current; the 2021 edition is still widely referenced).
- Core categories (2025): broken access control, security misconfiguration, software supply chain failures, cryptographic failures, injection, insecure design, authentication failures, software or data integrity failures, logging and alerting failures, mishandling of exceptional conditions. SSRF is folded into broken access control; it stays a standalone item in the API Security Top 10 (2023).

## Input and output
- Validate at the boundary: type, length, range, format, allow-list over deny-list. Reject, do not silently repair.
- Validation is not a substitute for safe APIs. Encode on output for the destination context (HTML, attribute, URL, SQL, shell).
- Injection: never build queries or commands by string concatenation. Use parameterised queries and argument arrays.

```ts
db.query("SELECT * FROM users WHERE id = $1", [id]);   // good
db.query(`SELECT * FROM users WHERE id = ${id}`);       // injection
```

- XSS: rely on framework auto-escaping; avoid raw HTML sinks; sanitise with a maintained library when HTML is required; set a Content Security Policy.
- CSRF: for cookie-based sessions use SameSite cookies plus anti-CSRF tokens on state-changing requests.
- SSRF: allow-list outbound hosts, block internal and metadata address ranges, disable redirects on user-supplied URLs.

## Authentication and authorisation
- Use proven libraries and standards (OIDC, OAuth 2.0). Never invent crypto or session schemes.
- Hash passwords with a slow adaptive algorithm (argon2id, bcrypt, scrypt). Support MFA. Rate-limit and lock out abuse.
- Authorise on the server for every request and object, not only at the UI. Check ownership, not just login (prevent IDOR).
- Deny by default. Centralise policy checks rather than scattering ad hoc conditions.

## Principles
- Least privilege: minimal scopes for tokens, database roles, service accounts, and containers.
- Secure defaults: safe configuration out of the box; features that weaken security are opt-in.
- Defence in depth: assume one layer fails; combine validation, authz, encoding, network limits, monitoring.
- Fail closed: on error or missing policy, deny. Never return partial data on an authorisation failure.
- Keep error messages generic to clients; detail goes to logs.

## Logging and secrets
- Log security events (login, denial, privilege change) with who, what, when, and request id.
- Never log passwords, tokens, keys, full card numbers, or personal data; mask or omit.
- Secrets never in source, logs, or client bundles; see `secret-handling`.

## Review checklist
- Every new input validated and every output encoded for its context.
- Every endpoint or action has an authorisation check on the server.
- No string-built queries, commands, or paths from user data.
- Outbound requests restricted; uploads limited by type, size, and storage location.
- Dependencies pinned and audited (`dependency-management`).
- Security tests exist for authz denial and malicious input (`software-testing-strategy`).

## Vulnerabilities
- Triage by exploitability and impact; fix critical issues first, then ship a regression test.
- Provide a documented private reporting channel (SECURITY.md) and acknowledge reports promptly.
- Disclose responsibly: fix, release, then publish an advisory describing impact and remediation.
- Rotate any credential that may have been exposed; do not wait to prove misuse.
