---
name: camera-systems
description: Camera engineering in Unity with Cinemachine - Cinemachine 2 vs 3 differences, virtual cameras or CinemachineCamera, brain, priority-based switching, follow and aim behaviours, blends, impulse and screen shake, confiner and collision avoidance, third-person orbital, first person, top-down and 2D pixel perfect cameras, Timeline and cutscene cameras, camera state tied to game state, camera-relative input, split-screen, FOV effects, motion-sickness accessibility options, update method and jitter, performance, and debugging. Load when setting up or debugging cameras, shake, blends, camera jitter, or player view options.
---

# Camera systems

Cinemachine is the default. Cinemachine 2.x (`CinemachineVirtualCamera`, `CinemachineBrain`) and Cinemachine 3.x (`CinemachineCamera`, components such as Position Composer, Orbital Follow) differ materially in class names, components, namespaces (`Cinemachine` vs `Unity.Cinemachine`), and upgrade tooling. Verify the package name, version, and every API or menu name against the installed package before copying code. Movement is in `character-controller-systems`; flow in `game-state-management`; URP setup in `game-performance` and `unity-project-patterns`.

## Architecture
- One real `Camera` with a Cinemachine Brain; many virtual cameras describe shots. Gameplay code changes which virtual camera is live, never the main camera transform.
- Virtual cameras hold position and aim behaviour; the brain blends and applies them.
- Keep camera setup in prefabs: a rig prefab per mode (gameplay, aim, cutscene) so shots are reusable.

## Switching
- Switch by priority: raising a camera's priority above the others makes it live. Establish a priority convention (gameplay 10, aim 20, cutscene 30) and document it.
- Enable and disable virtual cameras or change priority from state Enter/Exit. Do not poll in `Update`.
- Return to the previous camera on exit by restoring priority, not by guessing.
- Avoid equal priorities; the winner is then implementation-dependent.

## Follow and aim
- Set follow and look-at targets to a dedicated child transform (a head or camera-root target), not the raw root, to avoid bobbing and animation noise.
- Use damping for smooth follow, dead zones and soft zones for framing in 2D and action cameras. Overdamping causes lag; keep values as tuning.
- Targets move in the same update phase the brain samples; see jitter below.

## Blends
- Configure default blend on the brain and custom blends between specific cameras. Cuts for hard changes, ease-in-out for most.
- Do not change the target camera during a blend unless intended; verify how the installed version handles interrupted blends.
- Cutscene and dialogue shots set explicit blend times; gameplay-to-gameplay blends stay short.

## Impulse and shake
- Use the Cinemachine impulse system: an impulse source emits, an impulse listener on the camera reacts. Verify class names per version.
- Scale shake by distance and intensity, cap simultaneous shakes, and route through a single `CameraShake.Request(intensity)` API.
- Shake must respect the accessibility setting (see below).

## Constraints
- Use a confiner (2D polygon or 3D volume) to keep the view in bounds. Recalculate or invalidate the confiner cache when bounds change at runtime; verify the method name.
- Use collision avoidance (a Deoccluder or Collider extension, name varies by version) for third person so geometry does not block the view. Use a camera collision layer.
- Test confiners with the extremes of camera size and FOV.

## Camera modes
- Third person: orbital follow or FreeLook rig, look input mapped through `input-systems` with per-scheme sensitivity, pitch clamped, optional auto-recentre.
- First person: parent or track the head transform, apply look to body yaw and camera pitch, hide the body or use a separate arms layer, keep near clip small.
- Top-down and 2D: orthographic or fixed-angle cameras; framing via dead zones and look-ahead. For pixel art, use the Pixel Perfect extension or component per render pipeline; verify package (2D Pixel Perfect) and URP compatibility.
- Cutscenes: use Timeline with a Cinemachine track to control which camera is live; verify the track and shot clip names. Return control to gameplay camera explicitly.

## Camera and game state
- The game state owns camera mode: entering Playing activates the gameplay rig, Paused leaves it, Cutscene activates the cutscene rig and disables look input.
- Subscribe to `StateChanged` in one `CameraDirector`; no other script flips cameras.
- Brain update uses scaled time by default; check the ignore-time-scale option in the installed version if you need cameras while paused.

## Camera-relative input
- Read the camera's yaw (`Camera.main.transform` cached, not per-frame lookup) and project forward and right onto the ground plane. Use the live brain output camera, not a virtual camera transform.
- During blends, camera-relative direction can swing; for sensitive actions consider holding the last direction until the blend finishes.

## Split-screen
- One `Camera` per player with separate viewport rects, each with its own Brain. Use per-player Cinemachine channels or layers so virtual cameras do not cross; verify channel setup in the installed version.
- Pair with `PlayerInputManager` split-screen settings (`input-systems`) and per-camera audio listener handling.

## FOV and effects
- Change FOV through the virtual camera lens, not the real camera, or the brain will overwrite it.
- Smooth FOV changes for sprint or aim. Keep range small.
- Post-processing and speed lines are URP volume concerns; keep them optional.

## Accessibility
- Provide toggles or sliders for screen shake, head bob, camera sway, motion blur, and FOV, plus look sensitivity and invert Y.
- Defaults must be comfortable; persist the options via `save-load-systems`. Every shake and bob source reads the same settings object.

## Update method and jitter
- Jitter comes from mismatched update phases. Rule: if the target moves in `Update`, use Smart or Late update; if the target is a Rigidbody moved in `FixedUpdate`, enable interpolation and use Smart or Fixed update, per the brain and vcam options. Verify option names.
- Do not move cameras manually in `Update` while Cinemachine is active.
- Do not parent the camera to a physics body.

## Performance
- Limit active virtual cameras; disable inactive rigs. Avoid per-frame `Camera.main` lookups. Collision avoidance raycasts per frame are the main cost; use a narrow layer mask and a small sample count. Profile with `game-profiling`.

## Debugging
- Use the Cinemachine debug overlays and gizmos (guides, bounds, targets) in the Game and Scene views; verify toggles for the installed version.
- Log the live camera name on switch (editor builds only) to diagnose priority conflicts.

## Anti-patterns
- Scripts setting `Camera.main.transform` while a Brain is active.
- Mixed Cinemachine 2 and 3 snippets in one project.
- Shake with no accessibility toggle.
- Cameras switched from many scripts.
