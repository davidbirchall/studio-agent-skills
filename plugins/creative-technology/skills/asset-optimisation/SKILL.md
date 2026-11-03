---
name: asset-optimisation
description: Technical optimisation of game assets for Unity - budgets per asset class (triangles, texture size, materials, draw calls), mesh simplification and LODs, texture compression and mipmaps, atlasing, material consolidation, import-time versus runtime optimisation, platform-specific overrides, measuring before and after, and automated budget checks in CI through editor scripts, with audio and video sizing deferred to audio-integration. Load when setting asset budgets, reducing asset cost, configuring compression, or automating budget enforcement.
---

# Asset Optimisation

Builds on `3d-asset-pipeline` and `2d-asset-pipeline`; sources come from `blender-workflows`. Audio and video size and compression are covered in `audio-integration`. Compression formats, importer options, and profiler tools vary by Unity version and platform; verify against installed versions.

## Budgets
- Define budgets per asset class and target platform before production; store them in the repo as data. The values below are placeholders to tune from profiling.

| Class | Triangles | Texture (max) | Materials |
|---|---|---|---|
| Hero character | 30k-60k | 2048 | 2-4 |
| Prop, small | 500-3k | 512 | 1 |
| Prop, large | 3k-15k | 1024 | 1-2 |
| Environment piece | 5k-30k | 2048 | 1-3 |
| UI sprite | n/a | atlas 2048 | shared |

- Mobile budgets are roughly an order tighter than desktop; set per-platform tables.
- Budgets are limits derived from frame time and memory, not goals; revise when measurements show headroom or overrun.

## Measure first
- Record before and after for every optimisation: frame time, draw calls and batches, triangles, texture memory, build size, load time.
- Use the Profiler, Frame Debugger, and Memory Profiler on target hardware, not only the editor.
- Optimise the measured bottleneck. Triangle cuts do not help a fill-rate or draw-call bound scene.
- Keep a baseline scene or capture so results are comparable.

## Meshes and LODs
- Remove hidden faces, interior geometry, and unneeded edge loops at the source; bake detail into normal maps.
- LOD0 meets the budget at close range; each next LOD roughly halves triangles. Tune screen-percentage transitions in a test scene.
- Provide a cull level for small props. Use LODs on anything seen at many distances.
- Decimation in Blender is acceptable for drafts; inspect results for broken UVs and silhouettes.
- Read/Write off, vertex colours and extra UV channels removed if unused, mesh compression per policy.

## Textures
- Size to screen use: texel density consistent per class; do not exceed the on-screen pixel need.
- Use block-compressed formats for 3D textures; choose per platform in overrides (verify format support for each target).
- Mipmaps on for 3D and perspective use; off for UI and pixel art.
- Pack masks into channels (for example roughness, metallic, occlusion in one texture) to cut texture count.
- Normal maps and masks: sRGB off. Use a shared trim or tiling texture where possible.
- Lower Max Size per platform instead of authoring multiple sources.

## Batching and materials
- Fewer materials and shaders means fewer batch breaks. Share one material across a prop kit via a trim sheet or atlas.
- Combine static meshes by area when it reduces draw calls without harming culling; do not merge whole levels.
- Use GPU instancing or SRP batching where supported; verify compatibility with your render pipeline and shaders (`material-shader-workflows`).
- Atlas sprites per screen (`2d-asset-pipeline`).

## Import-time versus runtime
- Prefer import-time fixes: compression, resizing, LOD generation, material remapping. They cost nothing at runtime and are reproducible.
- Runtime options (streaming, Addressables loading, pooling, async load) address memory and hitches, not asset cost.
- Texture streaming and mipmap budgets trade memory for load behaviour; test with slow storage.

## Platform overrides
- Set per-platform Max Size, compression, and quality in importer overrides. Keep desktop as default and override down for mobile and consoles.
- Verify each platform build rather than trusting the editor.

## Automated checks
Fail CI when assets exceed budget.
```csharp
using UnityEditor;
using UnityEngine;

public static class BudgetCheck
{
    public static void Run()
    {
        int failures = 0;
        foreach (var guid in AssetDatabase.FindAssets("t:Mesh", new[] { "Assets/Art/Models" }))
        {
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var mesh = AssetDatabase.LoadAssetAtPath<Mesh>(path);
            if (mesh != null && mesh.triangles.Length / 3 > 30000)
            { Debug.LogError($"{path}: over triangle budget"); failures++; }
        }
        if (failures > 0) EditorApplication.Exit(1);
    }
}
```
- Run it in batch mode through the editor command line (`-executeMethod`); verify flags for your version.
- Load budgets from a data file, report the asset path and measured value, and test the checker with fixtures (`test-discipline`).

## See also

Optional, if installed: game-performance (the game-development plugin); performance-engineering (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
