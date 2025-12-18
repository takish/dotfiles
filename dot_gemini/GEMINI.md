# GEMINI.md

This file provides guidance to Gemini CLI when working with code.

## Overview

This is the Gemini CLI global configuration directory (~/.gemini) containing MCP server settings and global context.

## MCP Servers

The following MCP servers are configured:

| Server | Description |
|--------|-------------|
| `chrome-devtools` | Browser automation and DevTools interaction |
| `figma-mcp` | Figma design integration (requires local server) |
| `firecrawl` | Web scraping and search |
| `note-post-mcp` | note.com article publishing |

## chezmoi Management

This directory is managed by chezmoi. Edit source files in `~/.local/share/chezmoi/dot_gemini/`.

| Target | Source | Notes |
|--------|--------|-------|
| `settings.json` | `settings.json.tmpl` | Template file; edit source directly |
| `GEMINI.md` | `GEMINI.md` | This file |

### Editing Rules

1. **Template files (.tmpl)**: Cannot be updated via `chezmoi re-add`. Edit source directly.
2. **Regular files**: After editing target, run `chezmoi re-add` to sync.

## Environment Variables

Required environment variables for MCP servers:

| Variable | Description |
|----------|-------------|
| `FIRECRAWL_API_KEY` | Firecrawl API key |
| `NOTE_POST_MCP_STATE_PATH` | note.com authentication state file path |

## Related Configurations

- Claude Code: `~/.claude/`
- Codex CLI: `~/.codex/`

All three CLIs share the same MCP server configurations.
