---
name: game-performance
description: Runtime performance practices for Unity games - frame budgets, CPU and GC allocation avoidance, caching, event-driven updates, pooling, Jobs and Burst when justified, rendering cost (batching, SRP Batcher, instancing, overdraw, LOD, culling, lighting, post-processing, dynamic resolution), memory, loading hitches, mobile constraints, quality tiers, per-feature budgets, and regression guarding. Load when a game misses its frame or memory target, when reviewing code for runtime cost, or when setting performance budgets. Measure first with game-profiling.
---

# Game performance

Measure before changing anything (`game-profiling`). Feature names, defaults, and URP settings differ between Unity 6 and 2022 LTS; verify against the installed version, and confirm each optimisation with a before and after capture on target hardware.

## Frame budget
- 60 fps leaves 16.6 ms per frame, 30 fps leaves 33.3 ms. Aim for headroom (thermal throttling on mobile, background load), not the edge.
- Set the target hardware and frame rate first. Split the budget across CPU main thread, render thread, GPU, and per-feature slices (gameplay, physics, animation, UI, audio).
- Frame time is limited by the slower of CPU and GPU; find which one before optimising.

## CPU and allocations
- Avoid per-frame managed allocations; they trigger GC spikes. Typical sources: `new` in `Update`, LINQ, string concatenation and formatting, boxing (value types to `object`, non-generic collections), lambdas capturing variables, `foreach` over some non-generic collections, `GetComponents` returning arrays.
- Cache references: `GetComponent`, `Camera.main` (verify cost in your version), `Find*`, and string lookups (use `Animator.StringToHash`, shader property IDs).
- Reuse collections with `Clear()`; use non-allocating physics and `GetComponents(List<T>)` overloads (`physics-systems`).
- Do not run `Update` when events suffice. Disable components and objects you do not need, and use a manager that ticks many objects in one loop.
- Spread expensive work across frames; throttle low-priority systems (`game-ai`).
- Use object pooling for frequently spawned objects (projectiles, effects, UI rows), and reset state on return. Instantiate and Destroy cause both allocation and spikes.
- Use `StringBuilder` or cached strings for HUD text and update only on change.

```csharp
private readonly List<Enemy> nearby = new();

private void Scan()
{
    nearby.Clear();
    registry.Query(position, radius, nearby);
}
```

## Jobs and Burst
- Move to the Job System and Burst only for measured hot, data-parallel work (crowds, mesh generation, large queries). They add complexity: native memory lifetime, no managed references, safety rules.
- Verify package requirements and Burst-compatible code rules for your version. DOTS/ECS is a different architecture; adopt only with a clear need (`unity-architecture`).

## Animation and physics
- Reduce Animator layers and parameters, cull animation off-screen (culling mode), and lower update rate for distant characters.
- Physics cost scales with active bodies, contacts, and queries; see `physics-systems`.

## Rendering (GPU)
- Reduce draw calls and SetPass calls. In URP, keep materials SRP Batcher compatible (same shader variants, properties in the UnityPerMaterial constant buffer, verify in the shader inspector).
- Use GPU instancing for many identical meshes with the same material, static batching for static geometry (watch memory), and dynamic batching only for small meshes, if measured to help.
- Overdraw: minimise large transparent layers, particles, and UI stacked over each other. Use the Scene view overdraw mode to find it.
- Shader complexity: simplify fragment work, avoid unnecessary variants and keywords, use lower precision on mobile.
- LOD groups for meshes, and distance limits for small objects; occlusion culling for dense indoor or urban scenes (requires baking).
- Lighting: prefer baked light for static content, limit realtime lights and shadow-casting lights, reduce shadow distance, cascades, and resolution. Realtime shadows are a large cost.
- Post-processing is per-pixel cost; enable only the effects that matter and test on target hardware.
- Resolution scaling or dynamic resolution (verify URP support and platform behaviour) buys GPU headroom.

## Memory
- Managed heap (GC) and native memory (textures, meshes, audio, physics) are separate; track both.
- Textures dominate: compress with platform formats, set max sizes, use mipmaps, disable Read/Write unless needed (`unity-asset-management`).
- Release what you load: unload Addressables handles and assets when leaving a scene or feature; stale references leak.
- Incremental GC spreads collection over frames and reduces spikes; verify availability and the setting for your version, but it does not remove the need to avoid allocations.

## Loading
- Load asynchronously, preload before gameplay needs assets, and warm shaders (shader variant collections or equivalent; verify) to avoid first-use hitches.
- Never instantiate large hierarchies in one frame; spread across frames or pool in advance.

## Mobile
- Fill rate, memory bandwidth, and thermal throttling constrain performance. Sustained frame time matters more than peak.
- Lower target frame rate where acceptable, cut overdraw and resolution, avoid heavy post-processing, and watch battery impact.
- Test on the lowest supported device after the build is warm, not just on a fresh start.

## Quality tiers and budgets
- Provide quality levels with distinct values for resolution scale, shadows, texture quality, and effects. Choose a tier by device capability, with user override.
- Write budgets per feature (milliseconds, draw calls, memory, triangles, allocations per frame) and put them in the repository docs.

## Regression guarding
- Add automated performance tests with thresholds in CI (`game-profiling`) and review budget changes in the same way as code changes.
- Re-profile on target hardware at every milestone; most regressions arrive silently as content grows.

## See also

Optional, if installed: performance-engineering (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
