---
name: multiplayer-netcode
description: Multiplayer networking engineering for Unity and C# games - deciding whether multiplayer is worth its cost, topologies (authoritative client-server, host-client, peer-to-peer, relay), choosing a networking library (Netcode for GameObjects, Mirror, Fish-Net, Photon and others) by criteria, authority and ownership, state synchronisation vs RPCs vs events, tick rate and snapshot interpolation, client-side prediction and reconciliation, lag compensation basics, bandwidth budgets, determinism pitfalls, serialisation, anti-cheat basics, lobbies, matchmaking and relay services, testing under simulated latency and loss, debugging desync, and keeping single-player code separable. Load when adding or evaluating multiplayer, designing network architecture, syncing gameplay state, or debugging lag, desync, or cheating.
---

# Multiplayer netcode

Library APIs, package names and versions change often; verify every package-specific claim against the installed version and its documentation. State ownership: `game-state-management`. Gameplay rules: `gameplay-systems`. Movement: `character-controller-systems`. Physics: `physics-systems`. Testing: `unity-testing`.

## Decide first
- Multiplayer multiplies cost: design, testing, debugging, hosting, support, and cheat handling. Expect it to add well over the cost of the equivalent single-player feature. Warn the user before starting.
- Ask: is it required for the core loop? Would asynchronous features (leaderboards, ghosts, shared seeds, async challenges) deliver the value instead? Prefer those when they do.
- Define player count, genre latency tolerance, session length, and whether cheating matters before choosing anything.

## Topologies
- Dedicated authoritative client-server: default. Server owns the truth; clients send input and render. Best for cheating resistance and consistency.
- Host-client (listen server): one player runs the server. Cheaper to host; host has zero latency advantage and can cheat; host migration is hard. Acceptable for co-op.
- Peer-to-peer: no server; needs determinism or trusted peers. Rarely right for a solo developer except lockstep games.
- Relay: forwards packets when NAT blocks direct connections. Combine with host-client to avoid port forwarding. It adds latency and a service dependency.

## Choosing a library
Compare by criteria, not reputation; give the user options and tradeoffs:
- Authority model supported (server-authoritative, owner-authoritative, both).
- Maintenance activity, Unity version support, licence, and AOT/IL2CPP support.
- Transport options, relay and lobby integration, and WebGL or console support if needed.
- Built-in prediction, interpolation, and lag compensation vs hand-built.
- Concurrent-user pricing for hosted options (verify current pricing).
- Fit with the project's scene and prefab workflow, and tooling for debugging and simulation.

## Authority and ownership
- Every piece of state has exactly one authority. Others receive, never write.
- The server validates every client request: range, cooldown, resources, line of sight. Reject and log violations.
- Clients are display plus input. Never accept results (damage, position, loot) from a client.

## Sync mechanisms
- State sync (variables, snapshots): for continuous or late-join-relevant data such as position, health, and score. Late joiners receive it automatically.
- RPCs: for one-shot commands (client asks, server decides). Keep payloads tiny and validate arguments.
- Events and cosmetic effects: fire locally from state changes; do not RPC every particle.
- Anything a late joiner must know belongs in state, not in a past RPC.
```csharp
// Command pattern: client requests, server validates and mutates state.
public void RequestFire(Vector3 aimDir) { if (!CanFire(aimDir)) return; SpawnProjectileServer(aimDir); }
```

## Tick rate and interpolation
- Run simulation at a fixed tick (commonly 20-60 Hz; choose by genre) decoupled from render rate; send snapshots at the same or lower rate.
- Remote entities render by interpolating between two buffered snapshots, about 2 ticks behind (about 100 ms at 20 Hz). Extrapolate only briefly, then clamp.

## Prediction and reconciliation
- Local player applies input immediately and records inputs by tick. The server replies with the authoritative state and the last processed tick; the client rewinds to it and replays unacknowledged inputs.
- Smooth small corrections over several frames; snap above a threshold (for example over 1 m).
- Simulation must be a pure function of state plus input to replay correctly. Predict only the local player; interpolate everything else.

## Lag compensation
- For hit detection, the server rewinds target positions to the shooter's view time (input tick minus interpolation delay) within a cap (for example 200 ms), then tests the hit. Cap the rewind to limit abuse.

## Bandwidth and serialisation
- Budget bandwidth per client (for example under 10-30 KB/s) and measure it.
- Quantise floats (position to 1-2 cm, rotation to 8-16 bits), send deltas, send only changed fields, and lower rates for distant or unimportant objects.
- Use compact binary serialisation. Never send JSON or strings per tick. Use fixed enum and id sizes; version the protocol and reject mismatched clients.

## Determinism pitfalls
- Lockstep and replay need bit-exact simulation. Floating point, `Dictionary` and `HashSet` order, `UnityEngine.Random`, `Time.deltaTime`, physics, and thread timing all break it across machines and platforms.
- Use seeded custom RNG, fixed-point or integer maths, fixed step, and sorted iteration. Verify with state checksums.
- If not doing lockstep, do not chase determinism; use authoritative state instead.

## Anti-cheat basics
- Never trust the client: validate inputs and rates (speed, fire rate), keep secrets (hidden positions, loot rolls) on the server, and rate-limit requests.
- Client-side anti-cheat is deterrence; do not overspend. Log anomalies server-side. Do not store authoritative progression in client-editable files (see `save-load-systems`).

## Services
- Lobbies, matchmaking, relay, and authentication are services (Unity Gaming Services, whose Lobby, Relay, and Matchmaker are exposed through the Multiplayer Services package in current Unity versions, Steam, Epic, Photon, or custom; verify current offerings and pricing). Hide them behind interfaces.

## Testing
- Test under simulated latency, jitter, loss, and reordering (library simulator, transport settings, or OS-level tools; verify availability). Use at least 100 ms, 5 percent loss, and 30 ms jitter as baseline conditions.
- Run multiple instances locally (editor plus builds, or a multiplayer testing tool; verify). Automate a headless server test where possible.
- Log tick number, entity id, and state hash on both ends to find the first divergence in a desync.

## Single-player separability
- Gameplay logic reads and writes through interfaces (input provider, state store) so a local implementation and a networked one both work. Offline mode should run the same code with a local authority.

## Anti-patterns
- Adding multiplayer late to code that assumes one local player and global statics.
- Trusting client-reported positions, damage, or time.
- RPCs for continuous state; state for one-shot events.
- Testing only on localhost.

## Checklist
- [ ] Cost accepted; async alternative considered
- [ ] Topology and library chosen by recorded criteria
- [ ] Authority defined per state; server validates all requests
- [ ] Tick, interpolation, and bandwidth budget set and measured
- [ ] Prediction and reconciliation tested under bad networks
- [ ] Services behind interfaces; failure paths handled
