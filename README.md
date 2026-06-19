# Skills

A small collection of reusable agent skills.

## Included skills

- `kaizen-note` — capture workflow/tooling friction as a factual improvement note.
- `kaizen-fix` — investigate and resolve `docs/kaizen` notes.
- `ensemble-review` — run independent Claude/Codex/Gemini reviews and synthesize the findings.
- `bdd-discovery` — explore behaviour, rules, examples, questions, and scope before writing Gherkin.
- `bdd-formulation` — write or review Gherkin scenarios as living documentation.
- `ubiquitous-language` — review a codebase's domain vocabulary and produce a glossary.
- `exploratory-testing` — run chartered exploratory testing and report findings.
- `distill-design-heuristics` — turn real team design judgment into reusable heuristics.

Each skill lives in `skills/<skill-name>/SKILL.md`.

## Prompt templates

Thin Pi prompt wrappers live in `prompts/`:

- `/ensemble-review <review request>` — loads the `ensemble-review` skill for a specific review.
- `/kaizen-note [context]` — loads the `kaizen-note` skill to capture a workflow/tooling observation.
- `/kaizen-fix [note path, title, or slug]` — loads the `kaizen-fix` skill to resolve a kaizen note.
