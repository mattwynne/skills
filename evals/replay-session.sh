#!/usr/bin/env bash
# Usage: ./evals/replay-session.sh case.json [new-output-directory]
set -euo pipefail
umask 077
here="$(cd "$(dirname "$0")" && pwd -P)"
fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
[[ $# -ge 1 && $# -le 2 ]] || fail "Usage: $0 case.json [new-output-directory]"
for tool in pi jq; do command -v "$tool" >/dev/null || fail "$tool is required"; done
case_file="$(cd "$(dirname "$1")" && pwd -P)/$(basename "$1")"
jq -e '
  type == "object" and
  all(.session, .before, .skill, .prompt; type == "string" and length > 0 and (contains("\u0000") | not)) and
  (.references == null or (.references | type == "array" and all(.[];
    type == "string" and length > 0 and (startswith("/") | not) and
    (contains("\u0000") | not) and (split("/") | all(.[]; . != ".." and . != "." and . != ""))))) and
  all(.model, .thinking, .cwd; . == null or (type == "string" and length > 0 and (contains("\u0000") | not)))
' "$case_file" >/dev/null || fail "Invalid replay case: $case_file"
resolve() {
  local path="$1"
  [[ "$path" != '~/'* ]] || path="$HOME/${path:2}"
  [[ "$path" == /* ]] || path="$(dirname "$case_file")/$path"
  printf '%s\n' "$path"
}
source="$(resolve "$(jq -r .session "$case_file")")"
skill="$(resolve "$(jq -r .skill "$case_file")")"
[[ ! -d "$skill" ]] || skill="$skill/SKILL.md"
[[ -f "$source" ]] || fail "Missing session: $source"
[[ -s "$skill" ]] || fail "Missing or empty skill: $skill"
source="$(cd "$(dirname "$source")" && pwd -P)/$(basename "$source")"
skill="$(cd "$(dirname "$skill")" && pwd -P)/$(basename "$skill")"
model="${MODEL:-}"
[[ -n "$model" ]] || model="$(jq -r '.model // empty' "$case_file")"
if [[ -z "$model" && -n "${PI_PROVIDER:-}" && -n "${PI_MODEL:-}" ]]; then model="$PI_PROVIDER/$PI_MODEL"; fi
[[ -n "$model" ]] || fail "Set model in the case, MODEL=provider/model, or run from a Pi shell tool"
before="$(jq -r .before "$case_file")"
if [[ $# -eq 2 ]]; then
  mkdir -p "$(dirname "$2")"
  mkdir "$2" || fail "Output directory must not already exist: $2"
  output="$(cd "$2" && pwd -P)"
else
  output="$(mktemp -d "${TMPDIR:-/tmp}/skill-session-replay.XXXXXX")"
  output="$(cd "$output" && pwd -P)"
fi
printf 'Results: %s\n' "$output"
cp "$case_file" "$output/case.json"
cp "$source" "$output/source-session.jsonl"
# Preserve native entries and parent links on the selected branch. Do not turn
# messages into a transcript or regenerate the recorded compaction summaries.
jq -cs --arg before "$before" '
  .[0] as $header | .[1:] as $entries |
  if $header.type != "session" or ($header.version != 2 and $header.version != 3)
    then error("Need a v2/v3 Pi session") else . end |
  if ($entries | all(.[]; (.id | type == "string") and (.parentId == null or (.parentId | type == "string")))) | not
    then error("Invalid session entry IDs") else . end |
  if ($entries | map(.id) | length) != ($entries | map(.id) | unique | length)
    then error("Duplicate session entry IDs") else . end |
  ($entries | map({key: .id, value: .}) | from_entries) as $index |
  ($entries | to_entries | map({key: .value.id, value: .key}) | from_entries) as $positions |
  $index[$before] as $target |
  if $target.type != "message" or $target.message.role != "assistant" or $target.parentId == null
    then error("before must identify an assistant reply with a parent") else . end |
  if ($entries | all(.[]; .parentId == null or
      ($positions[.parentId] != null and $positions[.parentId] < $positions[.id]))) | not
    then error("Broken or cyclic parent links") else . end |
  [$index[$target.parentId] | recurse(if .parentId == null then empty else $index[.parentId] end)] | reverse |
  $header, .[]
' "$output/source-session.jsonl" > "$output/seed.jsonl" || fail "Cannot select reply $before; see $output"
thinking="${THINKING:-}"
[[ -n "$thinking" ]] || thinking="$(jq -r '.thinking // empty' "$case_file")"
[[ -n "$thinking" ]] || thinking="$(jq -sr '[.[] | select(.type == "thinking_level_change") | .thinkingLevel] | last // "off"' "$output/seed.jsonl")"
case "$thinking" in off|minimal|low|medium|high|xhigh|max) ;; *) fail "Invalid thinking level: $thinking" ;; esac
cwd="$(jq -r '.cwd // empty' "$case_file")"
if [[ -n "$cwd" ]]; then cwd="$(resolve "$cwd")"; else cwd="$(jq -r 'select(.type == "session") | .cwd' "$output/seed.jsonl")"; fi
[[ -d "$cwd" ]] || fail "Recorded working directory no longer exists; set cwd in the case: $cwd"
cwd="$(cd "$cwd" && pwd -P)"
mkdir "$output/skill"
cp "$skill" "$output/skill/SKILL.md"
while IFS= read -r reference; do
  [[ -s "$(dirname "$skill")/$reference" ]] || fail "Missing or empty reference: $reference"
  mkdir -p "$(dirname "$output/skill/$reference")"
  cp "$(dirname "$skill")/$reference" "$output/skill/$reference"
done < <(jq -r '.references[]?' "$case_file")
jq -n --arg path "$output/skill/SKILL.md" --rawfile content "$output/skill/SKILL.md" \
  '[{path: $path, content: $content}]' > "$output/inputs.json"
while IFS= read -r reference; do
  jq --arg path "$output/skill/$reference" --rawfile content "$output/skill/$reference" \
    '. + [{path: $path, content: $content}]' "$output/inputs.json" > "$output/inputs.next.json"
  mv "$output/inputs.next.json" "$output/inputs.json"
done < <(jq -r '.references[]?' "$case_file")
jq -n --arg source "$source" --arg skill "$skill" --arg before "$before" --arg model "$model" \
  --arg thinking "$thinking" --arg cwd "$cwd" --slurpfile seed "$output/seed.jsonl" \
  '{source: $source, skill: $skill, before: $before, cutoff: $seed[-1].id,
    model: $model, thinking: $thinking, cwd: $cwd, tools: ["read"],
    note: "Late loading in native session copies, not a test of automatic skill discovery."}' > "$output/settings.json"
pi --no-extensions --version > "$output/pi-version.txt"
for condition in control with_skill; do
  run="$output/$condition"
  mkdir "$run"
  jq -c --arg id "replay-$(basename "$output")-$condition" --arg source "$source" \
    'if .type == "session" then .id = $id | .parentSession = $source else . end' \
    "$output/seed.jsonl" > "$run/seed-session.jsonl"
  cp "$run/seed-session.jsonl" "$run/session.jsonl"
  if [[ "$condition" == with_skill ]]; then
    printf 'Read the complete skill and references at these paths:\n' > "$run/prompt.txt"
    jq -r '.[] | "- " + .path' "$output/inputs.json" >> "$run/prompt.txt"
    printf '\nFollow that guidance when answering this request:\n\n' >> "$run/prompt.txt"
  fi
  jq -r .prompt "$case_file" >> "$run/prompt.txt"
  printf 'Continuing session: %s\n' "$condition"
  if ! (cd "$cwd" && pi --print --mode json --session "$run/session.jsonl" --tools read \
      --no-extensions --no-skills --no-prompt-templates --no-themes --no-context-files \
      --no-approve --offline --model "$model" --thinking "$thinking" \
      < "$run/prompt.txt") > "$run/events.jsonl" 2> "$run/stderr.txt"; then
    fail "Pi failed; see $run/stderr.txt (partial results: $output)"
  fi
  jq -s --arg condition "$condition" --slurpfile seed "$run/seed-session.jsonl" \
    --slurpfile events "$run/events.jsonl" --slurpfile inputs "$output/inputs.json" \
    -f "$here/session-audit.jq" "$run/session.jsonl" > "$run/audit.json" \
    || fail "Invalid replay evidence: $run"
  jq -e '.valid' "$run/audit.json" >/dev/null || fail "Replay checks failed; see $run/audit.json"
  jq -r '.response' "$run/audit.json" > "$run/response.txt"
done
cmp -s "$source" "$output/source-session.jsonl" || fail "Original session changed during the run; cannot verify it was untouched"
jq -e -s '.[0].system_messages == .[1].system_messages and
  .[0].model == .[1].model and .[0].provider == .[1].provider' \
  "$output/control/audit.json" "$output/with_skill/audit.json" >/dev/null \
  || fail "System prompts/tool declarations or actual models differed between conditions"
# Hide which reply loaded the skill until the human has compared them.
a=control; b=with_skill
if (( RANDOM % 2 )); then a=with_skill; b=control; fi
jq -n --arg a "$a" --arg b "$b" '{A: $a, B: $b}' > "$output/answer-key.json"
jq -n '{clearer: null, reason: "", lost_or_invented_details: ""}' > "$output/review.json"
{
  printf '# Compare the replies\n\nWhich reply is easier to understand without decoding the agent’s working notes?\n'
  printf 'Record A, B, or tie in `review.json`, explain why, and note any important details lost or invented.\n'
  printf 'Then consult `answer-key.json`. Completion of this run is not a verdict on the skill.\n\n'
  printf '## Reply A\n\n%s\n\n## Reply B\n\n%s\n' "$(< "$output/$a/response.txt")" "$(< "$output/$b/response.txt")"
} > "$output/comparison.md"
jq -sr --arg before "$before" '.[] | select(.id == $before) |
  [.message.content[]? | select(.type == "text") | .text] | join("\n")' \
  "$output/source-session.jsonl" > "$output/recorded-response.txt"
jq -n '{replay_checks_passed: true, original_unchanged: true, skill_fully_read: true,
  references_fully_read: true, new_compactions: 0, system_prompts_matched: true,
  readability_verdict: null}' > "$output/summary.json"
printf 'Replay checks passed. Compare the replies: %s/comparison.md\n' "$output"
