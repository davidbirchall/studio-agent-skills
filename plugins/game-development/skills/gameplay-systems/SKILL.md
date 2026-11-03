---
name: gameplay-systems
description: Gameplay feature engineering in Unity and C# - composable component-based entities, ability and effect pipelines, stats with base/add/multiply modifiers, health and damage pipeline with resistances and death handling, interaction systems with raycast or overlap, inventory and item data as ScriptableObject definitions vs runtime instances, status effects with central ticking, event decoupling between systems, spawning and pooling, objectives and quest state, cooldowns, exposed tuning values, fixed timestep determinism, and testing gameplay rules as plain C#. Load when building or reviewing abilities, combat, stats, inventory, interactions, quests, or spawners.
---

# Gameplay systems

Version-specific APIs (UnityEngine.Pool, Awaitable, Unity 6 vs 2022 LTS) must be verified against the installed Unity version. Architecture layering is in `unity-architecture`; save data in `save-load-systems`; C# style in `csharp-conventions`.

## Entities and composition
- Build entities from small single-purpose components (`Health`, `Stats`, `Interactable`, `AbilityUser`) on a GameObject. Prefer composition over deep inheritance trees.
- Put rules in plain C# classes; MonoBehaviours are thin adapters that wire scene objects, forward Unity callbacks, and present results.
- Components talk through interfaces (`IDamageable`, `IInteractable`), resolved with `TryGetComponent`. Cache the result; never `GetComponent` per frame.
- One system owns one piece of state. Others request changes through its API or events.

## Stats and modifiers
- Separate base value from modifiers. Compute final value on demand or on change, never by mutating the base.
- Fixed ordering: base, then flat adds, then percent-add sum, then multipliers. Document the order and keep it in one function.
```csharp
public float Final(float baseValue, IReadOnlyList<Modifier> mods) {
    float flat = 0, pct = 0, mult = 1;
    foreach (var m in mods) {
        switch (m.Kind) {
            case ModKind.Add: flat += m.Value; break;
            case ModKind.PercentAdd: pct += m.Value; break;
            case ModKind.Multiply: mult *= m.Value; break;
        }
    }
    return (baseValue + flat) * (1f + pct) * mult;
}
```
- Modifiers carry a source reference so they are removed by source (item unequipped, effect expired), not by value.
- Cache the final value and invalidate on modifier change. Raise a change event only when the value changes.

## Health and damage
- Damage is data: a `DamageEvent` struct with amount, type, source, target, and flags (crit, ignores armor). Do not call `TakeDamage(float)` from everywhere.
- Pipeline in fixed order: validate target alive, apply source modifiers, apply resistances by type, clamp, apply to health, raise events, then check death.
- Death is handled once. Guard with an `IsDead` flag set in the same method that detects zero health, so simultaneous hits cannot fire it twice.
- Health exposes `Changed(current, max)` and `Died(DamageEvent)` events. UI, audio, VFX, and score subscribe; health knows none of them.
- Healing, shields, and invulnerability go through the same pipeline, not side paths.

## Abilities and effects
- Model an ability as data (`AbilityDefinition` ScriptableObject) plus a runtime instance holding cooldown and state.
- Execution pipeline: can-use check (resources, cooldown, state), pay cost, resolve targets, apply effects, start cooldown. Each step is a small replaceable unit.
- Effects are composable data objects (`DamageEffect`, `ApplyStatusEffect`, `SpawnEffect`) so new abilities are assets, not new classes.
- Targeting is separated from effect application (self, single target, cone, area via `Physics.OverlapSphereNonAlloc`; verify non-alloc names for the installed version).

## Status effects and timers
- No per-effect `Update`. A central ticker owns all active effects and advances them once per frame or fixed step.
- Effect instance holds remaining time, stacks, and source. Stacking policy (refresh, extend, stack, ignore) is declared in the definition.
- Remove modifiers and visuals in one `OnRemoved` path, including when the owner dies or is destroyed.
- Cooldowns store an end timestamp (`Time.time + duration`) or remaining time ticked centrally. Use unscaled time only for UI-owned timers.

## Interaction
- Interactables implement `IInteractable` with `CanInteract(actor)`, `Prompt`, and `Interact(actor)`.
- Detect candidates with a raycast from the camera or an overlap around the actor on a dedicated layer. Pick the best by distance and angle, once per frame or at a lower rate.
- Show the prompt only for the current best candidate; clear it when the candidate changes or the actor is disabled.
- The interaction trigger comes from the input layer (`input-systems`); the interaction system never reads devices.

## Items and inventory
- Item definitions are ScriptableObjects: immutable shared data (id, name, stack size, stats). Never mutate them at runtime.
- Runtime item instances hold mutable data (count, durability, rolled modifiers) and reference the definition by stable id for saving.
- Inventory is a plain C# class with add, remove, and query operations that return success results and raise `Changed`. UI binds to events.
- Validate every operation (capacity, stack limits) inside the inventory, not in UI code.

## Objectives and quests
- Objective state is plain data: id, progress, status. Progress advances from gameplay events (`EnemyKilled`, `ItemCollected`), not polling.
- Quest definitions are assets; quest runtime state is serialisable and saved via `save-load-systems`.
- Completion is evaluated in one place and raises a single event.

## Events and decoupling
- Use C# events, or a typed event channel (ScriptableObject or plain bus) for cross-system messages. Pick one convention per project.
- Subscribe in `OnEnable`, unsubscribe in `OnDisable`. Leaked subscriptions to destroyed objects are the common bug.
- Events describe what happened (`EnemyDied`), not commands. Keep payloads small structs.

## Spawning and pooling
- Pool frequently spawned objects (projectiles, VFX, enemies). Verify `UnityEngine.Pool.ObjectPool<T>` availability in the installed version.
- A pooled object resets all state on get (health, timers, velocity, subscriptions) and releases cleanly on return. Reset in one `ResetState` method.
- Do not `Destroy` pooled objects. Do not `Instantiate` in hot paths.

## Tuning and determinism
- Expose tuning values (damage, cooldown, speed, ranges) as ScriptableObject fields or serialized fields, not constants in code.
- Run simulation that must be reproducible in `FixedUpdate` or a manual fixed step; do not scale gameplay by variable `Time.deltaTime` where outcomes differ per frame rate.
- Use a seeded random source owned by the system, not global `UnityEngine.Random`, when replays or tests need repeatability.

## Testing
- Test damage pipeline, modifier ordering, cooldowns, inventory, and quest logic as plain C# with NUnit (Edit Mode tests). Inject time and random through interfaces.
- Test one rule per case: stacking policy, double-death guard, resistance ordering, capacity overflow.
- Use Play Mode tests only for wiring (events reaching UI, pooling reset), not for rules.

## Anti-patterns
- Rules inside MonoBehaviour callbacks that cannot run without a scene.
- Singletons used to reach other systems instead of injected references or events.
- Effects that each run their own coroutine or `Update`.
- Mutating a ScriptableObject asset at runtime to store state.
