---
name: input-systems
description: Unity Input System package engineering - Input Actions asset, action maps and control schemes, PlayerInput vs generated C# class vs direct action references, action types Value Button and PassThrough, interactions and processors, composite bindings, started/performed/canceled callbacks vs polling, runtime rebinding with saved overrides, multiple devices and local multiplayer with PlayerInputManager, device switching and prompt glyphs, gamepad dead zones and rumble, touch input, input buffering and coyote windows, enabling maps by game state, unsubscribing on disable, testing with InputTestFixture, and legacy Input Manager migration. Load when adding or reviewing player input, rebinding, controller support, or input bugs.
---

# Input systems

The new Input System package (`com.unity.inputsystem`) is the default. Verify package version, API names, and Project Settings options (Active Input Handling) against the installed Unity and package version. UI input module setup is in `ui-systems`; pause and state flow in `game-state-management`.

## Structure
- One Input Actions asset per project, with maps by context: `Gameplay`, `UI`, `Vehicle`. Actions are named by intent (`Jump`, `Interact`), never by device (`PressSpace`).
- Control schemes (Keyboard&Mouse, Gamepad, Touch) declare which devices bind together. Define them before adding bindings.
- Gameplay code consumes intents, not controls. Input to intent to motion keeps `character-controller-systems` device-free.

## Choosing an access pattern
- Generated C# class: type-safe, no string names, good for a single-player project. Enable it on the asset; verify the option in the installed version.
- `PlayerInput` component: good for per-player setup, device pairing, and local multiplayer. Choose one notification behaviour (Unity Events, C# events, Send Messages) and stay with it.
- Direct `InputActionReference` fields: good for isolated components and rebinding UI.
- Do not mix all three for the same actions.

## Action types and bindings
- Button for discrete presses, Value for continuous data (move, look), PassThrough when every device change must be reported without conflict resolution.
- Use composite bindings for 2D Vector (WASD, arrows, d-pad) and assign the stick directly for gamepad.
- Use processors for dead zones, normalisation, invert, and scale. Use interactions (Hold, Tap, MultiTap) instead of hand-written timers for press patterns.
- Mouse delta and stick look need different scaling: apply sensitivity per control scheme.

## Reading input
- Callbacks (`started`, `performed`, `canceled`) for events such as jump, interact, fire. Polling (`ReadValue<Vector2>()`) for continuous values such as move and look.
- Read movement once per frame into an intent struct; do not read devices from many scripts.
```csharp
public sealed class PlayerIntent : MonoBehaviour {
    [SerializeField] InputActionReference move, jump;
    public Vector2 Move { get; private set; }
    public event Action JumpPressed;

    void OnEnable() { move.action.Enable(); jump.action.Enable(); jump.action.performed += OnJump; }
    void OnDisable() { jump.action.performed -= OnJump; jump.action.Disable(); move.action.Disable(); }
    void Update() => Move = move.action.ReadValue<Vector2>();
    void OnJump(InputAction.CallbackContext _) => JumpPressed?.Invoke();
}
```
- Subscribe in `OnEnable`, unsubscribe in `OnDisable`. Handlers left attached to a shared asset fire on destroyed objects.
- Enabling a shared action from multiple owners needs a single owner; disabling it elsewhere silently kills input.

## Enabling by game state
- A state change enables the correct map and disables the others: Playing enables Gameplay; Paused enables UI. Do this in state Enter/Exit (`game-state-management`).
- Switching maps while a button is held can leave a stuck press; reset intents on map change.

## Rebinding
- Use `PerformInteractiveRebinding` with cancel controls, exclude unwanted controls, and handle duplicates; verify the exact API in the installed package.
- Disable the action before rebinding and re-enable after. Always dispose the operation.
- Save binding overrides as JSON (`SaveBindingOverridesAsJson`, verify name) through `save-load-systems`, and load them at boot before enabling maps.
- Provide reset to default per binding and per scheme. Display names come from the binding, not hard-coded strings.

## Devices and multiplayer
- Local multiplayer: `PlayerInputManager` joins players and `PlayerInput` pairs each with devices. Verify join behaviour and split-screen options in the installed version.
- Detect the active scheme and switch prompts or glyphs on device change (`PlayerInput.onControlsChanged` or `InputUser` events; verify names). Map glyphs by control path through one lookup asset.
- Gamepad: apply stick dead zones with processors, offer a configurable value, and handle disconnect by pausing.
- Rumble via `Gamepad.current.SetMotorSpeeds` must be stopped on pause, death, and scene change; expose a rumble toggle.
- Touch: use on-screen controls that feed the same actions, or the Enhanced Touch API (verify). Respect safe areas.

## Buffering and windows
- Input buffer: record a press timestamp and let gameplay consume it within a window (for example jump pressed shortly before landing). Coyote time is a controller concern but uses the same timestamp approach.
- Keep windows as tuning values. Use unscaled time if the buffer must survive pause.
- Consume the buffered press when used, so one press cannot trigger twice.

## Testing
- Use `InputTestFixture` (verify package test assembly requirements) to add virtual devices, press, and set values in Play Mode tests.
- Test intent logic with a fake intent source in Edit Mode; reserve device tests for bindings and rebinding.

## Legacy migration
- The legacy `Input` class (`Input.GetKey`, `GetAxis`) does not work when only the new system is active. Verify Active Input Handling in Project Settings.
- Migrate by action, replace each call site with an intent read, and remove the legacy calls. Third-party assets may require the legacy handler; both can be enabled temporarily.

## Anti-patterns
- Reading `Keyboard.current` or `Gamepad.current` in gameplay code.
- Hard-coded key names in prompts.
- Callback subscriptions never removed.
- Rebinding without persisting overrides.
