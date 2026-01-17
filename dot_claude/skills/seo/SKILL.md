---
name: seo
description: SEOへの影響を分析。テクニカルSEO、コンテンツSEO、モバイル対応の観点から改善点を提示する。
model: sonnet
---

# SEO Check

現在の実装・コンテンツがSEOに与える影響を分析します。

## 分析観点

詳細なチェックリストは [references/checklist.md](references/checklist.md) を参照。

### テクニカルSEO
- 構造化データ（JSON-LD）の実装
- canonical URL、hreflang設定
- サイトマップ、robots.txt
- クロール効率、リダイレクト

### コンテンツSEO
- メタタグ（title, description）
- 見出し階層（H1-H6）
- 画像alt属性
- 内部リンク構造
- キーワード配置

### モバイル対応
- レスポンシブデザイン
- タップターゲットサイズ
- ビューポート設定

## 出力形式

改善提案は、実装コストと期待される効果を明記：

```markdown
### 高優先度
[SEOに大きく影響・実装コスト低]

### 中優先度
[SEOに影響あり・計画的に対応]

### 低優先度
[余裕があれば対応]
```
