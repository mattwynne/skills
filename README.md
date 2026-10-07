# Skills

A small collection of reusable agent skills.

## Included skills

- `kaizen-note` — capture workflow/tooling friction as a factual improvement note.
- `kaizen-fix` — investigate and resolve `docs/kaizen` notes.
- `kaizen-jfdi` — capture a kaizen note and immediately run the fix workflow in one loop.
- `ensemble-review` — run independent Claude/Codex/Gemini reviews and synthesize the findings.
- `bdd-discovery` — explore behaviour, rules, examples, questions, and scope before writing Gherkin.
- `bdd-formulation` — write or review Gherkin scenarios as living documentation.
- `ubiquitous-language` — review a codebase's domain vocabulary and produce a glossary.
- `exploratory-testing` — run chartered exploratory testing and report findings.
- `distill-design-heuristics` — turn real team design judgment into reusable heuristics.
- `writing-adrs` — think through architectural decisions with stakeholders, then document and review the trade-offs. Contributed by Zell Gagnon.
- `writing-prose` — revise prose for clarity, force, and reader-centered style.
- `talking-to-humans` — explain work in plain, concrete language without assuming the reader shares the agent’s context.

Each skill lives in `skills/<skill-name>/SKILL.md`. To use these skills globally in Pi:

```sh
ln -s ~/git/mattwynne/skills/skills/writing-prose ~/.pi/agent/skills/writing-prose
ln -s ~/git/mattwynne/skills/skills/talking-to-humans ~/.pi/agent/skills/talking-to-humans
```

## Evaluations

- [`talking-to-humans`](evals/talking-to-humans.md) — cases and a rubric for comparing responses with and without the skill.
- [Run evals with Pi](evals/README.md) — resume a real session, load the skill before one reply, and compare the results. Includes supporting constructed cases and grader checks.

## Prompt templates

Thin Pi prompt wrappers live in `prompts/`:

- `/ensemble-review <review request>` — loads the `ensemble-review` skill for a specific review.
- `/kaizen-note [context]` — loads the `kaizen-note` skill to capture a workflow/tooling observation.
- `/kaizen-fix [note path, title, or slug]` — loads the `kaizen-fix` skill to resolve a kaizen note.
- `/kaizen-jfdi [problem context or note path]` — loads the `kaizen-jfdi` skill to capture and resolve a kaizen issue in one pass.
