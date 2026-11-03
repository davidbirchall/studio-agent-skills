---
name: game-store-release
description: Store distribution preparation for Unity (C#) games across PC, console and mobile stores in a platform-neutral way - store requirements checklist (build format, age rating, privacy policy, store page assets, trailer and screenshot specs), build pipeline to uploadable artifacts, versioning and build numbers, achievements, cloud saves and entitlements behind interfaces, store SDK isolation, crash and log reporting, EULA and third-party notices from the licence register, pre-submission test matrix, staged rollout and beta branches, patch and hotfix paths, post-release metrics and review monitoring as data, and refund and delisting awareness. Load when preparing a game for a store submission, integrating store services, or planning release and post-release operations.
---

# Game store release

Store rules change; verify every store-specific claim against current store documentation. Unity build mechanics, signing, and CI are in `unity-build-release`. Localised store text: `game-localisation`. Cloud saves: `save-load-systems`. Performance gates: `game-performance`.

## Principles
- Keep store knowledge as data (a checklist file per store) and code behind interfaces. The game must build and run with no store SDK present.
- The human owner makes account, legal, and pricing decisions; you prepare artifacts and checklists.

## Requirements checklist (one file per store, verify each)
- Account, developer verification, payment and tax setup.
- Build format and limits: package type, architecture, maximum size, signing or certificate needs.
- Age rating questionnaire or certificate; content descriptors; regional requirements.
- Privacy policy URL, data collection declarations, children's data rules, consent flows.
- Store page assets with exact pixel sizes, formats, and counts: capsule or icon images, hero art, screenshots, trailer, description, tags, supported languages.
- Technical requirements: input, controller support, accessibility, suspend and resume, save handling, network behaviour, platform naming and button glyph rules.
- Record each item as `{ id, source_url, status, owner, deadline }`; track as data, not memory.

## Assets as data
```csharp
[Serializable] public sealed class StoreAsset { public string id; public int width, height; public string format; public string path; public bool approved; }
```
- Generate screenshots from deterministic scenes or captured builds at required sizes. Avoid UI mock-ups that misrepresent the game; stores reject this.

## Build pipeline to artifacts
- CI builds each target from a clean checkout in a release configuration, produces the exact store package, and writes a manifest (version, commit, build number, hashes). See `unity-build-release`.
- Automate upload where the store tool supports it; keep credentials in CI secrets, never in the repo (see `secret-handling`).

## Versioning
- Separate display version (`1.2.0`) from monotonically increasing build number. Stores reject repeated or lower build numbers (verify per store).
- Derive numbers in CI from tags and run counters; stamp them into the build and show in a debug or about screen.

## Integration points behind interfaces
```csharp
public interface IAchievements { void Unlock(string id); void SetProgress(string id, float pct); }
public interface IEntitlements { bool Owns(string productId); event Action Changed; }
public interface ICloudSave { Task<bool> PushAsync(byte[] data); Task<byte[]> PullAsync(); }
```
- Achievements: define game-side ids once, map to store ids in data. Queue unlocks while offline; make them idempotent.
- Entitlements and DLC: query on launch and resume; handle revoked, refunded, and offline states without destroying saves.
- Cloud saves: reuse the versioned save format and conflict handling in `save-load-systems`.
- Provide a null implementation for editor and unsupported stores so gameplay code never branches on store.

## SDK isolation
- Each store SDK lives in its own assembly definition with a define symbol and a platform filter; only a composition root references it (see `unity-architecture`, `unity-project-patterns`).
- Verify SDK licence, Unity version support, and IL2CPP/stripping needs. Add `link.xml` entries as required.

## Crash and log reporting
- Integrate a crash reporter (Unity's service or a third party; verify) with symbols uploaded per build. Include version, build number, platform, store, and scene in reports.
- Disclose collection in the privacy policy and honour consent. Never log personal data or secrets.

## Legal
- EULA and privacy policy: owner-supplied text; the game shows them where stores or law require and records acceptance.
- Generate third-party notices from the project's licence register (fonts, audio, packages, SDKs); fail the release if an asset has no licence entry. Ship the notices in-game and with the store page where required.

## Pre-submission test matrix
- Clean install, update from previous version, uninstall and reinstall.
- Each target OS version and lowest-spec device; each supported input and resolution.
- Offline start, network loss, store sign-out, suspend and resume, low storage.
- Save migration from prior public builds; cloud save conflict.
- Achievements, entitlements, and purchases against store sandbox or test accounts.

## Rollout
- Use beta branches, test tracks, or staged percentages where stores offer them (verify); release to a small group first.
- Define rollback: which prior build to re-promote and how saves behave if the player downgrades (newer save versions must fail safely).

## Patch and hotfix
- Maintain a release branch per shipped version; hotfix from it, bump the build number, run the reduced test matrix, and merge back.
- Prefer small patches; keep patch size down with stable asset bundling and content hashes (see `unity-asset-management`).

## Post-release monitoring (as data)
- Track crash-free rate, session length, funnel and retention (privacy-compliant analytics), wishlist or install counts, and review score and text.
- Ingest store review and report exports into a simple file or table, tag by theme (bug, performance, price, content), and summarise for the owner. Do not auto-respond publicly.

## Refunds and delisting
- Know store refund windows and playtime rules (verify); a high refund rate often signals performance, crash, or expectation problems; review the telemetry.
- Plan for delisting or end of support: offline-capable play and entitlement behaviour.

## Anti-patterns
- Store SDK calls scattered through gameplay.
- Submitting a development build or an unarchived build.
- Untracked licences and missing notices.
- Shipping without testing the update path from the previous build.

## Checklist
- [ ] Per-store requirements file complete and sources linked
- [ ] Assets at exact sizes; text localised and truthful
- [ ] Artifact built by CI with manifest, symbols archived, tagged
- [ ] Store services behind interfaces with null implementations
- [ ] Notices generated from licence register
- [ ] Test matrix passed; rollback and hotfix path defined
