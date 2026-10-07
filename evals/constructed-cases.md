# Supporting constructed cases and grader checks

Use the [real-session replay](README.md) as the main test. This earlier runner remains useful for specific examples, grader calibration, and plumbing checks; its totals do not establish the skill’s effectiveness in real work.

Requires Bash, `jq`, and a Pi installation with credentials for your chosen model.

Start with one case:

```sh
MODEL=openai-codex/gpt-6.1-sol CASE_ID=1 \
  ./evals/run.sh evals/talking-to-humans.json
```

Omit `CASE_ID` to run all eight cases. Each case makes four model calls: two responses and two independent grading calls. A full run makes 32 calls and consumes your provider's API or subscription allowance.

When launched by a Pi shell tool, the runner uses that session's `PI_PROVIDER/PI_MODEL` unless `MODEL` is set. From an ordinary terminal, set `MODEL` explicitly. Use a full provider/model ID available in `pi --list-models`.

Optional settings:

```sh
MODEL=openai-codex/gpt-6.1-sol \
JUDGE_MODEL=openrouter/anthropic/claude-sonnet-4.6 \
THINKING=off CASE_ID=8 \
  ./evals/run.sh evals/talking-to-humans.json /tmp/my-new-eval-run
```

`JUDGE_MODEL` defaults to `MODEL`; the judge is always a fresh conversation. `THINKING` defaults to `off` for both generation and grading. Pin full model IDs for comparisons; fuzzy model patterns may resolve differently later.

## Check that the grader catches known problems

```sh
MODEL=openai-codex/gpt-6.1-sol CALIBRATE=1 \
  ./evals/run.sh evals/talking-to-humans.json
```

This skips response generation and grades five fixed responses for case 1: the original dense sentence, a good rewrite, vague ordinary language, headline fragments, and a clear but factually invented handoff. It makes five grading calls.

The judge sees only the task, response, and checks—not the fixture's label, expected outcome, or expected failures. The runner checks that the good response passes and the bad responses fail the specific criteria we expect. For example, headline fragments must fail `human-voice`, not merely fail because they omit a fact. Calibration exits nonzero if the judge gets an expected outcome or failure criterion wrong.

Inspect the evidence in `eval-1/calibration/<fixture>/run-1/grading.json` and the overall `calibration-summary.json`. These fixtures are proposed examples for human review. Passing this small calibration set does not establish that the judge handles every response, or that case 1 distinguishes the skill from the baseline.

## What happens

1. The runner snapshots the suite and system prompts in the results directory.
2. It sends identical context and requests to fresh Pi sessions, with and without the skill. The with-skill prompt includes `SKILL.md` and the references named in the suite.
3. A separate session grades each response against the shared rubric and case-specific expectations. It does not see the skill or a label saying which condition produced the response.
4. Bash validates the returned JSON, calculates totals, and prints a comparison. A case passes only if every check passes.

Pi runs from a temporary directory with tools, extensions, discovered skills, prompt templates, themes, context files, and session persistence disabled. Explicit system prompts replace the usual instructions; an explicit empty append prompt suppresses `APPEND_SYSTEM.md`. Existing Pi credentials and model configuration remain available. This prevents the globally installed skill from leaking into the baseline.

This tests the effect of supplied instructions, **not whether Pi automatically discovers or loads the skill**. References are supplied directly rather than read through tools.

## Results

The runner prints the output directory, which defaults to a new temporary directory. Supply a new directory to keep results somewhere durable; existing directories are refused.

- `system-*.txt`, `suite.json`, `settings.json`, `pi-version.txt`: what was tested.
- `eval-N/prompt.txt`, `inputs/`: the full model-facing prompt and copies of attached text files.
- `eval-N/{with_skill,without_skill}/run-1/outputs/response.txt`: generated responses.
- `judge-prompt.json`, `judge-output.txt`, `grading.json`: judge inputs, raw output, and validated grades.
- `results.jsonl`, `summary.json`: per-case results and totals.
- `*.stderr`: process diagnostics, including provider errors.

A completed run exits successfully even when responses fail checks. Invocation errors, empty responses, and invalid or incomplete judge JSON stop the run with a nonzero exit; partial results remain available.

All checks currently use a model judge. These grades are provisional: inspect the responses and evidence, and compare the judge's opinions with your own. There is one run per condition, no automatic rewriting of skills, and no browser viewer yet. The `grading.json` expectation fields follow Anthropic skill-creator's `text`, `passed`, and `evidence` convention.

## Add another skill

Copy `talking-to-humans.json`, set `skill_name` and `skill_path`, and replace the rubric and cases. `skill_path` is relative to the suite file; reference paths are relative to the skill directory. Rubric entries have a unique `id` and a `text` description. Each case needs a unique positive integer `id`, a `prompt` containing context and the user request, and `expectations` used only by the judge. Neither the rubric nor expectations are given to the response-generating model.

Cases can optionally include `files`: text-file paths relative to the suite (or absolute paths). Their full contents are appended to the prompt and copied into the results. This supports testing a handoff against a long conversation record without rewriting that history as a tidy summary. Keep private transcripts and suites outside the repository unless you intend to publish them. Supplying a transcript as text is not a native-role session replay and does not recreate the original model's hidden reasoning.

Cases can optionally include `calibration` fixtures with a unique lowercase/hyphenated `id`, a fixed `response`, an `expected_pass` boolean, and a `must_fail` list of rubric IDs. Only cases with fixtures run when `CALIBRATE=1`.

This first runner supports text responses only, not tasks that need tools or produce files.

## Use short cases to investigate wording

The approach in [Superpowers: writing-skills](https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md) treats skill instructions as behavior to test, not prose to approve by inspection.

- Observe the relevant failure without the skill before changing it.
- For an output-shape problem, test a positive recipe for the reply rather than adding more prohibitions.
- Use at least five fresh runs per wording variant, with no-skill controls. Read the responses and failure evidence, not just totals.
- Treat inconsistent results as a failure to establish reliability. Do not select the best run or weaken the checks to obtain a pass.
- Short tests must supply enough information to explain the work accurately. Internal labels alone may not establish their practical meaning.
- A short test does not replace a real-session replay or human judgment. Do not let an artificial case prevent testing the situation that actually matters, and do not publish an unverified claim of improvement.

## Test the runner without model calls

```sh
./evals/test-runner.sh
```

The tests substitute a fake Pi executable to check prompt separation, grading, saved results, and error handling. They deliberately substitute judges that always pass, always fail, or reject a response for the wrong reason, and verify calibration rejects each one. They do not establish whether the real judge agrees with humans or whether the skill improves real model responses.
