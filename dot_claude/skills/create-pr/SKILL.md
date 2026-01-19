---
name: create-pr
description: Pull Requestドラフトを作成。直前のコミットを分析し、ghコマンドでPRを作成してブラウザで開く。
model: sonnet
allowed-tools: Task
---

# Create Pull Request Draft

Pull Requestドラフトを作成します。

## 重要ルール

**ベースブランチは必ず `develop` にすること。`main` への PR は禁止。**

## 入力（任意）

参考にするPR番号

例: `123`

## 実行方法

Task ツールを使用して以下の設定で実行してください：

```
subagent_type: Bash
model: sonnet
description: "Create PR draft"
```

## プロンプト

**絶対ルール: ベースブランチは必ず `develop` にすること。`main` への PR は禁止。**

以下の手順で新しいPull request(PR)を作成してください。

### 1. 直前コミットの内容確認
```bash
git show HEAD
```

### 2. 手本PRの内容確認（引数がある場合のみ）
```bash
gh pr view {PR番号}
```

引数が空の場合はスキップ。

### 3. 新規PRの作成

直前コミット及び手本PRの内容を元にPRを作成:

```bash
# 変数の設定（変更禁止）
PR_BASE_BRANCH="develop"  # 必ず develop。main 禁止
PR_TITLE="<直前コミット/手本PRを参考にPRタイトルを作成>"
PR_BODY="<直前コミット/手本PRを参考にPR内容を作成>"

# PR作成
gh pr create --draft --assignee @me --base "$PR_BASE_BRANCH" --title "$PR_TITLE" --body "$PR_BODY"
```

### 4. 新規PRのブラウザ確認
```bash
gh pr view --web
```
