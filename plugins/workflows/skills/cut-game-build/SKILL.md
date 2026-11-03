---
name: cut-game-build
description: Recipe for producing a Unity release candidate and shipping it - scope freeze, content and asset audit, build configuration and automation, test pass, profiling on target hardware, save compatibility check, release checklist, versioning and changelog, provider-neutral store or distribution upload, post-release monitoring with a hotfix path, and retrospective. Names the skills to apply at each step, the exit check, and what to hand forward. Load when preparing a Unity build for testers, a demo, or a public release.
---

# Cut game build

An ordered recipe, not a reference. Each named skill is optional: if its plugin is not installed, do the step anyway using general good practice. Apply the skills; do not restate them here.

## When to use / when not to
- Use when a build leaves your machine: a playtest, a festival demo, a store submission, or an update.
- Not for daily development builds or for adding features (use build-game-feature).

## Steps
1. Freeze scope.
   - Goal: stop the target moving.
   - Apply: scope, milestones, release (production plugin).
   - Exit: a written list of what is in; only blocker fixes allowed after this point. Hand on: the frozen list and a cut-off date.
2. Content and asset audit.
   - Goal: nothing unfinished, oversized, or unlicensed.
   - Apply: unity-asset-management (game-development plugin), asset-optimisation (creative-technology plugin).
   - Exit: placeholders removed, unused assets pruned, texture and audio sizes in budget, licences recorded. Hand on: audit notes.
3. Build configuration and automation.
   - Goal: a repeatable build, not a hand-made one.
   - Apply: unity-build-release (game-development plugin), ci-cd-workflows and environment-configuration (platform-engineering plugin), git-workflows.
   - Exit: release branch or tag, scripted build from a clean checkout, debug tools and cheats disabled, symbols archived. Hand on: the candidate build id.
4. Test pass.
   - Goal: confirm the candidate, not a nearby build.
   - Apply: unity-testing (game-development plugin), software-testing-strategy (shared plugin).
   - Exit: automated tests green on the candidate; a manual run through the critical path (first launch, a full session, quit and resume). Hand on: defect list ranked by severity.
5. Profile on target hardware.
   - Goal: real performance, not editor performance.
   - Apply: game-profiling and game-performance (game-development plugin).
   - Exit: frame time, memory, load time, and build size measured on the lowest supported device; against stated targets.
6. Save compatibility.
   - Goal: never lose player progress.
   - Apply: save-load-systems (game-development plugin), data-integrity (data plugin) for the thinking on migration.
   - Exit: saves from the previous public version, and corrupted or empty saves, load or fail gracefully.
7. Release checklist and go/no-go.
   - Goal: one final gate.
   - Apply: release and release-management (production and platform-engineering plugins); dependency-management (shared plugin) for third-party licences and versions.
   - Exit: blockers zero, known issues listed, checklist ticked in a file, go/no-go decision recorded (the user makes the call).
8. Version and changelog.
   - Goal: players and future sessions know what changed.
   - Apply: technical-documentation (shared plugin), release-management.
   - Exit: version number follows the agreed scheme, tag created, changelog written in player terms.
9. Upload and distribute.
   - Goal: get the build to players through whichever provider is used.
   - Apply: deployment-patterns (platform-engineering plugin).
   - Exit: upload the exact tagged artefact, set the release to private or staged first, verify by downloading and launching it as a player would, then make it public. Keep the previous build available.
10. Monitor and hotfix path.
   - Goal: react quickly after release.
   - Apply: monitoring-observability, incident-response (shared plugin), debugging.
   - Exit: crash and feedback channels watched for a set window; hotfix branch process and rollback to the previous build written down before launch.
11. Retrospective.
   - Goal: make the next cut cheaper.
   - Apply: retrospective (production plugin).
   - Exit: two or three process changes recorded, manual steps queued for automation.

## Skip rules
- Internal playtest build: skip steps 7 through 9 beyond a tag and a short note; keep 3 to 6.
- No prior public version: skip the old-save portion of step 6, keep corrupted-save handling.
- Solo dev: the checklist can be a single file reused each time.
- Never skip the clean-checkout build or the launch check on real hardware.

## Common failure modes
- Features sneaking in after freeze.
- Release built from a dirty working copy or the wrong branch.
- Debug cheats or test scenes shipped.
- Performance verified only on a development machine.
- Updated build breaks existing saves.
- No tested rollback, so a bad release stays live.
- Uploading a different artefact from the one tested.

## Checklist
- [ ] Scope list frozen.
- [ ] Asset audit done, licences recorded.
- [ ] Scripted build from clean checkout; symbols saved.
- [ ] Tests and manual critical path pass on the candidate.
- [ ] Target hardware profile within budget.
- [ ] Old and corrupted saves handled.
- [ ] Go/no-go, version, tag, changelog complete.
- [ ] Staged upload verified; previous build kept.
- [ ] Monitoring and hotfix path ready; retro scheduled.
