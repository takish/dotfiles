#!/bin/bash
# VOICEVOX 音声ファイルをランダム再生（SEフォールバック対応）
# Usage: voicevox-play.sh <category>
# Categories: permission, idle, auth, elicitation, completion, startup, resume, session_end
#
# キャラクターはClaude Codeのsession_idから自動決定（同じセッションでは同じキャラクター）
# 手動指定: VOICEVOX_CHARACTER 環境変数
# Available: zundamon, shikoku_metan, tohoku_itako, voidoll, whitecul, aoyama_ryusei
#
# 環境変数:
#   VOICEVOX_MUTE=1     - 音声を無効化
#   VOICEVOX_MODE=se    - 強制的にSE（効果音）を使用
#   VOICEVOX_VOLUME     - 音量（0.0-1.0、デフォルト0.7）

CATEGORY="$1"
[[ -z "$CATEGORY" ]] && exit 0

# ミュート時は何もしない
[[ "${VOICEVOX_MUTE:-0}" == "1" ]] && exit 0

# 音量設定（デフォルト0.7、環境変数で上書き可能）
VOLUME="${VOICEVOX_VOLUME:-0.7}"

# SE再生関数
play_se() {
  case "$CATEGORY" in
    completion|session_end) SE_FILE="stop.wav" ;;
    *) SE_FILE="notification.wav" ;;
  esac
  SE_PATH="$HOME/.claude/sounds/$SE_FILE"
  [[ -f "$SE_PATH" ]] && afplay -v "$VOLUME" "$SE_PATH" &
}

# SEモードの場合は即座にSEを再生
if [[ "${VOICEVOX_MODE:-}" == "se" ]]; then
  play_se
  exit 0
fi

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

# VOICEVOXファイルがない場合はSEにフォールバック
if [[ ! -f "${FILES[0]}" ]]; then
  play_se
  exit 0
fi

SELECTED="${FILES[$RANDOM % ${#FILES[@]}]}"
afplay -v "$VOLUME" "$SELECTED" &
exit 0
