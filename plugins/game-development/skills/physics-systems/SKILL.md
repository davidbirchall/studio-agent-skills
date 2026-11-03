---
name: physics-systems
description: Unity physics engineering for 3D (PhysX) and 2D (Box2D) - FixedUpdate rules, Rigidbody movement (forces, velocity, MovePosition), interpolation and collision detection modes, collider choice, trigger versus collision callbacks, layers and the collision matrix, raycasts and overlap queries with non-allocating variants, materials, joints, timestep settings, determinism limits, transform sync cost, ragdolls, projectiles and tunnelling, debugging, and performance. Load when implementing or debugging physics, collisions, queries, projectiles, or physics cost.
---

# Physics systems

Controller design belongs to `character-controller-systems`; this skill covers the physics engine itself. Physics settings, API names, and 2D versus 3D differences (including Unity 6 versus 2022 LTS naming such as velocity properties) must be verified against the installed Unity version.

## Update loop
- Physics runs on the fixed timestep. Apply forces, set velocity, and read physics state in `FixedUpdate`; read input in `Update` and cache it for the next fixed step.
- Never drive a Rigidbody through `transform.position`; it bypasses the solver and causes jitter and missed collisions.
- Enable Rigidbody interpolation on objects that are rendered or followed by the camera, so motion is smooth when the fixed rate differs from the frame rate.
- 2D and 3D are separate engines: use `Rigidbody2D`, `Collider2D`, and `Physics2D` consistently; do not mix.

## Rigidbody
- Forces and impulses (`AddForce`) for physical, mass-dependent behaviour (pushes, explosions, vehicles).
- Setting velocity directly for responsive, arcade-style control; accept that it overrides the solver's result for that frame.
- `MovePosition`/`MoveRotation` for kinematic bodies that must push dynamic ones.
- Kinematic bodies are moved by code and are not affected by forces; use them for platforms and animated bodies that interact with dynamic bodies.
- Set mass to sensible ratios; extreme mass differences make joints and stacking unstable.
- Put sleeping to work: bodies at rest cost little. Do not wake them needlessly.

```csharp
private void FixedUpdate()
{
    var target = body.position + moveDirection * (speed * Time.fixedDeltaTime);
    body.MovePosition(target);
}
```

## Colliders
- Prefer primitives (box, sphere, capsule) and compound colliders from child objects over mesh colliders. Use convex mesh colliders only when needed, and keep them low-poly.
- Non-convex mesh colliders are only valid for static geometry in 3D.
- Never scale colliders non-uniformly on rotated parents; keep scale at 1 on physics objects where possible and resize the collider instead.
- Do not move static colliders (no Rigidbody) at runtime; it rebuilds acceleration structures. Add a kinematic Rigidbody to anything that moves.

## Triggers and collisions
- A collision callback (`OnCollisionEnter`) needs colliders that are not triggers and at least one Rigidbody involved. A trigger callback (`OnTriggerEnter`) needs a trigger collider and at least one Rigidbody involved. Verify the exact combination matrix in the manual for your version.
- Do heavy work outside callbacks: record the event, handle it in a controlled place.
- Use `CompareTag`, layer checks, or a cached component lookup, not string compares or repeated `GetComponent`.

## Layers and queries
- Design layers up front and configure the collision matrix so unrelated pairs never generate contacts.
- Always pass a layer mask to raycasts and overlaps; decide whether triggers are hit with `QueryTriggerInteraction`.
- Use the non-allocating variants (`RaycastNonAlloc`, `OverlapSphereNonAlloc`, or newer buffer-based overloads; verify names and deprecation status for your version) with reusable buffers sized to a known maximum.
- Prefer spherecast or capsulecast over thin raycasts for gameplay that must be forgiving.
- Budget queries per frame (`game-ai` perception, `game-performance`).

```csharp
private static readonly Collider[] Hits = new Collider[16];

private int FindTargets(Vector3 centre, float radius, int mask) =>
    Physics.OverlapSphereNonAlloc(centre, radius, Hits, mask, QueryTriggerInteraction.Ignore);
```

## Materials, joints, ragdolls
- Use physics materials for friction and bounce; share assets rather than per-object copies. Check how friction and bounciness are combined.
- Joints are expensive and can explode under extreme forces; set break limits, avoid chains of heavy bodies, and tune solver iterations only when needed.
- Ragdolls: swap an animated character for a ragdoll on death, keep few rigidbodies, disable them while alive, and cap the number alive simultaneously.

## Projectiles
- Fast bodies tunnel through thin colliders. Use continuous collision detection on the fast body (verify mode names), or do a raycast or spherecast from last to current position each fixed step.
- For hitscan, raycast instantly; for bullets with travel time, sweep each step.
- Pool projectiles (`game-performance`) and reset velocity and state on reuse.

## Settings and determinism
- Fixed timestep: default is a compromise. Lower it for precision, raise for cost; cap Maximum Allowed Timestep to avoid the spiral of death.
- Physics is not guaranteed deterministic across machines or platforms, nor with differing frame times. Never rely on it for lockstep or replay logic; use authored state instead.
- Simulation mode (for example script-driven stepping) allows custom stepping and separate Physics Scenes for prediction or isolation; verify the API for your version.
- Transform changes sync to physics automatically; frequent writes plus queries within the same frame cause repeated sync cost. Batch transform edits, and consider the auto-sync setting and `Physics.SyncTransforms` only after profiling; verify names.
- Jobs and Burst access to physics queries (batched raycasts) exist for heavy workloads; verify the API for your version.

## Debugging
- Use the Physics Debugger window to visualise colliders and contacts; draw gizmos for query ranges and results.
- Common bugs: moving through `transform`, no Rigidbody on a trigger pair, wrong layer or matrix, scale on colliders, jitter from missing interpolation, input read in `FixedUpdate` and missed, mesh colliders on moving bodies, thin colliders with fast bodies.

## Performance
- Count active Rigidbodies, contacts, and queries; keep the scene in the Physics section of the Profiler (`game-profiling`).
- Reduce layers that collide, simplify colliders, put distant bodies to sleep, and lower the physics rate for non-critical simulation (`game-performance`).
