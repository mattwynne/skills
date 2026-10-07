#!/usr/bin/env bash
# Exercise the runner with a fake Pi executable; no model calls or credentials.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir "$work/bin"
# This stub tests plumbing, NOT whether the real model follows the skill.
cat > "$work/bin/pi" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
[[ " $* " != *' --version '* ]] || { printf 'test-pi\n'; exit 0; }
flags=" $* "
for flag in --print --no-session --no-tools --no-extensions --no-skills --no-prompt-templates --no-themes --no-context-files --no-approve --offline; do
  [[ "$flags" == *" $flag "* ]] || exit 90
done
system_file='' model='' append='not-empty'
while [[ $# -gt 0 ]]; do
  case "$1" in
    --system-prompt) system_file="$2"; shift 2 ;;
    --append-system-prompt) append="$2"; shift 2 ;;
    --model) model="$2"; shift 2 ;;
    *) shift ;;
  esac
done
[[ -z "$append" ]] || exit 91
system="$(< "$system_file")"
prompt="$(</dev/stdin)"
printf '%s' "$prompt" > "$FAKE_PI_LOG.stdin"
jq -cn --arg system "$system" --rawfile prompt "$FAKE_PI_LOG.stdin" --arg model "$model" \
  '{system: $system, prompt: $prompt, model: $model}' >> "$FAKE_PI_LOG"
case "${FAKE_PI_MODE:-}" in
  error) printf 'Simulated provider error\n' >&2; exit 1 ;;
  empty) exit 0 ;;
esac
if [[ "$system" == Evaluate* ]]; then
  if [[ "${FAKE_PI_MODE:-}" == malformed ]]; then printf 'Not JSON\n'; exit 0; fi
  if [[ "${FAKE_PI_MODE:-}" == missing ]]; then printf '{"expectations":[]}\n'; exit 0; fi
  jq '{expectations: [.expectations[] as $e | {
    text: $e,
    passed: (if env.FAKE_PI_MODE == "always-pass" then true
      elif env.FAKE_PI_MODE == "always-fail" then false
      elif (.response | rtrimstr("\n")) == "clear response" or (.response | rtrimstr("\n")) == env.FAKE_PI_GOOD then true
      elif env.FAKE_PI_MODE == "wrong-reason" then ($e | startswith("Sounds like"))
      else false end),
    evidence: "Synthetic test grade"
  }]}' <<< "$prompt"
elif [[ "$system" == *'Never use jargon'* ]]; then
  printf 'clear response\n'
else
  printf 'dense response\n'
fi
STUB
chmod +x "$work/bin/pi"
export PATH="$work/bin:$PATH" FAKE_PI_LOG="$work/calls.jsonl"
export MODEL=fake/generator JUDGE_MODEL=fake/judge CASE_ID=1
export FAKE_PI_GOOD="$(jq -r '.evals[0].calibration[] | select(.expected_pass) | .response' "$here/talking-to-humans.json")"
"$here/run.sh" "$here/talking-to-humans.json" "$work/results with spaces"
output="$work/results with spaces"
jq -se 'length == 4 and .[0].model == "fake/generator" and .[1].model == "fake/judge" and
  .[0].prompt == .[2].prompt and
  (.[0].system | contains("Never use jargon") | not) and
  (.[2].system | contains("Never use jargon")) and
  (.[2].system | contains("# Normal words and the human voice")) and
  (.[1].system | contains("Never use jargon") | not) and
  (.[1].prompt | fromjson | has("configuration") | not)' "$FAKE_PI_LOG" >/dev/null
jq -e 'map(select(.configuration == "with_skill"))[0].cases_passed == 1 and
  map(select(.configuration == "without_skill"))[0].cases_passed == 0' "$output/summary.json" >/dev/null
jq -e '.summary.total == 9 and .summary.passed == 9' "$output/eval-1/with_skill/run-1/grading.json" >/dev/null
for mode in error empty malformed missing; do
  if FAKE_PI_MODE="$mode" "$here/run.sh" "$here/talking-to-humans.json" "$work/$mode" > "$work/$mode.log" 2>&1; then
    printf 'Expected failure for %s\n' "$mode" >&2; exit 1
  fi
  [[ ! -f "$work/$mode/summary.json" ]]
done
if CASE_ID=999 "$here/run.sh" "$here/talking-to-humans.json" "$work/unknown-case" > "$work/unknown.log" 2>&1; then
  printf 'Expected unknown case to fail\n' >&2; exit 1
fi
[[ ! -d "$work/unknown-case" ]]
if "$here/run.sh" "$here/talking-to-humans.json" "$output" > "$work/overwrite.log" 2>&1; then
  printf 'Expected existing output directory to be refused\n' >&2; exit 1
fi
CASE_ID='' "$here/run.sh" "$here/talking-to-humans.json" "$work/all-cases" > "$work/all.log"
jq -e 'length == 2 and all(.[]; .cases == 8)' "$work/all-cases/summary.json" >/dev/null
[[ "$(wc -l < "$work/all-cases/results.jsonl" | tr -d ' ')" == 16 ]]
CALIBRATE=1 "$here/run.sh" "$here/talking-to-humans.json" "$work/calibration" > "$work/calibration.log"
jq -e '.fixtures == 5 and .matched == 5' "$work/calibration/calibration-summary.json" >/dev/null
for mode in always-pass always-fail wrong-reason; do
  if CALIBRATE=1 FAKE_PI_MODE="$mode" "$here/run.sh" "$here/talking-to-humans.json" "$work/calibration-$mode" > "$work/calibration-$mode.log" 2>&1; then
    printf 'Expected calibration to reject %s judge\n' "$mode" >&2; exit 1
  fi
  jq -e '.matched < .fixtures' "$work/calibration-$mode/calibration-summary.json" >/dev/null
done
jq -e '.results[] | select(.fixture == "headline-fragments") |
  .response_passed == false and .matched == false and .missed_failures == ["human-voice"]' \
  "$work/calibration-wrong-reason/calibration-summary.json" >/dev/null
jq -se 'map(select(.system | startswith("Evaluate")) | .prompt | fromjson) |
  all(.[]; (has("expected_pass") or has("must_fail") or has("fixture")) | not)' "$FAKE_PI_LOG" >/dev/null
printf 'A preserved conversation with a distinct source marker.\n' > "$work/conversation.txt"
jq --arg skill "$here/../skills/talking-to-humans" \
  '.skill_path = $skill | .evals[0].files = ["conversation.txt"]' \
  "$here/talking-to-humans.json" > "$work/file-suite.json"
"$here/run.sh" "$work/file-suite.json" "$work/file-input" > "$work/file-input.log"
cmp "$work/conversation.txt" "$work/file-input/eval-1/inputs/input-1.txt"
jq -se '.[-4:] | .[0].prompt == .[2].prompt and
  (.[0].prompt | contains("A preserved conversation with a distinct source marker.")) and
  (.[1].prompt | fromjson | .task | contains("A preserved conversation with a distinct source marker."))' "$FAKE_PI_LOG" >/dev/null
printf 'Runner tests passed, including rejected broken judges and attached transcripts (fake Pi; no behavioral evaluation).\n'
