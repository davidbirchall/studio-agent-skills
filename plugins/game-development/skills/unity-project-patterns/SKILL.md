---
name: unity-project-patterns
description: Unity project structure and repository hygiene - folder layout, naming, scene organisation with bootstrap and additive scenes, prefab rules for nesting, variants and overrides, ScriptableObject use for config and event channels, avoiding Resources, package manifest pinning, Git setup with .gitignore, .gitattributes, Git LFS, force-text serialization and UnityYAMLMerge, meta files, tags and layers policy, Project Settings as code, render pipeline asset setup (URP default), assembly definitions, a project README for future sessions, and branching for binary assets. Load when creating a Unity project, reorganising folders, setting up version control, or recording project conventions.
---

# Unity project patterns

Menu paths and setting names change between Unity 6 and 2022 LTS; verify against the installed Unity version. URP is the default render pipeline for this plugin. Code conventions: `csharp-conventions`. Runtime structure: `unity-architecture`.

## Layout
- Put all first-party content under one root such as `Assets/_Project` so third-party packages and imported assets stay separate. Organise by feature (`Player/`, `Inventory/`) with type subfolders inside, or by type at the top level for small projects. Pick one and apply it everywhere.
- Standard subfolders: `Art`, `Audio`, `Prefabs`, `Scenes`, `Scripts`, `ScriptableObjects`, `Settings`, `Tests`. Editor code in `Editor/` folders with their own asmdef.
- Naming: PascalCase assets with a type prefix or suffix chosen once and recorded in the conventions doc (`PF_Enemy`, `T_Hero_Albedo`, or `Enemy.prefab`). No spaces. Names are stable; renaming through the Editor keeps GUIDs and references.
- No assets in the `Assets` root. Keep third-party imports in a clearly named folder and do not edit them in place; copy or wrap.

## Reference layout
```
Assets/_Project/
  Art/            Materials/ Models/ Textures/ Animations/
  Audio/          Music/ Sfx/ Mixers/
  Prefabs/        Characters/ Environment/ UI/
  Scenes/         Bootstrap.unity Level01_Env.unity Level01_Gameplay.unity
  Scripts/
    Core/         Game.Core.asmdef            (no dependencies)
    Gameplay/     Game.Gameplay.asmdef        (-> Core)
    UI/           Game.UI.asmdef              (-> Core)
    Editor/       Game.Editor.asmdef          (Editor only; -> all)
  ScriptableObjects/  Items/ Enemies/ Events/
  Settings/       URP/ InputActions/ Quality/
  Tests/          EditMode/ PlayMode/         (own asmdefs)
Assets/ThirdParty/    untouched imports
Packages/manifest.json  packages-lock.json
```
- Dependencies point one way: `Core` knows nothing of `Gameplay` or `UI`. A cycle means a missing interface or event channel (`unity-architecture`).
- Create the asmdefs on day one. Retrofitting them into a project with 500 scripts and implicit references costs days; adding them early costs minutes. They also cut recompile time because only changed assemblies rebuild.
- Mark test assemblies with the Test Assemblies constraint (`UNITY_INCLUDE_TESTS`), so they never ship (`unity-testing`).

## Decision rules
- Under about 10 scripts and 1 developer: a flat `Scripts/` folder is fine; split once any folder passes about 20 files.
- Feature folders by default; type folders only for tiny prototypes.
- Scene over about 500 objects, or touched by more than 1 person per week: split additively.
- Asset referenced by exactly one prefab: keep it beside that prefab. Shared by 2 or more features: move to a shared folder.
- Input actions asset, URP assets, and Volume profiles live in `Settings/`. Verify Input System and URP package versions and their default asset locations in the installed Unity 6 project.

## Scenes
- A tiny bootstrap scene (index 0) creates persistent services, then loads the first content scene (`unity-architecture`).
- Split big levels into additive scenes: environment, lighting, gameplay, UI. Name them `Level01_Env`, `Level01_Gameplay`. Avoid several people editing one scene; split to reduce merge conflicts.
- Keep scenes thin: instances of prefabs, not hand-built hierarchies. Do not store global config inside scenes.
- Register scenes in the build deliberately (`unity-build-release`).

## Prefabs
- Anything instanced twice is a prefab. Use nested prefabs for composition and prefab variants for variations of a base.
- Keep overrides minimal and intentional. Review overrides before committing; revert accidental ones. Apply changes to the prefab asset, not as scene overrides.
- Do not unpack prefabs without reason. Prefabs reference assets, not scene objects.
- Edit in Prefab Mode and keep each prefab loadable without scene dependencies.

## ScriptableObjects
- Use for static configuration, shared data tables, and event channels (`unity-architecture`). One definition type, many assets.
- Do not use them as mutable runtime state without a reset strategy: in the Editor, changes persist after leaving Play Mode, and in builds they do not persist. Copy with `Instantiate` or reset in `OnEnable` if a runtime copy is needed.
- Use `[CreateAssetMenu]` with a fixed menu path and file name.

## Resources and packages
- Do not use `Resources/`. Everything inside is included in the build and loads at startup indexing. Use direct references or Addressables (`unity-asset-management`).
- Pin package versions in `Packages/manifest.json` and commit `Packages/packages-lock.json`. Upgrade deliberately, one package per commit, after checking release notes for your Unity version.
- Remove unused packages; each adds build size and compile time. Prefer registry packages over embedded copies.

## Version control
- Use Git with a Unity `.gitignore`: ignore `Library/`, `Temp/`, `Obj/`, `Logs/`, `UserSettings/`, and IDE and build output; commit `Assets/`, `Packages/`, and `ProjectSettings/`.
- Set Asset Serialization to Force Text and Version Control Mode to Visible Meta Files (verify the setting labels in the installed version).
- Always commit `.meta` files with their asset, including for folders. Never delete a `.meta` by hand; GUIDs link references.
- `.gitattributes` tracks binaries with Git LFS (textures, audio, models, video, large fonts, plugin binaries). Configure LFS before the first commit of such files; migrating history later is painful.
- Configure UnityYAMLMerge as the merge tool for `.unity` and `.prefab` files; verify its location and options for the installed editor.
- Branch strategy: short-lived branches, small scene and prefab changes, frequent rebases from main. For binary assets that cannot be merged, work on one copy at a time and use LFS file locking if collaborators join (verify host support).

## Tags, layers, and settings
- Define layers and tags in code constants or a small static class; never use string literals for `CompareTag` or layer names scattered in code. Prefer layers for physics and culling, tags sparingly.
- Treat `ProjectSettings/` as code: review diffs, and change it in focused commits. Document non-default settings.
- Keep render pipeline assets (URP asset, renderer data, quality levels) under `Settings/`, with one asset per quality tier, assigned through Graphics and Quality settings. Verify URP asset fields in the installed package version.

## Code and project README
- Define one asmdef per module and keep references acyclic (`unity-architecture`). Separate `Runtime`, `Editor`, and `Tests` assemblies.
- A README (the knowledge file a future AI session or you after a break reads first) states required Unity version, Git LFS install, open instructions, folder rules, branch rules, and how to run tests and builds. Pin the version in `ProjectSettings/ProjectVersion.txt` and require the exact editor.

## Anti-patterns
- Dropping everything in `Assets/` root or in `Resources/`.
- One giant scene that accumulates every change and merge conflict.
- Deleting `.meta` files, or committing `Library/`.
- Editing third-party packages in place instead of wrapping them.
- Scene objects holding global config that code finds with `FindObjectOfType`.
- Mutable ScriptableObjects used as save data.

## Checklist for a new project
- [ ] `.gitignore`, `.gitattributes` (LFS), Force Text, Visible Meta Files set before first commit.
- [ ] `Assets/_Project` skeleton and asmdefs created, with Runtime, Editor, and Tests split.
- [ ] Bootstrap scene is build index 0; scenes listed in build settings.
- [ ] Packages pinned and lock file committed; exact Unity version recorded.
- [ ] URP asset per quality tier under `Settings/` (verify against the installed URP version).
- [ ] README and CI (compile, tests, player build) in place.
