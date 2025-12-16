#!/bin/bash
# VOICEVOX Engine API を使って音声ファイルを一括生成
# 事前に VOICEVOX Engine を起動しておくこと（デフォルト: localhost:50021）
#
# 使い方:
#   1. VOICEVOX Engine を起動
#   2. このスクリプトを実行: ./generate-voices.sh [SPEAKER_ID]
#   3. 生成されたファイルを確認: ls ~/.claude/sounds/voicevox/<character>/
#
# Speaker ID examples:
#   2   = 四国めたん (ノーマル)
#   3   = ずんだもん (ノーマル)
#   89  = Voidoll
#   109 = 東北イタコ (ノーマル)

SPEAKER_ID="${1:-3}"  # 引数で話者IDを指定可能（デフォルト: 3 = ずんだもん ノーマル）
API_URL="http://localhost:50021"

# VOICEVOX Engine が起動しているか確認
if ! curl -s "$API_URL/version" > /dev/null 2>&1; then
  echo "Error: VOICEVOX Engine is not running at $API_URL"
  echo "Please start VOICEVOX Engine first."
  exit 1
fi

# 日本語キャラクター名からディレクトリ名へのマッピング
map_character_name() {
  local name="$1"
  case "$name" in
    "ずんだもん") echo "zundamon" ;;
    "四国めたん") echo "shikoku_metan" ;;
    "春日部つむぎ") echo "kasukabe_tsumugi" ;;
    "雨晴はう") echo "amehare_hau" ;;
    "波音リツ") echo "namine_ritsu" ;;
    "玄野武宏") echo "kurono_takehiro" ;;
    "白上虎太郎") echo "shirakami_kotaro" ;;
    "青山龍星") echo "aoyama_ryusei" ;;
    "冥鳴ひまり") echo "meimei_himari" ;;
    "九州そら") echo "kyushu_sora" ;;
    "もち子さん") echo "mochiko" ;;
    "剣崎雌雄") echo "kenzaki_mesuo" ;;
    "WhiteCUL") echo "whitecul" ;;
    "後鬼") echo "goki" ;;
    "No.7") echo "no7" ;;
    "ちび式じい") echo "chibishikijii" ;;
    "櫻歌ミコ") echo "ohka_miko" ;;
    "小夜/SAYO") echo "sayo" ;;
    "ナースロボ＿タイプＴ") echo "nurserobo_typet" ;;
    "†聖騎士 紅桜†") echo "paladin_benizakura" ;;
    "雀松朱司") echo "wakamatsu_akeshi" ;;
    "麒ヶ島宗麟") echo "kigashima_sorin" ;;
    "Voidoll") echo "voidoll" ;;
    "東北イタコ") echo "tohoku_itako" ;;
    *) echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g' | sed 's/__*/_/g' | sed 's/^_//;s/_$//' ;;
  esac
}

# Speaker ID から キャラクター名を取得
get_character_name() {
  local id="$1"
  local name
  name=$(curl -s "$API_URL/speakers" | jq -r --arg id "$id" '.[] | select(.styles[].id == ($id | tonumber)) | .name' | head -1)
  map_character_name "$name"
}

CHARACTER_NAME=$(get_character_name "$SPEAKER_ID")
if [ -z "$CHARACTER_NAME" ]; then
  echo "Error: Could not find character for speaker ID $SPEAKER_ID"
  exit 1
fi

OUTPUT_DIR="$HOME/.claude/sounds/voicevox/$CHARACTER_NAME"

# 出力ディレクトリを作成
mkdir -p "$OUTPUT_DIR"

echo "Using speaker ID: $SPEAKER_ID"
echo "Character: $CHARACTER_NAME"
echo "Output directory: $OUTPUT_DIR"
echo ""

# 音声リスト（ファイル名とテキストのペア）
VOICES="
permission_01:ご確認お願いします
permission_02:許可が必要です
permission_03:確認をお待ちしています
idle_01:お待ちしています
idle_02:入力をお待ちしています
idle_03:何かありましたらどうぞ
auth_01:認証できました
auth_02:ログインしました
auth_03:準備完了です
elicitation_01:入力が必要です
elicitation_02:情報を教えてください
elicitation_03:追加情報をお願いします
completion_01:完了しました
completion_02:作業が終わりました
completion_03:タスク完了です
startup_01:よろしくお願いします
startup_02:はじめましょう
startup_03:準備OKです
resume_01:再開します
resume_02:続きからですね
resume_03:お帰りなさい
session_end_01:お疲れ様でした
session_end_02:また後ほど
session_end_03:ではまた
"

TOTAL=$(echo "$VOICES" | grep -c ":")
COUNT=0

echo "$VOICES" | while IFS=: read -r key text; do
  # 空行をスキップ
  [ -z "$key" ] && continue

  output_file="$OUTPUT_DIR/${key}.wav"
  COUNT=$((COUNT + 1))

  echo "[$COUNT/$TOTAL] Generating: $key"
  echo "  Text: $text"

  # 音声合成クエリを作成
  QUERY=$(curl -s -X POST "$API_URL/audio_query" \
    -H "Content-Type: application/json" \
    --get --data-urlencode "text=$text" \
    --data-urlencode "speaker=$SPEAKER_ID")

  if [ -z "$QUERY" ] || [ "$QUERY" = "null" ]; then
    echo "  Error: Failed to create audio query"
    continue
  fi

  # 音声合成を実行
  curl -s -X POST "$API_URL/synthesis?speaker=$SPEAKER_ID" \
    -H "Content-Type: application/json" \
    -d "$QUERY" \
    --output "$output_file"

  if [ -f "$output_file" ]; then
    SIZE=$(ls -lh "$output_file" | awk '{print $5}')
    echo "  -> $output_file ($SIZE)"
  else
    echo "  Error: Failed to generate $output_file"
  fi
done

echo ""
echo "Done! Generated files in $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"/*.wav 2>/dev/null | wc -l | xargs echo "Total files:"
echo ""
echo "To list available speakers, run:"
echo "  curl -s $API_URL/speakers | jq '.[] | {name, styles: [.styles[].name]}'"
