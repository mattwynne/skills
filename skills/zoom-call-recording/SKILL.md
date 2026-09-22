---
name: zoom-call-recording
description: Schedule, monitor, archive, and transcribe authorized Zoom calls using Matt's zoom-recorder LXC, persistent Proxmox storage, and conversation-capture. Use when Matt asks to record a Zoom meeting, check a Zoom recording, copy it locally, or turn it into a processed transcript.
---

# Zoom call recording

Use only for calls Matt is authorized to attend and record. Confirm any required notice, consent, and host approval. Do not expose meeting URLs, Zoom passwords, VNC passwords, or account credentials in notes or summaries.

## Architecture

- LXC: `zoom-recorder` at `192.168.1.219`
- Persistent recordings: host `/home/zoom-recorder`, mounted in the LXC at `/var/lib/zoom-recorder/recordings`
- Scheduled service: `workbc-recorder.service` and `workbc-recorder.timer`
- Remote access from outside the LAN: Tailscale jump host `root@100.67.167.59`
- Local transcript pipeline: `conversation-capture`, whose call-recording inbox is `~/Documents/Conversation Transcripts/Inbox`

The Zoom account should remain signed in, with its correct display name and avatar. The client must have its **Recording** speaker selected, **Null Input** microphone selected, and automatic join preview disabled. A meeting host may still need to admit it from a waiting room.

## Before a scheduled call

1. Verify the service has the intended meeting URL:

   ```sh
   ssh -J root@100.67.167.59 root@192.168.1.219 \
     'systemctl show -p ExecStart workbc-recorder.service'
   ```

2. Verify the timer is active:

   ```sh
   ssh -J root@100.67.167.59 root@192.168.1.219 \
     'systemctl list-timers --all workbc-recorder.timer'
   ```

3. Confirm no manual or test recorder session is still running. A stale Zoom client can block a new client or consume the meeting URL.

## During a call

Check that the recorder service is active and that the current FLAC contains non-silent audio:

```sh
ssh -J root@100.67.167.59 root@192.168.1.219 '
  systemctl is-active workbc-recorder.service
  recording=$(find /var/lib/zoom-recorder/recordings -maxdepth 1 -name "*.flac" -printf "%T@ %p\n" | sort -nr | head -1 | cut -d" " -f2-)
  ffmpeg -v info -i "$recording" -af astats=metadata=1:reset=0 -f null - 2>&1 |
    grep -E "Peak level dB|RMS level dB" | tail -4
'
```

`RMS level dB: -inf` means silence. Confirm that Zoom actually joined the meeting and is using the `Recording` speaker.

## Import and transcribe

Run the bundled importer from this skill directory. It repairs the FLAC into an M4A for reliable import, copies it to the `conversation-capture` inbox, and invokes the existing transcript/Notes automation:

```sh
scripts/import-recording.sh \
  /var/lib/zoom-recorder/recordings/<recording>.flac \
  "Descriptive meeting title"
```

The raw FLAC remains on persistent host storage. `conversation-capture` writes the processed Markdown transcript under `~/Documents/Conversation Transcripts` and performs its configured Apple Notes automation.

## Process the transcript

After import completes:

1. Read the generated Markdown transcript, not just the raw audio.
2. State whether the transcript is complete enough for processing; flag inaudible spans or likely errors.
3. If Matt asks for processing, produce concise notes with:
   - purpose and key decisions;
   - commitments, owners, and dates only when clearly supported;
   - questions and follow-ups;
   - a short summary suitable for his notes system.
4. Do not invent actions, attendance, or conclusions absent from the transcript.

## Troubleshooting

- **VNC connection refused:** no recorder/configuration session is running, so x11vnc is not listening on port 5900.
- **Zoom crash dialog:** dismiss it, then check whether the main Zoom process is still running. A pending crash report can appear on the next launch; do not assume it proves the current client failed.
- **Zoom stops at a name/preview screen:** save the intended name and disable the join preview, then restart a test session and verify it reaches the waiting room or meeting automatically.
- **FLAC has no duration:** systemd ended the process before FLAC metadata finalized. The importer re-encodes it before transcription.
- **No audio:** verify Zoom is admitted and connected to computer audio, then test the speaker path and re-check the live RMS level.
