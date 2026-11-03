# squad-skills-game-development

Game development engineering skills for Unity and C#: C# conventions, project patterns, architecture, editor workflows, asset management, gameplay and state systems, input, character controllers, cameras, UI, save/load, game AI, physics, procedural generation, performance, profiling, and build and release.

Version `0.4.0`, 24 skills.

## Install

```
copilot plugin install ./plugins/game-development
```

## Skills

| Skill | Purpose | Load when |
|-------|---------|-----------|
| `camera-systems` | Cinemachine, follow/aim, shake, collision | Setting up cameras |
| `character-controller-systems` | Movement, grounding, slopes, kinematic vs physics | Building a character controller |
| `csharp-conventions` | Unity-flavoured C# style, nullability, allocations, async | Writing or reviewing C# scripts |
| `game-accessibility` | Accessibility in games - vision (colour-blind-safe palettes, non-colour cues, text scaling, contrast, high-contrast mode, screen reader and... | Designing or reviewing game options, menus, controls, UI, audio, or when auditing a game for accessibility |
| `game-ai` | Behaviour trees, FSMs, perception, navigation | Implementing enemy or NPC AI |
| `game-analytics` | Game telemetry in Unity - event schema (session, level, economy, tutorial, error events), typed event classes and naming, batching and offline queue,... | Adding telemetry to a game, designing events, analysing player behaviour, or tuning difficulty and economy from data |
| `game-localisation` | Localisation engineering for Unity and C# games - string tables and keys with no hardcoded text, Unity Localization package basics, locale-aware... | Adding text to a game, preparing for translation, adding a language, or debugging missing glyphs, overflow, or wrong formatting |
| `game-performance` | Frame budget, GC, pooling, batching, jobs/Burst | Optimising runtime performance |
| `game-profiling` | Profiler, Memory Profiler, Frame Debugger, device capture | Finding performance problems |
| `game-state-management` | Game flow, state machines, scene transitions | Managing game and scene state |
| `game-store-release` | Store distribution preparation for Unity (C#) games across PC, console and mobile stores in a platform-neutral way - store requirements checklist... | Preparing a game for a store submission, integrating store services, or planning release and post-release operations |
| `gameplay-systems` | Abilities, health, inventory, interaction, data-driven rules | Implementing gameplay features |
| `input-systems` | Input System actions, rebinding, devices, buffering | Wiring player input |
| `multiplayer-netcode` | Multiplayer networking engineering for Unity and C# games - deciding whether multiplayer is worth its cost, topologies (authoritative client-server,... | Adding or evaluating multiplayer, designing network architecture, syncing gameplay state, or debugging lag, desync, or cheating |
| `physics-systems` | Layers, queries, fixed timestep, joints, determinism | Working with physics |
| `procedural-generation` | Seeded RNG, noise, WFC, validation, reproducibility | Generating content at runtime |
| `save-load-systems` | Serialization, versioning, migration, slots, integrity | Persisting game data |
| `ui-systems` | uGUI vs UI Toolkit, navigation, binding, scaling | Building in-game UI |
| `unity-architecture` | Composition, ScriptableObjects, events, dependency wiring | Designing runtime structure |
| `unity-asset-management` | Import settings, Addressables, loading, memory | Adding or loading assets |
| `unity-build-release` | Build pipeline, profiles, CI, platforms, versioning | Building and shipping |
| `unity-editor-workflows` | Custom inspectors, tooling, validation, editor scripts | Building editor tools |
| `unity-project-patterns` | Folder layout, assemblies, namespaces, scenes, prefabs | Setting up or reorganising a project |
| `unity-testing` | Automated testing for Unity projects - Unity Test Framework with NUnit, Edit Mode versus Play Mode tests, test assembly definitions, structuring code... | Adding tests to a Unity project, making game code testable, setting up CI test runs, or fixing flaky tests |

## Related plugins

Works well with: creative-technology, game, shared, platform-engineering. Skills may mention skills from other plugins in a short "See also" note; each skill stands on its own if those plugins are not installed.
