#!/usr/bin/env bash
# Check the committed real-session input without credentials or model calls.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd -P)"
fixture="${1:-$here/fixtures/memba-progress.session.jsonl}"
manifest="$here/fixtures/memba-progress.manifest.json"
case_file="$here/memba-progress.json"
jq -e --arg expected "fixtures/memba-progress.session.jsonl" '
  .session == $expected and .skill == "../skills/talking-to-humans" and .cwd == ".." and
  .references == ["references/human-voice.md"] and .prompt == "update on progress"
' "$case_file" >/dev/null
[[ -s "$here/../skills/talking-to-humans/SKILL.md" && -s "$here/../skills/talking-to-humans/references/human-voice.md" ]]
jq -se --slurpfile manifest "$manifest" --slurpfile case "$case_file" '
  .[0] as $header | .[1:] as $entries | $manifest[0] as $m |
  ($entries | map({key: .id, value: .}) | from_entries) as $by_id |
  ($entries | to_entries | map({key: .value.id, value: .key}) | from_entries) as $positions |
  (map(tojson) | join("\n")) as $text |
  $header.type == "session" and $header.version == 3 and $header.cwd == "." and
  $header.id == "memba-progress-fixture" and $header.parentSession == null and
  ($entries | length) == $m.entries and
  ($entries | map(.id) | unique | length) == ($entries | length) and
  all($entries[]; .parentId == null or
    ($positions[.parentId] != null and $positions[.parentId] < $positions[.id])) and
  ([$entries[] | select(.parentId == null)] | length) == 1 and
  ([$entries[] | select(.type == "compaction")] | length) == 1 and
  $by_id["4cb9a914"].firstKeptEntryId == "be72f223" and
  $by_id["be72f223"] != null and
  $case[0].before == $m.withheld_reply and
  $by_id[$m.withheld_reply].message.role == "assistant" and
  $by_id[$m.withheld_reply].message.stopReason == "stop" and
  $by_id[$m.withheld_reply].parentId == $m.cutoff and
  $entries[-1].id == $m.withheld_reply and
  ([$entries[] | select(.type == "thinking_level_change") | .thinkingLevel] | last) == $m.thinking and
  (any(.. | objects; has("thinkingSignature") or has("thoughtSignature") or has("textSignature") or .type == "image") | not) and
  (any(.. | strings; test("gAAAA[A-Za-z0-9_-]{100,}")) | not) and
  all($m.replacements[] | select(.replacement | startswith("00000000-"));
    .replacement as $placeholder | $text | contains($placeholder))
' "$fixture" >/dev/null || { printf 'Fixture tree, redaction, or provider-data checks failed\n' >&2; exit 1; }
[[ "$(wc -c < "$fixture" | tr -d ' ')" == "$(jq -r .bytes "$manifest")" ]]
# Either hashing utility is normally available on macOS or Linux.
if command -v shasum >/dev/null; then
  digest="$(shasum -a 256 "$fixture")"
elif command -v sha256sum >/dev/null; then
  digest="$(sha256sum "$fixture")"
else
  printf 'shasum or sha256sum is required for fixture integrity verification\n' >&2; exit 1
fi
[[ "${digest%% *}" == "$(jq -r .sha256 "$manifest")" ]]
printf 'Bundled real-session fixture checks passed (offline; no model calls).\n'
