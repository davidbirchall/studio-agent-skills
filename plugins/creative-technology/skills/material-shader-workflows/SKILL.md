---
name: material-shader-workflows
description: Technical material and shader integration for Unity - choosing a render pipeline (URP, HDRP, Built-in) and checking asset compatibility, Shader Graph versus hand-written HLSL, shared master materials, material variants and instancing, shader keywords and variant explosion, property naming, channel-packed mask textures, PBR texture conventions, colour space, SRP Batcher compatibility, shader stripping and warmup, and debugging with the Frame Debugger. Load when setting up materials, authoring or reviewing shaders, packing textures, or diagnosing pink materials, variant counts, or batching problems.
---

# Material and Shader Workflows

Builds on `3d-asset-pipeline`, `2d-asset-pipeline`, and `asset-optimisation`; feeds `vfx-implementation`. Shader and material features differ by Unity version and render pipeline; verify every menu, node, and keyword against the installed version and pipeline (URP, HDRP, Built-in).

## Pipeline choice and compatibility
- Pick one pipeline per project early; shaders and materials are not portable between them without conversion.
- URP: broad platform reach, mobile and VR friendly. HDRP: high-end desktop and console, heavier cost and feature set. Built-in: legacy; avoid for new projects.
- Check third-party assets and imported materials declare support for the active pipeline. Pink materials usually mean a shader/pipeline mismatch.
- Use the pipeline's upgrade or conversion tooling as a first pass only, then inspect results by hand.

## Shader Graph vs HLSL
- Shader Graph: default for artist-editable surface and unlit effects; fast to iterate, pipeline-aware.
- Hand-written HLSL: custom lighting, compute-adjacent work, tight control over variants, or logic that becomes unreadable as a graph.
- Wrap repeated graph logic in Sub Graphs. Use Custom Function nodes sparingly and keep HLSL in files under version control.
- Keep one shader per material family, not one per object.

## Shared master materials
- Build a small set of master shaders (opaque lit, cutout, transparent, unlit, foliage) and derive materials from them.
- Use material variants (where supported) for per-prop or per-biome overrides so changes in the parent propagate.
- Avoid per-instance material edits at runtime: `renderer.material` clones the material. Use `sharedMaterial` or a `MaterialPropertyBlock`, and verify the batching impact for the pipeline in use.

## Property naming
- Prefix by role and keep consistent: `_BaseMap`, `_BaseColor`, `_NormalMap`, `_MaskMap`, `_EmissionColor`.
- Match the pipeline's built-in names where the Lit shader already defines them so tooling and scripts keep working.
- Set the Shader Graph Reference name explicitly; do not rely on auto-generated names.
- Cache IDs in code: `static readonly int BaseColorId = Shader.PropertyToID("_BaseColor");`

## Texture conventions
| Map | Channels | Colour space | Notes |
|---|---|---|---|
| Albedo/base | RGB (A opacity if needed) | sRGB | No baked lighting |
| Normal | RG(B) | Linear, normal map type | Confirm OpenGL vs DirectX green direction |
| Metallic + smoothness | R metal, A smoothness | Linear (sRGB off) | Smoothness is the inverse of roughness |
| Packed mask | e.g. R metal, G occlusion, B detail, A smoothness | Linear | Document the layout in the shader |
- Data textures (masks, normals, height) are always linear; colour textures are sRGB. Project colour space should be Linear for PBR.
- Channel packing cuts samples and memory; keep one agreed layout per master shader and record it in the asset spec.
- Power-of-two or block-aligned sizes help compression; see `asset-optimisation`.

## Variants and keywords
- Every `multi_compile` or `shader_feature` multiplies variants. Count them before adding.
- Prefer `shader_feature` for material-driven toggles (stripped if unused) and `multi_compile` only for runtime-switched keywords.
- Prefer local keywords over global ones; prefer a material property branch over a keyword when the cost is trivial.
- Check variant counts in the build log or shader compile report; set a budget per shader.

## Batching and instancing
- SRP Batcher requires the shader to declare properties in a single `UnityPerMaterial` constant buffer; Shader Graph shaders usually comply. Check the shader inspector for compatibility.
- GPU instancing helps repeated identical meshes and materials; do not assume it combines with SRP Batcher, and verify which applies for your pipeline.
- Share materials across meshes; fewer unique materials means fewer SRP Batcher state changes.
- Use atlases or texture arrays to share materials across variations.

## Stripping and warmup
- Strip unused variants via build settings and shader preprocessing; verify the stripping options in the installed version.
- Warm up shaders (shader variant collections or the pipeline's prewarm option) before gameplay to avoid first-use hitches, especially on mobile and consoles.
- Always test stripping on a real build; a stripped needed variant renders pink only in the player.

## Debugging
- Frame Debugger: step through draw calls, read the reason a batch broke, and inspect keywords and properties per draw.
- Test in a development build on target hardware; Editor results can hide stripped or unsupported variants.
- Use the render pipeline's debug views (albedo, normals, overdraw) where available.
- Pink: check pipeline match, compile errors in the console, and missing variants.

## Checklist
- Pipeline compatibility confirmed for all imported materials.
- Texture colour spaces and packing layout documented.
- SRP Batcher compatible; no runtime `renderer.material` leaks.
- Keyword and variant count within budget; warmup in place.
- Verified in a target-platform build.

## See also

Optional, if installed: game-profiling (the game-development plugin) for the broader discipline this skill applies. This skill stands on its own.
