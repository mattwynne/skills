---
name: kaizen-note
description: Offer to capture and, when accepted, write a docs/kaizen observation when we notice friction, imperfections, waste, opacity, brittleness, or failure in the pipeline/factory/workflows/tooling used to create the product. Use for workflow/tooling problems, not ordinary product bugs.
---

# Kaizen Note

Use this skill when a conversation or run reveals an imperfection in the machinery we use to create the product: delivery workflows, agent skills/prompts, planning/review/implementation handoffs, sandboxing, checkpoints, CI/dev scripts, model routing, observability, recovery, or other delivery pipeline/factory friction.

The purpose is defect prevention: do not just patch around the immediate problem; capture what allowed it to happen so we can remove the cause and keep it from coming back.

A kaizen note is not the fix. It is a timely observation that preserves the evidence a later fix will need: what we expected, what actually happened, what made the failure possible, and what kind of guardrail might have caught or prevented it. Keep the note factual. Do not turn it into a solution plan unless the user asks.

## How to Think While Capturing

Treat delivery-machinery friction as a weakness in the work system, not a personal mistake. Ask:

- What should have made this impossible, obvious, or easy to recover from?
- What current workflow, prompt, script, checklist, validation gate, or handoff failed to protect us?
- Did the problem appear where it was caused, or only later after more work had piled on top?
- Did we get a clear signal that something was wrong, or did the system hide or blur the abnormality?
- Would continuing without stopping spread confusion, waste effort, or make the evidence harder to recover?
- What evidence will a later `kaizen-fix` need to find and fix the cause rather than the symptom?

## Trigger Habit

When you notice relevant friction, pause and offer to record it:

> This looks like pipeline/workflow friction. Would you like me to write a kaizen note in `docs/kaizen/` capturing the context and observations?

If the user declines, acknowledge and continue. Do not write the note.

If the user explicitly invokes `/kaizen-note`, `/skill:kaizen-note`, says to record a kaizen note, or otherwise clearly asks for one, treat that as consent and write it unless important facts are missing.

## What Qualifies

Good candidates:

- A workflow failed before or around product work because tooling, sandbox, checkpointing, branching, PR creation, model routing, or handoff machinery behaved badly.
- A process was ambiguous, brittle, hard to resume, or required manual archaeology.
- A prompt, skill, workflow, script, validation gate, or review loop created avoidable waste or confusion.
- We had to use an operator workaround that should be remembered.
- The system hid the real cause, reported an unhelpful status, or lacked enough evidence to debug quickly.

Usually not candidates:

- An ordinary application bug or failing product test with clear product-code ownership.
- A feature request for user-facing behaviour.
- A personal preference with no observed delivery friction.

## Writing Checklist

1. Confirm consent unless the user explicitly requested the note.
2. Inspect enough local context to write accurately. Useful sources include:
   - recent conversation details supplied by the user;
   - `git status --short --branch`;
   - relevant workflow, skill, prompt, script, or docs paths;
   - workflow run IDs, events, logs, URLs, commands, or failure text when available.
3. Identify the suspected system weakness without over-investigating:
   - What kind of protection was missing or weak? Examples: guardrail, validation, error message, default, documentation, checklist, handoff, recovery path, observability, or ownership boundary.
   - How urgent is it? Examples: minor friction, repeated friction, blocked work, quality risk, or customer risk.
4. Check for an existing note about the same symptom or problem before creating a new file:
   - list existing notes in `docs/kaizen/`;
   - search note titles and bodies for the same symptom, failure mode, workflow, command, tool, skill, or handoff;
   - prefer amending a matching note when the new evidence describes the same problem, even if the root cause is still uncertain.
5. If a matching note exists, update that note instead of creating a duplicate:
   - add the new evidence under the most relevant existing heading, or add a dated subsection such as `### Additional observation: YYYY-MM-DD`;
   - preserve the original observation and distinguish earlier evidence from the new observation;
   - update `Impact`, `What allowed it to happen`, `Open questions`, or `Possible prevention ideas` only when the new observation changes them;
   - do not rewrite the note into a solution plan unless the user asks.
6. If no matching note exists, choose a concise slug and create:
   - `docs/kaizen/YYYY-MM-DD-short-observation-slug.md`
7. Keep the note factual and diagnostic.
8. Commit the note once written. Do not include unrelated working-tree changes.

## Note Template

```markdown
# Problem: <short description>

Date: YYYY-MM-DD

## Context

What were we trying to do? Include the workflow/skill/script/iteration/plan path/run ID/URL when relevant.

## Expected standard

What workflow, command, prompt, script, or handoff did we expect to work? Link the current standard work when known.

## What happened

What friction, failure, ambiguity, abnormality, or waste did we observe? Include exact commands, statuses, and failure text when useful.

## Impact

How severe was it? Did it merely slow us down, repeat, block progress, threaten quality, or risk customer-facing impact?

## What allowed it to happen

What system weakness appears to have let the problem through? For example: missing guardrail, weak validation, confusing command, unclear error, flaky or slow feedback, unclear docs, manual step, brittle dependency, missing checklist, poor observability, or weak handoff.

## Observations

- Factual observations that distinguish this from ordinary product work.
- Evidence about where the machinery made the work slower, more brittle, less observable, or harder to resume.
- Workarounds used or safe retry/resume commands, if known.

## Why this matters

What risk or waste does this create for future delivery?

## Open questions

- Unknowns to investigate later.

## Possible prevention ideas

- Optional, only when obvious from the evidence: guardrails, preflight checks, clearer errors, safer defaults, templates, scripts, tests, prompt changes, documentation changes, or other changes that could make recurrence impossible, obvious, or easy to recover from.
```

Use additional headings when the evidence calls for them, but prefer a short useful note over a comprehensive report. When amending an existing note, use dated `Additional observation` subsections where they make the accumulation of evidence clearer.

## Style

- Write in plain language.
- Be specific about file paths, commands, run IDs, branches, statuses, and exact errors.
- Separate observed facts from hypotheses.
- If you include possible improvements, put them under a clearly labelled heading such as `## Possible prevention ideas`, and keep them secondary to the observation.
- Do not edit application code while recording the note.
