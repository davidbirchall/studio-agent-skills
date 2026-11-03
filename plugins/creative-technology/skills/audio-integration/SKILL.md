---
name: audio-integration
description: Technical audio integration in Unity - formats and import settings (load type, compression, sample rate, force mono), loudness targets and normalisation, AudioMixer groups, snapshots and ducking, voice limits and priorities, AudioSource pooling, spatial audio settings, music looping and transitions, adaptive music, localised voice-over, FMOD or Wwise middleware choice, naming conventions, memory budgets, and platform specifics. Load when importing audio, building mixers, wiring sound to gameplay, budgeting audio memory, or choosing between built-in audio and middleware.
---

# Audio Integration

Builds on `asset-optimisation`; cues often come from `animation-integration` events and `vfx-implementation`. This covers technical integration, not sound design. Import options and mixer features vary by Unity version and platform; verify against the installed version and target platforms.

## Source formats
- Deliver uncompressed WAV (or lossless) masters at 44.1 or 48 kHz, 16 or 24 bit; let Unity compress per platform.
- Never re-compress already lossy files; artefacts stack.
- Trim silence and leading padding; loops must be sample-accurate with no clicks at the seam.

## Import settings
| Clip type | Load type | Compression | Notes |
|---|---|---|---|
| Short SFX (UI, impacts) | Decompress On Load or Compressed In Memory | ADPCM or Vorbis | Low latency; preload |
| Frequently repeated SFX | Decompress On Load | ADPCM | Cheap CPU, higher memory |
| Long ambience, VO | Compressed In Memory | Vorbis/platform codec | Balance memory and CPU |
| Music | Streaming | Vorbis/platform codec | Lowest memory; watch disk and seek cost |
- Force To Mono for 3D positional sounds and non-stereo content; it halves memory.
- Lower sample rate for low-frequency or background sounds; verify audibly.
- Preload Audio Data off for rarely used clips to avoid scene-load cost; verify the effect on first-play latency.
- Set per-platform overrides for mobile and web; verify option names in the installed version.

## Loudness
- Agree a target (for example integrated loudness per category) and measure, not eyeball. Normalise assets consistently so mix levels are set in the mixer, not in clip volumes.
- Keep headroom on the master bus; avoid clipping when many voices overlap.
- Check on the target output: speakers, headphones, mobile speaker.

## AudioMixer
- Groups: Master, Music, SFX, UI, Voice, Ambience; sub-groups only when needed.
- Expose parameters (volume per group) for settings menus; set them in dB, convert from a linear slider with `Mathf.Log10(Mathf.Max(v, 0.0001f)) * 20f`.
- Snapshots: pause, underwater, low health; transition with a time.
- Ducking: use a Duck Volume effect on music or ambience, sidechained from Voice; tune attack and release.
- Never set volumes by mixer parameters on the hot path every frame.

## Voices and pooling
- Limit simultaneous voices (project audio settings) and assign priorities: voice and critical cues high, ambience low.
- Pool AudioSources behind an audio service; never `AddComponent` or `Instantiate` per shot.
- Use `PlayOneShot` for fire-and-forget sounds; use pooled sources when you need stop, fade, or position tracking.
- Cap instances per sound (for example footsteps, bullet hits) and add pitch or volume variation from a small clip set.

```csharp
public interface IAudioService { void Play(SoundCue cue, Vector3 position); }
```

## Spatial audio
- 2D for UI and music; 3D for world sounds. Set spatial blend, min/max distance, and rolloff curve per category, not per clip.
- Use a custom rolloff for large worlds; avoid very large max distances that keep sources audible and costly.
- Doppler and spread: leave defaults unless needed. Use the platform spatialiser plugin only after verifying support.

## Music
- Loop with the loop flag on a seamless asset; for intros plus loops, schedule with `AudioSettings.dspTime` and `PlayScheduled`.
- Transitions: crossfade on the beat or bar; keep stems tempo-matched.
- Adaptive music: layered stems controlled by game state parameters, or horizontal re-sequencing; keep stems synchronised from one start time.

## Localisation of voice-over
- Key audio by ID (not file name) and load by locale; keep locale variants identical in format, loudness, and loop points.
- Do not bake text-dependent timing into code; lip-sync and subtitles read timing data.
- Stream or load on demand per locale to stay within memory.

## Middleware (FMOD, Wwise)
- Choose for large projects needing designer-driven mixing, complex adaptive music, runtime profiling, or many events. Built-in audio suffices for small projects.
- Cost: extra integration, licensing, build size, and a second toolchain. Verify licence terms and Unity version support.
- Treat middleware events as data: game code posts events and sets parameters by ID and does not know about banks.
- Store licence keys and credentials per `secret-handling`; never commit them.

## Naming and budgets
- `SFX_Weapon_Rifle_Fire_01`, `MUS_Level1_Combat`, `VO_NPC_Guard_Greet_en`. Prefix by category, then source, then variant and locale.
- Budget memory per category and platform; check loaded clips in the profiler on target hardware.
- Mobile: prefer compressed formats, fewer voices, and handle interruption and focus loss. Consoles and web have their own constraints; verify per platform.

## Testing
- Test the audio service and cue selection as plain C# (see `test-discipline`): caps, priorities, and pool reuse.
- Manual pass on device: levels, ducking, loops, and interruption.

## See also

Optional, if installed: unity-asset-management (the game-development plugin) for the broader discipline this skill applies. This skill stands on its own.
