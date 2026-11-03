---
name: save-load-systems
description: Persistence engineering for Unity and C# games - what to save vs derive, save data models as plain serialisable classes, stable unique ids for saveable objects, serialisation choices (JsonUtility, Newtonsoft JSON, binary), Application.persistentDataPath, atomic writes with backups, versioning and migrations, corruption handling and validation, checksums vs encryption, autosave and checkpoint policy, slots with metadata and thumbnails, cloud saves, async IO, saving during scene transitions, PlayerPrefs for small settings, and round-trip and migration testing. Load when designing save files, adding saveable state, migrating save formats, or debugging lost or corrupt saves.
---

# Save and load systems

Verify `JsonUtility` limits, the Newtonsoft package name (`com.unity.nuget.newtonsoft-json`) and version, and platform save paths against the installed Unity version. Runtime state ownership is in `game-state-management`; the gameplay data being saved is in `gameplay-systems`; build and platform concerns in `unity-build-release`.

## What to save
- Save the minimum that cannot be rebuilt: progress, inventory, quest state, unlocks, player position where needed, world changes, and settings.
- Derive everything else (final stats from base plus items, UI state, caches) on load.
- Save definitions by id, never by copying ScriptableObject data. Rolled or mutated instance data is saved; static definition data is looked up.
- Decide per field whether it is run state (lost on quit) or profile state (persistent); keep them in different models.

## Data model
- Save data is plain C# classes or structs marked `[Serializable]`, with no MonoBehaviour, UnityEngine.Object, or scene references.
- Systems expose `Capture()` returning their data and `Restore(data)` applying it. A `SaveService` composes them; systems do not touch files.
```csharp
[Serializable] public sealed class SaveData {
    public int version = 3;
    public PlayerData player = new();
    public List<InventoryEntry> inventory = new();
    public List<QuestState> quests = new();
}
public interface ISaveable { string Key { get; } object Capture(); void Restore(object data); }
```
- Prefer lists of records over dictionaries when the serialiser does not support them (`JsonUtility` does not).
- Store enums and ids in a stable form; do not rely on enum numeric order if values can be reordered. Use explicit values or strings.

## Stable ids
- Saveable scene objects need an id that persists across builds and sessions: a serialized GUID generated in the editor, not instance IDs, names, or hierarchy paths.
- Make it unique per prefab instance (prefab variants and duplicates copy ids; detect and regenerate duplicates in an editor validator, see `unity-editor-workflows`).
- Runtime-spawned objects get an id at creation and store their definition id, so they can be respawned.

## Serialisation choice
- `JsonUtility`: built in and fast, but no dictionaries, no polymorphism, no nullable handling, and top-level collections are not supported. Fine for small flat models.
- Newtonsoft JSON (verify the package): dictionaries, polymorphism with care, and flexible settings. Disable type-name handling for untrusted data.
- Binary or schema formats (MessagePack, protobuf; verify packages and IL2CPP/AOT support): smaller and faster, harder to debug and migrate. Check AOT compatibility for il2cpp builds before committing.
- Human-readable JSON is the default; switch only with measured need.

## Files and locations
- Write under `Application.persistentDataPath`, in a `saves` folder, one file per slot. Never write into `Application.dataPath` or StreamingAssets.
- Build paths with `Path.Combine`. Platform behaviour (consoles, WebGL, mobile backup rules) differs; verify per target.

## Atomic writes and backups
- Write to a temporary file in the same directory, flush, then replace the real file, keeping the previous version as a backup. A crash mid-write must leave a valid file.
```csharp
File.WriteAllBytes(tmp, bytes);
if (File.Exists(path)) File.Replace(tmp, path, bak);
else File.Move(tmp, path);
```
- Verify `File.Replace` support on every target platform; use delete and move as a fallback.
- Load tries the main file, then the backup. Never delete a corrupt file; quarantine it by renaming.

## Versioning and migration
- Every save has an integer `version`. Migrations are small ordered steps (v1 to v2, v2 to v3) run in sequence on load, then the data is saved at the current version.
- Never edit an old migration. Keep one test fixture file per old version.
- Unknown newer versions: refuse to load with a clear message rather than corrupting data.
- Adding a field with a default needs no migration; renaming, splitting, and removing do.

## Validation and corruption
- Validate after deserialising: ids exist, counts non-negative, references resolvable. Repair or drop invalid entries and log them; do not crash.
- Handle exceptions around IO and parsing, return a typed result (`Loaded`, `Missing`, `Corrupt`, `NewerVersion`), and let the UI decide.
- Checksums detect accidental corruption. Encryption or obfuscation in a client file is not security; the player holds the key. Treat anti-tamper as deterrence only and never trust saves for server-side or competitive state.

## Autosave and checkpoints
- Autosave at safe moments: checkpoints, area transitions, after key events, and on pause or application quit (`OnApplicationPause` on mobile; verify lifecycle callbacks per platform).
- Do not save during combat, loading, or mid-transition. Gate with game state.
- Rate-limit saves and show a small saving indicator. Keep a rolling backup of recent autosaves.

## Slots and metadata
- One file per slot plus a small metadata file or header (playtime, location, timestamp, version, thumbnail path) so the slot list loads without reading full saves.
- Thumbnails: capture with a render texture or `ScreenCapture` (verify), encode, and store beside the save; keep small.

## Cloud saves
- Hide platform services behind an `ICloudSaveProvider`. Local save remains the source of truth for writes; sync compares timestamps or revision counters and asks the player on conflict.
- Cloud payloads must be size-limited and the same versioned format.

## Async and threading
- Serialise and write off the main thread where size matters (`Task.Run`, or `Awaitable` background switching; verify availability). Capture a snapshot on the main thread first; never read Unity objects from other threads.
- Prevent overlapping writes with a single queue. Await completion before quit or scene unload.

## Scene transitions
- Capture before unloading; restore after the target scene finishes loading and objects have initialised. Restore by id, so ordering does not matter.
- Objects spawned in a scene but not present in the save keep default state.

## Settings
- `PlayerPrefs` only for small, non-critical values (volume, quality, input overrides JSON). It is not suited for progress; storage is platform dependent.
- Larger or portable settings go in a versioned settings file using the same save pipeline.

## Testing
- Round-trip test: build a populated `SaveData`, serialise, deserialise, compare. Include empty lists, null fields, and large values.
- Migration tests load fixtures from every old version and assert the result at current version.
- Test corruption: truncated file, invalid JSON, missing main with valid backup, newer version.
- Test atomicity by simulating failure between temp write and replace.

## Anti-patterns
- Serialising MonoBehaviours or ScriptableObjects directly.
- Saving by hierarchy path or instance id.
- Writing the save in place, with no temp file.
- Calling encryption security.
- Saving on every frame or during loading.

## See also

Optional, if installed: data-integrity (the data plugin) for the broader discipline this skill applies. This skill stands on its own.
