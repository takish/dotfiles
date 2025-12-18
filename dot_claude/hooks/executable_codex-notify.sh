#!/bin/bash
# Codex CLI notification handler
# Receives JSON from stdin: {"type": "agent-turn-complete", "thread-id": "...", "cwd": "..."}
#
# Triggers VOICEVOX, terminal-notifier, and Slack notifications on task completion.

set -euo pipefail

# Read JSON payload from stdin
read -r json || json=""

# Parse event type (default to empty if parsing fails)
event_type=$(echo "$json" | jq -r '.type // empty' 2>/dev/null || echo "")

if [[ "$event_type" == "agent-turn-complete" ]]; then
    # VOICEVOX voice notification
    ~/.claude/hooks/voicevox-play.sh completion &

    # Desktop notification
    ~/.claude/hooks/terminal-notify.sh "Codex" "Task Complete" "タスクが完了しました" &

    # Slack notification
    ~/.claude/hooks/slack-notify.sh "🤖 Codex: タスクが完了しました" &

    # Wait for all background jobs
    wait
fi
