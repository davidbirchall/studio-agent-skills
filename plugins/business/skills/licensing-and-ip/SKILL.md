---
name: licensing-and-ip
description: Licensing and intellectual property for a solo maker of software and games - choosing a licence for your own code (permissive, copyleft, source-available), dependency licence compatibility and auditing with licence scans and SBOMs, copyleft traps for distributed apps and games, asset licensing for fonts, art, audio and 3D models, attribution records, AI-generated content and training-data provenance, trademarks and names, third-party and contributor code provenance, an asset-and-licence register template, and store or platform terms. Load when picking a licence, adding a dependency or asset, shipping a build, using AI-generated content, or naming a product.
---

# Licensing and IP

Not legal advice. Flag to a qualified professional: choosing a licence for a commercial product, any copyleft dependency in a distributed build, trademark filings, disputes, and anything marked "verify for your jurisdiction". Licence text and store terms change; re-read the current text, do not rely on memory.

## Default position
- Unlicensed code is "all rights reserved". Publishing without a licence grants others nothing.
- Closed product: keep the code proprietary and ship an end-user licence plus a third-party notices file.
- Open code you want used freely: permissive (MIT, BSD, Apache-2.0). Apache-2.0 adds a patent grant.
- Open code you want improvements returned: copyleft (GPL, AGPL for network services). AGPL deters commercial reuse; choose it deliberately.
- Source-available (BUSL, FSL, custom): code is visible but not free to use commercially. These are not open source; label them accurately.
- Decide once per repo, put a `LICENSE` file at root, and an SPDX identifier in package metadata.

## Dependency audit
- Run a licence scan for your ecosystem on every release and after every added dependency. Record output as an SBOM (SPDX or CycloneDX) per release.
- Include transitive dependencies; most surprises are 2-3 levels deep.
- Unknown, missing, or "custom" licence = do not ship until resolved.
- Block list by default for closed distribution: GPL, AGPL, SSPL, and "non-commercial" or "no-derivatives" terms. LGPL is usually fine if dynamically linked and replaceable; verify.
- Copyleft triggers on distribution. Shipping an app, a game binary, an installer, or a mobile build is distribution. A server-side-only use is not, except AGPL and similar network clauses.
- Static linking, bundling, and engine plugins count. A GPL plugin inside a game build can pull the whole build under GPL.
- Keep a notices file listing each dependency, version, licence, and copyright line; ship it in the product.

## Asset licensing (fonts, art, audio, 3D, templates)
- Every asset needs a recorded source URL, licence, and proof of purchase or download date.
- Common licence types: CC0 (no attribution), CC-BY (attribution), CC-BY-SA (share-alike, can infect derived art), CC-NC (no commercial use), editorial-only, royalty-free (still restricted by the vendor EULA).
- Traps: asset packs licensed for use but not for redistribution of the raw files (an open repo or a modding export leaks them); fonts licensed per-seat, per-app, or desktop-only versus embedding/web; "free for personal use"; sample packs with uncleared voices.
- Raw asset files in a public repo count as redistribution. Keep paid assets in a private location or exclude from public builds.
- Check whether the licence is transferable if you sell the product or hand it over.

## AI-generated content
- Record per asset: tool, model/version, date, prompt or workflow, and the tool's terms at that date.
- Copyright protection for purely AI-generated output is uncertain or absent in many places; verify for your jurisdiction. Do not assume exclusive ownership.
- Training-data provenance of the model is often unclear and under litigation. Prefer tools with stated commercial-use terms and indemnity; avoid prompting with named living artists or protected characters.
- Store platforms may require AI-use disclosure; check each platform's current rules before submission.
- Treat AI code suggestions as untrusted for licence purposes: do not paste long verbatim blocks you cannot trace.

## Names and trademarks
- Before naming a product: search the registers for your target jurisdictions, app stores, domains, and package registries. Search the class of goods (software, games).
- Avoid names that contain or sound like an existing mark in the same class. Do not use a third party's mark in your name, icon, or store keywords.
- Registration is a professional decision; verify for your jurisdiction.

## Third-party and contributor code
- Copying a snippet from a forum, gist, or tutorial inherits its licence (often CC-BY-SA for Q&A sites). Record origin or rewrite it.
- If you accept outside contributions, require a DCO sign-off or a contributor licence agreement before merge; otherwise you cannot relicense later.
- Contractors and collaborators: get a written assignment or licence for their work before using it.

## Store and platform terms
- Each store and engine has its own terms: revenue share, content rules, redistribution of SDK files, branding use, and engine royalty or runtime-fee thresholds. Re-read when you cross a revenue threshold or change engine version.
- Platform SDKs and console tools are usually under NDA; do not commit them to a public repo.

## Asset-and-licence register (keep in repo, private if needed)
| id | item | type | source | licence | attribution text | redistributable | proof | used in | reviewed |
|----|------|------|--------|---------|------------------|-----------------|-------|---------|----------|
| a-001 | UI font | font | vendor url | EULA, app embed ok | none | no | receipt id | menu | 2026-01-10 |

## Anti-patterns
- Shipping with an unscanned lockfile.
- "Free" assets with no recorded source.
- Assuming MIT everywhere because the top-level package says so.
- Choosing a licence by habit rather than by who may use the code commercially.

## Checklist
- [ ] `LICENSE` and SPDX id set
- [ ] Licence scan clean or exceptions documented
- [ ] SBOM and notices file generated for this release
- [ ] Register covers every asset, including AI-generated
- [ ] Name searched across registers and stores
- [ ] Store terms re-read; professional review flagged where needed
