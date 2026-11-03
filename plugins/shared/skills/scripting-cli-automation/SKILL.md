---
name: scripting-cli-automation
description: Writing small scripts and command-line tools to automate repeatable tasks in Node and TypeScript (default) or shell - when to script versus do by hand, idempotent and safe-by-default behaviour (dry-run, confirmation for destructive actions), argument parsing, exit codes, stdout versus stderr, machine-readable JSON output, logging verbosity, config and environment variables, keeping secrets out of arguments, cross-platform paths, shell safety (quoting, strict mode, avoiding eval), testing scripts, usage via --help, script locations and pnpm package scripts, scheduled runs with failure alerts, and keeping scripts small and boring. Load when automating a repeated task, adding a script or CLI to a project, or reviewing a script for safety.
---

# Scripting and CLI automation

Types and style: `typescript-conventions`. Secrets: `secret-handling` and `application-security`. Script tests: `software-testing-strategy`. Dependencies: `dependency-management`.

## Script or not
- Done twice by hand and likely a third time: script it. Done once and never again: do it by hand.
- Script when errors are costly, steps are many (over 4), or an AI session must repeat it reliably.
- Do not script what a built-in tool or existing package script already does.
- Write the manual steps down first; the script is those steps made exact.

## Language
- Node/TypeScript by default: typed, testable, cross-platform, same toolchain as the project.
- Shell only for under about 30 lines of gluing commands. Past that, or with loops over structured data, switch to TypeScript.
- Run TypeScript with the project's runner (for example `pnpm exec tsx scripts/x.ts`); do not add a build step for a script.

## Safe by default
- Idempotent: running twice gives the same end state. Check before creating, use upsert, skip what exists.
- Destructive actions (delete, overwrite, push, send) require `--yes` or an interactive confirmation; non-interactive runs without the flag abort.
- Provide `--dry-run` that prints exactly what would change and touches nothing. Make dry-run the default for anything irreversible.
- Validate inputs before the first change; fail early, change nothing on bad input.
- Write outputs to a new file or temp path, then rename, so a crash leaves no half file.

## Interface
- Positional args for the required subject; flags for options. Long flags (`--output`), short only for the common ones.
- Use a parser (`node:util` `parseArgs`, or the project's CLI library); never hand-split `process.argv`.
- Exit codes: 0 success, 1 failure, 2 bad usage. Distinct codes only when callers branch on them.
- stdout holds results only; stderr holds logs, progress, and errors. This keeps pipes clean.
- Offer `--json` for machine-readable output: a single JSON document on stdout, stable keys, no decoration.
- Verbosity: quiet by default, `-v` for steps, `-vv` for debug; `--quiet` for none.
- `--help` prints usage, flags, defaults, one example, and exit codes. Missing args print usage to stderr and exit 2.

## Config and secrets
- Order of precedence: flags, environment variables, config file, defaults. Document it.
- Secrets come from env vars or a secret store; never from arguments (visible in process lists and shell history) and never committed or logged.
- Print resolved config with secrets masked in debug mode.

## Paths and portability
- Use `node:path` (`path.join`, `path.resolve`), never string-concatenated separators.
- Resolve relative to the script or repo root, not the current directory, unless the user passes a path.
- Avoid platform-only commands in TypeScript; use Node APIs (`fs`, `child_process.spawn` with an args array, no shell string).

## Shell rules
```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
dir="${1:?usage: clean.sh <dir>}"
[[ -d "$dir" ]] || { echo "not a dir: $dir" >&2; exit 2; }
find "$dir" -name '*.tmp' -print0 | xargs -0 rm -f --
```
- Quote every expansion: `"$var"`, `"${arr[@]}"`.
- Never `eval`; never build commands from strings; never `rm -rf "$var/"` with an unchecked variable.
- Use `mktemp` plus `trap 'rm -rf "$tmp"' EXIT` for cleanup.
- Run `shellcheck` when available.

## Testing
- Pull logic into pure functions; test them. Keep the entry file a thin wrapper.
- Test dry-run output, exit codes, bad input, and the second (idempotent) run against a temp directory.
- Never test destructive paths against real data.

## Location and running
- Put scripts in `scripts/`, named by verb: `sync-docs.ts`, `rotate-logs.sh`.
- Expose via `package.json`: `"sync-docs": "tsx scripts/sync-docs.ts"`, run with `pnpm sync-docs --dry-run` (pnpm passes options after the script name through; npm needs `--`).
- A header comment states purpose, usage, and side effects in under 5 lines.
- Small and boring: one job per script, under about 150 lines, few dependencies, no cleverness.

## Scheduling
- Use cron, launchd, or CI schedules; the script must be non-interactive, idempotent, and use absolute paths and explicit env.
- Log to a file with timestamps; rotate it.
- Alert on failure (non-zero exit triggers a notification) and on silence (a missed run heartbeat). Success should be quiet.
- Add a lock or timeout so overlapping or hung runs cannot pile up.

## Anti-patterns
- Secrets in flags; logs mixed into stdout so JSON breaks.
- Always exiting 0; swallowed errors.
- Destructive default with no dry-run.
- `shell: true` with interpolated input.
- A 500-line script with its own framework.
- Undocumented script that only its author can run.

## Checklist
- Done-twice rule met; language fits size.
- Dry-run, confirmation, idempotency present.
- Exit codes, stdout/stderr split, `--json`, `--help` correct.
- No secrets in args or logs; paths portable; shell quoted.
- Tests cover logic and second run; scheduled runs alert on failure.
