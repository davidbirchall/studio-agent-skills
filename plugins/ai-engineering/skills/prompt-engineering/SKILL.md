---
name: prompt-engineering
description: Prompt engineering for a TypeScript chat and agent backend - prompt structure, system vs user vs tool roles, instructions and constraints, few-shot examples, output contracts and format specs, delimiting untrusted input, prompt templates, versioning prompts as code, change review, regression-tested prompt changes, and common failure fixes. Load when writing or editing system prompts, designing output formats, adding examples, templating prompts, or changing a prompt that already ships.
---

# Prompt engineering

Builds on `llm-integration` for calls and structured output, and feeds `ai-evaluation` for regression checks. Model behaviour varies by provider and version; verify every change with tests, not intuition.

## Structure
- Order sections: role and goal, context, rules, output format, examples. Keep each section labelled and short.
- State the task, audience and success criteria first. One prompt, one job; split multi-purpose prompts into steps.
- Write positive, specific instructions ("answer in two sentences") over vague ones ("be brief") and over bare prohibitions.
- Put hard rules and format requirements where they are hard to miss; repeat a critical rule at the end of long prompts.
- Say what to do when information is missing or the request is out of scope (ask, refuse, or answer "unknown").

## Roles
- System message: stable identity, policies, tool guidance, output contract. Never put user-supplied text in it.
- User message: the request and per-turn data. Tool messages: tool results only, as data.
- Do not rely on the system prompt for secrecy or security; it can leak (`ai-security`).

## Untrusted input
- Wrap user text, retrieved documents and tool output in clear delimiters and label them as data.
```ts
const user = `<document id="${id}">\n${escape(text)}\n</document>\nSummarise the document above.`
```
- Instruct the model that content inside delimiters is data, not instructions. Delimiters reduce, not remove, injection risk; enforce controls in code.

## Output contracts
- Specify exact format, fields, allowed values and length. Show one valid example.
- Prefer native structured output or a JSON schema, then validate in code (`llm-integration`). Keep schema descriptions in sync with the prompt.
- Define behaviour for empty, partial and uncertain results (null, empty array, explicit `unknown`).
- Ask for reasoning in a separate field or step only when it improves accuracy; do not expose raw reasoning to users unless intended.

## Few-shot examples
- Use 2 to 5 diverse examples covering typical, edge and refusal cases. Match the real output format exactly.
- Examples bias heavily; vary wording and avoid ordering patterns (all same label, label last).
- Keep examples in data files, tested against the schema, not inlined in strings.

## Templates and versioning
- Prompts are code: store in files or a typed module, changes covered by the eval set, never built by ad hoc string concatenation across the codebase.
- Template with typed variables and fail on missing ones.
```ts
export const summarise = {
  id: 'summarise', version: 3,
  render: (v: { text: string; maxWords: number }) => `Summarise in at most ${v.maxWords} words.\n<text>\n${v.text}\n</text>`,
}
```
- Record prompt id and version with each call in logs and traces (`ai-observability`) so regressions can be tied to a change.
- Keep model, temperature and other parameters with the prompt version; a model change is a prompt change.

## Changing prompts safely
- Keep a fixed eval set of real and adversarial inputs with expected properties; run it before and after every edit (`ai-evaluation`, `ai-testing`).
- Change one thing at a time. Compare pass rates, not single outputs; model output is non-deterministic.
- Add a failing case to the eval set for each production bug before fixing the prompt.
- Assert contracts (schema, required fields, refusals, no leaked instructions), not exact wording (`test-discipline`).
- Roll out behind a flag or percentage so a bad version can be reverted by config.

## Common fixes
- Ignored rule: shorten the prompt, move the rule, add a counter-example.
- Wrong format: add schema enforcement and an example, not more emphasis.
- Hallucination: supply source text, require citations or "unknown" (`retrieval-augmented-generation`).
- Verbose output: set a length limit in the prompt and a max output token cap.
- Tool misuse: improve tool names and descriptions first (`tool-integration`).
