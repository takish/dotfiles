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
```

## Architecture

### Core Components

1. **Status Line System**: Custom Node.js script (statusline.js) that monitors token usage by reading JSONL transcript files from projects/, calculates percentage of compaction threshold (160K tokens), and displays color-coded warnings

2. **Notification Pipeline**: Dual notification system using:
   - macOS terminal-notifier for desktop alerts with Japanese messages
   - Slack webhook integration for remote notifications
   - Both triggered on "Notification" and "Stop" hooks

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