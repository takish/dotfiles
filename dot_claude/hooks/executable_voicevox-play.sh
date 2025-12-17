#!/bin/bash
# VOICEVOX 音声ファイルをランダム再生
# Usage: voicevox-play.sh <category>
# Categories: permission, idle, auth, elicitation, completion, startup, resume, session_end
#
# キャラクターはClaude Codeのsession_idから自動決定（同じセッションでは同じキャラクター）
# 手動指定: VOICEVOX_CHARACTER 環境変数
# Available: zundamon, shikoku_metan, tohoku_itako, voidoll, whitecul, aoyama_ryusei

CATEGORY="$1"
[[ -z "$CATEGORY" ]] && exit 0

# stdinからsession_idを取得してキャラクター決定
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)

if [[ -n "$SESSION_ID" ]]; then
  HASH=$(echo -n "$SESSION_ID" | md5)
  INDEX=$(( 0x${HASH:0:2} % 6 ))
  CHARACTERS=(zundamon shikoku_metan tohoku_itako voidoll whitecul aoyama_ryusei)
  CHARACTER="${CHARACTERS[$INDEX]}"
else
  CHARACTER="${VOICEVOX_CHARACTER:-zundamon}"
fi

SOUND_DIR="$HOME/.claude/sounds/voicevox/$CHARACTER"
FILES=("$SOUND_DIR/${CATEGORY}_"*.wav)
[[ ! -f "${FILES[0]}" ]] && exit 0

SELECTED="${FILES[$RANDOM % ${#FILES[@]}]}"
afplay "$SELECTED" &
exit 0
