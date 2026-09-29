---
name: writing-prose
description: Improve, rewrite, critique, or draft prose with a concise, vigorous, reader-centered style inspired by classic usage guidance including Strunk's public-domain The Elements of Style. Use for essays, emails, docs, blog posts, memos, announcements, and any request involving clarity, tone, grammar, style, or line editing.
metadata:
  short-description: Revise prose for clarity, force, and grace
---

# Writing Prose

Use this skill whenever the task is to write, revise, critique, or polish non-code prose.

## Core workflow

1. Identify purpose, audience, medium, and desired tone. If missing and consequential, ask a brief clarifying question; otherwise infer and proceed.
2. Preserve the user's meaning, facts, voice, and constraints. Do not make factual claims stronger than the source supports.
3. Revise in passes:
   - Structure: put the main point where readers need it; order ideas logically.
   - Sentences: prefer direct subjects and verbs; cut needless words; vary rhythm.
   - Diction: choose concrete, specific words; replace jargon unless the audience expects it.
   - Mechanics: fix grammar, punctuation, spelling, and consistency.
4. Return the revised prose first when the user asks for a rewrite. Add notes only if useful or requested.
5. For critique, give the highest-leverage issues first, with examples and suggested replacements.

## Style principles

- Be clear before being clever.
- Prefer the active voice unless passive voice better serves emphasis, tact, or unknown agency.
- Make every word earn its place. Remove throat-clearing, redundancy, filler, and hedging.
- Use definite, specific, concrete language where possible.
- Keep related words together. Avoid interrupting subject-verb and verb-object pairs with long modifiers.
- Put emphatic words at emphatic positions: sentence end, paragraph start/end, title/subhead.
- Use parallel structure for parallel ideas.
- One paragraph should generally develop one topic. Open paragraphs with a clear signal when helpful.
- Prefer positive statements over negative constructions when meaning is unchanged.
- Maintain consistent tense, person, number, names, formatting, and terminology.
- Break rules when audience, genre, accuracy, rhythm, or humane tone requires it.

## Output patterns

### Rewrite or polish

Return:
1. `Revised:` followed by the edited text.
2. Optional `Notes:` with 2-5 bullets explaining important changes, tradeoffs, or unresolved questions.

### Line edit

Return a compact table when useful:

| Original | Suggested edit | Why |
|---|---|---|

### Critique

Return:
- `Overall:` one short diagnosis.
- `Most important fixes:` 3-7 prioritized bullets.
- `Example revision:` a representative rewrite if the text is long.

### Draft from scratch

Return the finished draft. If assumptions matter, include a short `Assumptions:` note after the draft.

## Editing checklist

Before finalizing, check:

- Is the main point obvious?
- Can any sentence be shorter without losing useful nuance?
- Are verbs doing the work?
- Are abstractions backed by concrete detail?
- Is the tone suited to the reader and occasion?
- Are transitions sufficient but not fussy?
- Are punctuation and formatting consistent?

For a fuller reference, read `references/style-principles.md`.
