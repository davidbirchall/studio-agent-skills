---
name: animation-integration
description: Technical integration of animation in Unity - rig and skeleton conventions, humanoid versus generic rigs, import settings, clip splitting, root motion, Animator Controller structure (layers, state machines, sub-state machines, blend trees), avatar masks, Animation Rigging, retargeting, animation events and their cautions, Timeline versus Animator, hashed parameters, driving animation cleanly from code, compression, and naming. Load when importing rigged characters and clips, building Animator Controllers, wiring animation to gameplay code, or diagnosing foot sliding, popping, or event bugs.
---

# Animation Integration

Builds on `blender-workflows` (export) and `3d-asset-pipeline` (import); optimise with `asset-optimisation`. This covers technical setup, not animation craft. Import options, Animation Rigging, and Timeline features vary by Unity version; verify names and settings against the installed version.

## Rig and skeleton conventions
- One skeleton per character family; consistent bone naming, a single root bone, T-pose or A-pose reference chosen once and recorded.
- Apply scale and rotation on export (`blender-workflows`); import at unit scale to avoid scaled bones.
- Keep bone count within budget and avoid non-deforming helper bones in the exported hierarchy unless needed.
- Name consistently: `Char_Hero_Idle`, `Char_Hero_Run_Fwd`; clips carry state and direction.

## Humanoid vs Generic
- Humanoid: use for shared animation and retargeting across characters. Requires a valid avatar; check the avatar mapping and muscle limits.
- Generic: creatures, props, and anything non-bipedal; no retargeting, usually cheaper.
- Pick per character before animating; switching later invalidates clips. Verify avatar validity after every re-export.

## Import settings
- Set animation type, avatar source, and root node explicitly; do not leave defaults for key characters.
- Split clips by frame range with clear names; set loop time only for cycles and verify loop pose and loop blend match.
- Strip unused curves (scale, unneeded channels) and choose a compression level; verify visual error on feet, hands, and root.
- Reuse the same avatar across clips of one skeleton; avoid duplicate rigs per file.

## Root motion
- Decide per clip family: root motion (animation drives movement) or in-place (code drives movement), not both.
- With root motion, apply movement in `OnAnimatorMove` and keep the controller and collider consistent with it.
- Bake rotation, height, and position into pose as appropriate for loops; check foot sliding against actual speed.

## Animator Controller structure
- Layers: base locomotion, upper-body or additive layers with avatar masks, and override layers. Keep layer count small.
- State machines: group related states in sub-state machines (Locomotion, Combat); use Any State sparingly.
- Blend trees: for locomotion (speed, direction); keep thresholds matched to real movement speeds.
- Transitions: define explicit conditions and durations; avoid exit-time dependencies except for one-shots; check interruption settings.
- Share one controller across characters where possible; use Animator Override Controllers for variants.

## Driving from code
- Hash parameters once: `static readonly int SpeedHash = Animator.StringToHash("Speed");`
- Drive with a small facade (`CharacterAnimator`) that exposes intent (`SetSpeed`, `TriggerAttack`); gameplay code does not touch the Animator.
- Use damping when setting continuous floats; avoid setting parameters every frame when unchanged.
- Prefer bool and float parameters for states and triggers for one-shots; reset triggers on interrupted states.
- Do not read state by string name; use hashes or events.

## Animation events
- Use for footsteps, hit frames, and VFX or audio cues (`vfx-implementation`, `audio-integration`).
- Cautions: events fire from blended or interrupted clips, may fire twice or not at all on transition, and break on clip rename or reimport. Put handlers on the same object as the Animator, check weights if needed, and keep handlers idempotent.
- Keep event function names stable and documented; validate missing receivers in tests.

## Animation Rigging and procedural
- Use the Animation Rigging package for IK, aim, and look-at layered over clips; verify the package and constraint names for the version installed.
- Weight constraints through a controller script; disable rigs when off-screen or distant.

## Timeline vs Animator
- Timeline: cutscenes, scripted sequences, cross-object choreography.
- Animator: runtime-reactive character states.
- Do not drive the same property from both; hand over explicitly at sequence start and end.

## Retargeting and masks
- Retarget via Humanoid avatars; check proportions, hip height, and hand/foot placement after import.
- Avatar masks isolate body parts for layered motion; build named masks (UpperBody, Arms) and reuse them.

## Checklist
- Rig type and avatar validated after export.
- Clips split, named, looped correctly; compression visually checked.
- Root motion decision made per clip family.
- Controller organised; parameters hashed; facade in place.
- Events verified under blending and interruption.

## See also

Optional, if installed: character-controller-systems (the game-development plugin) for the broader discipline this skill applies. This skill stands on its own.
