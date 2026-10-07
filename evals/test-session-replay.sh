#!/usr/bin/env bash
# Regression tests for native session replay. Fake Pi only; never calls a model.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd -P)"
work="$(mktemp -d "${TMPDIR:-/tmp}/session-replay-tests.XXXXXX")"
work="$(cd "$work" && pwd -P)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/cases with spaces/skill source/references" "$work/cases with spaces/working directory"
count=0
pass() { count=$((count + 1)); printf 'ok %s - %s\n' "$count" "$1"; }
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

# This executable really continues the supplied native log, rather than just
# printing a canned answer. The faults below change one piece of evidence.
cat > "$work/bin/pi" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
if [[ "$*" == '--no-extensions --version' ]]; then
  printf 'fake-pi-native-replay\n'
  exit 0
fi
argv="$(jq -cn --args '$ARGS.positional' -- "$@")"
session='' model='' thinking=''
flags=' '
while [[ $# -gt 0 ]]; do
  case "$1" in
    --session) session="$2"; shift 2 ;;
    --model) model="$2"; shift 2 ;;
    --thinking) thinking="$2"; shift 2 ;;
    --mode) [[ "$2" == json ]] || exit 90; shift 2 ;;
    --tools) [[ "$2" == read ]] || exit 91; shift 2 ;;
    --print|--no-extensions|--no-skills|--no-prompt-templates|--no-themes|--no-context-files|--no-approve|--offline)
      flags+="$1 "; shift ;;
    *) printf 'Unexpected Pi argument: %s\n' "$1" >&2; exit 92 ;;
  esac
done
for flag in --print --no-extensions --no-skills --no-prompt-templates --no-themes --no-context-files --no-approve --offline; do
  [[ "$flags" == *" $flag "* ]] || exit 93
done
[[ -s "$session" && -n "$model" && -n "$thinking" ]] || exit 94
run="$(dirname "$session")"
output="$(dirname "$run")"
condition="$(basename "$run")"
prompt="$(</dev/stdin)"
jq -cn --arg condition "$condition" --arg session "$session" --arg cwd "$PWD" \
  --arg prompt "$prompt" --arg model "$model" --arg thinking "$thinking" \
  --argjson argv "$argv" --slurpfile seed "$session" \
  '{condition: $condition, session: $session, cwd: $cwd, prompt: $prompt,
    model: $model, thinking: $thinking, argv: $argv, seed: $seed}' >> "$FAKE_PI_LOG"
mode="${FAKE_PI_MODE:-normal}"
if [[ "$mode" == provider-nonzero ]]; then
  printf 'Synthetic provider failure\n' >&2
  exit 17
fi
if [[ "$mode" == mutate-original && "$condition" == control ]]; then
  printf 'Changed source after snapshot\n' > "$FAKE_SKILL"
  printf 'Changed reference after snapshot\n' > "$FAKE_REFERENCE"
fi
serial=0
append_entry() {
  local payload="$1" record parent
  serial=$((serial + 1))
  parent="$(jq -sr 'last.id' "$session")"
  record="$(jq -cn --argjson payload "$payload" --arg parent "$parent" \
    --arg id "fake-$condition-$serial" \
    '$payload + {id: $id, parentId: $parent, timestamp: "2026-01-01T00:01:00.000Z"}')"
  printf '%s\n' "$record" >> "$session"
  if jq -e '.type == "message"' <<< "$record" >/dev/null; then
    jq -c '{type: "message_end", message: .message}' <<< "$record"
  fi
}
append_message() { append_entry "$(jq -cn --argjson message "$1" '{type: "message", message: $message}')"; }
read_input() {
  local path="$1" content="$2" fault="$3" name="${4:-read}" call_id
  call_id="call-$condition-$serial"
  append_message "$(jq -cn --arg id "$call_id" --arg path "$path" --arg name "$name" \
    '{role: "assistant", content: [{type: "toolCall", id: $id, name: $name, arguments: {path: $path}}],
      api: "fake", provider: "fake", model: "replay", stopReason: "toolUse", timestamp: 1}')"
  if [[ "$fault" == partial ]]; then content="${content:0:12}"; fi
  append_message "$(jq -cn --arg id "$call_id" --arg content "$content" --arg fault "$fault" --arg name "$name" \
    '{role: "toolResult", toolCallId: $id, toolName: $name,
      content: [{type: "text", text: $content}], isError: ($fault == "errored"), timestamp: 2}')"
}
# The audit collects any generated system messages from native records.
system='Identical generated system and read declaration'
if [[ "$mode" == differing-systems && "$condition" == with_skill ]]; then system='Different generated system'; fi
append_message "$(jq -cn --arg text "$system" '{role: "system", content: [{type: "text", text: $text}], timestamp: 0}')"
append_message "$(jq -cn --arg text "$prompt" '{role: "user", content: [{type: "text", text: $text}], timestamp: 1}')"
if [[ "$condition" == with_skill ]]; then
  for index in 0 1; do
    path="$(jq -r --argjson i "$index" '.[$i].path' "$output/inputs.json")"
    content="$(jq -r --argjson i "$index" '.[$i].content' "$output/inputs.json")"
    label=skill; [[ "$index" == 0 ]] || label=reference
    fault=normal
    case "$mode" in
      "missing-$label") continue ;;
      "partial-$label") fault=partial ;;
      "errored-$label") fault=errored ;;
    esac
    read_input "$path" "$content" "$fault"
  done
  case "$mode" in
    unexpected-read) read_input "$output/undeclared.txt" 'Undeclared contents' normal ;;
    unexpected-tool) read_input "$output/skill/SKILL.md" 'Undeclared tool' normal bash ;;
  esac
elif [[ "$mode" == control-tools ]]; then
  read_input "$(jq -r '.[0].path' "$output/inputs.json")" "$(jq -r '.[0].content' "$output/inputs.json")" normal
fi
case "$mode" in
  new-compaction) append_entry '{"type":"compaction","summary":"New summary","firstKeptEntryId":"cutoff","tokensBefore":42}' ;;
  new-context-edit) append_entry '{"type":"context_edit","edits":[]}' ;;
  corrupted-prefix)
    jq -c 'if .type == "session" then .cwd = "/corrupted" else . end' "$session" > "$run/corrupted.jsonl"
    mv "$run/corrupted.jsonl" "$session" ;;
esac
response='A concrete answer for the reader.'
[[ "$condition" != with_skill ]] || response='A clearer answer for the reader.'
[[ "$mode" != blank-response ]] || response=$' \t\n '
stop=stop; [[ "$mode" != stop-error ]] || stop=error
final="$(jq -cn --arg text "$response" --arg stop "$stop" \
  '{role: "assistant", content: [{type: "text", text: $text}], api: "fake", model: "replay", provider: "fake",
    usage: {input: 1, output: 1, totalTokens: 2}, stopReason: $stop, timestamp: 3}')"
if [[ "$mode" == missing-final-event ]]; then
  append_message "$final" >/dev/null
elif [[ "$mode" == mismatched-final ]]; then
  append_message "$final" >/dev/null
  jq -cn --argjson message "$final" '{type: "message_end", message: ($message | .content[0].text = "Not the persisted reply")}'
else
  append_message "$final"
fi
STUB
chmod +x "$work/bin/pi"
export PATH="$work/bin:$PATH" FAKE_PI_LOG="$work/calls.jsonl" MODEL=fake/default
unset THINKING PI_MODEL PI_PROVIDER FAKE_PI_MODE
case_dir="$work/cases with spaces"
source="$case_dir/native session.jsonl"
skill="$case_dir/skill source/SKILL.md"
reference="$case_dir/skill source/references/extra notes.md"
export FAKE_SKILL="$skill" FAKE_REFERENCE="$reference"
printf '# Skill\nUse complete, concrete sentences.\nKeep the important details.\n' > "$skill"
printf '# Reference\nExplain what happens next.\nDo not invent facts.\n' > "$reference"
cp "$skill" "$work/original-skill.md"
cp "$reference" "$work/original-reference.md"
# Native v3 Pi entries, including a preserved compaction and an abandoned
# sibling with later model/thinking changes that must NOT enter the seed.
jq -cn --arg cwd "$case_dir/working directory" '
  {type: "session", version: 3, id: "recorded-session", timestamp: "2026-01-01T00:00:00.000Z", cwd: $cwd},
  {type: "model_change", id: "model-main", parentId: null, provider: "fake", modelId: "recorded"},
  {type: "thinking_level_change", id: "thinking-main", parentId: "model-main", thinkingLevel: "low"},
  {type: "message", id: "old-user", parentId: "thinking-main", message: {role: "user", content: [{type: "text", text: "Earlier request"}], timestamp: 1}},
  {type: "message", id: "old-assistant", parentId: "old-user", message: {role: "assistant", content: [{type: "text", text: "Earlier reply"}], api: "fake", provider: "fake", model: "recorded", stopReason: "stop", timestamp: 2}},
  {type: "compaction", id: "existing-compaction", parentId: "old-assistant", firstKeptEntryId: "old-user", summary: "Recorded summary must survive unchanged", tokensBefore: 1000},
  {type: "model_change", id: "abandoned-model", parentId: "existing-compaction", provider: "wrong", modelId: "sibling"},
  {type: "thinking_level_change", id: "abandoned-thinking", parentId: "abandoned-model", thinkingLevel: "high"},
  {type: "message", id: "abandoned-user", parentId: "abandoned-thinking", message: {role: "user", content: [{type: "text", text: "Sibling request"}], timestamp: 3}},
  {type: "message", id: "abandoned-reply", parentId: "abandoned-user", message: {role: "assistant", content: [{type: "text", text: "Sibling answer"}], api: "fake", provider: "wrong", model: "sibling", stopReason: "stop", timestamp: 4}},
  {type: "message", id: "cutoff", parentId: "existing-compaction", message: {role: "user", content: [{type: "text", text: "Selected request"}], timestamp: 5}},
  {type: "message", id: "withheld", parentId: "cutoff", message: {role: "assistant", content: [{type: "text", text: "WITHHELD ANSWER MUST NOT LEAK"}], api: "fake", provider: "fake", model: "recorded", stopReason: "stop", timestamp: 6}},
  {type: "message", id: "future", parentId: "withheld", message: {role: "user", content: [{type: "text", text: "Future request"}], timestamp: 7}}
  | if .type == "session" then . else . + {timestamp: "2026-01-01T00:00:01.000Z"} end
' > "$source"
cp "$source" "$work/original-session.jsonl"
prompt=$'Explain the result in plain language.\nRetain the important details.'
jq -n --arg prompt "$prompt" '{session: "native session.jsonl", before: "withheld", skill: "skill source",
  prompt: $prompt, references: ["references/extra notes.md"], model: "fake/case"}' > "$case_dir/case.json"
run_success() {
  local config="$1" output="$2"
  if ! bash "$here/replay-session.sh" "$config" "$output" > "$output.log" 2>&1; then
    printf '%s\n' "Replay unexpectedly failed: $output" >&2
    while IFS= read -r line; do printf '%s\n' "$line" >&2; done < "$output.log"
    for stderr in "$output"/*/stderr.txt; do
      [[ -f "$stderr" ]] || continue
      while IFS= read -r line; do printf '%s\n' "$line" >&2; done < "$stderr"
    done
    exit 1
  fi
}
output="$work/results with spaces"
run_success "$case_dir/case.json" "$output"
# Native ancestry, headers, and old compaction are preserved in both copies.
jq -se 'map(.id) == ["recorded-session", "model-main", "thinking-main", "old-user", "old-assistant", "existing-compaction", "cutoff"]' "$output/seed.jsonl" >/dev/null
jq -se --slurpfile original "$source" '
  .[1:] == [$original[] | select(.id == "model-main" or .id == "thinking-main" or .id == "old-user" or .id == "old-assistant" or .id == "existing-compaction" or .id == "cutoff")]
' "$output/seed.jsonl" >/dev/null
for condition in control with_skill; do
  run="$output/$condition"
  jq -se --arg condition "$condition" --arg output "$output" --arg source "$source" --slurpfile seed "$output/seed.jsonl" '
    .[0].id == ("replay-" + ($output | split("/") | last) + "-" + $condition) and
    .[0].parentSession == $source and .[1:] == $seed[1:]
  ' "$run/seed-session.jsonl" >/dev/null
  jq -se 'all(.[]; .id != "withheld" and .id != "future" and (.id | startswith("abandoned-") | not)) and
    ([.[] | select(.type == "compaction")] | length) == 1' "$run/session.jsonl" >/dev/null
  jq -e '.valid and .history_unchanged and .final_persisted and .new_compactions == 0 and .new_context_edits == 0' "$run/audit.json" >/dev/null
  jq -se --slurpfile events "$run/events.jsonl" '
    ([.[] | select(.type == "message" and .message.role == "assistant") | .message] | last) ==
    ([$events[] | select(.type == "message_end" and .message.role == "assistant") | .message] | last)
  ' "$run/session.jsonl" >/dev/null
  [[ -s "$run/response.txt" && -f "$run/stderr.txt" ]]
done
cmp "$source" "$work/original-session.jsonl"
cmp "$source" "$output/source-session.jsonl"
jq -e --arg source "$source" --arg skill "$skill" --arg cwd "$case_dir/working directory" '
  .source == $source and .skill == $skill and .cutoff == "cutoff" and .before == "withheld" and
  .model == "fake/default" and .thinking == "low" and .cwd == $cwd and .tools == ["read"]
' "$output/settings.json" >/dev/null
pass 'selected native ancestry, preserved compaction, withheld answer omitted, source untouched'

jq -se --arg output "$output" --arg cwd "$case_dir/working directory" --arg prompt "$prompt" '
  length == 2 and .[0].condition == "control" and .[1].condition == "with_skill" and
  all(.[]; .model == "fake/default" and .thinking == "low" and .cwd == $cwd and
    (.argv | index("--no-session") == null)) and
  .[0].session == ($output + "/control/session.jsonl") and
  .[1].session == ($output + "/with_skill/session.jsonl") and
  .[0].prompt == $prompt and
  .[1].prompt == ("Read the complete skill and references at these paths:\n- " + $output +
    "/skill/SKILL.md\n- " + $output + "/skill/references/extra notes.md\n\nFollow that guidance when answering this request:\n\n" + $prompt)
' "$FAKE_PI_LOG" >/dev/null
for condition in control with_skill; do
  jq -er --arg condition "$condition" 'select(.condition == $condition) | .prompt' "$FAKE_PI_LOG" > "$work/expected-prompt.txt"
  cmp "$work/expected-prompt.txt" "$output/$condition/prompt.txt"
done
jq -e '.calls == []' "$output/control/audit.json" >/dev/null
jq -e '.reads | length == 2 and all(.[]; .fully_read)' "$output/with_skill/audit.json" >/dev/null
cmp "$skill" "$output/skill/SKILL.md"
cmp "$reference" "$output/skill/references/extra notes.md"
jq -e --rawfile skill "$skill" --rawfile reference "$reference" --arg output "$output" '
  . == [{path: ($output + "/skill/SKILL.md"), content: $skill},
        {path: ($output + "/skill/references/extra notes.md"), content: $reference}]
' "$output/inputs.json" >/dev/null
pass 'exact prompts, paths with spaces, read-only CLI restrictions and complete snapshot reads'

jq -e 'keys == ["A", "B"] and ([.A, .B] | sort) == ["control", "with_skill"]' "$output/answer-key.json" >/dev/null
jq -e '. == {clearer: null, reason: "", lost_or_invented_details: ""}' "$output/review.json" >/dev/null
jq -e '.replay_checks_passed and .original_unchanged and .skill_fully_read and .references_fully_read and
  .new_compactions == 0 and .system_prompts_matched and .readability_verdict == null' "$output/summary.json" >/dev/null
jq -n --rawfile comparison "$output/comparison.md" --slurpfile key "$output/answer-key.json" \
  --rawfile control "$output/control/response.txt" --rawfile skill "$output/with_skill/response.txt" '
  {control: $control, with_skill: $skill} as $answers |
  ($comparison | contains("## Reply A\n\n" + $answers[$key[0].A]) and
    contains("## Reply B\n\n" + $answers[$key[0].B]) and
    (contains("with_skill") or contains("## control") or contains("WITHHELD") | not))
' | jq -e . >/dev/null
printf 'WITHHELD ANSWER MUST NOT LEAK\n' > "$work/expected-recorded.txt"
cmp "$work/expected-recorded.txt" "$output/recorded-response.txt"
pass 'blind answer key, correct A/B text, unanswered JSON review and no automatic verdict'

FAKE_PI_MODE=mutate-original run_success "$case_dir/case.json" "$work/immutable snapshot"
cmp "$work/original-skill.md" "$work/immutable snapshot/skill/SKILL.md"
cmp "$work/original-reference.md" "$work/immutable snapshot/skill/references/extra notes.md"
! cmp -s "$skill" "$work/immutable snapshot/skill/SKILL.md"
! cmp -s "$reference" "$work/immutable snapshot/skill/references/extra notes.md"
jq -e '.valid and all(.reads[]; .fully_read)' "$work/immutable snapshot/with_skill/audit.json" >/dev/null
cp "$work/original-skill.md" "$skill"
cp "$work/original-reference.md" "$reference"
pass 'snapshot is independent of skill and reference source mutations during replay'

# Config-relative paths, skill-file input, and explicit case/CLI overrides.
jq '.skill = "skill source/SKILL.md" | .cwd = "working directory" | .thinking = "medium"' "$case_dir/case.json" > "$case_dir/override.json"
MODEL='' run_success "$case_dir/override.json" "$work/case settings"
jq -e '.model == "fake/case" and .thinking == "medium"' "$work/case settings/settings.json" >/dev/null
MODEL=fake/env THINKING=high run_success "$case_dir/override.json" "$work/env settings"
jq -e '.model == "fake/env" and .thinking == "high"' "$work/env settings/settings.json" >/dev/null
jq 'del(.model, .thinking)' "$case_dir/case.json" > "$case_dir/pi-env.json"
MODEL='' PI_PROVIDER=fake PI_MODEL=pi-env run_success "$case_dir/pi-env.json" "$work/pi env settings"
jq -e '.model == "fake/pi-env" and .thinking == "low"' "$work/pi env settings/settings.json" >/dev/null
pass 'case model/thinking/cwd, file skill path, env overrides and Pi model fallback'

expect_failure() {
  local name="$1" config="${2:-$case_dir/case.json}" out="${3:-$work/reject-$1}"
  if bash "$here/replay-session.sh" "$config" "$out" > "$work/reject-$name.log" 2>&1; then
    fail "accepted $name"
  fi
  [[ ! -f "$out/summary.json" ]] || fail "published success summary for $name"
}
# Check the specific audit predicate so a broken fake or unrelated CLI failure
# cannot accidentally make these negative tests pass.
for mode in missing-skill partial-skill errored-skill missing-reference partial-reference errored-reference; do
  FAKE_PI_MODE="$mode" expect_failure "$mode"
  index=0; [[ "$mode" != *reference ]] || index=1
  jq -e --argjson i "$index" '.valid == false and .reads[$i].fully_read == false' \
    "$work/reject-$mode/with_skill/audit.json" >/dev/null
  pass "reject $mode"
done
for mode in stop-error blank-response corrupted-prefix new-compaction new-context-edit control-tools missing-final-event mismatched-final; do
  FAKE_PI_MODE="$mode" expect_failure "$mode"
  predicate=''
  case "$mode" in
    stop-error) predicate='.final_stop_reason == "error"' ;;
    blank-response) predicate='(.response | test("\\S") | not)' ;;
    corrupted-prefix) predicate='.history_unchanged == false' ;;
    new-compaction) predicate='.new_compactions == 1' ;;
    new-context-edit) predicate='.new_context_edits == 1' ;;
    control-tools) predicate='(.calls | length) == 1' ;;
    missing-final-event|mismatched-final) predicate='.final_persisted == false' ;;
  esac
  jq -e ".valid == false and ($predicate)" "$work/reject-$mode/control/audit.json" >/dev/null
  pass "reject $mode"
done
for mode in unexpected-read unexpected-tool; do
  FAKE_PI_MODE="$mode" expect_failure "$mode"
  jq -e '.valid == false and (.unexpected_calls | length) == 1 and all(.reads[]; .fully_read)' \
    "$work/reject-$mode/with_skill/audit.json" >/dev/null
  pass "reject $mode"
done
FAKE_PI_MODE=provider-nonzero expect_failure provider-nonzero
[[ "$(< "$work/reject-provider-nonzero/control/stderr.txt")" == 'Synthetic provider failure' ]]
[[ ! -f "$work/reject-provider-nonzero/control/audit.json" ]]
pass 'reject nonzero provider exit, retaining stderr'
FAKE_PI_MODE=differing-systems expect_failure differing-systems
for condition in control with_skill; do
  jq -e '.valid' "$work/reject-differing-systems/$condition/audit.json" >/dev/null
done
jq -se '.[0].system_messages != .[1].system_messages' \
  "$work/reject-differing-systems/control/audit.json" "$work/reject-differing-systems/with_skill/audit.json" >/dev/null
pass 'reject differing generated system prompts despite individually valid audits'

jq '.before = "nonexistent"' "$case_dir/case.json" > "$case_dir/missing-before.json"
expect_failure missing-before "$case_dir/missing-before.json"
[[ ! -d "$work/reject-missing-before/control" ]]
pass 'reject missing before ID before calling Pi'
jq '.references = false' "$case_dir/case.json" > "$case_dir/invalid-references.json"
expect_failure invalid-references "$case_dir/invalid-references.json"
[[ ! -d "$work/reject-invalid-references" ]] || fail 'invalid references reached Pi instead of failing validation'
pass 'reject invalid reference type before creating output or calling Pi'
for defect in missing-parent forward-parent duplicate-id non-assistant-before; do
  jq -c --arg defect "$defect" '
    if .id == "cutoff" and $defect == "missing-parent" then .parentId = "absent"
    elif .id == "cutoff" and $defect == "forward-parent" then .parentId = "withheld"
    elif .id == "future" and $defect == "duplicate-id" then .id = "cutoff"
    elif .id == "withheld" and $defect == "non-assistant-before" then .message.role = "user"
    else . end
  ' "$source" > "$case_dir/$defect.jsonl"
  jq --arg session "$defect.jsonl" '.session = $session' "$case_dir/case.json" > "$case_dir/$defect.json"
  expect_failure "$defect" "$case_dir/$defect.json"
  [[ ! -d "$work/reject-$defect/control" ]]
  pass "reject bad ancestry: $defect"
done
# Refusal must leave a completed output and the call count entirely untouched.
calls_before="$(wc -l < "$FAKE_PI_LOG")"
cp "$output/summary.json" "$work/summary-before.json"
if bash "$here/replay-session.sh" "$case_dir/case.json" "$output" > "$work/existing-output.log" 2>&1; then
  fail 'accepted existing output directory'
fi
cmp "$work/summary-before.json" "$output/summary.json"
[[ "$(wc -l < "$FAKE_PI_LOG")" == "$calls_before" ]]
cmp "$source" "$work/original-session.jsonl"
pass 'refuse existing output without overwriting results or calling Pi'
printf '%s session replay regression tests passed (fake Pi; no model calls).\n' "$count"
