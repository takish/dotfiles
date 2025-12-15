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

## chezmoi 編集ルール（重要）

chezmoi で管理されているファイルを編集する際は、以下のルールを厳守すること。

### 基本原則

**ソースを先に編集 → apply で適用**が原則。ターゲット（`$HOME`）を直接編集しない。

```bash
# 1. ソースファイルを編集（このリポジトリ内のファイル）
#    例: dot_zshrc, dot_config/xxx など

# 2. 差分を確認
chezmoi diff

# 3. 適用
chezmoi apply
```

### ターゲットを編集してしまった場合

やむを得ずターゲットを直接編集した場合は、必ず `re-add` でソースに反映する。

```bash
# 管理済みファイルをソースに反映
chezmoi re-add ~/.zshrc

# 差分がないことを確認
chezmoi diff
```

### 編集前の確認事項

1. `chezmoi diff` で現在の差分を確認
2. 差分がある場合は先に解消してから作業開始
3. 編集後は必ず `chezmoi diff` で確認

### 特殊なファイル

| ファイル | 管理方法 | 注意点 |
|---------|---------|--------|
| `.claude.json` | `modify_dot_claude.json` で MCP 設定のみマージ | 直接 `chezmoi add` しない。MCP 設定は `dot_claude.json.mcpServers` を編集 |
| `.tmpl` ファイル | テンプレート | `re-add` では更新されない。手動でソースを編集 |
| `.chezmoiignore` 記載ファイル | 管理対象外 | `01-install-homebrew.sh`, `02-brew-bundle.sh`, `Brewfile` など |

### MCP サーバー設定の追加・変更

`.claude.json` の `mcpServers` を変更する場合：

```bash
# 1. MCP 設定ファイルを編集
vim ~/.local/share/chezmoi/dot_claude.json.mcpServers

# 2. apply で ~/.claude.json にマージ
chezmoi apply ~/.claude.json
```

### よくあるミス

- ターゲットを編集して `re-add` を忘れる → 次回 `apply` で上書きされる
- `.tmpl` ファイルを `re-add` しようとする → 反映されない
- `.claude.json` を直接 `add` する → API キー等の機密情報がコミットされる
