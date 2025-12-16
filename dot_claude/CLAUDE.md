# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the Claude Code configuration directory (~/.claude) containing user-specific settings, custom agents, output styles, and project metadata.

## Commands

### Status Line Testing
```bash
# Test the custom status line script
echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"/test"},"session_id":"test"}' | node ~/.claude/statusline.js
```

### Notification Testing
```bash
# Test terminal notifications
~/.claude/hooks/terminal-notify.sh "Test Title" "Test Subtitle" "テストメッセージ"

# Test Slack notifications
~/.claude/hooks/slack-notify.sh "🤖 Test notification"

# Test VOICEVOX voice notifications
~/.claude/hooks/voicevox-play.sh completion
~/.claude/hooks/voicevox-play.sh permission
```

### VOICEVOX Voice Generation
```bash
# Generate all voice files (requires VOICEVOX Engine running)
~/.claude/scripts/generate-voices.sh [SPEAKER_ID]

# List available speakers
curl -s http://localhost:50021/speakers | jq '.[] | {name, styles: [.styles[].name]}'
```

## Architecture

### Core Components

1. **Status Line System**: Custom Node.js script (statusline.js) that monitors token usage by reading JSONL transcript files from projects/, calculates percentage of compaction threshold (160K tokens), and displays color-coded warnings

2. **Notification Pipeline**: Multi-channel notification system using:
   - macOS terminal-notifier for desktop alerts with Japanese messages
   - Slack webhook integration for remote notifications
   - VOICEVOX voice synthesis for audio notifications (24 voice patterns)
   - Triggered on Notification, Stop, SessionStart, SessionEnd hooks

3. **Permission Framework**: Granular control system allowing specific git operations (with origin only), npm/pnpm package management, and file operations in src/docs/.tmp directories while blocking sudo, destructive rm -rf, and sensitive file access

4. **Custom Agents**: Specialized AI agents optimized for practical development tasks:
   - **backend-engineer**: API implementation, database operations, authentication, business logic, Next.js API routes
   - **frontend-engineer**: React/Next.js components, TypeScript, Tailwind CSS, UI/UX implementation
   - **code-debugger**: Bug fixing, error analysis, troubleshooting, runtime issues
   - **performance-optimizer**: Performance bottleneck identification, query optimization, rendering optimization, caching strategies
   - **test-engineer**: Test strategy, unit/integration/E2E test implementation, test coverage improvement, test debugging

## Hook System

### Notification Hooks
- **Location**: `~/.claude/hooks/terminal-notify.sh` and `~/.claude/hooks/slack-notify.sh`
- **Trigger**: When Claude Code needs user attention
- **Payload**: Japanese messages with Slack URL auto-open functionality

### Environment Variables
- `SLACK_WEBHOOK_URL`: Set in settings.json for Slack notifications
- Hooks receive standard shell environment plus Claude Code context

## File Patterns

### Allowed Operations
- `Read(**)`: Universal read access
- `Write(src/**)`: Source code modifications
- `Write(docs/**)`: Documentation updates
- `Bash(git push origin*:*)`: Safe git push with explicit origin
- `Bash(npm/pnpm install:*)`: Package installation

### Denied Operations
- `Bash(sudo:*)`: No elevated privileges
- `Read/Write(.env*)`: Environment files protection
- `Read(id_rsa, id_ed25519)`: SSH key protection
- `Bash(git push:*)`: Direct push without origin specification

## chezmoi 管理対象ファイル

以下のファイルは chezmoi で管理されています。編集時は `~/.local/share/chezmoi/dot_claude/` のソースを編集してください。

| ターゲット | ソース | 備考 |
|-----------|--------|------|
| `settings.json` | `settings.json.tmpl` | テンプレート。re-add不可、手動編集必須 |
| `hooks/terminal-notify.sh` | `hooks/executable_terminal-notify.sh` | デスクトップ通知 |
| `hooks/slack-notify.sh` | `hooks/executable_slack-notify.sh` | Slack通知 |
| `hooks/voicevox-play.sh` | `hooks/executable_voicevox-play.sh` | VOICEVOX音声再生 |
| `hooks/play-sound.sh` | `hooks/executable_play-sound.sh` | 効果音再生（旧） |
| `scripts/generate-voices.sh` | `scripts/executable_generate-voices.sh` | VOICEVOX音声生成 |
| `sounds/voicevox/*.wav` | `sounds/voicevox/*.wav` | VOICEVOX音声ファイル（24個） |
| `sounds/notification.wav` | `sounds/notification.wav` | 効果音（旧） |
| `sounds/stop.wav` | `sounds/stop.wav` | 効果音（旧） |
| `agents/*.md` | `agents/*.md` | カスタムエージェント定義 |
| `commands/*.md` | `commands/*.md` | スラッシュコマンド定義 |
| `CLAUDE.md` | `CLAUDE.md` | このファイル |
| `.gitignore` | `dot_gitignore` | |

### 編集ルール

1. **テンプレートファイル（.tmpl）**: `chezmoi re-add` では更新されない。ソースを直接編集
2. **通常ファイル**: ターゲット編集後に `chezmoi re-add` でソースに反映
3. **新規ファイル**: `chezmoi add` でソースに追加