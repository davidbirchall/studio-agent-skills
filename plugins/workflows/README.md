# squad-skills-workflows

End-to-end recipe skills that sequence the other plugins for common jobs: ship a web feature, add a chat capability, build a game feature, and cut a game build.

Version `0.2.0`, 9 skills.

## Install

```
copilot plugin install ./plugins/workflows
```

## Skills

| Skill | Purpose | Load when |
|-------|---------|-----------|
| `add-chat-capability` | Recipe for adding a capability to a conversational AI application, such as a new connector, a project feature, or a new model behaviour... | Extending chat features end to end or planning a change to how the assistant behaves |
| `build-game-feature` | Recipe for taking a Unity game feature from concept to playable - the design question, mechanic and system design, balance placeholders, architecture... | Asked to build, prototype, or add a gameplay feature in Unity and see it playable |
| `cut-game-build` | Recipe for producing a Unity release candidate and shipping it - scope freeze, content and asset audit, build configuration and automation, test... | Preparing a Unity build for testers, a demo, or a public release |
| `fix-a-bug` | Recipe for fixing a defect without guessing - reproduce first with a failing test or minimal repro, isolate the failing area, find the root cause... | Asked to fix a bug, investigate unexpected behaviour, or resolve a failing test or error report |
| `refactor-safely` | Recipe for restructuring code without changing behaviour - establish a behavioural safety net first, write characterisation tests where coverage is... | Asked to refactor, restructure, rename, extract, simplify, or clean up existing code |
| `ship-web-feature` | Recipe for taking a web feature from idea to production on a Nuxt 3 frontend and NestJS backend - discovery and scope, technical design,... | Asked to build, ship, or deliver a full-stack feature end to end |
| `start-new-project` | Recipe for starting a project from an empty directory - clarify the goal and constraints with minimal questions, choose the stack from sensible... | Asked to create, scaffold, bootstrap, or start a new application, service, library, or tool |
| `understand-codebase` | Recipe for getting oriented in an unfamiliar repository fast - read the README, manifests, and entry points, map the structure, find conventions,... | Asked to explore, onboard to, audit, or explain a codebase, or before changing code you have not seen |
| `upgrade-dependencies` | Recipe for upgrading packages safely - inventory outdated and vulnerable dependencies, read changelogs, upgrade one at a time or grouped by... | Asked to update, bump, or upgrade dependencies, resolve audit findings, or migrate to a new major version |

## Related plugins

Recipes name skills from the other plugins in plain prose. Each named skill is optional; if its plugin is not installed the step should still be done using general good practice.
