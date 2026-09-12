---
name: kaizen-fix
description: Investigate and resolve docs/kaizen problem observation notes. Use when the user asks to fix a kaizen note, investigate root cause, suggest repair options, or apply an obvious workflow/tooling fix and update the note with the resolution.
---

# Kaizen Fix

Use this skill to turn a `docs/kaizen/` observation note into an investigated improvement. The goal is to understand the root cause, identify safe repair options, apply an obvious fix when one exists or collaborate with the user to choose a resolution, and update the original kaizen note with the outcome. An evidence-backed investigation followed by a human decision is a valid outcome, not a failure to act autonomously.

This skill is for delivery-machinery problems: delivery workflows, agent skills/prompts, planning/review/implementation handoffs, sandboxing, checkpoints, CI/dev scripts, model routing, observability, recovery, and related workflow/tooling friction. Do not use it for ordinary product bugs unless the kaizen note shows that the product bug exposed a workflow/tooling problem.

## Inputs

The user may provide:

- a kaizen note path, for example `docs/kaizen/2026-05-29-example.md`;
- a note title or slug;
- no note at all.

## Note Selection

1. If the user provides a path, title, or slug, resolve it to exactly one file under `docs/kaizen/`.
   - If multiple files match, show the matches and ask the user which one to fix.
   - If no files match, stop and report that the note could not be found.
2. If the user does not specify a note, find unresolved recent notes:
   - List `docs/kaizen/*.md` newest first.
   - Treat a note as resolved when it has a heading named `## Resolution`, `## Resolution applied`, `## Resolution plan`, or another clear resolution heading with substantive content.
   - Treat a note as unresolved when it lacks a substantive resolution heading. Options or a plan awaiting a decision or implementation do not count as resolved, even if their heading contains “Resolution”.
   - Before presenting unresolved notes, check recent git history for each candidate. Some older notes are implementation plans or observations that were completed but never backfilled with a resolution.
   - When git history or repository state clearly shows a candidate was already fixed, do not present it as unresolved; append a concise `## Resolution` section with the evidence instead.
   - Ignore archive or non-markdown files.
3. If no unresolved notes exist, report that there is nothing unresolved in `docs/kaizen/`.
4. If exactly one unresolved note exists, select it automatically and tell the user which note was selected.
5. If more than one unresolved note exists, present a short numbered list of recent unresolved notes, including path and title, and ask the user which one to fix. Do not investigate until the user chooses.

Useful commands:

```bash
find docs/kaizen -maxdepth 1 -type f -name '*.md' -print | sort -r
rg -L '^## Resolution( |$)|^## Resolution applied$|^## Resolution plan' docs/kaizen/*.md
```

Use the commands as aids, not as a substitute for reading candidate notes. Some notes may use a variant resolution heading; inspect before deciding.

Before asking the user to choose from multiple unresolved notes, run targeted `git log --oneline -- <note>` and, when useful, repository-wide `git log --oneline --grep='<keywords>'` checks for stale candidates. Backfill resolutions for candidates that have already been completed, then recompute the unresolved list.

## Investigation Workflow

Use [A3 problem-solving](a3-problem-solving.md) to frame the improvement from observed problem through tested countermeasure and follow-up. Scale the detail to the problem; a small fix does not need a separate A3 document.

1. **Protect unrelated work**
   - Run `git status --short --branch`.
   - If there are unrelated uncommitted changes, avoid touching those files. If the fix would overlap them, stop and ask the user how to proceed.
2. **Read the note fully**
   - Identify the observed problem, context, commands, errors, affected workflow/script/prompt/skill paths, open questions, and any retry command.
3. **Inspect the relevant system**
   - Read the referenced workflows, prompts, scripts, skills, docs, or logs.
   - Reproduce or validate the problem when it is cheap and safe.
   - Use `/systematic-debugging` as the default investigation method for failures, surprising behaviour, or unclear causes. Load and follow that skill before proposing or applying fixes.
   - Keep evidence factual. Separate observations from hypotheses.
4. **Find the root cause**
   - Use [Five Whys](five-whys.md) to trace evidence-supported causes, branching where needed rather than forcing five answers or a single root cause.
   - Investigate both why the defect occurred and why it escaped detection. Distinguish correction, detection/containment, and prevention when choosing countermeasures.
   - State the smallest causal mechanism that explains the observation.
   - Identify whether the problem is in code, prompt instructions, workflow graph, handoff metadata, environment/sandbox setup, documentation, or operator procedure.
5. **Choose the action, autonomously or collaboratively**
   - If there is an obvious, low-risk fix within the authorised scope, apply it without an unnecessary approval round.
   - If there are meaningful trade-offs, several plausible fixes, or a risky/product-facing change, consult the user before implementing. Use the [resolution interview](#resolution-interview) to choose the best course together; do not force an autonomous fix just to close the note.
   - If the root cause is external or cannot be fixed in this repository, document the finding and propose next actions.
   - If a decision is deferred, record the options, recommendation, and open decision. Report the investigation as complete but the resolution as pending.
6. **Validate any applied fix**
   - Run the smallest relevant checks first.
   - Follow the target project's validation instructions and required quality gates (for example, its documented `dev check` or `just` command).
   - For purely documentation changes, use narrower checks when the project permits them.
7. **Update the kaizen note**
   - Append or update a resolution section in the original note.
   - Preserve the original observation text.
   - Include the date, root cause, applied fix or options, files changed, validation performed, and remaining follow-up.
   - Follow the [A3 check-and-act loop](a3-problem-solving.md#check-results-and-sustain-the-improvement): record expected versus observed results, and any owner/review point for later effectiveness checks. Distinguish a fix being applied from recurrence prevention being demonstrated.
8. **Commit the completed kaizen fix**
   - Review `git status --short` and `git diff --stat`.
   - Commit only the kaizen fix, its resolution-note update, and directly supporting workflow/skill/doc changes.
   - Do not include unrelated user work.
   - Use a concise message such as `kaizen: <short resolved problem>`.
   - Do not push unless the user explicitly asks.

## Resolution Interview

After investigating, use a short interview when the best resolution depends on the user's priorities or an acceptable trade-off. Do not assume they have read the logs, followed the investigation, or share your working context.

1. **Brief before asking.** Explain the observed problem and its impact, the causal mechanism, the key supporting evidence, and any remaining uncertainty. Describe how the relevant part of the system works in plain language; paths and logs support the explanation but do not replace it.
2. **Frame the decision.** Present the viable options, what each changes, and the practical benefits, costs, risks, and maintenance consequences. Include deferring action or containment alone when reasonable. Recommend an option and explain why, including which priorities your recommendation assumes.
3. **Interview, don't dump a menu.** Ask one focused question at a time about the priority or constraint that would change the choice. Use a question tool when available for discrete choices, with enough context and meaningful option descriptions for the user to decide without reconstructing the investigation. Invite alternatives rather than forcing a choice among your initial options.
4. **Refine together.** Use the answer to narrow or revise the options. Investigate newly exposed factual unknowns yourself rather than asking the user to guess. Before acting, summarise the agreed change and its scope; seek confirmation if those differ materially from what they selected.
5. **Record the outcome.** Capture the decision and rationale in the kaizen note, including accepted trade-offs and follow-up. If no choice is made, preserve the investigation and mark the decision as pending; do not claim the problem is resolved.

## Resolution Section Template

When the fix was applied:

```markdown
## Resolution

Date: YYYY-MM-DD

Root cause: <concise causal explanation>

Fix applied:

- <file/path>: <what changed and why>
- <file/path>: <what changed and why>

Validation:

- `<command>` — <result>

Remaining follow-up:

- <none, or concrete follow-up>
```

When no fix was applied yet:

```markdown
## Resolution options

Date: YYYY-MM-DD

Root cause: <concise causal explanation, or what remains unknown>

Options:

1. <option> — <benefit, cost/risk>
2. <option> — <benefit, cost/risk>

Recommendation: <recommended option and why>

Validation plan:

- <commands/checks that should prove the chosen fix>

Status: awaiting decision.
```

If an existing resolution section is present but incomplete, update it rather than adding a duplicate.

## Fixing Rules

- Prefer the smallest change that prevents recurrence of the observed workflow/tooling problem.
- Do not rewrite the observation note into a plan; append the resolution while keeping historical evidence intact.
- Do not make broad product-code changes unless the kaizen note clearly points to a delivery-machinery defect in that code and the fix is obvious.
- Commit the completed kaizen fix before reporting done, unless the user explicitly asks not to commit.
- Do not push or create a PR unless the user explicitly asks.
- Report changed file paths and validation results at the end.

## Reporting Format

When done, report:

- Selected kaizen note path.
- Root cause.
- Whether a fix was applied or options were proposed.
- Files changed.
- Validation run and result.
- Commit SHA and message, or why no commit was made.
- Any remaining follow-up or decision needed from the user.
