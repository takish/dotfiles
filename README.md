# dotfiles

[chezmoi](https://www.chezmoi.io/) で管理する macOS 用 dotfiles。

## chezmoi とは？

chezmoi（シェモア）は、複数のマシン間で dotfiles を安全に管理するためのツールです。

**従来の方法の問題点:**
- シンボリックリンク方式だと、誤って設定ファイルを削除するリスクがある
- 手動コピーだと、マシン間で設定が同期できない

**chezmoi の解決策:**
- `~/.local/share/chezmoi/` にソースファイルを保存
- `chezmoi apply` でホームディレクトリにコピー
- Git でバージョン管理＆複数マシン間で同期

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

## 重要な概念: ソースとターゲット

chezmoi を理解する上で最も重要な概念です：

| 用語 | 場所 | 説明 |
|-----|------|------|
| **ソース** | `~/.local/share/chezmoi/` | chezmoi が管理するファイル（Git で追跡） |
| **ターゲット** | `~/` (ホームディレクトリ) | 実際に使われるファイル |

```
ソース (dot_zshrc)  ─── chezmoi apply ───▶  ターゲット (~/.zshrc)
                    ◀── chezmoi re-add ───
```

**重要: 変更は自動では反映されない**

- ソースを編集しても、`chezmoi apply` を実行するまでターゲットは更新されない
- ターゲットを直接編集しても、ソースには反映されない（`chezmoi re-add` が必要）

## ファイル名の読み方

chezmoi は特殊なプレフィックスでファイルの属性を制御します：

| ソースファイル名 | 実際のファイル名 | 説明 |
|-----------------|----------------|------|
| `dot_zshrc` | `.zshrc` | `dot_` → `.` に変換 |
| `private_dot_config/` | `.config/` | パーミッション 0600/0700 |
| `executable_script.sh` | `script.sh` | 実行権限付き |
| `encrypted_secret.txt.age` | `secret.txt` | 暗号化ファイル |

## ケーススタディ

### ケース1: 新しい設定ファイルを管理対象にしたい

**状況:** `~/.gitconfig` を chezmoi で管理したい

```bash
# ステップ1: ファイルを追加
chezmoi add ~/.gitconfig

# 確認: ソースディレクトリにコピーされた
ls ~/.local/share/chezmoi/
# → dot_gitconfig が作成されている

# ステップ2: Git にコミット
cd ~/.local/share/chezmoi
git add dot_gitconfig
git commit -m "Add gitconfig"
git push
```

**ポイント:**
- `chezmoi add` はターゲットをソースにコピーするだけ
- この時点ではまだ Git には追加されていない
- 手動で `git add` & `git commit` が必要

### ケース2: 設定ファイルを編集したい（正しい方法）

**状況:** `.zshrc` にエイリアスを追加したい

```bash
# 方法A: chezmoi edit を使う（推奨）
chezmoi edit ~/.zshrc
# → エディタでソースファイル (dot_zshrc) が開く
# → 保存しただけでは適用されない！

# 変更を適用（必須）
chezmoi apply

# 方法B: ソースファイルを直接編集
vim ~/.local/share/chezmoi/dot_zshrc
chezmoi apply  # 忘れずに実行
```

**よくある間違い:**
```bash
# ❌ ターゲットを直接編集してしまう
vim ~/.zshrc  # これはダメ！次の chezmoi apply で上書きされる
```

### ケース3: 間違えてターゲットファイルを直接編集してしまった

**状況:** `~/.zshrc`（ターゲット）を直接編集してしまった

```bash
# まず差分を確認
chezmoi diff
# → ソースとターゲットの差分が表示される

# 選択肢A: ターゲットの変更を採用したい場合
chezmoi re-add ~/.zshrc  # ターゲット → ソースに反映

# 選択肢B: ソースの状態に戻したい場合
chezmoi apply  # ソース → ターゲットに上書き
```

### ケース4: 新しいマシンに設定を適用したい

**状況:** 新しい Mac を買った。既存の dotfiles を適用したい

```bash
# ステップ1: chezmoi をインストール
brew install chezmoi

# ステップ2: リポジトリから初期化＆適用を一発で
chezmoi init --apply https://github.com/<username>/dotfiles.git

# これで全ての設定ファイルがホームディレクトリにコピーされる
```

**手動で配置が必要なファイル:**

chezmoi で管理していない環境固有のファイルを手動で作成する：

1. `~/.config/chezmoi/chezmoi.toml`

```toml
[scriptEnv]
  FIRECRAWL_API_KEY = "your-api-key"
  NOTE_POST_MCP_STATE_PATH = "/Users/your-username/.note-state.json"
```

2. `~/.zshrc.local`

```bash
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/xxx/xxx/xxx"
```

※ これらは機密情報を含むため Git 管理対象外

### ケース5: 変更を適用する前に確認したい

**状況:** `chezmoi apply` で何が変わるか事前に知りたい

```bash
# 差分を確認（実際には何も変更しない）
chezmoi diff

# 詳細なプレビュー
chezmoi apply --dry-run --verbose
```

### ケース6: API キーやパスワードを含むファイルを管理したい

**状況:** `.env` や認証情報を含むファイルを安全に管理したい

**方法1: age による暗号化（推奨）**

```bash
# 初回のみ: age の鍵を生成
age-keygen -o ~/.config/chezmoi/key.txt

# chezmoi 設定に鍵のパスを追加
chezmoi edit-config
```

```toml
# ~/.config/chezmoi/chezmoi.toml
encryption = "age"
[age]
  identity = "~/.config/chezmoi/key.txt"
  recipient = "age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

```bash
# 暗号化してファイルを追加
chezmoi add --encrypt ~/.config/secrets/api-keys.txt
# → encrypted_dot_config/secrets/api-keys.txt.age が作成される

# Git にコミットしても中身は暗号化されている
git add .
git commit -m "Add encrypted secrets"
```

**方法2: テンプレート + 環境変数**

```bash
# テンプレートとして追加
chezmoi add --template ~/.config/app/config.yaml
```

ソースファイル (`dot_config/app/config.yaml.tmpl`):
```yaml
api_key: {{ env "MY_API_KEY" }}
database_url: {{ env "DATABASE_URL" }}
```

```bash
# 環境変数を設定してから apply
export MY_API_KEY="sk-xxxxx"
chezmoi apply
```

**方法3: 1Password / Bitwarden 連携**

```bash
# 1Password CLI と連携
chezmoi add --template ~/.config/app/config.yaml
```

ソースファイル:
```yaml
api_key: {{ onepasswordRead "op://Vault/Item/password" }}
```

**やってはいけないこと:**
```bash
# ❌ 秘密情報を平文で Git にコミット
chezmoi add ~/.env  # 暗号化なしで追加すると危険！
```

### ケース7: 差分があるときの挙動を理解する

**状況:** ソースとターゲットで差分がある

```bash
# 差分を確認
chezmoi diff

# 出力例:
# diff --git a/.zshrc b/.zshrc
# --- a/.zshrc
# +++ b/.zshrc
# @@ -1,3 +1,4 @@
#  # zshrc
# +alias ll='ls -la'  # ← ソースにあってターゲットにない行
```

**chezmoi apply の動作:**
- ソースの内容でターゲットを**完全に上書き**する
- マージはしない（ソースが正）
- ターゲットにしかない変更は消える

**安全に差分を確認してから適用:**
```bash
# 1. 差分確認
chezmoi diff

# 2. ターゲットの変更を残したい場合
chezmoi re-add ~/.zshrc  # 先にソースを更新

# 3. ソースの変更を適用
chezmoi apply
```

### ケース8: ディレクトリごと管理したい

**状況:** `~/.config/nvim/` ディレクトリ全体を管理したい

```bash
# ディレクトリを再帰的に追加
chezmoi add ~/.config/nvim

# 確認
ls ~/.local/share/chezmoi/dot_config/
# → nvim/ ディレクトリが作成されている

# 特定のファイルだけ追加することも可能
chezmoi add ~/.config/nvim/init.lua
```

### ケース9: 管理対象から外したい

**状況:** `~/.gitconfig` の管理をやめたい

```bash
# ソースから削除（ターゲットはそのまま残る）
chezmoi forget ~/.gitconfig

# ソースディレクトリから dot_gitconfig が消える
# ~/.gitconfig は残るので、手動管理に戻る
```

### ケース10: リモートの変更を取り込みたい

**状況:** 別のマシンで変更をプッシュした。このマシンに反映したい

```bash
# リモートから取得して適用
chezmoi update

# これは以下と同じ:
# cd ~/.local/share/chezmoi && git pull && chezmoi apply
```

### ケース11: 動的に更新されるファイルの一部だけを管理したい

**状況:** Claude Code の `~/.claude.json` から MCP サーバー設定だけを同期したい

`~/.claude.json` には以下のような情報が混在している：
- MCP サーバー設定（`mcpServers`）→ 同期したい
- 起動回数、トークン使用量などの統計 → 同期不要（常に変化する）

**問題:** ファイル全体を管理すると、Claude Code 起動のたびに統計情報が更新され、毎回 `chezmoi apply` で競合が発生する。

**解決策:** `modify_` スクリプトで特定のキーだけをマージする

```bash
# ステップ1: MCP設定だけを抽出
cat ~/.claude.json | jq '.mcpServers' > ~/.local/share/chezmoi/dot_claude.json.mcpServers

# ステップ2: マージスクリプトを作成
cat > ~/.local/share/chezmoi/modify_dot_claude.json << 'EOF'
#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MCP_CONFIG="$SCRIPT_DIR/dot_claude.json.mcpServers"

current=$(cat)
if [[ -f "$MCP_CONFIG" ]]; then
    mcp_servers=$(cat "$MCP_CONFIG")
    echo "$current" | jq --argjson mcp "$mcp_servers" '.mcpServers = $mcp'
else
    echo "$current"
fi
EOF

# ステップ3: 実行権限を付与
chmod +x ~/.local/share/chezmoi/modify_dot_claude.json
```

**`modify_` スクリプトの動作:**
1. `chezmoi apply` 時、既存のターゲットファイル（`~/.claude.json`）を標準入力として受け取る
2. `mcpServers` キーだけを上書き
3. 統計情報など他のキーはそのまま保持

**MCP設定を更新したい場合:**
```bash
# 現在の設定を再抽出
cat ~/.claude.json | jq '.mcpServers' > ~/.local/share/chezmoi/dot_claude.json.mcpServers
```

**ポイント:**
- `modify_` プレフィックスは、ファイルを置換するのではなく変更するスクリプトを示す
- スクリプトは標準入力で現在のターゲット内容を受け取り、標準出力で結果を返す
- jq を使って JSON の特定キーだけを更新できる

## 変更の正しいワークフロー

### 日常的な編集フロー

```
1. chezmoi edit ~/.zshrc     # ソースを編集
2. chezmoi diff              # 差分確認（任意）
3. chezmoi apply             # ターゲットに反映
4. cd $(chezmoi source-path) # ソースディレクトリに移動
5. git add -A && git commit  # コミット
6. git push                  # プッシュ
```

### 別マシンでの同期フロー

```
1. chezmoi update            # リモートから取得＆適用
# または
1. chezmoi git pull          # 取得のみ
2. chezmoi diff              # 差分確認
3. chezmoi apply             # 適用
```

## よく使うコマンド一覧

| コマンド | 説明 | 使用頻度 |
|---------|------|---------|
| `chezmoi add <file>` | ファイルを管理対象に追加 | ★★★ |
| `chezmoi edit <file>` | ソースファイルを編集 | ★★★ |
| `chezmoi apply` | 変更を適用 | ★★★ |
| `chezmoi diff` | 差分を確認 | ★★☆ |
| `chezmoi re-add` | ターゲットの変更をソースに反映 | ★★☆ |
| `chezmoi update` | リモートから取得＆適用 | ★★☆ |
| `chezmoi forget <file>` | 管理対象から除外 | ★☆☆ |
| `chezmoi cd` | ソースディレクトリに移動 | ★☆☆ |
| `chezmoi add --encrypt` | 暗号化して追加 | ★☆☆ |
| `chezmoi managed` | 管理中のファイル一覧 | ★☆☆ |

## 含まれる設定

| ファイル | 説明 |
|---------|------|
| `.zshrc` | zsh 設定（エイリアス、補完、tmux連携） |
| `.tmux.conf` | tmux 設定（C-t プレフィックス、セッション別カラー） |
| `.vimrc` | vim 基本設定 |
| `~/.config/yazi/` | yazi ファイルマネージャー |
| `~/Library/Application Support/lazygit/` | lazygit 設定 |
| `~/Library/Preferences/com.googlecode.iterm2.plist` | iTerm2 設定 |
| `~/.claude.json` (部分) | Claude Code MCP サーバー設定のみ（`modify_` スクリプトで管理） |

## Claude Code MCP サーバー

chezmoi で管理している MCP サーバーの一覧です。

### 管理対象のサーバー

| サーバー名 | 用途 | タイプ | 必要な環境変数 |
|-----------|------|--------|--------------|
| `chrome-devtools` | Chrome DevTools 連携（ブラウザ操作・デバッグ） | stdio | なし |
| `figma-mcp` | Figma デザイン連携 | http | なし（ローカルサーバー必須） |
| `firecrawl` | Web スクレイピング・検索 | stdio | `FIRECRAWL_API_KEY` |

### セットアップ手順

#### 1. 環境変数の設定

`~/.zshrc.local`（マシン固有の設定ファイル）に追加：

```bash
# Firecrawl API Key (https://firecrawl.dev で取得)
export FIRECRAWL_API_KEY="your-api-key-here"
```

※ `.zshrc.local` は chezmoi の管理対象外で、各マシンの秘密情報を保持

#### 2. 各サーバーのインストール

**chrome-devtools**: インストール不要（npx で自動実行）
- Chrome を `--remote-debugging-port=9222` で起動する必要あり
- 参考: https://github.com/nicholasoxford/chrome-devtools-mcp

**figma-mcp**: Figma デスクトップアプリで MCP サーバーを起動
1. Figma デスクトップアプリを開く
2. Settings → Developer → Enable MCP Server
3. `http://127.0.0.1:3845/mcp` でローカルサーバーが起動
- 参考: https://help.figma.com/hc/en-us/articles/32132100833559

**firecrawl**: インストール不要（npx で自動実行）
- API キーが必要: https://firecrawl.dev でアカウント作成
- 参考: https://docs.firecrawl.dev/mcp

#### 3. chezmoi で MCP 設定を適用

```bash
chezmoi apply
```

### MCP 設定の更新方法

Claude Code で MCP サーバーを追加・変更した場合：

```bash
# 現在の設定を chezmoi に反映
cat ~/.claude.json | jq '.mcpServers' > ~/.local/share/chezmoi/dot_claude.json.mcpServers

# コミット
cd ~/.local/share/chezmoi
git add dot_claude.json.mcpServers
git commit -m "update MCP servers config"
```

## トラブルシューティング

### Q: `chezmoi apply` しても反映されない

```bash
# キャッシュをクリアして再適用
chezmoi apply --force
```

### Q: どのファイルが管理されているか確認したい

```bash
chezmoi managed
```

### Q: ソースディレクトリの場所は？

```bash
chezmoi source-path
# → /Users/<username>/.local/share/chezmoi
```

### Q: ターゲットを直接編集したが消したくない

```bash
# 編集したターゲットをソースに反映
chezmoi re-add ~/.zshrc

# 複数ファイルをまとめて反映
chezmoi re-add
```

### Q: 特定のファイルだけ適用したい

```bash
chezmoi apply ~/.zshrc
```

### Q: 暗号化ファイルの中身を確認したい

```bash
chezmoi cat ~/.config/secrets/api-keys.txt
```
