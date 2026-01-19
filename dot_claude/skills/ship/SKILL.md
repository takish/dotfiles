---
name: ship
description: 変更をコミットし、Pull Requestを作成。差分を分析し、コミット→プッシュ→PR作成を一括実行する。
model: sonnet
allowed-tools: Task
---

# Ship

変更をコミットし、リモートにプッシュして Pull Request を作成します。

## 実行方法

Task ツールを使用して以下の設定で実行してください：

```
subagent_type: Bash
model: sonnet
description: "Commit and create PR"
```

## プロンプト

以下の手順で変更をコミットし、PRを作成してください。

---

## Phase 0: ブランチ確認と作成

### 0-1. 現在のブランチを確認

```bash
git branch --show-current
```

### 0-2. feature branch の作成（必要な場合）

現在のブランチが `main`、`master`、または `develop` の場合:

1. `git diff` と `git diff --cached` で変更内容を確認
2. 変更内容から適切なブランチ名を生成:
   - プレフィックス: `feat/`, `fix/`, `refactor/`, `docs/` など
   - 変更の要約を kebab-case で（例: `feat/add-logout-button`）
3. feature branch を作成してチェックアウト:

```bash
git checkout -b <生成したブランチ名>
```

上記以外のブランチ（既に feature branch にいる場合）はこのステップをスキップ。

---

## Phase 1: Commit

### 1-1. 変更の確認とステージング

以下のコマンドを並列実行:
- `git status`
- `git diff`
- `git diff --cached`

変更がある場合、関連するファイルをステージング:
- 未追跡ファイルを `git add` で追加
- シークレットファイル（.env、credentials.json等）は追加しない
- 不要なファイル（ログ、一時ファイル等）は追加しない

### 1-2. 最近のコミットスタイルの確認

```bash
git log -10 --oneline --no-decorate
```

### 1-3. 変更されたファイルの内容確認

1. `git diff --cached --name-only` で変更ファイルリストを取得
2. 主要な変更ファイルをReadツールで読み取る
3. 変更の文脈、目的、影響範囲を理解

### 1-4. コミットメッセージの生成とコミット実行

**メッセージ要件:**
- ソースコードから推測した変更の目的を反映
- 変更の性質を正確に反映（新機能、機能強化、バグ修正等）
- 「why」に焦点を当て、簡潔（1〜2文）にまとめる
- リポジトリの既存スタイルに合わせる
- 適切なプレフィックス（add, update, fix, refactor等）

```bash
git commit -m "$(cat <<'EOF'
<生成したコミットメッセージ>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

### 1-5. コミット結果の確認

```bash
git status
git log -1 --stat
```

**コミットが失敗した場合は Phase 2 をスキップして終了。**

---

## Phase 2: Create PR

**絶対ルール: ベースブランチは必ず `develop` にすること。`main` への PR は禁止。**

### 2-1. 直前コミットの内容確認

```bash
git show HEAD
```

### 2-2. 手本PRの内容確認（引数がある場合のみ）

引数でPR番号が指定されている場合:

```bash
gh pr view {PR番号}
```

引数が空の場合はスキップ。

### 2-3. リモートへプッシュ

```bash
git push -u origin HEAD
```

### 2-4. 新規PRの作成

```bash
PR_BASE_BRANCH="develop"  # 必ず develop。main 禁止
PR_TITLE="<コミットメッセージを参考にPRタイトルを作成>"
PR_BODY="<変更内容を要約してPR本文を作成>"

gh pr create --draft --assignee @me --base "$PR_BASE_BRANCH" --title "$PR_TITLE" --body "$PR_BODY"
```

### 2-5. PRをブラウザで開く

```bash
gh pr view --web
```

---

## 完了報告

- コミットメッセージ
- PR URL
- 次のアクション（レビュー依頼など）
