---
name: pricing-and-monetisation
description: Pricing and monetisation for a solo maker of software and games - pricing models (one-time, subscription, usage-based, freemium, ads, in-app purchase, premium games), cost-plus floor from real unit costs including LLM and API costs, value-based ceiling, price experiments with little traffic, tiers (maximum three), refunds and trials, game monetisation ethics and dark-pattern anti-patterns, pricing page as structured data, regional pricing, and recording price decisions with assumptions. Load when setting or changing a price, choosing a business model, designing tiers or trials, adding in-app purchases or ads, or reviewing monetisation for manipulative patterns.
---

# Pricing and monetisation

Not legal or tax advice. Flag to a qualified professional: consumer-law rules on refunds, auto-renewal, price display, loot-box regulation, and tax-inclusive pricing; mark these "verify for your jurisdiction". Implementation of charging lives in `payments-and-billing`; measuring conversion in `product-analytics`; user data in `privacy-and-data-retention`.

## Pick a model by cost shape
| Model | Fits | Watch |
|-------|------|-------|
| One-time | tools, premium games, no ongoing cost | no recurring revenue; support is forever |
| Subscription | ongoing server, content, or updates | churn; cancel must be easy |
| Usage-based | variable cost (LLM, compute, storage) | bill shock; need caps and previews |
| Freemium | viral or low marginal cost | free users cost money; set a conversion target |
| Ads | high volume only | needs large audience; privacy and store rules |
| IAP | games, with strict ethics | see game section |
- Ongoing cost to you (hosting, API, support) implies recurring or usage pricing. No ongoing cost implies one-time is fine.

## Floor: cost-plus
- Compute real unit cost per user or per action: hosting, LLM tokens, storage, bandwidth, payment fees, platform cut (stores often take 15-30%; verify current), tax handling, refunds.
- Formula: floor = (variable cost per unit + fees) / (1 - target margin). Add fixed costs divided by realistic units, not hoped-for units.
- Price LLM features against worst-case users (heavy 5%), not the average. Set a usage cap or credit pool.

## Ceiling: value-based
- Ceiling = what the alternative costs the customer (competitor, manual time, DIY) plus what they gain. Time saved x hourly value is the usual anchor.
- Price between floor and ceiling. If floor exceeds ceiling, change the cost structure or the product, not the story.

## Tiers and packaging
- Maximum three tiers. One recommended, one cheaper or free, one higher. Differentiate on a limit or capability that tracks value (seats, projects, volume), not arbitrary feature removal.
- Do not put core safety, data export, or account deletion behind a paywall.
- Annual plan: discount 15-20% vs monthly; verify it does not break cash flow or refund policy.

## Trials and refunds
- Trial 7-14 days for subscriptions; require payment method only if you accept more churn at conversion. Say clearly what happens at trial end.
- Refund policy written before launch: window (14-30 days typical), conditions, how triggered. Some regions mandate withdrawal rights; verify.
- Treat refund and chargeback rate as a health metric; above about 2-3% investigate product or messaging.

## Experiments with little traffic
- Below roughly 1,000 visitors per variant, A/B tests cannot detect typical price effects. Use alternatives: sequential price changes with a log, new-customer-only cohorts, price-sensitivity interviews, willingness-to-pay questions (what is too cheap, too expensive).
- Change one variable at a time; hold for at least one full business cycle (usually 2-4 weeks).
- Never charge different people different prices for the same thing without a clear rule (region, plan) that you can state; verify local rules.
- Grandfather existing customers or give notice; silent increases erode trust and may breach terms.

## Regional pricing
- Use purchasing-power tiers (3-4 bands), not per-country invention. Check store tools, tax-inclusive display rules, and currency rounding (charm prices like 4.99 in local style).
- Watch for abuse (VPN arbitrage) only if material.

## Games: monetisation ethics
- Allowed and sane: premium price, honest DLC, cosmetic-only purchases, optional expansions.
- Anti-patterns: pay-to-win on competitive play, randomised paid rewards (loot boxes; regulated or banned in some places, verify), artificial scarcity timers, hidden currency layers that obscure real price, nagging popups, selling to minors, spending without confirmation, difficulty tuned to push purchases, free-to-start-then-hard-paywall bait.
- Show real-money cost next to virtual currency. Cap or warn on spending. Make purchases restorable and refundable per platform rules.
- If the game may reach children, default to no IAP or parental gating; verify rules.

## Pricing page as data
- Keep plans in a structured file (id, name, price per currency, interval, limits, entitlements). Page, checkout, and entitlements read from it; copy lives separately.
```
plan: pro
prices: {usd: 9, eur: 9}
interval: month
limits: {projects: 20, ai_credits: 500}
```
- Single source of truth prevents page, provider catalogue, and code from drifting.

## Record the decision
Log in the decision file: date, price, model, floor and ceiling numbers, assumptions (conversion, churn, usage), review date, and what result would change it. Review at 90 days.

## Anti-patterns
- Pricing from competitors alone, with no cost data.
- Lifetime deals with unbounded ongoing cost.
- Free tier that costs more than it converts.
- Hiding the price, renewal terms, or cancellation.

## Checklist
- [ ] Unit cost computed incl. fees, platform cut, LLM
- [ ] Floor and ceiling written down
- [ ] 3 or fewer tiers, limits tied to value
- [ ] Trial and refund policy defined and legally checked
- [ ] No manipulative patterns
- [ ] Plans in structured data; decision logged with review date
