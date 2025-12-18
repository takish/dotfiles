# Codex Instructions

This file provides guidance to Codex CLI when working with code.

## Overview

This is the Codex CLI global configuration directory (~/.codex) containing MCP server settings, notification configuration, and global instructions.

## Features

### Notifications

Codex is configured to send notifications on task completion (`agent-turn-complete` event):
- Desktop notification via terminal-notifier
- Slack webhook notification
- VOICEVOX voice notification

### MCP Servers

The following MCP servers are configured:

| Server | Description |
|--------|-------------|
| `chrome-devtools` | Browser automation and DevTools interaction |
| `figma-mcp` | Figma design integration (requires local server) |
| `firecrawl` | Web scraping and search |
| `note-post-mcp` | note.com article publishing |

## chezmoi Management

This directory is managed by chezmoi. Edit source files in `~/.local/share/chezmoi/dot_codex/`.

| Target | Source | Notes |
|--------|--------|-------|
| `config.toml` | `config.toml.tmpl` | Template file; edit source directly |
| `instructions.md` | `instructions.md` | This file |

### Editing Rules

1. **Template files (.tmpl)**: Cannot be updated via `chezmoi re-add`. Edit source directly.
2. **Regular files**: After editing target, run `chezmoi re-add` to sync.

## Environment Variables

Required environment variables for MCP servers:

| Variable | Description |
|----------|-------------|
| `FIRECRAWL_API_KEY` | Firecrawl API key |
| `NOTE_POST_MCP_STATE_PATH` | note.com authentication state file path |

## Notification Environment Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `VOICEVOX_MODE` | `se` | Force sound effect mode instead of voice |
| `VOICEVOX_MUTE` | `1` | Mute all voice notifications |
| `VOICEVOX_VOLUME` | `0.0-1.0` | Volume level (default: 0.7) |

## Related Configurations

- Claude Code: `~/.claude/`
- Gemini CLI: `~/.gemini/`

All three CLIs share the same MCP server configurations.
