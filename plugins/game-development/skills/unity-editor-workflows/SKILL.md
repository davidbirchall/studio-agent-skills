---
name: unity-editor-workflows
description: Unity Editor productivity and workflows - custom inspectors and PropertyDrawers, inspector attributes, OnValidate, editor-only code separation with Editor folders, asmdefs and UNITY_EDITOR, gizmos and debug draws, menu items and editor scripts for repeatable tasks, ScriptableObject-based tooling, validation tooling, prefab workflow, Play Mode domain reload settings and pitfalls, layouts and shortcuts, version control hygiene, batchmode automation, Test Framework runs, and Cinemachine and Timeline hand-offs. Load when building editor tools, improving data-authoring workflows, validating project data, or configuring the Editor.
---

# Unity editor workflows

Menu paths, option names, and APIs differ between Unity 6 and 2022 LTS; verify against the installed Unity version. Folder and VCS rules: `unity-project-patterns`.

## Inspector attributes
- Make data self-explanatory to designers: `[Header]`, `[Tooltip]`, `[Range]`, `[Min]`, `[Space]`, `[TextArea]`. Add a tooltip to every tunable.
- `[CreateAssetMenu(fileName = "...", menuName = "Game/...")]` for ScriptableObjects, with a consistent menu root.
- `[ContextMenu("Do thing")]` for quick developer actions on a component.
- Validate in `OnValidate` (clamp values, check references, auto-fill). Keep it cheap and side-effect free: it runs on load and on every inspector edit. Do not create or destroy objects or call `SendMessage` there.
```csharp
private void OnValidate()
{
    _speed = Mathf.Max(0f, _speed);
    if (_target == null) Debug.LogWarning($"{name}: target missing", this);
}
```

## Custom inspectors and drawers
- Prefer attributes and `PropertyDrawer`s over whole-inspector overrides; they compose across types. Write a `CustomEditor` only for buttons, previews, or complex layouts.
- Use `SerializedObject` and `SerializedProperty` so undo, multi-edit, and prefab overrides work. Call `serializedObject.Update()` and `ApplyModifiedProperties()`. If mutating objects directly, call `Undo.RecordObject` and `EditorUtility.SetDirty`.
- UI Toolkit or IMGUI for editor UI: verify which the installed version recommends for inspectors, and be consistent.
- Decision rule: a drawer for any field type reused in 3 or more components; a custom editor only when a button, preview, or conditional layout is needed; plain attributes otherwise.

## Editor-only code
- Place editor scripts in an `Editor` folder or an Editor-only asmdef (include platform: Editor). Runtime assemblies must never reference `UnityEditor`.
- Where editor code must sit beside runtime code, wrap it in `#if UNITY_EDITOR` and keep blocks small. Build failures from stray `UnityEditor` usings appear only at build time, so compile a player build in CI (`unity-build-release`).

## Gizmos and scene tools
- Draw spawn areas, ranges, paths, and triggers with `OnDrawGizmos` or `OnDrawGizmosSelected`. Gizmos are free at runtime in builds because they are editor-only, but keep the code behind `#if UNITY_EDITOR`.
- Use `Debug.DrawLine` or `Debug.DrawRay` for temporary runtime debugging. Remove noise before commit.
- Scene view handles (`Handles`) for editing positions and radii directly.

## Automation and tooling
- Script repeatable chores with `[MenuItem("Tools/Game/...")]` methods: batch re-import, prefab setup, scene validation. Menu items must be undo-aware and idempotent.
- Build ScriptableObject-driven tools (config registries, content tables) so designers edit data, not code.
- Validation: a menu command and a CI check that scans for missing references, missing scripts, naming violations, oversize textures, and scenes not in build (`unity-asset-management`). Fail CI on errors.
```csharp
public static class ProjectValidator
{
    [MenuItem("Tools/Game/Validate Prefabs")]
    public static void Run()
    {
        int errors = 0;
        foreach (var guid in AssetDatabase.FindAssets("t:Prefab", new[] { "Assets/_Project" }))
        {
            var path = AssetDatabase.GUIDToAssetPath(guid);
            var root = AssetDatabase.LoadAssetAtPath<GameObject>(path);
            if (GameObjectUtility.GetMonoBehavioursWithMissingScriptCount(root) > 0)
            { Debug.LogError($"Missing script: {path}", root); errors++; }
        }
        if (Application.isBatchMode && errors > 0) EditorApplication.Exit(1);
    }
}
```
- Run Editor scripts headless with batchmode and `-executeMethod` (verify flags in the installed editor docs). The same entry points serve CI (`unity-build-release`).

## Play Mode and iteration
- Enter Play Mode Options can skip domain and scene reload for faster iteration (verify the exact setting names). With domain reload off, static fields and static event subscriptions persist between runs. Reset them with `[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]` and avoid statics for state.
- Test with domain reload enabled before merging; a static-state bug can hide when it is off.
```csharp
private static int s_count;
[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
private static void ResetStatics() => s_count = 0;
```
- Rule of thumb: if entering Play Mode takes more than about 5 seconds, turn on the skip options and add reset hooks for every static; if the project has few statics, leave the defaults.
- Save custom window layouts and share them in the repo or onboarding doc. Set shortcuts through the Shortcuts manager rather than editing files by hand.

## Prefab and scene hygiene
- Edit prefabs in Prefab Mode. Review overrides before applying.
- Do not leave scenes dirty or modified by accident: check `git status` before committing and revert incidental changes such as lighting data, reserialisation, or moved objects.
- Keep scenes small and additive to limit conflicts (`unity-project-patterns`).

## Testing and hand-offs
- Run Edit Mode and Play Mode tests from the Test Runner window locally, and in batchmode in CI. Keep tests in their own asmdefs (`unity-architecture`).
- Cinemachine cameras and Timeline sequences are authored in the Editor: keep the camera rig as prefabs and name virtual cameras clearly. Design details in `camera-systems`; verify package versions.
- Profiling in the Editor misleads; profile builds (`game-profiling`).

## Batchmode example
```
Unity -batchmode -nographics -quit -projectPath . \
  -executeMethod ProjectValidator.Run -logFile Logs/validate.log
```
- Verify flags and exit-code behaviour for the installed editor. Always pass `-logFile` and archive it. A non-zero exit must fail the CI job.

## Anti-patterns
- Runtime assemblies referencing `UnityEditor`, discovered only at build time.
- `OnValidate` that instantiates objects, loads assets, or calls into other systems.
- Editing serialised fields directly without `SerializedObject` or `Undo`, so edits are lost or not undoable.
- Menu items that are not idempotent or silently modify many assets without a log.
- Trusting Editor frame times for performance decisions.

