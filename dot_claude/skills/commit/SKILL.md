---
name: commit
description: 変更をコミット。差分を分析し、リポジトリのスタイルに合わせたコミットメッセージを自動生成する。
model: sonnet
allowed-tools: Task
---

# Commit

変更をコミットします。

## 実行方法

Task ツールを使用して以下の設定で実行してください：

```
subagent_type: Bash
model: sonnet
description: "Commit changes"
```

## プロンプト

以下の手順で変更をコミットしてください。

---

### 1. 変更の確認とステージング

以下のコマンドを並列実行:
- `git status`
- `git diff`
- `git diff --cached`

変更がある場合、関連するファイルをステージング:
- 未追跡ファイルを `git add` で追加
- シークレットファイル（.env、credentials.json等）は追加しない
- 不要なファイル（ログ、一時ファイル等）は追加しない

### 2. 最近のコミットスタイルの確認

```bash
git log -10 --oneline --no-decorate
```

### 3. 変更されたファイルの内容確認

1. `git diff --cached --name-only` で変更ファイルリストを取得
2. 主要な変更ファイルをReadツールで読み取る
3. 変更の文脈、目的、影響範囲を理解

### 4. コミットメッセージの生成とコミット実行

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

### 5. コミット結果の確認

```bash
git status
git log -1 --stat
```

---

## 完了報告

- コミットメッセージ
- 変更されたファイル数
- 次のアクション（push、PR作成など）
