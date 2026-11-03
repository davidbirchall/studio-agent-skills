---
name: character-controller-systems
description: Character movement engineering in Unity and C# - choosing CharacterController vs Rigidbody kinematic or dynamic vs custom kinematic controller, Update vs FixedUpdate placement, input to intent to motion separation, ground detection with raycast spherecast or overlap, slopes and steps, gravity and variable-height jump with coyote time and buffering, acceleration curves, moving platforms, collision layers, Animator integration and root motion tradeoffs, locomotion state machine, camera-relative movement, 2D vs 3D differences, tuning exposure, gizmo debugging, and testing. Load when building or debugging player or NPC movement, jumping, grounding, slopes, platforms, or animation sync.
---

# Character controller systems

Verify API details (`Rigidbody.linearVelocity` in Unity 6 vs `velocity` in 2022 LTS, `CharacterController` members) against the installed Unity version. Input in `input-systems`, camera in `camera-systems`, physics rules in `physics-systems`.

## Choosing a controller
- `CharacterController`: simple capsule, built-in slope limit and step offset, no physics forces. Good for typical 3D player and NPC movement. You own gravity and pushing rigidbodies.
- Dynamic `Rigidbody`: reacts to forces and collisions naturally; harder to make tight and predictable. Good for vehicles, ragdoll-like or physics-driven characters.
- Kinematic `Rigidbody` or custom kinematic controller (cast-based collide-and-slide): full control and precision; more code. Choose when `CharacterController` limits (moving platforms, odd shapes, 2D precision) bite.
- Decide early; switching late changes feel, collision, and animation. Document the choice.

## Separation of concerns
- Three layers: input produces intent (move vector, jump pressed), the controller turns intent into desired velocity, the motor applies motion and resolves collisions.
- The controller reads an `IMovementIntent`, not devices, so AI, replay, and tests drive the same code.
```csharp
public struct MoveIntent { public Vector2 Move; public bool JumpPressed; public bool JumpHeld; }
```
- Presentation (animation, VFX, sound) observes controller state and never changes motion.

## Update loop
- `CharacterController.Move`: call once per frame in `Update`, with `Time.deltaTime`. Call it once per frame; multiple calls cause inconsistent grounded state.
- Rigidbody motion: apply in `FixedUpdate`; read input in `Update` and store it. Enable interpolation on the rigidbody for smooth rendering; verify setting name.
- Do not move a Rigidbody via `transform.position` in Update.
- Camera follows after movement (`camera-systems`).

## Ground detection
- Ground check from a spherecast or short overlap at the feet on a ground layer mask. A single centre raycast fails on edges.
- Store `IsGrounded`, ground normal, and ground collider. `CharacterController.isGrounded` is only valid after `Move` and flickers on slopes; verify behaviour and prefer an explicit check when precision matters.
- Slopes: project movement onto the ground plane (`Vector3.ProjectOnPlane`). Limit walkable angle by comparing normal to up. Slide off steeper slopes.
- Steps: use `stepOffset` for `CharacterController`; for custom or Rigidbody motors, cast forward and up to step over small ledges.
- Snap to ground when walking down slopes or stairs, only when not jumping.

## Gravity and jump
- Apply gravity yourself for kinematic motion; clamp terminal velocity. Keep a small downward force when grounded so grounding stays stable.
- Variable height: apply stronger gravity or cut upward velocity when jump is released early.
- Coyote time: allow a jump for a short window after leaving ground. Jump buffering: remember a press shortly before landing. Both are timers stored as tuning values and consumed on use.
```csharp
if (grounded) _coyote = coyoteTime; else _coyote -= dt;
_buffer = intent.JumpPressed ? jumpBuffer : _buffer - dt;
if (_buffer > 0 && _coyote > 0) { _velocityY = jumpSpeed; _buffer = _coyote = 0; }
```
- Derive jump speed from desired height and gravity rather than hand-tuning both: `v = sqrt(2 * g * h)`.

## Acceleration
- Move velocity toward target with `Vector3.MoveTowards` or an acceleration value, separate rates for ground, air, and turning. Instant velocity feels stiff; unbounded smoothing feels floaty.
- Air control is its own tuning value. Apply friction only when grounded.
- Normalise diagonal input (clamp magnitude to 1), preserve analog magnitude.

## Moving platforms
- Track the ground collider and apply its frame delta (position and, if needed, rotation) to the character before own movement. Parent-based approaches distort scale; prefer delta application.
- Move platforms in the same update phase the controller expects (for Rigidbody platforms, FixedUpdate); mismatched phases cause jitter.

## Layers and collision
- Dedicated layers for player, enemies, ground, one-way platforms, and triggers; configure the collision matrix and use layer masks in casts.
- Exclude the character's own collider from casts. Use `QueryTriggerInteraction.Ignore` where triggers should not ground you.
- Avoid allocation: use non-alloc cast and overlap variants (verify names in the installed version).

## Animation
- The controller drives Animator parameters (speed, grounded, vertical velocity) once per frame; animation does not decide movement. Cache parameter hashes with `Animator.StringToHash`.
- Smooth parameters with damping to avoid blend jitter.
- Root motion gives authentic foot planting but couples motion to clips and complicates tuning, networking, and moving platforms. Use it for cinematic or melee-heavy characters; use script-driven motion for responsive platforming.

## Locomotion states
- Model Grounded, Airborne, Crouch, Sprint, Climb, Swim as states with Enter, Exit, and Tick, not nested booleans. Transitions are explicit.
- Share motor code; states choose speed, gravity, and permitted actions.

## Camera-relative movement
- Convert input to world direction using the camera's yaw projected onto the ground plane, then rotate the character toward it. Do not use the camera's pitch. Camera setup is in `camera-systems`.

## 2D vs 3D
- 2D: `Rigidbody2D`, `Collider2D`, `Physics2D` casts; `CharacterController` does not apply. Verify 2D property names (velocity naming differs by version).
- 2D platformers need tighter feel: coyote time, buffering, variable jump, and corner correction matter more.
- Do not mix 2D and 3D physics calls.

## Networking-agnostic notes
- Keep movement deterministic from state plus intent plus delta time; avoid reading global state or `Random` in the motor. This eases prediction and replay if added later.

## Tuning and debugging
- Expose speed, acceleration, jump height, gravity, coyote time, and buffer window as serialized fields or a settings asset. Tune in play mode, copy values back.
- Draw gizmos for ground checks, normals, and cast shapes with `OnDrawGizmosSelected`. Show current state and velocity in a debug overlay.

## Testing
- Test intent to velocity math, jump timers, and slope projection as plain C# in Edit Mode.
- Play Mode tests: spawn the character on a test floor, apply intent, assert grounded, jump apex, and slope behaviour within tolerance, not exact floats.

## Anti-patterns
- Reading input devices inside the motor.
- Multiple `Move` calls per frame.
- Setting `transform.position` on physics bodies.
- Ground checks on the wrong layer mask, hitting self.
