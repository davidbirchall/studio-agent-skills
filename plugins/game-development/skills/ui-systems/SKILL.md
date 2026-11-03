---
name: ui-systems
description: In-game and menu UI engineering in Unity - UI Toolkit versus uGUI selection, Canvas setup and scaling, safe area, layout cost and canvas splitting, TextMeshPro, gamepad and keyboard navigation with the EventSystem, new Input System UI module, MVP and MVVM binding to game state, screen stack and modal management, event-driven HUDs, localisation readiness, accessibility, animation, virtualised lists, loading screens, UI performance, and testing UI flows. Load when building or reviewing menus, HUDs, popups, UI navigation, or UI performance.
---

# UI systems

Builds on `unity-architecture` and `input-systems`. UI Toolkit runtime support, data binding, and Unity Localization integration differ between Unity 6 and 2022 LTS; verify every feature against the installed Unity and package versions before committing to it.

## Choosing a toolkit
- Pick one primary system per project. Mixing is allowed (for example UI Toolkit menus, uGUI world-space widgets) but each mix needs a reason.
- UI Toolkit: UXML/USS authoring, strong for menus, tools, and data-heavy screens. Check runtime feature coverage (world-space UI, shader/effect support, data binding) for your version.
- uGUI: mature, GameObject-based, good for world-space UI, heavy animation, and existing asset-store content.
- Decide from the screens you must ship, not from preference. Prototype the hardest screen in each candidate first.

## Canvas setup (uGUI)
- Use Screen Space Overlay for most HUD and menus, Screen Space Camera when UI needs post-processing or perspective, World Space for in-world widgets.
- Canvas Scaler: Scale With Screen Size, set one reference resolution, and choose the match value deliberately (width, height, or blend) for your target aspect ratios.
- Apply safe area: size a root RectTransform from `Screen.safeArea` and re-apply when it changes. Keep interactive and critical HUD elements inside it.
- Anchor to the corners or edges they belong to; never position by absolute pixels from a fixed resolution.

## Canvas and layout cost
- Any change to a canvas element rebuilds that whole canvas. Split canvases by update frequency: static backgrounds, rarely changing panels, and per-frame elements (timers, health bars) on separate canvases.
- Layout groups and ContentSizeFitter are costly and nest badly. Use them on static content, avoid deep nesting, and disable them or use fixed sizes for frequently changing content.
- Disable Raycast Target on every Graphic that is not interactive (labels, icons, backgrounds).
- Use TextMeshPro, not legacy Text. Pre-generate font atlases for needed character sets and verify dynamic atlas behaviour for your localisation.
- Pack sprites into atlases per screen or feature to keep batching intact; avoid mixing atlases within one canvas.
- Avoid large overlapping transparent images; overdraw is the usual mobile UI cost.

## Navigation and input
- Every screen must be usable with gamepad and keyboard. Set a default selected element on screen open (`EventSystem.current.SetSelectedGameObject`) and restore it when returning from a popup.
- Define explicit navigation for non-trivial layouts rather than relying on automatic mode.
- Use one EventSystem. With the new Input System, use the Input System UI Input Module; verify the component name and action asset wiring for your version. Keep UI actions in a separate action map from gameplay and switch maps when UI opens (`input-systems`).
- Handle pointer, touch, and gamepad as equals; show prompts matching the active device.

## Architecture
- Views display and raise events; they hold no game rules. Use MVP or MVVM: a presenter or view model reads state and exposes view-ready data, the view binds to it.
- Game code never references widgets. It publishes state changes or events; the presenter subscribes (`unity-architecture`).
- Update the HUD on events, not in `Update`. Where a value changes continuously, throttle or write only when the displayed value changes.

```csharp
public sealed class HealthPresenter : IDisposable
{
    private readonly PlayerHealth model;
    private readonly IHealthView view;

    public HealthPresenter(PlayerHealth model, IHealthView view)
    {
        this.model = model;
        this.view = view;
        model.Changed += OnChanged;
        OnChanged(model.Current, model.Max);
    }

    private void OnChanged(int current, int max) => view.Show(current, max);
    public void Dispose() => model.Changed -= OnChanged;
}
```

## Screen stack and modals
- Manage screens through one UI manager with a stack: push, pop, replace. Each screen has open, close, and focus-restored hooks.
- Popups are stacked screens that block input beneath them. Back or cancel closes the top of the stack only.
- Pause, confirmation, and error dialogs go through the same stack so focus and input maps stay consistent.
- Screens declare what they need (input map, pause state) and the manager applies and reverts it.

## Localisation and accessibility
- Externalise every user-facing string from day one; no literals in views. Consider the Unity Localization package and verify its integration with your UI system and version.
- Allow 30-50% text expansion and right-to-left where relevant; use flexible layouts and wrapping, not fixed widths. Never concatenate sentence fragments.
- Provide scalable text size, sufficient colour contrast, never colour alone to convey state (add icon or shape), a colourblind-safe palette or mode, and remappable controls.
- Keep UI scale and text size in saved settings (`save-load-systems`).

## Animation and lists
- Animate with Animator, tween code, or UI Toolkit transitions; use unscaled time for UI that must run while paused. Animate transforms and alpha, not layout-affecting properties.
- Long lists must be virtualised or pooled: reuse a fixed set of row views and rebind on scroll. UI Toolkit ListView supports virtualisation; verify settings for your version.
- Loading and transition screens must be driven by real async progress, remain responsive, and block input until complete.

## Testing
- Keep presenters plain C# and unit test them with fake views.
- Test flows (open, navigate, back, popup, focus restore) in Play Mode tests with the actual EventSystem.
- Check the main screens at the extreme aspect ratios and with the longest localised strings. Profile UI separately (`game-profiling`, `game-performance`).
