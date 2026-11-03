---
name: procedural-generation
description: Procedural content generation engineering in Unity C# - seeded deterministic generation, noise, algorithm selection (BSP, cellular automata, drunkard's walk, wave function collapse, L-systems, Poisson-disc, graph grammars, tile versus voxel), validation passes, data-first generation pipelines, chunking and time-sliced streaming, Mesh API basics, Burst and Jobs options, authored hybrids, saving as seed plus deltas, debug tooling, and testing with fixed seeds. Load when building or debugging level, terrain, dungeon, or item generators.
---

# Procedural generation

Builds on `csharp-conventions` and `unity-architecture`. Unity.Mathematics noise functions, the Mesh API surface, and Burst and Jobs details vary by package and Unity version; verify names against the installed versions.

## Determinism
- Same seed must produce the same result. Use `System.Random` or your own small PRNG owned by the generator. Never use `UnityEngine.Random` for reproducible generation; it is global state shared with gameplay.
- Wrap the PRNG in your own type so the algorithm can be swapped and tested. `System.Random` sequences are not guaranteed identical across .NET versions or platforms; use an own implementation (for example xorshift or PCG) if seeds must be stable across builds.
- Derive sub-seeds per feature from the master seed (hash of seed plus feature id or coordinates), so adding a feature or changing generation order does not reshuffle everything else.
- Avoid floating-point order dependence, hash-set iteration order, and frame-time or `Time` inputs in generators.

```csharp
public readonly struct SeedSource
{
    private readonly int master;
    public SeedSource(int master) => this.master = master;

    public System.Random For(string feature, int x = 0, int y = 0) =>
        new System.Random(StableHash(master, feature, x, y));

    private static int StableHash(int seed, string s, int x, int y)
    {
        unchecked
        {
            int h = seed;
            foreach (var c in s) h = h * 31 + c;
            return (h * 31 + x) * 31 + y;
        }
    }
}
```
Do not use `HashCode.Combine` for persistent seeds; it is randomised per process.

## Noise
- `Mathf.PerlinNoise` is 2D only, has limited range and repeats; use it for prototypes. For 3D, simplex, Worley, or tunable octaves consider `Unity.Mathematics` noise functions (verify availability and names) or your own implementation.
- Layer octaves (fBm) with lacunarity and persistence exposed as parameters. Offset sample coordinates by the seed, not by `Time`.
- Sample in world coordinates so adjacent chunks match at borders.

## Algorithms by use case
- Rooms and corridors: BSP partition, or room placement plus connection graph (minimum spanning tree, then add loops).
- Caves: cellular automata with smoothing passes and region cleanup.
- Organic paths and tunnels: drunkard's walk with bias and boundaries.
- Local rule-driven tilings: wave function collapse; needs backtracking or restart on contradiction and a retry cap.
- Plants and branching structures: L-systems.
- Even scattering (trees, loot): Poisson-disc sampling rather than uniform random.
- Gameplay-structured dungeons: graph or grammar generation (mission graph first, spatial layout second).
- Tile-based suits grid games and authored art; voxel suits editable volumetric worlds at higher memory and meshing cost.

## Constraints and validation
- Generation is not finished until validated. Run passes after generation: connectivity or reachability (flood fill or graph search from start), required items reachable, minimum and maximum sizes, no overlap, difficulty bounds.
- On failure, repair if cheap, otherwise regenerate with the next sub-seed and a retry limit. Log the seed and failure reason.
- Keep validators as pure functions over generated data so they are testable.

## Pipeline
- Stages: parameters, layout, content placement, validation, then instantiation. Generate data (grids, graphs, plain structs) first; create GameObjects or meshes afterwards.
- Each stage takes input data and a PRNG and returns data; stages are independently testable and skippable in tools.
- Do not call Unity APIs in the data stages, which allows threads, jobs, and EditMode tests.

## Chunking and streaming
- Divide large worlds into chunks generated from (seed, chunk coordinates) only, so any chunk can be regenerated independently.
- Generate asynchronously or time-sliced: a per-frame millisecond budget in a coroutine, `async` on a background thread for data stages, or the Job System for numeric work. Unity API calls (mesh upload, instantiation) stay on the main thread.
- Prioritise chunks by distance to the player, unload and pool distant ones, and avoid hitches (`game-performance`).

## Meshes
- Build with `Mesh` and its vertex or mesh-data APIs; reuse lists and arrays to avoid GC. Set index format to 32-bit when a mesh exceeds 65535 vertices (verify the property and 16-bit default for your version).
- Recalculate bounds after setting geometry, and normals if you did not supply them. Upload once, then mark non-readable where you do not need CPU access. Add a collider mesh only if needed (`physics-systems`).
- Heavy loops (noise fields, marching cubes, meshing) are Burst and Jobs candidates; verify package requirements and use `NativeArray` with explicit disposal.

## Authored plus procedural
- Prefer hybrids: procedural arrangement of hand-authored room templates, prefabs, or rule tiles. This keeps visual quality and limits what can go wrong.
- Template data declares connectors, size, tags, and weight in ScriptableObjects (`unity-project-patterns`). Validate templates in the editor (`unity-editor-workflows`).

## Persistence
- Save the seed, generator version, parameters, and player-made deltas (opened doors, destroyed tiles), not the whole generated world (`save-load-systems`).
- Version the generator: any algorithm change invalidates old seeds. Record a generator version in saves and keep or migrate old generators deliberately.

## Debugging
- Build a visualiser (gizmos, debug texture, editor window) that shows stages, rooms, graph edges, and failed validations. Provide a seed field with regenerate and step controls.
- Always log the seed, version, and parameters at generation and include them in bug reports and crash data.

## Testing
- Test with fixed seeds: same seed gives identical output (hash the result), and known seeds produce known layouts for regression.
- Property tests over many seeds (hundreds or thousands): every result passes validation, and is reachable and within size bounds. Report the failing seed.
- Measure generation time and allocations per chunk or level (`game-profiling`) and set budgets.
