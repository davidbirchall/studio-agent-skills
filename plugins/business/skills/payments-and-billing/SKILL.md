---
name: payments-and-billing
description: Payments and billing architecture for a solo maker - payment provider categories (merchant of record versus payment processor and what each handles for tax, VAT and chargebacks), choosing one, checkout flow design, webhooks with signature verification, idempotency, replay and ordering, the subscription state machine (trialing, active, past_due, canceled), entitlements stored in your own database and derived from events, never trusting the client, test mode, reconciliation jobs, refunds, tax and invoicing flagged to verify, avoiding PCI scope by never touching card data, secrets handling, failure modes and dunning. Load when integrating payments, handling webhooks, modelling subscriptions or entitlements, or debugging billing state.
---

# Payments and billing

Not legal or tax advice. Flag to a qualified professional: sales tax, VAT, and invoicing obligations, money-transmission questions, and subscription auto-renewal law; mark "verify for your jurisdiction". Provider names are omitted on purpose; verify every provider's current fees, terms, and API. Keys follow `secret-handling`. Tests follow `test-discipline`. Price design is in `pricing-and-monetisation`.

## Provider categories
| Category | Handles | You handle |
|----------|---------|------------|
| Merchant of record (MoR) | sells on your behalf: collects and remits sales tax/VAT, invoices, many chargebacks | product, entitlements; higher fee |
| Payment processor/gateway | card processing, fraud tooling, subscriptions engine | tax registration, collection, remittance, invoices, disputes evidence |
| Platform stores (app/game stores) | billing inside their ecosystem, tax | store rules, their cut, their refund flow |
- Default for a solo seller of digital goods across borders: MoR, because tax compliance is the largest hidden burden. Choose a processor only when you can handle tax registration or have an accountant.
- Choose on: fees all-in, payout countries and currencies, tax coverage, subscription features, refund/dispute handling, webhook quality, exit/export of customer data, lock-in. Compare two; run test mode on both for an hour.
- Platform rules may force store billing for in-app digital purchases; verify before adding an external checkout.

## Never touch card data
- Use provider-hosted checkout or hosted fields so card numbers never reach your server, logs, or analytics. This keeps PCI scope to the lightest self-assessment; verify the current level.
- Store only provider customer id, subscription id, and last-four display if needed.

## Checkout flow
1. Client asks your server for a checkout session for a plan id (from your plans file).
2. Server validates user and plan, creates the provider session with your user id in metadata, returns the URL.
3. Client redirects. The success page only says "processing"; it does not grant anything.
4. Provider webhook tells your server the real result. Grant entitlement there.
- Take prices from server config, never from client input.

## Webhooks
- Verify the signature on the raw request body with the provider's secret, and reject stale timestamps (for example over 5 minutes).
- Idempotency: store each event id in a table with a unique constraint; skip duplicates. Process then mark, in one transaction where possible.
- Ordering is not guaranteed. Use the object's own timestamp or version; on an out-of-order event, refetch current state from the provider API rather than trusting the payload.
- Respond 2xx fast; push work to a queue if slow. Providers retry on failure for days; handlers must tolerate replay.
- Keep a raw event log (id, type, received, status) for debugging and reconciliation.

## Subscription state machine
```
trialing -> active -> past_due -> canceled
              |          |
              +-> canceled_at_period_end
past_due -> active (payment recovered)
```
- Map provider statuses to your own small enum; do not leak provider vocabulary through the codebase.
- Cancel-at-period-end keeps access until the period end. Immediate cancel or refund revokes now.
- Define grace for past_due (for example 3-7 days of access) and write it in the plan data.

## Entitlements
- Your database holds `user_id, plan, status, current_period_end, source_event_id`. Derive it only from verified events plus reconciliation.
- Gate features on the entitlement row server-side. Never trust a client flag, a receipt, a local license file, or a query parameter. For offline games, sign a time-limited token from the server and verify it locally; accept that offline checks can be bypassed.
- One-time purchases: store product id and order id; make grants idempotent.

## Reconciliation
- Nightly job: list active subscriptions and recent payments from the provider, compare to your entitlements, report mismatches, fix by provider truth. Alert if mismatches exceed 0 for paid-and-no-access, which is the costliest.
- Compare revenue totals monthly against payout reports.

## Refunds and disputes
- Refund through the provider; the webhook revokes entitlement. Do not hand-edit the database.
- Disputes have short deadlines (often under 10 days); keep evidence: access logs, delivery proof, terms accepted. A MoR may handle this; verify.

## Dunning and failure modes
- Failed renewals: provider retry schedule (typically several attempts over 1-3 weeks), email the user with a link to update the payment method, move to past_due, then cancel. Configure it and test it.
- Webhook endpoint down: provider retries then drops; reconciliation is the backstop.
- Provider outage: show "try later"; do not grant free access automatically.
- Currency and rounding: store minor units as integers with a currency code. Never floats.

## Tax and invoicing (verify for your jurisdiction)
- Know whether your provider collects and remits tax. If not, registration thresholds, VAT on digital services, and invoice content are yours; get an accountant.

## Test mode
- Build and test against the provider's test mode and test cards; separate test and live keys per environment. Write tests for: duplicate event, out-of-order event, bad signature, failed renewal, refund, cancel at period end.

## Anti-patterns
- Granting access on the success redirect.
- Verifying webhooks after parsing JSON, or skipping signature checks locally and forgetting them in production.
- Storing entitlements only at the provider and calling it on every request.
- Secret keys in client code or the repo.

## Checklist
- [ ] Provider category chosen with tax responsibility explicit
- [ ] No card data touches your systems
- [ ] Signature, replay window, idempotency table in place
- [ ] State enum and grace rules defined
- [ ] Server-side entitlement table; reconciliation job running
- [ ] Refund, dunning, and test-mode cases tested
- [ ] Tax questions flagged for a professional
