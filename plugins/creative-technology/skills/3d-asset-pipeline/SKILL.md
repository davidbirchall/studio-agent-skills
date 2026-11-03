---
name: 3d-asset-pipeline
description: Technical pipeline for getting 3D assets from Blender into Unity - FBX versus glTF export, scale and axis conventions, naming for LODs and colliders, mesh and material preparation, Unity model import settings (scale factor, normals, tangents, read/write, compression), prefab creation and organisation, folder structure, AssetPostprocessor validation, and per-asset-type checklists. Load when exporting from Blender, configuring Unity model imports, structuring 3D asset folders, or automating import validation.
---

# 3D Asset Pipeline

Builds on `blender-workflows` for source files and `asset-optimisation` for budgets; materials continue in `material-shader-workflows` and rigs in `animation-integration`. Importer option names and FBX/glTF exporter settings vary by Unity and Blender version; verify against installed versions.

## Format choice
- FBX: default for Unity meshes, rigs, and animation; widely supported by the Unity importer.
- glTF: good for static meshes and PBR materials; check that your Unity version has a supported importer package and how it maps materials.
- Pick one format per project. Exports are generated output, never the source of truth.

## Scale and axes
- Blender is Z-up, right-handed; Unity is Y-up, left-handed. Use the exporter axis and apply-transform options appropriate to your versions, then test one asset: it must arrive at correct size, facing +Z forward, with scale 1 on the prefab.
- Target 1 unit = 1 metre. If an asset arrives 100x or 0.01x, fix the Blender unit/export scale, not the transform on the instance.
- Record the chosen exporter settings in the repo and reuse them via a script or preset.

## Naming and structure
- Follow the `blender-workflows` naming table; Unity reads these names at import.
- Colliders: a naming convention in the source (for example `UCX_` prefix) is only meaningful if an importer script converts it; Unity does not do this by default. Verify, or build colliders in Unity.
- LODs: `_LOD0..n` suffix; Unity's model importer can create LOD groups from this naming; verify behaviour in your version.
- Folder layout:
```
Assets/Art/Models/<Category>/<AssetName>/
    <AssetName>.fbx
    Materials/  Textures/  Prefabs/
```

## Mesh and material preparation
- One material per distinct surface; keep slot count low (`asset-optimisation`).
- Transforms applied, normals checked, UV0 clean, UV1 for lightmaps if baked lighting is used.
- Textures live next to the model or in a shared folder; use relative references, not absolute paths.
- Prefer remapping materials to project materials on import rather than extracting per-asset duplicates.

## Unity import settings
- Scale Factor: 1 when the export is metre-correct; avoid compensating on instances.
- Normals and tangents: import normals unless a custom setup needs calculated ones; calculate tangents only when using normal maps without baked tangents.
- Read/Write: off by default (it doubles mesh memory); on only for runtime mesh access, combining, or procedural use.
- Mesh compression: off to Medium by project policy; verify visual artefacts on small or precise meshes.
- Disable import of cameras, lights, and animation on static models; enable only what the asset needs.
- Generate lightmap UVs only if UV1 is not authored.

## AssetPostprocessor validation
Enforce rules at import so bad assets fail early.
```csharp
using UnityEditor;
using UnityEngine;

public class ModelImportRules : AssetPostprocessor
{
    void OnPreprocessModel()
    {
        if (!assetPath.StartsWith("Assets/Art/Models/")) return;
        var importer = (ModelImporter)assetImporter;
        importer.isReadable = false;
        importer.importCameras = false;
        importer.importLights = false;
    }

    void OnPostprocessModel(GameObject root)
    {
        foreach (var mf in root.GetComponentsInChildren<MeshFilter>())
            if (mf.sharedMesh.vertexCount > 65000)
                Debug.LogWarning($"{assetPath}: {mf.name} is over budget", mf);
    }
}
```
- Keep rules in a single class, scoped by path; log warnings for budget issues and errors for hard contract breaks.
- Test the rules on sample fixtures (`test-discipline`).

## Prefabs
- One prefab per placeable asset, as a wrapper around the model: collider, LOD group, scripts. Do not edit the imported model instance.
- Use prefab variants for visual or tuning differences. Name prefabs after the asset (`SM_Crate_A.prefab`).
- Place prefabs under `Assets/Prefabs/` or beside the model per project convention, and keep that consistent.

## Checklists
- Static prop: metre scale, pivot at base, UV0 and UV1, collider, LODs if over budget, Read/Write off.
- Modular kit: grid-aligned pivots, snapping verified in a test scene, consistent texel density.
- Character or rig: T/A-pose, applied scale, clean skin weights, humanoid or generic rig chosen deliberately; see `animation-integration`.
- Environment or large mesh: split for culling, lightmap UVs, LODs; check material count.

## See also

Optional, if installed: unity-asset-management (the game-development plugin) for the broader discipline this skill applies. This skill stands on its own.
