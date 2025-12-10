# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a chezmoi-managed dotfiles repository for macOS. Chezmoi is a dotfile manager that uses source state in `~/.local/share/chezmoi` to manage target state in `$HOME`.

## Commands

```bash
# Apply changes to home directory
chezmoi apply

# Preview changes before applying
chezmoi diff

# Add a new dotfile to be managed
chezmoi add ~/.config/some/file

# Edit a managed file (opens source file)
chezmoi edit ~/.zshrc

# Re-add a file after editing target directly
chezmoi re-add
```

## File Naming Conventions

Chezmoi uses special prefixes to control file attributes:

| Prefix | Effect |
|--------|--------|
| `dot_` | Becomes `.` in target (e.g., `dot_zshrc` → `.zshrc`) |
| `private_` | Sets restrictive permissions (0600/0700) |
| `executable_` | Makes file executable |

Example: `private_dot_config/` → `~/.config/` with restricted permissions

## Managed Configurations

- **Shell**: zsh with custom prompt, aliases, and tmux integration
- **Terminal multiplexer**: tmux with C-t prefix, vim-style splits, session-specific color themes
- **Editor**: vim with minimal but functional config
- **Tools**: lazygit (with delta pager), yazi file manager
- **iTerm2**: Application support files

## Key Aliases (from dot_zshrc)

- `tc/tw/tv/ti` - Start tmux with isolated sockets per IDE (cursor/windsurf/vscode/iterm)
- `tnew <name>` - Create new named tmux session with isolated socket
- `ts-up/ts-down/ts-status` - Tailscale management (DNS disabled by default)
