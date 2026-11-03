---
name: unity-testing
description: Automated testing for Unity projects - Unity Test Framework with NUnit, Edit Mode versus Play Mode tests, test assembly definitions, structuring code for testability with plain C# logic classes, interfaces and ScriptableObject data, testing coroutines and async with UnityTest, deterministic time and random number injection, input testing with Input System fixtures, scene and prefab smoke tests, balance data validation tests, performance tests, headless CI runs with batchmode and results XML, flaky test policy, and what not to test. Load when adding tests to a Unity project, making game code testable, setting up CI test runs, or fixing flaky tests.
---

# Unity testing

Verify Test Framework, Performance Testing, and Input System package versions and APIs against the installed Unity version. Strategy is in `test-discipline` and the shared testing-strategy skill if installed; architecture in `unity-architecture`; input in `input-systems`; CI builds in `unity-build-release`; speed in `game-performance`.

## Choose the mode
- Edit Mode tests run in the editor without entering play. Default for logic, data validation, editor tools, and serialisation. Fast.
- Play Mode tests run with the player loop. Use only for behaviour needing MonoBehaviour lifecycle, physics, scenes, or real frames.
- Push as much as possible down to Edit Mode. A pyramid of many Edit Mode tests and few Play Mode tests keeps feedback under a minute.

## Assemblies
- Create one test assembly per mode: `Game.Tests.EditMode` (Editor platform only) and `Game.Tests.PlayMode`. Enable the `UNITY_INCLUDE_TESTS` define constraint and reference `nunit.framework` and `UnityEngine.TestRunner`/`UnityEditor.TestRunner` (verify names).
- Reference the runtime assembly under test via asmdef; code in `Assembly-CSharp` cannot be referenced, so game code needs its own asmdefs (see `unity-project-patterns`).
- Never ship test assemblies in builds; keep them out of runtime asmdefs.

## Structure for testability
- Put rules in plain C# classes with no `UnityEngine.Object` dependency: damage, inventory, quests, economy. MonoBehaviours stay thin adapters that call them.
- Depend on interfaces for the clock, RNG, input, save storage, and services; pass them via constructor or `Init()`.
- Use ScriptableObject definitions as data, but create them in tests with `ScriptableObject.CreateInstance<T>()` and destroy them afterwards.
```csharp
public sealed class DamageCalc {
    readonly IRandom _rng;
    public DamageCalc(IRandom rng) => _rng = rng;
    public int Roll(int atk, int def) => Mathf.Max(1, atk - def + _rng.Range(0, 3));
}
[Test] public void Roll_NeverBelowOne() =>
    Assert.AreEqual(1, new DamageCalc(new FixedRandom(0)).Roll(1, 99));
```

## Determinism
- Inject `ITimeSource` (delta, now) instead of reading `Time.deltaTime` or `DateTime.Now` in logic. Tests advance a fake clock manually.
- Inject a seedable RNG; never call `UnityEngine.Random` inside logic. Tests use fixed or scripted sequences.
- Avoid `Time.timeScale` and real waits (`WaitForSeconds`) in assertions; step frames or a fake clock.

## Coroutines and async
- `[UnityTest]` returns `IEnumerator`; `yield return null` advances a frame. Use for Play Mode flows.
- Wait on conditions with a bounded loop or `WaitUntil` plus a frame cap, so a hang fails instead of timing out the run.
- For async code, use `[Test] async Task` (supported by Test Framework 1.4 and later; verify). `[UnityTest]` must return `IEnumerator`, so wrap tasks in a helper there.
- Prefer testing the logic behind a coroutine synchronously and keep one Play Mode test for the wiring.

## Input
- Use `InputTestFixture` (Input System package) in Play Mode: add a `Keyboard`/`Gamepad` device, `Press`/`Set`, then advance a frame. Call `base.Setup()`/`TearDown()` (verify).
- Test action maps and bindings by simulating devices, not by calling private handlers.
- Test gameplay logic by feeding it an `IInputSource` fake; reserve device simulation for binding tests.

## Scenes and prefabs
- Smoke test: for every scene in build settings (or a list), load it additively, wait a few frames, and assert no errors logged (`LogAssert`) and no missing references.
- Prefab test: instantiate each prefab, check required components, no missing scripts, and serialized references non-null. Destroy afterwards.
- Unexpected `Debug.LogError` fails a test by default; use `LogAssert.Expect` only for intended errors.

## Data validation
- Edit Mode tests load every definition asset and assert invariants: unique ids, non-negative costs, resolvable references, drop weights sum above zero, curves monotonic where required.
- Snapshot balance numbers (key stats, XP table) into a committed file; the test fails on drift, forcing a deliberate update in the same commit.
- Same validators can run as editor menu items and as CI tests.

## Performance tests
- Use the Performance Testing package (verify) with `Measure.Method()` or `Measure.Frames()` for hot paths and allocation counts; compare with a stored baseline.
- Run on a fixed machine or build target; noisy shared runners give meaningless timings. Assert on GC allocations (stable) before time (noisy).
- Profiling workflow is in `game-profiling`.

## CI headless
- Run: `Unity -batchmode -nographics -projectPath . -runTests -testPlatform EditMode -testResults results/editmode.xml -logFile -` (verify flags). Repeat with `PlayMode`.
- Do not pass `-quit` with `-runTests`; the runner exits itself (verify). Fail the job on a non-zero exit code and publish the NUnit XML.
- Cache the Library folder keyed by Unity version and manifest hash. Pin the editor version.
- Activate the license through a secret (see `secret-handling`); never commit it.

## Flaky tests
- A flaky test is a bug: quarantine promptly with a note in the project's issue or task log, then fix or delete within a couple of work sessions.
- Typical causes: real time, unseeded RNG, frame-count assumptions, shared static state, leftover scene objects. Reset statics and destroy created objects in `TearDown`.
- Never add blind retries or longer sleeps as the fix.

## What not to test
- Engine behaviour: that `Rigidbody` falls, `Vector3.Dot` works, or serialisation of built-in types.
- Private methods, exact visual output, and trivial getters.
- Tuning feel; use playtests for that. Test the rules, not the numbers, apart from snapshot data.

## Anti-patterns
- Play Mode tests for logic that could be plain C#.
- `Thread.Sleep` or `WaitForSeconds` to wait for state.
- Static singletons with no reset between tests.
- Tests depending on scene order or editor state.
- Ignoring logged errors.

## Checklist
- Logic in plain C# with injected clock, RNG, and input.
- Separate Edit Mode and Play Mode asmdefs, excluded from builds.
- Data validators and scene/prefab smoke tests present.
- CI runs both modes headless and publishes XML.
- Flaky tests logged with a deadline.
