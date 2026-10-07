# Test a skill in a real Pi session

Use Bash, `jq`, and Pi to continue two copies of a recorded session. One answers the request normally; the other reads the skill and its references before answering. Compare the replies yourself.

This is the main test for `talking-to-humans`. The [constructed cases and grader calibration](constructed-cases.md) are supporting checks, not a substitute for the real session.

## Run Matt’s existing case

The private Memba case is saved locally, not committed:

```sh
./evals/replay-session.sh evals/local/talking-to-humans-memba.json
```

To keep the results somewhere durable:

```sh
./evals/replay-session.sh evals/local/talking-to-humans-memba.json evals/local/run-1
```

An existing output directory is refused. A run continues two sessions; reading the skill and references can require additional model turns. Long sessions consume API or subscription allowance even when replies are short.

## Choose another session

Copy `session-case.example.json` into `evals/local/` and edit it. Paths are relative to the case file; absolute paths and `~/` also work. Adjust the example’s paths if you move it.

```json
{
  "session": "/path/to/real-session.jsonl",
  "before": "assistant-reply-entry-id",
  "skill": "~/.pi/agent/skills/talking-to-humans",
  "references": ["references/human-voice.md"],
  "prompt": "update on progress",
  "model": "openai-codex/gpt-6.1-sol"
}
```

- `before` identifies the assistant reply to withhold. Both copies stop at its parent, before that reply is generated.
- `prompt` is the same human request in both conditions. The intervention adds an instruction to read the skill, not a request to improve or rewrite the recorded reply.
- `references` lists the files the skill needs, relative to its directory. They are snapshotted and must actually be read.
- `model` selects the same model for both continuations. `MODEL=provider/model` overrides it. When neither is supplied, a Pi shell tool can provide `PI_PROVIDER/PI_MODEL`.
- Thinking defaults to the recorded level on the selected branch, or `off` if none was recorded. Set `thinking` in the case or use `THINKING=high` to override it.
- The process runs from the recorded working directory. If it no longer exists, set `cwd` in the case.

To find candidate reply IDs:

```sh
jq -r 'select(.type == "message" and .message.role == "assistant") |
  [.id, ([.message.content[]? | select(.type == "text") | .text] |
    join(" ") | .[0:120])] | @tsv' /path/to/real-session.jsonl
```

## What the runner checks

The runner keeps the original messages, roles, tool results, parent links, and recorded compactions. It does not flatten the history or generate a new summary. It resumes native Pi session files, not a textual imitation of a conversation.

Only the read tool is available. Automatic skill discovery, extensions, context files, and project resources are disabled so the intervention is explicit. Both continuations get the same freshly generated Pi system prompt and tools; this is not necessarily the historical system prompt or original model.

A successful run verifies:

- The original session and both copied histories remain unchanged.
- Both continuations finish with nonempty replies, saved consistently in the session and event stream.
- No new compaction or context edits change the comparison.
- The intervention successfully reads the full snapshotted skill and declared references, not just their names or first lines.
- The control makes no tool calls; the intervention reads only the declared snapshots. Present-day project files cannot silently enter a successful comparison.
- The generated system prompts, tools, and actual responding models match.

An error stops the run and leaves the evidence available. These checks test whether the experiment ran correctly. **They do not prove the skill helped.** The control may already contain earlier skill guidance from the recorded session; this measures the effect of explicitly loading it at the chosen point.

## Review the replies

Open `comparison.md`. Replies are labelled A and B in random order. Before opening `answer-key.json`, record your judgment in `review.json`:

```json
{
  "clearer": "A",
  "reason": "It explains the database failure instead of naming it OOM.",
  "lost_or_invented_details": "None noticed."
}
```

Use `A`, `B`, or `tie`. Look for ordinary words, concrete meanings, and a conversational voice. Note lost or invented facts separately. There is no automated readability verdict or all-checks-must-pass language score.

One pair is evidence about that session, not a claim of universal improvement. Repeat with fresh output directories and other real sessions before drawing broader conclusions. The [Superpowers writing-skills guide](https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md) informed the failure-first approach; real replies and human judgment take precedence over a convenient score.

## Saved evidence and privacy

- `comparison.md`, `review.json`, `answer-key.json`: the comparison and human judgment.
- `control/response.txt`, `with_skill/response.txt`: unedited replies.
- `source-session.jsonl`, `seed.jsonl`, per-condition `seed-session.jsonl` and `session.jsonl`: original snapshot, selected history, and continuations.
- `skill/`, `inputs.json`, `case.json`, `settings.json`, `pi-version.txt`: exactly what was supplied.
- `events.jsonl`, `audit.json`, `stderr.txt` inside each condition: runtime evidence and diagnostics.
- `recorded-response.txt`: the original reply, withheld from both continuations; useful as a reference, not an equivalent same-model control.
- `summary.json`: successful replay checks, with the readability verdict left unanswered.

Results contain private conversations and may include credentials or other secrets present in the original log. Outputs use private filesystem permissions. `evals/local/` is ignored by Git; temporary outputs are also supported. Do not commit or share session logs without reviewing them.

## Test the plumbing without model calls

```sh
./evals/test-session-replay.sh
./evals/test-runner.sh
```

Fake-Pi tests deliberately break reads, history preservation, provider responses, and other invariants and require the runner to fail. They test the harness, not communication quality. The older runner additionally tests grader calibration.
