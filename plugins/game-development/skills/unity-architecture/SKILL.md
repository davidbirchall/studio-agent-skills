---
name: unity-architecture
description: Runtime architecture for Unity C# projects - composition over inheritance, thin MonoBehaviours with logic in plain C# classes, dependency injection options, ScriptableObject event channels vs C# events vs message buses, singletons and bootstrapping, update loop ownership, initialisation order, data-driven design, model-view separation, state machines, assembly boundaries enforcing dependency direction, testing with the Unity Test Framework, and when to adopt ECS/DOTS. Load when designing systems, splitting code into assemblies, choosing communication patterns, structuring for testability, or reviewing coupling.
---

# Unity architecture

Verify package names and APIs (DI frameworks, Test Framework, DOTS) against the installed Unity and package versions; Unity 6 and 2022 LTS differ. Gameplay specifics: `gameplay-systems`, `game-state-management`. Style: `csharp-conventions`.

## Composition
- Build behaviour from small single-purpose components on a GameObject (`Health`, `Mover`, `Damageable`), not deep inheritance chains. Inheritance depth beyond two levels is a smell.
- Communicate through interfaces (`IDamageable`) rather than concrete types. Use `TryGetComponent` to discover capabilities.
- Prefer data in ScriptableObjects or serializable classes over hardcoded constants.

## Thin MonoBehaviours
- A MonoBehaviour is glue: serialized references, Unity messages, and delegation. Rules, calculations, and state live in plain C# classes that take dependencies through constructors.
```csharp
public sealed class Health
{
    public int Current { get; private set; }
    public event Action Died;
    public Health(int max) => Current = max;
    public void Damage(int amount) { Current = Mathf.Max(0, Current - amount); if (Current == 0) Died?.Invoke(); }
}
```
- Plain classes are testable in Edit Mode without scenes. Keep `UnityEngine` references out of domain logic where practical.

## Dependencies
- Start with manual injection: a composition root (bootstrap scene, `unity-project-patterns`) builds services and passes them to consumers through `Init(...)` methods.
- A service locator is acceptable as a bootstrap-level tool but hides dependencies; do not call it from deep inside domain code.
- DI containers (VContainer, Zenject/Extenject) are third-party; adopt one only when plain constructor injection stops scaling for a solo project, and verify maintenance status and version support first.
- Avoid `FindObjectOfType` and `GameObject.Find` in runtime paths. Inject or serialize the reference.

## Messaging
- Direct reference or interface call: default for tightly related objects.
- C# events: typed, fast, code-only; require unsubscription (`csharp-conventions`).
- ScriptableObject event channels: designer-wireable, decoupled across scenes; harder to trace and easy to overuse. Use for cross-scene signals such as "level completed".
- Message bus: decouples broadly but makes flow implicit. Use for few global domain events, and keep message types as small structs or records.
- Pick one default per project and document it.

## Singletons and lifetime
- Avoid `static Instance` singletons. If a persistent service is needed, create it in the bootstrap scene, mark it `DontDestroyOnLoad`, and pass it explicitly. Guard against duplicates and reset statics for Play Mode with domain reload disabled (`unity-editor-workflows`).
- Own lifetime explicitly: whoever creates a thing disposes it. Implement `IDisposable` for subscriptions and native resources.

## Update loops and initialisation
- Many MonoBehaviours with `Update` cost a native-to-managed call each. For large counts (hundreds and up), use one manager that ticks registered plain objects. Measure first (`game-profiling`).
- Use `FixedUpdate` for physics, `Update` for input and logic, `LateUpdate` for camera follow and post-movement.
- Order: `Awake` for self-initialisation (no other objects), `OnEnable` for subscriptions, `Start` for cross-object wiring. Avoid Script Execution Order settings; use explicit `Init` calls from the owner so order is visible in code.

## Data-driven and model-view
- Define content (enemies, items, levels) as data assets read by generic systems. Adding content should not need new code.
- Separate model (state and rules, plain C#), view (MonoBehaviours, animation, UI), and controller or presenter (translates between). Apply for UI (`ui-systems`) and gameplay objects. The model never references the view.
- Use explicit state machines (enum plus switch, or state classes) for characters, AI, and game flow rather than boolean flags (`game-ai`, `game-state-management`).

## Assemblies
- Enforce direction with asmdefs: `Core` (no dependencies) <- `Gameplay` <- `UI`/`Presentation` <- `Bootstrap`. Lower layers never reference higher. Features talk through interfaces defined in a shared lower assembly.
- Turn on "No Engine References" for pure logic assemblies where useful (verify the asmdef option name). Separate asmdefs also cut compile times.

## Testing
- Use the Unity Test Framework (verify package version). Edit Mode tests for pure C# logic and editor tooling: fast, no scene. Play Mode tests for MonoBehaviour lifecycle, physics, and scene integration: slower, fewer.
- Put tests in their own asmdefs referencing the code under test. Design for tests by injecting time, random, and input sources.
- Run tests in CI (`unity-build-release`).

## Scale and ECS
- DOTS/ECS is justified by measured need: thousands to millions of similar entities, or CPU-bound simulation that GameObjects cannot meet. It changes authoring, tooling, and hiring cost, and package APIs shift between versions; verify the installed Entities version.
- Try cheaper steps first: pooling, a ticking manager, Jobs and Burst on isolated hot loops (`game-performance`).

## See also

Optional, if installed: software-architecture (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
