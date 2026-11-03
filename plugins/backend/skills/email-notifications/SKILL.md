---
name: email-notifications
description: Transactional email and notifications for NestJS backends - queueing sends through background jobs, outbox and idempotency keys, a provider-neutral mail interface, MJML/HTML plus plain-text templates with typed data, deliverability (SPF, DKIM, DMARC, bounce and complaint webhooks, suppression lists), unsubscribe and preference models for non-transactional mail, local catcher and fake provider testing, rate limits and retries, PII-safe logging, and brief in-app and push notification patterns. Load when sending email, adding notification types, wiring a mail provider, building templates, or handling bounces and user notification preferences.
---

# Email and notifications

Builds on `background-processing`, `nestjs-patterns`, and `backend-observability`. Provider specifics (SDKs, webhook payloads, quotas) change; verify against current provider docs.

## Architecture
- Never send email inside the request path. The request records intent; a job sends (`background-processing`).
- Use the outbox pattern for sends tied to a DB change: insert a `NotificationOutbox` row in the same transaction as the business write, then a relay enqueues it. This avoids "committed but no email" and "email but rolled back".
- Every send carries an idempotency key (`${type}:${recipientId}:${entityId}`), stored with a unique constraint. A retry or duplicate job must not send twice.
- Separate concerns: `NotificationService` (decides who/what), `TemplateRenderer` (builds content), `MailProvider` (delivers).

## Provider abstraction
- Depend on an interface, never on a vendor SDK, in business code. Bind via a Nest injection token.
```ts
export interface MailMessage {
  to: string; subject: string; html: string; text: string;
  idempotencyKey: string; tags?: Record<string, string>;
}
export interface MailProvider {
  send(msg: MailMessage): Promise<{ providerId: string }>;
}
export const MAIL_PROVIDER = Symbol('MAIL_PROVIDER');
```
- Implementations: SMTP, an HTTP API provider, a fake (tests), a catcher (dev). Select by validated config (`data-validation`).
- Map provider errors to transient (429, 5xx, timeouts) versus permanent (invalid address, 4xx) so the job retries correctly (`error-handling`).

## Templates
- Author in MJML or table-based HTML compiled at build time; always ship a plain-text alternative. Inline CSS; test dark mode and common clients.
- Type template data per template; compile-time failure beats a blank placeholder.
```ts
type TemplateData = {
  'password-reset': { name: string; resetUrl: string; expiresInMinutes: number };
  'invoice-ready': { name: string; invoiceUrl: string };
};
render<K extends keyof TemplateData>(key: K, data: TemplateData[K]): { html: string; text: string };
```
- Escape all interpolated values. Links must be absolute, use HTTPS, and carry short-lived single-use tokens for sensitive actions (`authentication-authorization`).
- Subject and preheader are part of the template, not caller-supplied strings. Localise via locale on the recipient (frontend internationalisation conventions, if installed).

## Deliverability
- Send from a dedicated subdomain. Configure SPF, DKIM (provider-signed), and DMARC (start `p=none` with reports, move to `quarantine` then `reject`).
- Expose a webhook endpoint for bounces and complaints. Verify the provider signature, respond fast, process via a job, make handling idempotent.
- Hard bounce or complaint: add to a suppression list (table keyed by normalised address) and check it before every send. Soft bounces: retry, suppress after about 3 consecutive.
- Keep bounce rate under about 2 percent and complaints under about 0.1 percent; alert above.

## Transactional versus non-transactional
- Transactional (reset, receipt, security alert): no unsubscribe, but still honour the suppression list for hard bounces.
- Marketing and digests: require consent, a visible unsubscribe link, and `List-Unsubscribe` plus `List-Unsubscribe-Post` headers for one-click. Honour opt-out immediately.
- Preference model: `NotificationPreference(userId, category, channel, enabled)` with unique `(userId, category, channel)`; categories are an enum; security categories cannot be disabled. Default to opt-in for non-essential categories.

## Rate limits and retries
- Throttle workers to the provider quota using queue limiter settings (`rate-limiting-quotas`). Back off with jitter on 429.
- Cap attempts (about 5), dead-letter the rest, and alert. Limit user-triggered sends per recipient (for example 3 reset emails per hour) to prevent abuse.

## Logging and privacy
- Log message id, template key, provider id, and outcome. Never log bodies, tokens, links, or full addresses; mask (`j***@example.com`) (`backend-security`).
- Never put secrets in job payloads; pass ids and load at send time (`secret-handling`).

## In-app and push
- In-app: a `Notification(userId, type, payload, readAt, createdAt)` table, list endpoint with cursor pagination (`api-design`), unread count, deliver live via SSE or WebSocket (`realtime-streaming`).
- Push: store device tokens per user and device, remove tokens on provider "unregistered" errors, send via a job, keep payloads minimal (no sensitive content).
- Fan out per channel from one notification event, applying preferences before dispatch.

## Local dev and testing
- Dev: route SMTP to a local catcher (Mailpit or similar) via compose; never real addresses.
- Tests: bind a `FakeMailProvider` that records messages; assert on recipient, template key, and idempotency (`backend-testing`, `test-discipline`).
- Render every template in a snapshot-free test checking required fields exist and no `undefined` appears in output.

## Anti-patterns
- Awaiting the provider inside a controller.
- Provider SDK types leaking into services.
- Unique-key-less retries that double-send.
- Ignoring bounces and complaints.
- HTML-only mail; unescaped user input in templates.

## Checklist
- [ ] Send is a job with an idempotency key; outbox where tied to DB writes
- [ ] Provider behind an interface with a fake
- [ ] Typed templates with text alternative
- [ ] SPF, DKIM, DMARC set; bounce webhook and suppression list live
- [ ] Preferences and unsubscribe for non-transactional mail
- [ ] Retries classified, rate limited, dead-lettered
- [ ] No PII or tokens in logs or payloads
