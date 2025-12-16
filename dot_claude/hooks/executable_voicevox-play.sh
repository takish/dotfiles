#!/bin/bash
# VOICEVOX 音声ファイルをランダム再生
# Usage: voicevox-play.sh <category>
# Categories: permission, idle, auth, elicitation, completion, startup, resume, session_end
#
# Environment variables:
#   VOICEVOX_CHARACTER: Character directory name (default: zundamon)
#                       Available: zundamon, shikoku_metan, tohoku_itako, voidoll

CHARACTER="${VOICEVOX_CHARACTER:-zundamon}"
SOUND_DIR="$HOME/.claude/sounds/voicevox/$CHARACTER"
CATEGORY="$1"

# カテゴリが指定されていない場合は終了
[[ -z "$CATEGORY" ]] && exit 0

# カテゴリに対応するファイルを取得（ワイルドカード）
FILES=("$SOUND_DIR/${CATEGORY}_"*.wav)

# ファイルが存在しない場合は終了
[[ ! -f "${FILES[0]}" ]] && exit 0

# ランダムに1つ選択
SELECTED="${FILES[$RANDOM % ${#FILES[@]}]}"

# 非同期で再生
afplay "$SELECTED" &

exit 0
