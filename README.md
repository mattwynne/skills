# Skills

Reusable instructions for coding agents, covering testing, design, workflow improvements, and writing. Browse the skills below, then install the ones that suit your work.

## Included skills

| Skill | Description |
| --- | --- |
| [kaizen-note](skills/kaizen-note/SKILL.md) | Record a problem with your workflow or tools so it can be investigated and fixed. |
| [kaizen-fix](skills/kaizen-fix/SKILL.md) | Investigate and resolve improvement notes in `docs/kaizen`. |
| [kaizen-jfdi](skills/kaizen-jfdi/SKILL.md) | Record a workflow problem and work through the fix straight away. |
| [ensemble-review](skills/ensemble-review/SKILL.md) | Get independent reviews from Claude, Codex, and Gemini, then bring their findings together. |
| [bdd-discovery](skills/bdd-discovery/SKILL.md) | Explore behaviour, rules, examples, open questions, and scope before writing Gherkin scenarios. |
| [bdd-formulation](skills/bdd-formulation/SKILL.md) | Write or review Gherkin scenarios that document how the software should behave. |
| [ubiquitous-language](skills/ubiquitous-language/SKILL.md) | Review the terms a codebase uses for its domain and produce a glossary. |
| [exploratory-testing](skills/exploratory-testing/SKILL.md) | Explore the software with a clear testing goal and report what you find. |
| [distill-design-heuristics](skills/distill-design-heuristics/SKILL.md) | Turn a team's real design decisions into practical guidelines for future work. |
| [writing-adrs](skills/writing-adrs/SKILL.md) | Think through architectural decisions with the people involved, then document and review the trade-offs. Contributed by Zell Gagnon. |
| [writing-prose](skills/writing-prose/SKILL.md) | Make prose clearer, more direct, and easier to read. |
| [talking-to-humans](skills/talking-to-humans/SKILL.md) | Explain work in plain, concrete language without assuming the reader shares the agent’s context. |

## Install skills

Each skill lives in `skills/<skill-name>/`. Install the whole directory, not just `SKILL.md`, so any supporting files are included.

Copy and paste this prompt into your coding agent:

```text
Browse https://github.com/mattwynne/skills and read the SKILL.md files in
its skills directory. Give me a short summary of each skill, then ask
which one or more I'd like to install. Wait for my choice before installing.

Confirm which coding agent I use and whether I want the skills available
in all projects or just the current project. Use that agent's supported
skills location and install each selected skill's whole directory,
including any supporting files. Ask before replacing an existing skill.
Tell me what you installed, where it lives, and how to use it.
```
