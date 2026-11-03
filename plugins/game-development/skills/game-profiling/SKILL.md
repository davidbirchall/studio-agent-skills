---
name: game-profiling
description: Measure Unity CPU, GPU, memory, GC, loading, and build-size problems using Profiler, Frame Debugger, Memory Profiler, target devices, and automated reports. Load when investigating a performance symptom or collecting evidence; use game-performance for the fix.
---

# Game profiling

Measure, then change. Tool names, menu paths, and packages (Memory Profiler, Profile Analyzer, Performance Testing) change across Unity versions; verify availability and usage against the installed Unity and package versions.

## Workflow
1. Reproduce: pick a scenario that triggers the problem and is repeatable (scripted route, fixed seed, saved state; `procedural-generation`).
2. Capture: record a representative window on the target device, with a baseline run first.
3. Hypothesise: identify whether CPU main thread, render thread, GPU, memory, or loading is the limit, and which system inside it.
4. Change one thing.
5. Re-measure with the same scenario and hardware. Keep the change only if the numbers improve.
- Record metrics, not impressions. One capture is anecdote; repeat several runs and compare medians and worst frames.

## Where to profile
- Profile on the target device in a Development Build with Autoconnect Profiler. Editor numbers include editor overhead and differ in GPU, memory, and scripting behaviour; use the Editor only to find obvious problems.
- Use release-like settings (IL2CPP where shipped, correct graphics API and quality tier) for final numbers. Development builds are slower than release.
- Warm the build before capture (shaders compiled, assets loaded) unless you are measuring first-use hitches.
- Mobile: let the device reach thermal steady state before conclusions.

## Unity Profiler
- CPU Usage: main thread and render thread timeline and hierarchy. Sort by self time and GC alloc column; look at the spikes, not just averages.
- GPU module: GPU time where supported; verify per platform and graphics API.
- Memory module: managed versus native totals and per-category usage.
- Rendering module: batches, SetPass calls, triangles. Physics, Audio, and UI profilers show their own counters (contacts, voices, canvas rebuilds).
- Use the Timeline view to see main versus render thread waiting; waiting on the render thread or GPU means the bottleneck is not scripts.
- Use the Highlights/Counters and recorded frames to find frame-time spikes, then inspect each spike frame.

## Markers and deep profiling
- Add `ProfilerMarker` around your own systems so they show by name with low overhead. `Profiler.BeginSample` also works but is string-based and costlier; prefer markers.

```csharp
private static readonly ProfilerMarker PerceptionMarker = new("Ai.Perception");

private void TickPerception()
{
    using (PerceptionMarker.Auto())
    {
        // work
    }
}
```
- Deep Profile instruments every call and distorts timings and allocations heavily. Use it only to find where inside a slow function the time goes, then confirm with markers.

## Rendering and GPU
- Frame Debugger steps through draw calls to find batching breaks, unexpected passes, and overdraw sources.
- For GPU cost, use platform or generic GPU capture tools (RenderDoc, vendor and console tools) on the target device. Check shader cost, bandwidth, and pass cost. Verify supported APIs for your platform.

## Memory
- Use the Memory Profiler package: take snapshots at defined points (menu, level start, level end) and compare them to find growth. Leaks appear as objects surviving a scene unload or growing counts between identical snapshots.
- Inspect the reference chain to find what holds an asset (static fields, event handlers never unsubscribed, unreleased Addressables handles).
- Distinguish managed heap growth (GC) from native growth (textures, meshes, audio).

## GC allocations
- Track per-frame GC Alloc in the CPU hierarchy view; aim for zero in steady-state gameplay. Click through the call stack to the allocating site (deep profile for call stacks, if needed).
- Watch for GC.Collect spikes and frequency, not only totals.

## Other tools
- Profile Analyzer (package; verify): compare two captures statistically and across frames, useful for before and after.
- Build report / build size: review the Editor log after a build for largest assets and unexpected inclusions (`unity-build-release`, `unity-asset-management`).
- Logs: read Player logs for warnings, load times, and errors; time-stamp your own timing logs.

## Automation
- Use the Performance Testing package (verify) to measure frame time, markers, and allocations in automated tests, with recorded baselines and a tolerance threshold. Run on dedicated, consistent hardware in CI.
- Fail builds on budget regressions defined in `game-performance`. Keep scenarios deterministic and note device and settings with every result.

## In-game debug overlay
- Provide a toggleable overlay: fps, average frame time, percentile frame times (for example 1% lows over a rolling window), memory used, GC count, and key system counters.
- Frame time percentiles reveal stutter that average fps hides. Keep the overlay allocation-free and compiled out of release builds.

## Reading the data
- Flame graph or hierarchy: wide blocks are expensive; start at the largest, drill down to self time. A function with high total but low self time is a pass-through.
- Many cheap calls can add up: look at call counts. Repeated spikes at fixed intervals point to periodic work (GC, loading, autosave).
- Common culprits: per-frame allocations, `Find`/`GetComponent` calls, too many active Update scripts, physics queries, canvas rebuilds, shadows, overdraw, unpooled instantiation, synchronous loads, and expensive logging.

## Report template
- Scenario and how to reproduce (build, scene, seed, route).
- Hardware, OS, graphics API, quality tier, build type, Unity version.
- Target (for example 60 fps, 16.6 ms) and observed numbers: average, 1% low, worst frame, memory peak, allocations per frame.
- Finding: what limits the frame and the evidence (screenshot or capture reference).
- Change made and the after numbers in the same scenario.
- Remaining risks and next steps; hand fixes to `game-performance`.

## See also

Optional, if installed: performance-engineering (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
