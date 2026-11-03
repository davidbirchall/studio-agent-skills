---
name: privacy-and-data-retention
description: Privacy and data retention for a solo maker of software and games - data inventory (what, why, where, how long), data minimisation, lawful basis and consent basics (GDPR, CCPA, COPPA flagged to verify), retention schedules and deletion jobs, user data export and deletion endpoints, PII scrubbing in logs and analytics, third-party processor lists, children's data caution in games, LLM prompt and response data handling, breach response for one person, and deriving the privacy policy from the inventory. Load when collecting a new kind of user data, adding a third-party service or analytics, building account deletion or export, handling LLM inputs, or writing a privacy policy.
---

# Privacy and data retention

Not legal advice. Flag to a qualified professional: any child audience, health, biometric, or location data, cross-border transfers, a breach involving personal data, and anything marked "verify for your jurisdiction". Laws and thresholds change; check current text. Secrets and keys follow `secret-handling`.

## Principle
- The cheapest data to protect is data you never collect. Collect only what a named feature needs, keep it only as long as needed, and be able to delete it.

## Data inventory (source of truth)
Keep one file in the repo. Every field you store or send out has a row. Update it in the same change that adds the field.
| field | purpose | where stored | processor | basis | retention | deletion path |
|-------|---------|--------------|-----------|-------|-----------|---------------|
| email | login, receipts | primary db | email service | contract | account life + 30d | delete endpoint |
| ip address | abuse limiting | edge logs | host | legitimate interest | 14d | log expiry |
- No row, no collection. Review the inventory before every release.
- Include backups, logs, analytics, crash reports, support mail, and LLM calls; these are the usual hidden stores.

## Minimisation
- Prefer no account. Prefer a random id over email. Prefer a coarse value (country, age band) over a precise one (address, birth date).
- Do not log request bodies, tokens, or full IPs by default. Truncate or hash where you only need uniqueness; note that hashed low-entropy values (email, phone) are still personal data.
- Free-text fields will contain personal data; treat them as sensitive.

## Lawful basis and consent (verify for your jurisdiction)
- GDPR-style regimes need a lawful basis per purpose: contract, legal obligation, legitimate interest, or consent. Consent must be specific, optional, and as easy to withdraw as to give.
- Non-essential analytics, ads, and cross-site tracking generally need opt-in consent in the EU and UK; verify.
- CCPA/CPRA-style regimes focus on disclosure, opt-out of sale/sharing, and deletion rights; thresholds depend on revenue or data volume; verify.
- Do not sell or share data for advertising without the legal mechanism and a recorded decision.

## Retention and deletion
- Set a retention period per row of the inventory. Default short: logs 14-30 days, analytics raw events 13 months or less, inactive accounts reviewed at 24 months, backups rotated within 35 days.
- Implement as a scheduled job, not a promise: query rows older than the limit, delete, log counts (not content). Test it with a fixture.
- Soft delete is not deletion. Hard-delete or irreversibly anonymise; backups age out on rotation, state that in the policy.
- Keep records you must legally retain (invoices, tax) separate and minimal.

## User rights endpoints
- Export: authenticated endpoint returning all the user's data in a machine-readable file (JSON or CSV) within the legal deadline (commonly 30 days; verify).
- Deletion: authenticated, confirmed, propagates to processors (analytics, email list, payment provider, error tracker). Keep a checklist of each processor's deletion call.
- Both must work without you manually editing the database.

## Third-party processors
- Maintain a list: name, what data they get, region, deletion method, contract/DPA status. Verify each provider's current terms for data use and sub-processors.
- Disable provider features that retain or train on your users' data unless you intend that.

## Children's data (games)
- If the audience may include children, COPPA (US), GDPR child-consent ages, and age-appropriate design codes may apply; verify and get professional review.
- Default: no personal data from users who may be minors, no behavioural ads, no open chat, no precise location, no persistent identifiers shared with third parties.
- Do not rely on a checkbox age gate alone; platform ratings and store forms carry their own obligations.

## LLM prompts and responses
- Treat prompts and outputs as user data: put them in the inventory, with retention.
- Strip or avoid identifiers before sending to a model provider. Check whether the provider retains or trains on inputs and use the no-training setting or terms.
- Do not log full prompts in plain application logs. Do not put secrets or other users' data into shared context.

## Breach response (one person)
1. Contain: rotate credentials, revoke tokens, block access.
2. Scope: which data, which users, since when. Preserve logs.
3. Notify: regulators often require notice within 72 hours of awareness; users when risk is high; verify for your jurisdiction and consult a professional.
4. Record what happened and the fix in a decision file. Keep a one-page runbook before you need it.

## Privacy policy
- Generate from the inventory: what, why, basis, processors, retention, rights, contact. If a statement is not in the inventory it does not belong in the policy.
- Version it, date it, and update it when the inventory changes.

## Anti-patterns
- Collecting "in case it is useful later".
- Copying a policy template that does not match the inventory.
- Raw user ids or emails in analytics events or logs.
- Deletion that skips processors.

## Checklist
- [ ] Inventory current, every field has purpose and retention
- [ ] Deletion job scheduled and tested
- [ ] Export and delete endpoints work end to end
- [ ] Processor list and provider data settings verified
- [ ] Logs and events scrubbed of PII
- [ ] Child-audience and jurisdiction questions flagged for review
- [ ] Policy matches inventory
