---
name: 2d-asset-pipeline
description: Technical pipeline for 2D assets in Unity - source PSD/Aseprite versus exported files, naming, sprites and pixels per unit, pivots, filter mode for pixel art, power-of-two and compression choices, sRGB versus linear colour space, sprite atlases, 9-slice, tilemaps and tile palettes, UI assets, and import validation with AssetPostprocessor. Load when importing sprites, textures, or UI art into Unity, configuring atlases and tilemaps, or automating 2D import rules.
---

# 2D Asset Pipeline

Builds on `asset-optimisation` for budgets and compression; animated sprites continue in `animation-integration`, materials in `material-shader-workflows`. Texture importer and Sprite Atlas options differ across Unity versions; verify against the installed version.

## Source and export
- Source files (PSD, Aseprite, Krita) live in `Source/`; exported PNGs in `Assets/Art/`. Do not commit or import layered sources into Unity unless the project deliberately uses the importer for them.
- Export from the source with a repeatable preset or CLI/script; do not hand-export.
- Keep a clean canvas: trim only if pivots are set intentionally; otherwise keep consistent frame sizes.
- Use lossless PNG as the interchange format.

## Naming
| Item | Pattern | Example |
|---|---|---|
| Sprite | `spr_<name>` | `spr_hero_idle_00` |
| Sprite sheet | `sheet_<name>` | `sheet_hero` |
| UI | `ui_<screen>_<name>` | `ui_hud_heart` |
| Tile | `tile_<set>_<name>` | `tile_grass_corner` |
| Texture | `tex_<name>` | `tex_noise_soft` |

- Lowercase, ASCII, no spaces; frame number suffix with zero padding.

## Sprites and pixels per unit
- Choose one Pixels Per Unit for the project (for example 16, 32, or 100) and apply it everywhere, so one world unit equals a known pixel count.
- Pixel art: Filter Mode Point, compression None, no mipmaps; match the camera setup (pixel-perfect options) per project.
- Smooth art: Bilinear, mipmaps only if scaled in perspective or heavily minified.
- Pivots: set per sprite by convention (bottom-centre for characters, centre for effects); store in the import preset, not by hand per sprite.
- Sprite mode Multiple with automatic or grid slicing for sheets; keep sheet cell sizes consistent.

## Texture size and compression
- Prefer power-of-two dimensions for mipmaps and compressed formats; some formats (for example PVRTC) require them, while others do not. Verify platform rules.
- Respect compression block sizes (multiples of 4 for common block formats); verify your target format.
- Max Size caps the imported size; do not import 4K sources for small sprites.
- Compression per platform: pick desktop, mobile, and console formats in platform overrides (`asset-optimisation`). Avoid compression on pixel art and sharp UI unless tested.

## Colour space
- Colour textures: sRGB on. Data textures (masks, normal maps, noise, lookup tables): sRGB off.
- Project colour space (linear or gamma) is a global decision; confirm before importing, since gamma projects differ in blending.
- Premultiplied versus straight alpha: export and import consistently; fix fringing at the source.

## Atlases
- Use Sprite Atlas assets to group sprites that render together (same screen or level). Fewer textures means fewer batch breaks.
- Group by usage, not by type; do not put every sprite in one atlas, since loading it loads all.
- Add padding to prevent bleeding; set atlas filter and compression separately from sources.
- Verify atlas packing in Play Mode and builds (packing behaviour depends on editor settings); check the atlas preview for overflow into extra pages.

## 9-slice and UI
- Set sprite borders in the importer, then use Sliced image type for panels and buttons; borders should be in source pixels.
- Keep UI sprites in a separate atlas per screen or feature. Use Single sprite mode, mipmaps off.
- Export at the highest reference resolution used and test scaling at target aspect ratios.

## Tilemaps
- Tile Palette per tileset; the tile size matches Pixels Per Unit and grid cell size.
- Tile sprites have identical dimensions and consistent pivots; tile edges extruded or padded to avoid seams.
- Rule or Animated Tiles for variation; keep tile assets in a folder per tileset.

## Import automation
```csharp
using UnityEditor;

public class SpriteImportRules : AssetPostprocessor
{
    void OnPreprocessTexture()
    {
        if (!assetPath.StartsWith("Assets/Art/Sprites/")) return;
        var t = (TextureImporter)assetImporter;
        t.textureType = TextureImporterType.Sprite;
        t.spritePixelsPerUnit = 32;
        t.mipmapEnabled = false;
        if (assetPath.Contains("/Pixel/")) t.filterMode = UnityEngine.FilterMode.Point;
    }
}
```
- Scope rules by folder; run validation in CI (`test-discipline`) and fail on wrong PPU or non-power-of-two sizes where required.

## See also

Optional, if installed: unity-asset-management (the game-development plugin) for the broader discipline this skill applies. This skill stands on its own.
