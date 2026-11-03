---
name: ai-evaluation
description: Measure chat, RAG, and agent quality with versioned datasets, rubrics, graders, trajectory checks, groundedness metrics, human calibration, and regression gates. Load when deciding whether prompts, models, retrieval, or agent changes improved or degraded quality.
---

# AI evaluation

Builds on `prompt-engineering`, `agent-design`, and `retrieval-augmented-generation`; deterministic unit tests live in `ai-testing`, run telemetry in `ai-observability`. Evals measure quality on realistic inputs; tests assert correctness of code.

## Datasets
- Start with 20-50 hand-written cases covering the real task, then grow from production traces: failures, thumbs-down, escalations, and odd inputs.
- Cover the happy path, edge cases, adversarial inputs (`ai-security`), refusals that should happen, and cases that must not be refused.
- One case per behaviour; tag cases (`category`, `difficulty`, `source`) so results can be sliced.
```ts
interface EvalCase {
  id: string
  input: { messages: Message[]; context?: Record<string, unknown> }
  expected?: { answer?: string; toolCalls?: string[]; mustContain?: string[]; mustNot?: string[] }
  tags: string[]
  source: 'handwritten' | 'production' | 'synthetic'
}
```
- Strip PII and secrets before a trace becomes a case (`secret-handling`).
- Synthetic cases help coverage but keep them a minority and review each one by hand.

## Versioning
- Datasets are versioned files in the repo (JSONL) or a registry with immutable versions. Record dataset version, prompt version, model id, and config with every run.
- Hold out a test split that is never used for prompt tuning. Fixing prompts against the full set overfits it; refresh with new production cases.
- Never put eval cases in prompts or few-shot examples.

## Graders
- Prefer code-based graders first: exact match, regex, JSON schema validity, tool name and argument checks, citation present, length, latency. They are cheap and deterministic.
- Use LLM-as-judge only for qualities code cannot check (helpfulness, tone, faithfulness). Use a different or stronger model than the one under test, temperature 0, and structured output.
- Grade one criterion per judge call. Ask for reasoning first, then a score or pass/fail verdict. Prefer binary or 3-point scales over 1-10.
- Judge prompts get a rubric with concrete anchors and examples per level.
```ts
const verdict = await judge.grade({ rubric: FAITHFULNESS_V2, question, answer, context })
// { reasoning: string, pass: boolean }
```
- Mitigate bias: randomise order in pairwise comparisons, do not reveal which system produced an answer, watch for length and self-preference bias.

## Judge calibration
- Label 50-100 cases by hand, run the judge, and measure agreement (accuracy, Cohen's kappa, false-pass rate). Do not trust a judge without this.
- Re-calibrate when the judge model, rubric, or task distribution changes. Version the judge prompt like code.

## Retrieval and agents
- Retrieval: label relevant chunks per query; report recall@k, precision@k, and MRR separately from answer quality so failures localise.
- Generation over retrieved context: grade groundedness (every claim supported by context) and answer relevance independently.
- Agents: grade the outcome (task done, final state correct) first, then the trajectory: right tools, valid arguments, no redundant or forbidden calls, step count, cost.
- Check final state in a sandbox or fake backend rather than trusting the agent's own summary.

## Variance
- Outputs vary: run each case N times (3-5) for stochastic systems and report pass rate per case, not a single pass.
- Small sets are noisy. Report confidence intervals; a 2-point change on 50 cases is usually noise. Use paired comparison on the same cases.
- Do not conclude from an aggregate alone; read the diffs of cases that flipped.

## Offline, online, and gates
- Offline evals run on fixed datasets before release. Online evals score sampled live traffic (judge scores, user feedback, task success) via `ai-observability`.
- Gate CI on thresholds for critical slices and on regressions vs the baseline run, not on one global average. Keep a small fast smoke set for every PR and the full set nightly or on prompt, model, or tool changes.
- A model or prompt upgrade is a change like any other: rerun the full suite before switching.
- Store results with run metadata so trends and per-case history are queryable. Track cost and latency alongside quality.

## See also

Optional, if installed: software-testing-strategy (the shared plugin) for the broader discipline this skill applies. This skill stands on its own.
