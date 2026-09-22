#!/usr/bin/env bash
# Copy one completed zoom-recorder FLAC into conversation-capture's import flow.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: import-recording.sh <remote-flac-path> <title>

Repairs the remote FLAC into a temporary M4A, copies it to conversation-capture's
call-recording inbox, then runs conversation-capture.
EOF
}

if [[ $# -ne 2 ]]; then
  usage >&2
  exit 64
fi

remote_flac=$1
title=$2
container_host=${ZOOM_RECORDER_HOST:-192.168.1.219}
jump_host=${ZOOM_RECORDER_JUMP_HOST:-100.67.167.59}
container_key=${ZOOM_RECORDER_KEY:-"$HOME/git/mattwynne/hub.local/.local/container_key.pem"}
inbox=${CONVERSATION_CAPTURE_INBOX:-"$HOME/Documents/Conversation Transcripts/Inbox"}

[[ -r $container_key ]] || { echo "Container key not found: $container_key" >&2; exit 1; }
command -v conversation-capture >/dev/null || { echo "conversation-capture is not installed." >&2; exit 1; }

safe_title=$(printf '%s' "$title" | tr '/:' '--' | tr -cd '[:alnum:] ._()-' | sed 's/  */ /g; s/^ *//; s/ *$//')
[[ -n $safe_title ]] || { echo "Title contains no usable filename characters." >&2; exit 64; }

stamp=$(date +%F)
remote_tmp="/tmp/conversation-capture-${stamp}-$$.m4a"
local_file="$inbox/${stamp} - ${safe_title}.m4a"
proxy_command="ssh -i $container_key -o IdentitiesOnly=yes -o IdentityAgent=none root@$jump_host -W %h:%p"
ssh_args=(
  -i "$container_key"
  -o IdentitiesOnly=yes
  -o IdentityAgent=none
  -o "ProxyCommand=$proxy_command"
)

mkdir -p "$inbox"
cleanup() {
  ssh "${ssh_args[@]}" "root@$container_host" "rm -f '$remote_tmp'" 2>/dev/null || true
}
trap cleanup EXIT

# Re-encoding gives incomplete FLAC files a final container/trailer and produces
# the M4A format expected by conversation-capture's call-recording importer.
ssh "${ssh_args[@]}" "root@$container_host" \
  "ffmpeg -y -v error -err_detect ignore_err -i '$remote_flac' -c:a aac -b:a 128k '$remote_tmp'"

scp "${ssh_args[@]}" "root@$container_host:$remote_tmp" "$local_file"
echo "Imported audio: $local_file"

conversation-capture
echo "conversation-capture completed; see ~/Documents/Conversation Transcripts."
