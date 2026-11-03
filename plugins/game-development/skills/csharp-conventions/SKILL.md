---
name: csharp-conventions
description: Unity-flavoured C# standards - naming, serialized fields vs public fields, properties, namespaces mapped to assembly definitions, nullable reference types caveats, Unity's overloaded null on UnityEngine.Object, readonly and const, events and unsubscription, coroutines vs async/await vs Awaitable vs UniTask with cancellation, LINQ and allocation habits, strings and boxing, struct vs class, generics, enums and flags, attributes, XML docs, analyzers and .editorconfig, and logging conventions. Load when writing or reviewing Unity C# code, setting a code style, or deciding on async, event, or null-handling patterns.
---

# C# conventions for Unity

Language level, nullable support, and `Awaitable` availability depend on the Unity version (Unity 6 vs 2022 LTS). Verify against the installed Unity version before relying on them. Allocation-sensitive work continues in `game-performance`; layout in `unity-project-patterns`; structure in `unity-architecture`.

## Naming and members
- PascalCase for types, methods, properties, events, public members. camelCase for locals and parameters. `_camelCase` for private fields. No Hungarian prefixes, no `m_`. Interfaces start with `I`.
- Expose inspector data with `[SerializeField] private`, never public fields. Expose read access through a property.
```csharp
[SerializeField] private float _moveSpeed = 5f;
public float MoveSpeed => _moveSpeed;
```
- Use `readonly` for fields set once in the constructor and `const` for compile-time values. Do not mark serialized fields `readonly`; Unity cannot set them.
- Use expression-bodied members for trivial one-line properties and accessors only. Use block bodies when logic has branches.
- One top-level type per file; the MonoBehaviour class name must equal the file name.
- Do not use `public` by default. Default to the narrowest accessibility; use `internal` across an assembly.

## Namespaces and assemblies
- Namespace = company/project + feature, matching the folder path and its asmdef (`Game.Inventory` in `Scripts/Inventory/Game.Inventory.asmdef`). Do not leave game code in the global namespace.
- One asmdef per cohesive module. References point one direction (`unity-architecture`). Editor code lives in its own Editor-only asmdef (`unity-editor-workflows`).

## Null handling
- `UnityEngine.Object` overrides `==`. A destroyed object compares equal to `null` while the C# reference is still non-null.
- Never use `?.`, `??`, `??=`, or `is null` on `UnityEngine.Object` types; they bypass the override. Use `if (_target == null)` or `if (!_target)`.
```csharp
if (_target == null) return;   // correct for Unity objects
var name = _config?.Name;      // fine only if _config is a plain C# class
```
- Nullable reference types (`#nullable enable`) are supported on a per-file or per-asmdef basis depending on Unity and compiler version. Verify before enabling. Serialized fields are populated by Unity, so annotate with care or use `= default!` sparingly and document it.
- Use `TryGetComponent` instead of `GetComponent` plus a null check. Validate required references in `Awake` or `OnValidate` and fail loudly.

## Events
- Use C# `event Action<T>` for code-to-code messaging; `UnityEvent` only when designers must wire it in the inspector.
- Subscribe in `OnEnable`, unsubscribe in `OnDisable`. Every `+=` has a matching `-=`. Never subscribe in `Awake` without unsubscribing in `OnDestroy`.
- Raise with `Changed?.Invoke(value)` on a plain C# event; delegates are not Unity objects.
- Do not expose a public `Action` field; expose an `event` so outsiders cannot invoke or overwrite it.

## Async and coroutines
- Coroutines for simple frame-timed sequences owned by a MonoBehaviour. They stop when the object is disabled or destroyed.
- `async`/`await` for I/O, Addressables, and web requests. Always pass a `CancellationToken`; use `destroyCancellationToken` on a MonoBehaviour (verify availability in the installed version).
- Unity 6 (6000.x) includes `Awaitable`, first added in 2023.1, for engine-aware async (verify). UniTask is a third-party alternative; adopt one library per project and verify its version.
- Never `async void` except event handlers and Unity messages. Never block with `.Result` or `.Wait()` on the main thread.
- After any `await`, re-check that the object still exists (`this == null`) before touching it.
- Unity APIs run on the main thread. Do not call them from `Task.Run` threads.

## Allocations and data
- Avoid LINQ, closures, `foreach` over non-struct enumerators, `params`, and string concatenation in `Update` and other hot paths. Use `for` loops, cached lists, and `NonAlloc` APIs.
- Cache `Camera.main`, `GetComponent` results, and `WaitForSeconds` instances.
- Avoid boxing: do not pass value types to `object`, non-generic collections, or `string.Format`. Use `StringBuilder` for repeated building.
- Prefer `struct` for small immutable value data (under about 16 bytes, no inheritance). Make structs `readonly` where possible. Use `class` otherwise; large structs copy cost.
- Prefer generic constraints (`where T : Component`) over casts. Use `[Flags]` enums with explicit power-of-two values, and give `None = 0`. Never reorder or renumber serialized enum values.

## Attributes
- `[RequireComponent(typeof(Rigidbody))]` for hard dependencies. `[DisallowMultipleComponent]` for singletons per object.
- `[FormerlySerializedAs("oldName")]` whenever renaming a serialized field, so existing assets keep data.
- `[field: SerializeField]` on auto-properties is allowed; the backing field name is compiler-generated, so avoid it for fields that may be renamed.

## Documentation, analyzers, logging
- XML doc comments (`///`) on public APIs of shared modules. Comment why, not what.
- Commit a `.editorconfig` with naming and style rules; enable Roslyn analyzers through an asmdef or IDE setup (verify supported mechanism for the Unity version). Treat analyzer warnings as errors in CI.
- Wrap logging in a small static class or use `[Conditional("UNITY_EDITOR")]`/`[Conditional("DEVELOPMENT_BUILD")]` methods so calls are stripped in release. Include the context object: `Debug.LogWarning(msg, this)`.
- No stray `Debug.Log` in `Update`. Log levels: errors for broken invariants, warnings for recoverable problems, info sparingly.

## See also

Optional, if installed: code-review (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
