---
name: vfx-implementation
description: Technical implementation of visual effects in Unity - choosing between the Particle System and VFX Graph, GPU versus CPU cost, pooling and lifetime management, overdraw and transparency sorting, LOD and culling, exposed parameters for gameplay, event-driven triggering, flipbook textures, shader-driven effects, mobile limits, determinism, performance budgets, and effect prefab organisation. Load when building, integrating, triggering, or budgeting effects such as impacts, trails, ambient particles, and screen or shader-driven effects.
---

# VFX Implementation

Builds on `material-shader-workflows` and `asset-optimisation`; textures come from `2d-asset-pipeline`. This covers technical integration, not artistic design. VFX Graph availability, requirements, and features depend on Unity version, pipeline, and platform; verify against the installed versions.

## Choose the system
| Need | Prefer |
|---|---|
| Few hundred particles, CPU collision, simple gameplay-coupled effects, mobile, wide device support | Particle System |
| Tens of thousands or more particles, GPU simulation, complex forces | VFX Graph (requires compute support) |
| Mesh or skinned mesh driven, sub-frame deterministic needs | Evaluate case by case |
- Do not mix systems in one effect unless required. Check target devices support compute before committing to VFX Graph.
- GPU simulation moves cost off the CPU but still costs fill rate; CPU particles can read gameplay state easily.

## Effect prefab organisation
- One prefab per effect with a single root; sub-emitters and lights as children.
- Root carries a small controller script exposing Play, Stop, and parameters; gameplay code never touches child emitters directly.
- Folder by category (impacts, ambient, UI, weapons). Prefix names: `VFX_Impact_Metal`.
- Keep materials and textures local to the effect folder or in shared libraries per `material-shader-workflows`.

## Triggering and parameters
- Trigger by event (hit, spawn, state change), not by polling in `Update`.
- Expose gameplay inputs as named parameters: intensity, colour, direction, scale. Cache property IDs for VFX Graph and Shader properties.
- Set parameters before Play, and verify the exposed property API names for your VFX Graph version.

```csharp
public sealed class ImpactVfx : MonoBehaviour
{
    [SerializeField] ParticleSystem[] systems;
    public void Play(Vector3 pos, Vector3 normal)
    {
        transform.SetPositionAndRotation(pos, Quaternion.LookRotation(normal));
        foreach (var s in systems) s.Play(true);
    }
}
```

## Pooling and lifetime
- Pool frequently spawned effects; never `Instantiate`/`Destroy` per hit.
- Return to pool on completion: use the particle stop action callback or a timer from the known duration, and clear state (`Clear`, reset parameters) on reuse.
- Cap simultaneous instances per effect type; drop or recycle the oldest when over cap.
- Looping effects need an explicit owner that stops them; no orphaned emitters.

## Overdraw and sorting
- Transparent overdraw is the main cost. Reduce particle size and count, trim quad area to the visible shape, use tighter meshes for particles.
- Prefer additive or premultiplied blending for fewer sorting problems; avoid large soft-edged quads close to the camera.
- Control sort via sorting fudge, priority, or distance; check with the pipeline's overdraw view.
- Soft particles and depth reads cost bandwidth, especially on mobile; verify they are needed.

## Textures and shader-driven effects
- Flipbooks: pack frames on a sheet, keep dimensions aligned and compress; blend frames only if needed.
- Use channel-packed masks and shared noise textures; one texture serving several effects saves memory.
- Shader-driven effects (dissolve, fresnel, scrolling UVs, distortion) belong in shared Shader Graph assets driven by exposed properties or `MaterialPropertyBlock`.
- Use unscaled or scaled time deliberately so effects respect pause and slow motion.

## LOD and culling
- Set culling mode and bounds so off-screen systems stop simulating; fix bounds for GPU effects, as incorrect bounds cause popping.
- Fade or disable effects by distance; reduce emission rate at lower quality levels.
- Cap per-frame spawns; budget by effect category.

## Mobile limits
- Keep particle counts low, avoid collision and trails on many systems, avoid full-screen transparent layers, and favour fewer, larger-lifetime-friendly emitters.
- Test on the lowest-spec target device; quality tiers should swap or disable heavy effects.

## Determinism and budgets
- Set explicit random seeds when an effect must repeat identically (replays, networking visuals); gameplay must not depend on particle results.
- Define budgets per scene: max live particles, max effect instances, max overdraw layers, ms of GPU time.
- Profile with the Frame Debugger and profiler on target hardware; see `asset-optimisation` for texture and memory budgets.

## Checklist
- System choice justified for target platforms.
- Prefab has a controller; parameters exposed and IDs cached.
- Pooled, capped, and cleaned on reuse.
- Overdraw and bounds checked; quality tiers defined.
- Within particle and GPU budgets on the lowest target device.

## See also

Optional, if installed: game-performance (the game-development plugin) for the broader discipline this skill applies. This skill stands on its own.
