---
name: unity-asset-management
description: Unity asset pipeline and memory management - import settings for textures, models and audio, naming and folders, Addressables groups, labels, async loading, reference counting and release, remote content and catalog updates, comparison with Resources and direct references, AssetBundles, memory budgets, shared dependencies and duplicates, atlasing, LODs, Git LFS, asset auditing, art and audio hand-off specs, loading strategies, and leak detection. Load when configuring imports, adopting Addressables, setting memory or size budgets, auditing assets, or fixing loading hitches and leaks.
---

# Unity asset management

Import setting names and Addressables APIs vary between package and Unity versions (Unity 6 vs 2022 LTS); verify against the installed Unity and Addressables versions. Folder and VCS basics: `unity-project-patterns`. Runtime cost: `game-performance`, `game-profiling`.

## Import settings
- Set import defaults per asset type with presets or an `AssetPostprocessor` so new assets start correct, and audit existing ones (below).
- Textures: power-of-two or block-aligned sizes for compression; set Max Size to the smallest acceptable per platform; use platform-appropriate compression (verify ASTC/ETC2/BCn choices per target); disable Read/Write; enable mipmaps for 3D, disable for UI and 2D sprites; sRGB on for color, off for data maps (normal, mask). Use a Sprite Atlas for UI and 2D sprites to cut draw calls.
- Models: set a consistent scale factor, Read/Write off, enable mesh compression where quality allows, strip unused channels and cameras/lights, import only needed animation. Use LOD groups for distant meshes and verify the mesh optimisation options.
- Audio: Load Type by length: Decompress On Load for short SFX, Compressed In Memory for medium, Streaming for music and long loops. Pick a compression format per platform (verify). Force To Mono for non-spatial or 3D-positioned effects where stereo is not needed.
- Fonts, video, and shaders: set platform-specific limits and verify shader variant counts (`game-performance`).

## Loading approach
- Direct serialized references: simplest; everything referenced loads with its owner. Fine for small or always-resident content.
- `Resources/`: avoid (`unity-project-patterns`).
- Addressables: use for large, optional, or remotely updated content. AssetBundles are the underlying mechanism; use them directly only with strong reason, and verify what the current Addressables package expects.
- Choose per asset: core resident = direct; per-level or optional = Addressables.

## Layout and naming
```
Assets/_Project/Art/
  Textures/   T_<Asset>_<Map>   e.g. T_Hero_Albedo, T_Hero_Normal, T_Hero_Mask
  Models/     SM_<Asset> (static), SK_<Asset> (skinned)
  Materials/  M_<Asset>   Animations/ A_<Rig>_<Action>
Assets/_Project/Audio/  SFX_<Thing>_<Variant>  MUS_<Track>
Assets/AddressableAssetsData/  groups and settings (commit; verify path)
```
- Suffix texture maps (`_Albedo`, `_Normal`, `_Mask`) so a postprocessor can set sRGB and compression by name.

## Decision thresholds
- Texture over 2048 px on mobile or over 4096 px on desktop needs a written reason; sprites for UI rarely exceed 1024 px.
- Clip under about 200 KB decoded: Decompress On Load; up to about 1 MB: Compressed In Memory; music and ambience over about 10 s: Streaming. Treat these as starting points and verify by profiling.
- Move content to Addressables when it is over about 5% of build size, used by only some levels, or must update without a store release. Content in every session stays as direct references.
- A group above about 100-200 MB, or one holding assets that never load together, should be split (verify the guidance for the installed Addressables package).
- Pool a prefab instantiated more than a few times per second; load it once and keep the handle.

## Addressables
- Organise groups by lifetime and update cadence (core, per-level, DLC, remote). One asset appears in one group. Group size affects bundle granularity.
- Use labels for bulk loading (`tutorial`, `level_03`). Reference with `AssetReference` rather than string keys where possible.
- Load asynchronously and always release. Every `LoadAssetAsync` or `InstantiateAsync` needs a matching `Release` or `ReleaseInstance` when the owner dies; store the handle.
```csharp
private AsyncOperationHandle<GameObject> _handle;
public async Task LoadAsync(AssetReference reference)
{
    _handle = reference.LoadAssetAsync<GameObject>();
    await _handle.Task;
}
private void OnDestroy() { if (_handle.IsValid()) Addressables.Release(_handle); }
```
- Reference counting means unreleased handles keep bundles in memory. Pair loads and releases in the same owner.
- Remote content: host catalog and bundles, check for catalog updates at start, version content with builds, and plan rollback. Keep a local fallback for the first launch. Verify catalog update and content update APIs in the installed version.
- Run the Analyze tool (verify menu path) to find duplicate dependencies and fix by moving shared assets to a common group.

## Memory and dependencies
- Set per-platform budgets for texture memory, mesh memory, audio, and total resident memory, and test on the lowest-spec target (`game-profiling`). Texture memory is usually the largest share: width x height x bits per pixel (plus about a third for mipmaps).
- Watch shared dependencies: an asset referenced from several bundles or scenes can be duplicated in each. Check via Build Report or Addressables Analyze.
- Avoid referencing a heavy asset from a lightweight prefab; use an `AssetReference` to defer it.
- Unload deliberately: release Addressables handles, unload additive scenes, then `Resources.UnloadUnusedAssets` at safe points (it is expensive; do it in loading screens).
- Pool frequently spawned prefabs instead of repeated load and destroy (`game-performance`).

## Loading strategy
- Preload what the next scene needs during a loading screen or fade. Stream large worlds with additive scenes (`unity-architecture`). Show progress from the operation handle.
- Avoid synchronous loads (`WaitForCompletion`) during gameplay; they stall the frame.
- Warm shaders and prefabs that cause first-use hitches.

## Version control and auditing
- Track big binaries with Git LFS, and agree on art file formats; commit source files (PSD, Blender) in a separate repo or LFS area, not in `Assets/`.
- Schedule an audit script (`unity-editor-workflows`) that reports oversize textures, uncompressed audio, Read/Write enabled, missing atlases, duplicate files, and unreferenced assets. Compare build size through the Build Report (`unity-build-release`).
- Detect leaks with the Memory Profiler (verify package) by comparing snapshots across a load-unload cycle; assets that remain resident point to unreleased handles or static references.

## Anti-patterns
- Calling `LoadAssetAsync` without storing the handle, so the asset can never be released.
- `WaitForCompletion` in gameplay, or loading inside `Update`.
- The same heavy texture referenced from several groups, producing silent duplicates.
- Read/Write enabled "just in case"; it doubles texture and mesh memory.
- Fixing bad art in-engine instead of rejecting it against the spec.
- Judging memory from the Editor rather than a device build.

## Checklist
- [ ] Import presets or postprocessor cover textures, models, and audio.
- [ ] Per-platform memory and size budgets are written and checked in CI.
- [ ] Every Addressables load has a paired release owner.
- [ ] Analyze shows no duplicate dependencies.
- [ ] Load-unload cycle in the Memory Profiler returns to baseline.

## Asset specs
- Write a one-page asset spec (for yourself, generation tools, or any outside contributor): naming, resolution limits and budgets per asset class, texel density, poly/bone limits, formats, sample rates, loudness, and delivery folder. Reject assets that break the spec rather than patching in-engine; a validation script can check it.

## See also

Optional, if installed: asset-optimisation (the creative-technology plugin); 3d-asset-pipeline (the creative-technology plugin) for the broader discipline this skill applies. This skill stands on its own.
