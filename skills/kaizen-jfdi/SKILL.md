---
name: kaizen-jfdi
description: Capture delivery-process friction as a kaizen note and immediately run the kaizen-fix workflow on it. Use when Matt asks to JFDI a kaizen issue, wants a kaizen note and fix in one pass, or asks to turn an observed workflow/tooling problem directly into an applied improvement.
---

# Kaizen JFDI

Use this skill when Matt wants the full kaizen loop in one operation: record the delivery-machinery problem, investigate it, apply an obvious low-risk fix, and update the note with the resolution.

This is an orchestration skill. Do not duplicate the detailed rules, templates, or checklists from the underlying skills. Instead, read and follow them as the source of truth:

- `../kaizen-note/SKILL.md`
- `../kaizen-fix/SKILL.md`

## Workflow

1. **Load the referenced skills**
   - Read both skill files above before acting.
   - Treat this skill as the wrapper that chooses the sequence; treat the referenced skills as authoritative for note quality, investigation discipline, resolution format, validation, and reporting.

2. **Confirm the target problem**
   - If Matt explicitly invoked `kaizen-jfdi`, `/kaizen-jfdi`, `/skill:kaizen-jfdi`, or asked to JFDI a specific kaizen issue, treat that as consent to write the note and attempt the fix.
   - If the problem is ambiguous or multiple workflow/tooling problems are present, ask which one to JFDI before creating or editing notes.
   - If Matt provides an existing `docs/kaizen/` note, skip new-note capture and run the `kaizen-fix` workflow on that note.

3. **Capture or reuse the note**
   - Follow `kaizen-note` to search for a matching existing note, amend it when appropriate, or create a new `docs/kaizen/YYYY-MM-DD-*.md` observation.
   - Keep the observation factual and diagnostic, even though a fix will happen immediately afterwards.
   - For this combined operation, defer the note-only commit until after the fix unless Matt asks to stop after recording the observation.

4. **Fix immediately**
   - Follow `kaizen-fix` on the selected or newly created note.
   - Protect unrelated work, inspect the relevant machinery, find the smallest causal mechanism, apply only obvious low-risk fixes, validate, and append/update the note's resolution section.
   - If the fix is not obvious, risky, or outside this repository, record resolution options in the note rather than forcing a change.

5. **Commit and report**
   - Make one final commit containing the observation note, resolution update, and directly supporting workflow/tooling/doc changes, unless Matt explicitly asks not to commit.
   - Use the reporting format from `kaizen-fix`, adding whether the note was newly created or reused.

## Boundaries

- Use this only for delivery pipeline, workflow, prompt, skill, script, handoff, observability, recovery, sandboxing, or similar tooling friction.
- Do not use it for ordinary product bugs unless the bug exposed a workflow/tooling defect.
- Do not broaden scope beyond the single selected problem without asking Matt.
- Do not push, create a PR, or make product-facing changes unless Matt explicitly asks.
