---
name: unity-build-release
description: Unity builds and release engineering - Build Profiles vs Build Settings, scripting backends Mono and IL2CPP, managed code stripping and link.xml, player settings and versioning, scripting define symbols, development vs release builds, scenes in build, batchmode CI builds with GameCI or the Unity CLI, BuildPipeline scripts, licence activation in CI, signing and platform requirements, size optimisation and build reports, release checklists, crash reporting and analytics, QA smoke tests on target hardware, rollback, and store submission. Load when setting up builds or CI, cutting a release, debugging build-only failures, or reducing build size.
---

# Unity build and release

Build UI, Build Profiles (Unity 6) vs Build Settings (older), option names, and CLI flags differ by version; verify against the installed Unity version and its documentation. Editor automation: `unity-editor-workflows`. Size and memory: `unity-asset-management`, `game-performance`.

## Repository layout for builds
```
Assets/_Project/Editor/Build/   BuildScript.cs  VersionStamp.cs  (Editor-only asmdef)
Assets/link.xml                 stripping preserve rules
ProjectSettings/                committed; reviewed per release
.github/workflows/              test.yml  build.yml   (or equivalent CI)
Builds/                         git-ignored output
```

## Settings
- Unity 6 introduces Build Profiles for per-target configuration (verify); 2022 LTS uses the Build Settings window. Keep one profile or configuration per target and environment, committed to the repo where supported.
- Scripting backend: Mono for fast iteration; IL2CPP for release on platforms that require it (iOS, consoles, WebGL) and for better runtime performance. Test IL2CPP builds early; some reflection and generic code fails only there.
- Managed code stripping removes unreferenced code. Protect reflection-used types with `[Preserve]` or a `link.xml` file, and test release builds for missing-type errors. Plugins using reflection and serializers often need entries.
- List scenes in the build explicitly and in order (bootstrap first). Verify no test or sandbox scenes ship. Prefer generating the list in the build script.
```xml
<linker>
  <assembly fullname="Game.Gameplay" preserve="all"/>
  <assembly fullname="Assembly-CSharp">
    <type fullname="Game.Net.Messages.*" preserve="all"/>
  </assembly>
</linker>
```
- Stripping level rule: start at the default; raise to High only after a release-build smoke test passes, and add `link.xml` entries for each missing-type error rather than lowering the level. Verify stripping options for the installed version.

## Versioning and identity
- Set company, product name, and bundle/application identifier once; changing the identifier later breaks store continuity.
- Version scheme: `MAJOR.MINOR.PATCH` for user-facing version, plus a monotonically increasing build number (Android version code, iOS build number). Derive the build number from CI run number or commit count; never reuse one.
- Inject version and commit hash into the build via the build script and show it in a debug overlay and crash reports.
```csharp
PlayerSettings.bundleVersion = "1.4.2";
PlayerSettings.Android.bundleVersionCode = int.Parse(Environment.GetEnvironmentVariable("BUILD_NUMBER") ?? "1");
PlayerSettings.iOS.buildNumber = Environment.GetEnvironmentVariable("BUILD_NUMBER") ?? "1";
```

## Define symbols and config
- Scripting define symbols per environment (`DEV`, `STAGING`, `RELEASE`). Keep the set small and set it in the build script, not by hand.
- Use data (ScriptableObject or remote config) for URLs, keys, and feature flags per environment; never commit secrets. Code behind defines must compile under every combination in CI.
- Development builds enable the profiler, script debugging, and `Debug.Log`; release builds do not. Never ship a development build. Strip or route logs (`csharp-conventions`).

## Automation and CI
- Build headless with batchmode: Unity CLI flags such as `-batchmode`, `-quit`, `-projectPath`, `-buildTarget`, and `-executeMethod` (verify flags for the installed version). GameCI provides maintained GitHub Actions for tests and builds; verify current action versions and image tags before adopting.
- A static `BuildPipeline.BuildPlayer` entry point takes target, output path, version, and defines, then returns a non-zero exit code on failure.
```csharp
public static void BuildRelease()
{
    var report = BuildPipeline.BuildPlayer(new BuildPlayerOptions {
        scenes = EditorBuildSettingsScene.GetActiveSceneList(EditorBuildSettings.scenes),
        locationPathName = "Builds/Game.exe", target = BuildTarget.StandaloneWindows64,
        options = BuildOptions.None });
    if (report.summary.result != BuildResult.Succeeded) EditorApplication.Exit(1);
}
```
- Reproducibility: pinned Unity version, pinned packages, clean checkout with LFS pulled, cache `Library/` between runs, deterministic version stamping. Same commit should give an equivalent build.
- Licence activation in CI: use the supported CI licensing method (verify current Unity licence and GameCI docs), store credentials as CI secrets, and return the licence after the job when required.
- CI order: compile and lint, Edit Mode and Play Mode tests (`unity-architecture`), validation scripts, player build per target, archive artefacts and the build report.

## Platform requirements
- Android: keystore kept outside the repo in CI secrets; App Bundle for Play; minimum and target API per store rules (verify current requirement).
- iOS: provisioning profile, signing certificate, and Xcode build from Unity's generated project; verify current Xcode and SDK requirements.
- Desktop: signing and notarisation where the platform requires.
- Consoles: follow the platform holder documentation and certification requirements; they are under NDA and change.
- Keep a per-platform checklist of permissions, privacy declarations, and capabilities.

## Size
- Read the Build Report (verify access method) and the Editor log for the largest assets. Fix big contributors first: textures, audio, duplicated dependencies, unused packages, and unstripped code.
- Use compression suited to platform and Addressables for downloadable content (`unity-asset-management`). Track size per build in CI and fail on regressions beyond a set threshold (for example more than 5% growth or 20 MB over the previous build).
- Input System and URP packages add size and shader variants; strip unused URP features and variants and verify the stripping settings against the installed package versions.

## Anti-patterns
- Building from a developer machine with local uncommitted changes.
- Reusing a build number, or bumping it by hand.
- Discovering IL2CPP or stripping failures only on release day.
- Shipping a development build, or a build with test scenes.
- Keystores, licence files, or API keys in the repository.
- Skipping a device smoke test because the Editor works.

## Release
- Checklist: version and build number bumped, release notes, release (not development) build, scenes and defines verified, tests green, symbols uploaded, size within budget, third-party licences and privacy policy updated.
- Hook up crash reporting and analytics with a vendor SDK (verify supported version); upload debug symbols for IL2CPP builds; respect consent and privacy rules. Test the integration in a release build.
- QA smoke test on real target hardware, including the lowest-spec device: install, first launch, new game, save and load (`save-load-systems`), purchase or key flows, suspend and resume, and performance against budget (`game-profiling`).
- Stage rollouts where the store allows it. Keep the previous build and its symbols for rollback; know in advance how to halt a rollout or hot-fix remote content. Follow each store's current submission checklist for ratings, screenshots, metadata, and compliance.

## See also

Optional, if installed: release-management (the platform-engineering plugin); ci-cd-workflows (the platform-engineering plugin) for the broader discipline this skill applies. This skill stands on its own.
