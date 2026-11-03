---
name: blender-workflows
description: Prepare Blender source scenes for reliable Unity production: units, transforms, origins, collections, modifiers, UVs, normals, naming, linked assets, version control, bpy validation, and repeatable exports. Load when editing Blender files or automating Blender-side asset preparation.
---

# Blender Workflows

Feeds `3d-asset-pipeline` (export and import) and `asset-optimisation` (budgets). Not about modelling craft. Blender menus, operator names, and bpy APIs change between versions; verify against the installed Blender before relying on any snippet.

## Scene setup
- Set unit system and scale at the start of every file; do not change mid-project. Metric with unit scale 1.0 maps 1 Blender unit to 1 metre, matching Unity.
- Model at real-world size (door about 2 m, character about 1.8 m). Never fix size with object scale.
- Use one template .blend with units, collections, and export settings preconfigured.
- Keep one asset per file, or one clearly named root per asset in a kit file.

## Transforms and origins
- Apply scale and rotation before export so objects have scale 1 and rotation 0 (apply location only when the origin is meant to be world zero).
- Check for negative or non-uniform scale; they flip normals and break colliders.
- Place the origin where Unity needs the pivot: base-centre for props and characters, hinge for doors, grid corner for modular pieces.
- Keep the 3D cursor at world zero when resetting origins.

## Modifiers
- Keep stacks non-destructive while authoring (mirror, bevel, array, subdivision, weighted normals).
- Order matters: mirror and array before bevel, bevel before weighted normals.
- Export settings decide whether modifiers are applied; confirm in the exporter. Never apply modifiers on shape-keyed meshes without checking the result.
- Keep render-only modifier levels out of exports; game meshes use the viewport level or an explicit low-poly pass.

## Naming and collections
- Names are the contract with Unity. Use ASCII, no spaces, PascalCase with underscore-separated parts.

| Item | Pattern | Example |
|---|---|---|
| Mesh object | `Type_Name` | `SM_Crate_A` |
| Collider | `UCX_` or `COL_` prefix per project | `UCX_SM_Crate_A` |
| LOD | `_LOD0`, `_LOD1` suffix | `SM_Crate_A_LOD1` |
| Material | `M_Name` | `M_Wood_Old` |
| Armature | `Armature` or `Rig_Name` | `Rig_Hero` |

- Remove `.001` suffixes; duplicates mean orphaned data. Mesh data name matches the object name.
- One collection per exportable asset; collections named for the output file (`SM_Crate_A`). Use separate collections for LODs, colliders, and excluded helpers.

## Geometry checks
- UVs: every mesh has a non-overlapping UV0 unless deliberately mirrored; a UV1 for lightmaps when baked lighting is used; no UVs outside intended tiling.
- Normals: consistent outward facing, no flipped faces; choose smooth or flat per intent; verify tangents compute (needs UVs).
- Remove loose vertices, zero-area faces, and doubles; triangulate only if the pipeline requires it.
- Delete unused materials, empty slots, and orphan data before export.

## Batch scripting
Check, then export each collection to its own file.
```python
import bpy, os
out = bpy.path.abspath("//../Export")
for col in bpy.data.collections:
    for o in col.objects:
        if o.type == 'MESH' and o.scale[:] != (1.0, 1.0, 1.0):
            print("Unapplied scale:", o.name)
    bpy.ops.object.select_all(action='DESELECT')
    for o in col.objects:
        o.select_set(True)
    bpy.ops.export_scene.fbx(filepath=os.path.join(out, col.name + ".fbx"),
                             use_selection=True)
```
- Run headless for CI or bulk work: `blender -b file.blend --python script.py`; verify the flags for your version.
- Scripts live in the repo, take paths as arguments, and fail loudly on violations.

## Files and libraries
- Separate source from export: `Source/` holds .blend, textures, and PSD files; `Export/` holds generated FBX/glTF. Exports are reproducible, so never hand-edit them.
- Use linked libraries for shared rigs and kits; keep paths relative and the library in a stable folder. Make overrides instead of editing linked data.
- Pack nothing into the .blend that should stay an external texture; keep relative paths.

## Version control
- .blend files are large binaries that do not merge. Use Git LFS or a binary-aware VCS, and keep a single working copy.
- Version through commits and a short name suffix only for milestones (`_v02`); do not keep `.blend1` backups in the repo (ignore them).
- Store export scripts and a checklist alongside the file. Never commit secrets or machine paths (`secret-handling`).

## Export addons
- Prefer the built-in FBX and glTF exporters. Third-party addons (for example batch or Unity-focused exporters) must be pinned to a version and documented in the repo; verify compatibility with your Blender release.
