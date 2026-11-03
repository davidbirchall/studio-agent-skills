---
name: build-game-feature
description: Recipe for taking a Unity game feature from concept to playable - the design question, mechanic and system design, balance placeholders, architecture fit, a vertical slice, input, camera and UI hooks, save impact, tests, profiling, playtest and iteration, and asset integration. Names the skills to apply at each step, the exit check, and what to hand forward. Load when asked to build, prototype, or add a gameplay feature in Unity and see it playable.
---

# Build game feature

An ordered recipe, not a reference. Each named skill is optional: if its plugin is not installed, do the step anyway using general good practice. Apply the skills; do not restate them here.

## When to use / when not to
- Use for a new mechanic, system, or content type that players will interact with.
- Not for bug fixes (use debugging), pure art passes, or build and release work.

## Steps
1. Frame the design question.
   - Goal: say what the feature must prove about the game.
   - Apply: game-design (game plugin), scope (production plugin).
   - Exit: one question ("is carrying a lantern tense or tedious?") and a pass/fail playtest signal. Hand on: the question.
2. Mechanic and system design.
   - Goal: rules on paper before code.
   - Apply: mechanic-design and systems-design (game plugin); progression-design or level-design if the feature affects them.
   - Exit: inputs, outputs, states, and interactions with existing systems written down. Hand on: rules sheet.
3. Balance placeholders.
   - Goal: tunable numbers, not magic numbers.
   - Apply: balance (game plugin).
   - Exit: every value listed with a rough range and a place to edit it (data asset, not code). Hand on: tuning table.
4. Architecture fit.
   - Goal: slot into the codebase without tangling it.
   - Apply: unity-architecture, unity-project-patterns, csharp-conventions, game-state-management, gameplay-systems (game-development plugin).
   - Exit: where the code lives, what owns state, what events it raises, and which assembly it joins. Hand on: component sketch.
5. Vertical slice.
   - Goal: one thin playable path, ugly but complete.
   - Apply: gameplay-systems and character-controller-systems (game-development plugin) as relevant; game-ai if enemies are involved.
   - Exit: a player can start, use, and finish the feature in a scene. Hand on: playable build or scene.
6. Input, camera, and UI hooks.
   - Goal: the feature is controllable and readable.
   - Apply: input-systems, camera-systems, ui-systems (game-development plugin).
   - Exit: rebindable input actions, camera behaves during the feature, UI shows state and feedback.
7. Save impact.
   - Goal: decide what persists.
   - Apply: save-load-systems (game-development plugin).
   - Exit: new saved fields listed with defaults for older saves; load of an old save tested.
8. Tests.
   - Goal: lock in rules that are cheap to test.
   - Apply: unity-testing (game-development plugin), software-testing-strategy (shared plugin).
   - Exit: edit-mode tests for rules and calculations, play-mode test for the main path, passing.
9. Profile.
   - Goal: catch cost early.
   - Apply: game-profiling and game-performance (game-development plugin).
   - Exit: frame time and allocations measured in the slice against a stated budget; no per-frame garbage in hot paths.
10. Playtest and iterate.
   - Goal: answer the step 1 question.
   - Apply: balance (game plugin), game-design (game plugin).
   - Exit: notes from at least a few sessions, decision to keep, change, or cut; tuning table updated. Repeat from step 3 or 5 if needed.
11. Asset integration, if needed.
   - Goal: replace placeholders once the design holds.
   - Apply: asset-optimisation, animation-integration, audio-integration, vfx-implementation (creative-technology plugin); unity-asset-management (game-development plugin).
   - Exit: final assets meet budgets and are wired through the same data, not hard-coded.

## Skip rules
- Tiny tweak to an existing mechanic: skip steps 2 and 4, keep 3, 8, and 10.
- No persistent data: skip step 7. No new assets: skip step 11.
- The rules sheet and tuning table can share one page.
- Never skip the playtest; it is the point.

## Common failure modes
- Building the full system before knowing it is fun.
- Hard-coded values that make tuning a recompile.
- Feature owns global state, so other systems break.
- New save fields with no default, corrupting old saves.
- Polishing assets before the design question is answered.
- Profiling only in the editor.

## Checklist
- [ ] Design question and pass signal written.
- [ ] Rules sheet and tuning table exist.
- [ ] Code placement and state ownership decided.
- [ ] Vertical slice playable end to end.
- [ ] Input, camera, UI hooked up.
- [ ] Old saves load.
- [ ] Tests pass; profile within budget.
- [ ] Playtest result recorded with a decision.
