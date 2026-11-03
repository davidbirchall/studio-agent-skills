# Skill design guide

Notes to myself on how to design, write and maintain skills in this repo. For a solo project this replaces a contribution guide.

## Principles

1. **Layer the library.**
   - Generic principles live in `shared` (how to think about testing, security, design).
   - Specialised skills apply them to a stack (`backend-testing`, `frontend-security`). Most of the value is here.
   - Goal-oriented groupings are stacks (`scripts/install-stack.sh`), not skills. Add a short workflow skill only when a job spans many skills and the order matters.
2. **Encode opinions, not common knowledge.** If a model already knows it, leave it out. Keep your defaults, conventions, thresholds and "never do X" rules.
3. **One skill, one job.** If the description needs "and" twice, split it.
4. **Grow from real work.** Write a skill after the same guidance has been repeated two or three times. Don't fill in a taxonomy ahead of need.
5. **Don't couple skills to a project.** Use projects and goals to decide what is missing, then write the skill for the general case. Use neutral examples, not your own product.
6. **Write for an AI agent serving one person.** Skills guide an agent to complete tasks and capture knowledge. They are not about human communication. Leave out stakeholders, status updates, meeting formats, presentations and team ceremony (reviewers, RACI, sprints, on-call rotations). Prefer exit criteria, automated checks, durable written artifacts, and asking the user one focused question when a real decision is needed. If a practice would help with collaborators, keep it to one line: 'If you work with others: ...'.
7. **Stay self-contained.** A skill must work if no other plugin is installed. Link to others only in prose.

## Anatomy

```
plugins/<domain>/skills/<name>/SKILL.md
```

- Frontmatter has only `name` (equal to the folder name) and `description`.
- The description is one dense paragraph: what the skill covers, then a trigger sentence ending "Load when ...". The description decides whether the skill loads, so spend effort on it.
- The body is terse imperative rules, short examples, anti-patterns, and a checklist if the skill is procedural.
- Aim for 60-100 lines. Under about 40 usually means it's too thin; over 150 means it should be split.
- ASCII only, no emojis.

## Choosing a plugin

| If the skill is... | Put it in |
|---|---|
| A discipline that applies across stacks | `shared` |
| Specific to a framework, engine or tool | The matching technical plugin |
| A process or method, not code | A process plugin (`product`, `game`, `creative`, `production`, `knowledge`) |
| Provider-specific (AWS, Azure) | A new plugin; keep `platform-engineering` neutral |

Overlap between a generic skill and its specialisation is intended. Keep the generic one short and the specialised one concrete.

## Cross-references

- Backticked skill names may point only at siblings in the same plugin, or at Squad's bundled `secret-handling` and `test-discipline`.
- To point at another plugin, end the skill with a `## See also` section in plain prose, no backticks: "Optional, if installed: application-security (the shared plugin) for the broader discipline. This skill stands on its own."
- The one known exception is the frontend's `typescript-conventions` references to `shared`.

## Independence

This repo is a self-contained exploration. Don't reference employer tooling, internal packages or proprietary architecture. Use neutral examples (`@acme/config`, a fictional game) and pnpm as the default package manager.

## Adding a skill

1. Create `plugins/<domain>/skills/<name>/SKILL.md` using the anatomy above.
2. Add a row to `plugins/<domain>/README.md` and bump the plugin version in `plugin.json` (minor for a new skill, patch for edits).
3. Mirror the version and description in `.github/plugin/marketplace.json`.
4. Update the root `README.md` if the skill count or a plugin's purpose changed.
5. Run the checks below.

## Checks before committing

Run `python3 scripts/check-skills.py`. It checks the items below automatically (except the `yarn` rule) and exits non-zero on any problem.

- `name` equals the folder name.
- Code fences are balanced.
- Backticked references resolve to sibling skills.
- No employer names, `yarn` commands (other than a "never npm or yarn" rule), or links to external plugins.
- `marketplace.json` is valid JSON and the versions match each `plugin.json`.

## Maintaining quality

- Skills drawn from general knowledge are unverified. Add a "verify against the installed version" note for version-sensitive claims.
- Test a skill by running a real task and checking that it loads and changes the result. Delete or rewrite skills that never trigger.
- Record decisions that affect several skills in `.squad/decisions/inbox/`.

## Commits and branches

Use `squad/{issue-number}-{slug}` branches and conventional-style messages. Add the trailer `Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>` when Copilot helped.

## Coming back later

### Current state

- 16 plugins, 181 skills: `shared`, `frontend`, `backend`, `data`, `platform-engineering`, `ai-engineering`, `game-development`, `creative-technology`, `product`, `game`, `creative`, `production`, `knowledge`, `agent-practices` (how the agent works), `business` (solo-business knowledge), `workflows` (recipe skills that sequence the others in plain prose).
- Stacks in `scripts/install-stack.sh`: web, game, ai, process, all (web, game and ai include `agent-practices` and `workflows`; process includes `business`).
- Goals (a conversational AI app, Unity games, a Nuxt/NestJS stack) guide which skills to build. They are context for spotting gaps, not content: skills describe the discipline generically and never name a specific project.
- Content was drafted mostly by AI agents from general knowledge. It has not been fact-checked or load-tested in Copilot CLI.
- The marketplace could not be tested on the machine where it was built (managed policy blocks it). Local-path installs work.

### Known gaps and ideas

- Fact-check version-sensitive content: OWASP edition, Unity packages and Cinemachine versions, MCP revisions, OpenTelemetry GenAI conventions.
- Load-test one plugin per stack and check that the descriptions trigger on realistic prompts.
- Reserved for later: provider-specific plugins such as an AWS deployment plugin.
- `.squad/decisions.md` is append-only and still holds old employer-specific text. The inbox note `copilot-independence-from-employer.md` supersedes it.
- Per-plugin READMEs were generated once and are edited by hand. If it gets tedious, write a generator.

### How the library was built (reuse this process)

1. Agree the plugin's skill list and purpose with a short design discussion.
2. Scaffold `plugins/<domain>/plugin.json` and the skills folder. Create directories before files.
3. Split the skills across two or three parallel agents, each given the format rules, the sibling skill names for allowed references, and one fully worked example skill.
4. Verify with `scripts/check-skills.py` and read a sample of the output.
5. Add the plugin README, the marketplace entry and the root README row.
6. Add a `## See also` note to skills that specialise a `shared` discipline.

### Working agreements

- Keep the repo independent of any employer or proprietary system.
- Package manager default is pnpm. Never npm or yarn in examples.
- Prefer fewer, deeper skills over many thin ones.
- Commit one plugin at a time.
