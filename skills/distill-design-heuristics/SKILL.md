---
name: distill-design-heuristics
description: Use when distilling practical design heuristics from code reviews, PR discussions, design sessions, architecture debates, incident reviews, or prior team decisions
---

# Design Heuristics

Use this skill to turn real team judgment into reusable design heuristics. A design heuristic is fallible, context-sensitive guidance: a plausible aid to judgment, not a rule.

Before doing substantial distillation work, read `rebecca-wirfs-brock-design-heuristics.md` in this skill directory for the underlying framing and capture practices.

Good sources include human review comments, design conversations, pairing notes, incident reviews, architecture decisions, and stories about past design choices. Prefer evidence from real work over abstract opinions.

## Core Stance

- Capture judgment, not policy.
- Preserve context, tradeoffs, and uncertainty.
- Prefer vivid examples over slogans.
- Treat disagreement and counterexamples as useful data.
- Do not turn one comment into a universal law.
- Test candidates against more than one situation before presenting them as team heuristics.

## Distillation Workflow

1. **Collect evidence**
   - Gather the relevant human discussion, code changes, decisions, and outcomes.
   - For PRs, prefer merged PRs and comments from reviewers.
   - Ignore bot comments unless a human explicitly discusses or endorses them.
   - Use author replies as context, not primary evidence for team preference.

2. **Find design judgment**
   - Look for comments that reveal how the team decides, not merely what was buggy.
   - Notice pressure around names, ownership, boundaries, coupling, compatibility, UX, tests, operations, or project idioms.
   - Ask what design question the reviewer was implicitly answering.

3. **Draft QHE cards**
   - **Question**: What design question does this help answer?
   - **Heuristic**: What fallible guidance helps make progress?
   - **Example**: What concrete before/problem/review-direction story makes it memorable?

4. **Refine the heuristic**
   - Phrase it as guidance, not commandment.
   - Add scope: where it applies.
   - Add consequences: what improves when applied.
   - Add caveats: when it may fail or overreach.
   - Add a competing heuristic: when the opposite advice may be better.
   - Mark confidence: strong, moderate, or weak.

5. **Validate before recommending**
   - Check whether other recent, merged, human-reviewed work supports, weakens, or complicates it.
   - Prefer heuristics that explain several examples.
   - If evidence is thin, keep it as a field note instead of a catalogue entry.

## Candidate Heuristic Template

Use this structure when reporting candidates:

```text
Name:
Design question:
Heuristic:
Scope:
Evidence:
Example:
  Before:
  Problem:
  Review direction:
Consequences:
Caveats:
Competing heuristic:
Confidence: strong | moderate | weak
Recommendation: add to catalogue | revise existing heuristic | keep as field note
```

## Adversarial Checks

For each candidate, ask:

- Is this really a team preference, or one reviewer's local opinion?
- Is the evidence from reviewers rather than mainly from the author?
- Did the work merge, or is this from an unmerged spike?
- Is there a counterexample in the same discussion?
- Does the heuristic explain multiple cases, or is it overfit to one debate?
- Is it too broad, too vague, or just a slogan?
- Is the example concrete enough to show the original problem and better direction?
- What would make the opposite advice better?

## Output Shape

Return:

- A short summary of the review or design themes.
- 3-7 candidate heuristics, unless the evidence only supports fewer.
- For each recommended catalogue entry, at least one before/problem/review-direction example.
- Cross-example validation: what supports, weakens, or complicates each heuristic.
- A clear recommendation: add, revise, or keep as a field note.

## Quality Bar

A weak heuristic says, “A reviewer suggested X.”

A strong heuristic shows:

- The design question being answered.
- The context where the advice helps.
- The concrete problem in the original design.
- The direction the review pushed toward.
- The cost or risk of following the heuristic.
- The situation where competing advice may be better.

## Common Heuristic Shapes

These examples are inspiration, not a fixed catalogue:

- Preserve meaningful behavior unless you explicitly choose the tradeoff.
- Prefer project vocabulary over local cleverness.
- Put behavior at the layer that owns it.
- Names should reveal intent.

When a new candidate overlaps an existing catalogue entry, revise the existing entry instead of adding a duplicate.
