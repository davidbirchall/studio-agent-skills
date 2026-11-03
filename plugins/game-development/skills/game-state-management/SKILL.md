---
name: game-state-management
description: Game flow and runtime state in Unity and C# - game state machine for boot, menu, loading, playing, paused and game over, stack states for pause and overlays, scene loading flow with additive and async loads, bootstrap scene and loading screens, Time.timeScale pause pitfalls, runtime vs persistent state, single source of truth and state ownership, state change events, session and run data, persistent service lifetime and DontDestroyOnLoad, static state with domain reload disabled, and testing state machines. Load when designing game flow, pause, scene transitions, global services, or debugging state that leaks between sessions or scenes.
---

# Game state management

Verify scene loading, `Awaitable`, and Enter Play Mode option behaviour against the installed Unity version (Unity 6 vs 2022 LTS). Persistence of state lives in `save-load-systems`; project layering in `unity-architecture`.

## Game state machine
- Model top-level flow as an explicit state machine: Boot, MainMenu, Loading, Playing, Paused, GameOver. One current state at a time.
- Each state has `Enter`, `Exit`, and optionally `Tick`. Enter and Exit own setup and teardown (input maps, UI, camera, time scale).
- Transitions go through one `ChangeState` method that validates the transition, calls Exit, swaps, calls Enter, then raises `StateChanged(from, to)`.
```csharp
public interface IGameState { void Enter(); void Exit(); void Tick(float dt); }

public sealed class GameFlow {
    IGameState _current;
    public event Action<IGameState, IGameState> StateChanged;
    public void ChangeState(IGameState next) {
        var prev = _current;
        _current?.Exit();
        _current = next;
        _current.Enter();
        StateChanged?.Invoke(prev, next);
    }
}
```
- Invalid transitions (Paused to MainMenu without confirm) are rejected or logged, not silently allowed.
- Do not scatter `if (isPaused)` checks across scripts. Systems react to state events or are enabled and disabled by state.

## Stack states
- Overlays (pause, inventory, dialogue, settings) are a stack on top of the base state. Push to open, pop to return to the exact prior state.
- Only the top of the stack receives input. Lower entries are suspended, not exited.
- Pause is "push Paused", so opening settings from pause is another push and Back is a pop.
- Guard against double push of the same overlay and against pop on an empty stack.

## Pausing and time
- `Time.timeScale = 0` stops `FixedUpdate` and scaled-time animation and coroutines, but `Update` still runs. Input callbacks and UI still fire.
- Use unscaled time (`Time.unscaledDeltaTime`, Animator update mode Unscaled Time, `WaitForSecondsRealtime`) for pause menus and UI animation.
- Audio, particles, and physics-independent systems do not pause automatically; pause or duck them explicitly in the Paused state Enter.
- Restore `timeScale` in Exit of every state that changes it, including on scene unload. A stuck `timeScale = 0` after returning to menu is a classic bug.
- Prefer one owner of `Time.timeScale`. Multiple writers (slow-motion, hit-stop, pause) need a request stack or priority, not direct assignment.

## Scene flow
- Use a bootstrap scene that creates persistent services, then loads the first content scene. Make Boot the only scene that must be loaded first; support entering from any scene in the editor via a bootstrap helper.
- Load content additively: a persistent scene plus level scenes. Use `SceneManager.LoadSceneAsync(name, LoadSceneMode.Additive)` and set the active scene after load.
- Loading flow: enter Loading state, show loading screen, load, initialise, fade, enter Playing. Do not enable `allowSceneActivation = false` workflows without handling the 0.9 progress cap; verify behaviour in the installed version.
- Await completion before touching scene objects. Initialise level objects in an explicit step, not in racing `Awake` or `Start` order.
- Unload the previous scene explicitly and release assets loaded for it (`unity-asset-management`).
- Show progress from a smoothed value; loading screens must use unscaled time.

## Runtime vs persistent state
- Persistent state survives quitting (progress, unlocks, settings). Runtime state exists only in a session (current health, enemy positions, run seed).
- Keep them in separate types. Persistent data is a plain serialisable model; runtime state is rebuilt or restored from it.
- Session or run data is a plain object created at run start and discarded at run end. Reset by creating a new instance, never by clearing fields one by one.

## Ownership
- Every piece of state has exactly one owner. Others read via property or event, and request changes via methods.
- Do not duplicate state in UI or in a second manager "for convenience". Derived values are computed or cached with invalidation.
- Raise events on change, with old and new values where useful. Subscribers update on event and read initial value on subscribe.

## Services and lifetime
- Persistent services (audio, input, save, flow) are created in Boot and passed by reference or through a simple service locator. Avoid hidden singletons with `static Instance` set in `Awake`.
- `DontDestroyOnLoad` creates duplicates when a scene containing it is reloaded. Guard against duplicates or create the object only from Boot.
- Services must tolerate being reached before and after scene loads; expose explicit `Initialize` and `Shutdown`.

## Statics and domain reload
- With Enter Play Mode options disabling domain reload, static fields and static event subscriptions persist across play sessions. Verify the setting and its behaviour in the installed Unity version.
- Reset statics deliberately, for example with a method marked `[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]` (verify attribute and enum in the installed version). Clear static events too.
- Prefer instance state over statics so the problem does not exist.

## Testing
- Keep the state machine free of UnityEngine types where possible; test transitions, rejected transitions, enter/exit ordering, and stack push/pop in Edit Mode.
- Assert that `StateChanged` fires once per transition with correct arguments.
- Test that Exit restores what Enter changed (time scale, input map) using fake services.

## Anti-patterns
- Boolean flags (`isPaused`, `isLoading`, `isDead`) replacing an explicit state.
- `Time.timeScale` writes from many scripts.
- Logic that depends on scene object `Awake` order across scenes.
- Static singletons holding runtime state across scene loads without a reset path.

## See also

Optional, if installed: software-architecture (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
