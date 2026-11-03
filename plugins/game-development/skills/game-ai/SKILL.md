---
name: game-ai
description: NPC AI engineering in Unity - choosing between finite state machines, hierarchical FSMs, behaviour trees, utility AI, GOAP, and steering; separating perception, decision, and action; sight and hearing perception with memory; NavMesh navigation with the AI Navigation package; A* alternatives; time-sliced updates and AI LOD; blackboards; group coordination; difficulty exposure; debugging, determinism, and testing AI as plain C#. Load when designing, implementing, debugging, or optimising enemy or NPC behaviour.
---

# Game AI

Builds on `unity-architecture` and `gameplay-systems`. The NavMesh components live in the AI Navigation package in recent Unity versions; verify package name, component names, and baking APIs against the installed Unity version (Unity 6 and 2022 LTS differ).

## Choose by need
- FSM: few states, clear transitions (patrol, chase, attack). Default for simple enemies.
- Hierarchical FSM: when states share sub-behaviour or the flat FSM grows transition spaghetti.
- Behaviour tree: many reusable behaviours, priority fallbacks, designer-readable composition.
- Utility AI: many competing options weighed continuously (needs, threats, opportunities); tuned through curves.
- GOAP: agents that plan action sequences toward goals; costly to build and debug, use only when emergent sequencing is the point.
- Steering behaviours: local movement (seek, flee, separation, avoidance) layered under any of the above.
- Start with the simplest technique that meets the need. Switching later is easier when decision logic is separated from action execution.

## Separate perception, decision, action
- Perception writes facts to a blackboard. Decision reads the blackboard and chooses an action. Action executes it (move, animate, attack) and reports status.
- Decision logic is plain C# with no engine calls so it can be unit tested. Engine access sits behind interfaces (`IPerception`, `IMover`).

```csharp
public interface IBrain { AiAction Decide(in Blackboard bb, float now); }

public sealed class Blackboard
{
    public Vector3 SelfPosition;
    public bool CanSeeTarget;
    public Vector3 LastKnownTargetPosition;
    public float TimeSinceTargetSeen;
    public float Health01;
}
```

## Perception
- Sight: distance check, then angle against the view cone, then a line-of-sight raycast against an obstruction layer mask. Order checks cheapest first.
- Hearing: events with a position and loudness; agents within range react. Do not poll.
- Memory: store last-known position and time seen; let memory decay. Agents search the last-known position, they do not know the true one.
- Give perception its own tick rate (for example 5-10 Hz) and a per-frame raycast budget (`physics-systems`).
- Use non-allocating query variants and cached buffers; verify names for your Unity version.

## Navigation
- Use NavMeshAgent for pathing on baked NavMesh. Configure agent types (radius, height, step, slope) to match the character; bake per agent type.
- Use NavMeshObstacle (carving) for movable blockers; carving costs, so limit it and verify behaviour. Use off-mesh links for jumps and doors, and area types with costs to prefer or forbid terrain.
- Runtime baking and surface updates are supported by the package; verify the API and that it is not run every frame.
- Check path validity and `pathPending` before reading remaining distance. Handle partial and failed paths explicitly.
- For 2D, grids, or custom rules, use A* on your own graph: reuse open/closed buffers, use a binary heap, cap iterations per frame, and spread long searches over frames.

## Update cost
- Do not give each agent its own `Update`. Use a central AI manager that ticks agents.
- Stagger: update a fraction of agents per frame, or give each a fixed interval with random offset. Time-slice expensive work (perception, path requests) with a budget in milliseconds.
- AI LOD: distant or off-screen agents tick slower, skip perception, or use simplified movement. Keep visible behaviour consistent when promoting back.
- Cap simultaneous path requests and queue the rest.

## Group coordination
- Use a shared coordinator, not agent-to-agent chatter. Attack tokens limit how many agents attack at once; slot allocation spreads agents around a target; squads share a blackboard for target and alerts.
- Readability matters: expose timings (windup, cooldown, reaction delay) as data so designers can tune them.

## Tuning and data
- Put thresholds, ranges, reaction times, and aggression in ScriptableObjects (`unity-project-patterns`). Difficulty levels are alternative data assets, not code branches.
- Expose per-agent parameters in config, not magic numbers.

## Determinism and randomness
- Use an injected, seeded random source for AI choices so behaviour is reproducible in tests and replays. Do not call `UnityEngine.Random` in decision code.
- Frame-rate dependence: use `Time.deltaTime` consistently and test at varying frame rates.

## Debugging
- Draw gizmos for sight cones, paths, last-known positions, and target links. Show current state and top utility scores in an overlay.
- Log state transitions with agent id, reason, and time; keep it behind a debug flag.
- Provide a way to freeze AI, step one tick, and select an agent to inspect.

## Testing
- Unit test brains with fabricated blackboards and a fake clock: given these facts, expect this action. Cover transitions, timeouts, and memory decay.
- Play Mode tests for navigation: agent reaches target, handles blocked path, and recovers from a failed path.
- Profile AI cost with many agents (`game-profiling`) and optimise with `game-performance`.
