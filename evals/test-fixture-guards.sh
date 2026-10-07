#!/usr/bin/env bash
# Prove that the fixture checks reject corrupt/unsafe input, not just valid input.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd -P)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
fixture="$here/fixtures/memba-progress.session.jsonl"
"$here/test-fixture.sh"
for defect in signature broken-parent missing-handoff changed-summary; do
  jq -c --arg defect "$defect" '
    if .id == "5cd59679" and $defect == "signature" then .message.content[0].thinkingSignature = "opaque-provider-data"
    elif .id == "5cd59679" and $defect == "broken-parent" then .parentId = "missing"
    elif .id == "5cd59679" and $defect == "missing-handoff" then empty
    elif .id == "4cb9a914" and $defect == "changed-summary" then .summary += " changed"
    else . end
  ' "$fixture" > "$work/$defect.jsonl"
  if "$here/test-fixture.sh" "$work/$defect.jsonl" > "$work/$defect.log" 2>&1; then
    printf 'Accepted broken fixture: %s\n' "$defect" >&2; exit 1
  fi
  if [[ "$defect" != changed-summary ]]; then
    grep -q 'Fixture tree, redaction, or provider-data checks failed' "$work/$defect.log"
  fi
  printf 'Rejected fixture defect: %s\n' "$defect"
done
printf 'Fixture guard tests passed (offline; no model calls).\n'
