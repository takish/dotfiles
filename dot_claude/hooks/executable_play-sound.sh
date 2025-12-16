#!/bin/bash
# Claude Code notification sound player
# Usage: play-sound.sh [notification|stop]

SOUND_FILE="${1:-notification}"
SOUND_PATH="$HOME/.claude/sounds/${SOUND_FILE}.wav"

if [[ -f "$SOUND_PATH" ]]; then
    /usr/bin/afplay "$SOUND_PATH" &
fi

exit 0
