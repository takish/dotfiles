# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理する macOS 用 dotfiles。

## セットアップ

```bash
# chezmoi をインストール
brew install chezmoi

# このリポジトリから初期化
chezmoi init https://github.com/<username>/dotfiles.git

# 適用（プレビュー）
chezmoi diff

# 適用（実行）
chezmoi apply
```

## 含まれる設定

| ファイル | 説明 |
|---------|------|
| `.zshrc` | zsh 設定（エイリアス、補完、tmux連携） |
| `.tmux.conf` | tmux 設定（C-t プレフィックス、セッション別カラー） |
| `.vimrc` | vim 基本設定 |
| `~/.config/yazi/` | yazi ファイルマネージャー |
| `~/Library/Application Support/lazygit/` | lazygit 設定 |
| `~/Library/Preferences/com.googlecode.iterm2.plist` | iTerm2 設定 |

## よく使うコマンド

```bash
chezmoi add <file>    # ファイルを管理対象に追加
chezmoi edit <file>   # ソースファイルを編集
chezmoi diff          # 差分を確認
chezmoi apply         # 変更を適用
chezmoi re-add        # ターゲットの変更をソースに反映
```
