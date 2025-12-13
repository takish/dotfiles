#!/bin/bash

# Terminal notification script for Claude Code hooks
# Reads JSON from stdin and sends macOS notification

# Read JSON from stdin
INPUT=$(cat)

# Extract fields from JSON
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "Unknown"')
MESSAGE=$(echo "$INPUT" | jq -r '.message // ""')
NOTIFICATION_TYPE=$(echo "$INPUT" | jq -r '.notification_type // ""')

# Slack channel URL for opening
SLACK_URL="https://app.slack.com/client/T089WE571DZ/C08GCKP1VUP"

# Set notification content based on hook event
case "$HOOK_EVENT" in
    "Notification")
        TITLE="Claude Code"
        SUBTITLE="🤖 応答を求めています"
        if [ -n "$MESSAGE" ]; then
            BODY="$MESSAGE"
        else
            BODY="応答を求めています"
        fi
        ;;
    "Stop")
        TITLE="Claude Code"
        SUBTITLE="✅ 完了"
        BODY="タスクが完了しました"
        ;;
    *)
        TITLE="Claude Code"
        SUBTITLE="通知"
        if [ -n "$MESSAGE" ]; then
            BODY="$MESSAGE"
        else
            BODY="イベント: $HOOK_EVENT"
        fi
        ;;
esac

# Check if terminal-notifier is installed
if [ -x "/opt/homebrew/bin/terminal-notifier" ]; then
    /opt/homebrew/bin/terminal-notifier \
        -title "$TITLE" \
        -subtitle "$SUBTITLE" \
        -message "$BODY" \
        -sound Hero \
        -open "$SLACK_URL" \
        2>/dev/null
elif command -v terminal-notifier &> /dev/null; then
    terminal-notifier \
        -title "$TITLE" \
        -subtitle "$SUBTITLE" \
        -message "$BODY" \
        -sound Hero \
        -open "$SLACK_URL" \
        2>/dev/null
else
    # Fallback: just echo the message if terminal-notifier is not available
    echo "[$TITLE - $SUBTITLE] $BODY"
fi

# Return success even if notification fails
exit 0
