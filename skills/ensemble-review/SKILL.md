---
name: ensemble-review
description: Run a parallel multi-model review with Gemini, Codex, and Claude, then synthesize the reports into a single decision-oriented review. Use when the user asks for an ensemble review, three-way review, deep review, or independent second opinions on code, design, plans, or documents.
---

# Ensemble Review

Run a parallel review with multiple independent models, then synthesize their findings.

The point is not to average opinions. The point is to reduce single-model blind spots: each reviewer explores independently, writes a standalone report, and the main agent adjudicates the results into concrete findings and recommendations.

## Workflow

1. Create a temporary review directory under the system temp directory, named with an `ensemble-review-` or `pi-review-` prefix. Keep the path for the final answer.
2. Dispatch three independent reviewers in parallel:
   - Gemini
   - Codex
   - Claude
3. Give each reviewer the same review request, plus:
   - the temporary review directory path;
   - its exact report output path:
     - `gemini.md`
     - `codex.md`
     - `claude.md`
   - an instruction to write its complete standalone report to that path;
   - an instruction not to edit repository files.
4. Wait for all three reports. If one reviewer fails, continue with the reports that exist and call out the failure in the synthesis.
5. Read the report files from the temporary directory.
6. Synthesize the findings into a single report for the user.

## Reviewer Task Template

```text
Review request:

<paste the user's request here>

Write a standalone review report to:

<temporary review directory>/<model-name>.md

Rules:

- Do not modify repository files.
- You may write only the report file named above.
- Use read-only exploration commands only.
- Focus on concrete findings with evidence.
- Include file paths and line numbers where applicable.
- Separate high-confidence findings from lower-confidence concerns.
- End with a short "Top recommendations" section.
```

## Suggested Pi Subagent Setup

If the project has Pi subagents named `deep-review-gemini`, `deep-review-codex`, and `deep-review-claude`, use the `subagent` tool with `agentScope` set to `"both"` and `confirmProjectAgents` set to `false`.

Dispatch all three project-local agents in parallel with the reviewer task template above.

## Suggested CLI Fallbacks

If project-local review agents are not available, use non-interactive CLI commands when installed. Write the reviewer prompt to a temporary file first, then adapt these command shapes as needed:

```bash
claude -p --permission-mode dontAsk --tools Read,Grep,Glob < /tmp/ensemble-review-prompt.txt
codex exec -C "$PWD" -s read-only - < /tmp/ensemble-review-prompt.txt
gemini --skip-trust --approval-mode plan --prompt "$(cat /tmp/ensemble-review-prompt.txt)"
```

If a CLI is unavailable or fails non-interactively, skip it and report the exact command/error in the synthesis rather than blocking the review.

## Synthesis Format

```markdown
# Ensemble Review Synthesis

Temporary reports: <directory>

## Executive Summary

## Findings

Group findings by severity. For each finding, include:

- severity;
- concise title;
- evidence and file references;
- which reviewer(s) raised it;
- whether the synthesis agrees it is valid;
- recommended action.

## Disagreements Or Single-Reviewer Findings

## Gaps And Follow-Up Checks

## Source Reports

- Gemini: <path>
- Codex: <path>
- Claude: <path>
```

Keep the final synthesized report direct and decision-oriented. Do not paste the full three source reports unless the user asks for them.
