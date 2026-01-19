# Codex プラグイン

Claude Code用の汎用Codex MCP統合プラグインです。コードレビュー、技術調査、ドキュメント生成、カスタムクエリの包括的な機能を提供します。

[English version](./README.md)

## 機能

- 🔍 **コードレビュー**: 自動コンテキスト収集によるセキュリティ、設計、品質の包括的レビュー
- 🔬 **技術調査**: プロジェクトコンテキストを含むライブラリ、パターン、ベストプラクティスの詳細調査
- 📝 **ドキュメント生成**: 技術ドキュメント、API仕様、コメントの自動生成
- 🎯 **カスタムクエリ**: あらゆる技術的な質問に対応する柔軟なカスタムプロンプト

## 前提条件

- **Claude Code** がインストールされていること
- **Codex MCPサーバー** が設定されていること（必須）

このプラグインはCodex MCPサーバーのセットアップと設定が必要です。MCPが利用できない場合、スキルはエラーメッセージを表示します。

## インストール

### 1. マーケットプレイスを追加

```bash
/plugin marketplace add gendosu/gendosu-claude-plugins
```

### 2. プラグインをインストール

```bash
/plugin install codex@gendosu-claude-plugins
```

### 3. インストールの確認

```bash
/skills list
```

スキルリストに `codex` が表示されるはずです。

## 使い方

### コードレビュー

レビューを依頼するだけで、スキルが自動的に:
- 現在の変更のgit diffを取得
- 変更されたファイルを読み込み
- 技術スタックを検出
- プロジェクト設計原則を読み込み（CLAUDE.md）
- 最適化されたレビュープロンプトを構築
- Codexレビューを実行

```
codexでレビューして
codex review
```

**詳細な使い方:**
```
このファイルをcodexでレビュー: src/api/auth.ts
Review this file with Codex: src/api/auth.ts
```

### 技術調査

技術調査を依頼すると、スキルは:
- プロジェクトの技術スタックを検出
- 既存実装を読み込み
- プロジェクト制約を収集
- 調査プロンプトを構築
- Codex調査を実行

```
React 19の新機能を調査して
Research React 19 new features

TypeScriptの依存性注入のベストプラクティスを調査
Research dependency injection best practices in TypeScript
```

### ドキュメント生成

ドキュメント生成を依頼すると、スキルは:
- 対象コードファイルを読み込み
- APIシグネチャを抽出
- 既存ドキュメントスタイルを確認
- ドキュメント生成プロンプトを構築
- Markdownドキュメントを生成

```
このAPIのドキュメントを生成して
Generate documentation for this API

src/utils/auth.tsのドキュメント作成
Create documentation for src/utils/auth.ts
```

### カスタムクエリ

Codexに直接質問:

```
Codexでこのエラーの原因を教えて: TypeError: Cannot read property 'map' of undefined
Using Codex, explain this error: TypeError: Cannot read property 'map' of undefined

/codex TypeScriptの型システムについて詳しく説明して
/codex Explain TypeScript's type system in detail
```

## 仕組み

Codexスキルは、Codex MCPを直接使用するよりも大きな付加価値を提供します:

### 自動コンテキスト収集

- **技術スタック検出**: package.json、requirements.txt等を読み込み
- **設計原則**: CLAUDE.mdやプロジェクトガイドラインを読み込み
- **既存パターン**: Glob/Grepを使用して類似実装を発見
- **スマートファイル読み込み**: バイナリファイルを回避、.gitignoreを尊重

### 最適化されたプロンプト構築

各ユースケースごとに、以下を含む詳細なプロンプトを構築:
- 明確な目的
- プロジェクトコンテキスト
- 構造化された形式の期待値
- 具体的な制約（言語、深さ、形式）

### 向上したユーザー体験

- **自然言語**: 「codexでレビューして」のようなシンプルなリクエスト
- **自動検出**: ユースケースを自動的に判定
- **整形された結果**: 美しいMarkdown出力
- **フォローアップアクション**: 次のステップを提案（docsに保存、さらなる分析）

## 設定

Codex MCPサーバーのセットアップ以外に追加設定は不要です。

### Codex MCPサーバーのセットアップ

Codex MCPサーバーのドキュメントを参照して、インストールと設定を行ってください。

## 使用例

### 例1: クイックコードレビュー

```
ユーザー: "codexでレビューして"

→ スキル実行:
1. git diffを取得（3ファイル変更）
2. 変更ファイルを読み込み
3. 技術スタックを検出 → TypeScript、React
4. CLAUDE.mdを読み込み → 設計原則を抽出
5. 全コンテキストを含むレビュープロンプトを構築
6. mcp__codex__codexを呼び出し
7. 整形されたレビュー結果を表示
```

### 例2: プロジェクトコンテキスト付き調査

```
ユーザー: "GraphQLのベストプラクティスを調査"

→ スキル実行:
1. package.jsonを確認 → GraphQLバージョンを検出
2. 既存GraphQLコードを検索 → パターンを発見
3. CLAUDE.mdを読み込み → プロジェクト制約を取得
4. コンテキスト付き調査プロンプトを構築
5. mcp__codex__codexを呼び出し
6. 実装例を含む調査結果を表示
```

### 例3: ドキュメント生成

```
ユーザー: "src/api/users.tsのドキュメント生成"

→ スキル実行:
1. src/api/users.tsを読み込み
2. 関数シグネチャとエクスポートを抽出
3. 既存ドキュメントスタイルを確認
4. ドキュメント生成プロンプトを構築
5. mcp__codex__codexを呼び出し
6. Markdownドキュメントを表示
7. docs/api/users.mdへの保存を提案
```

## トラブルシューティング

### エラー: Codex MCPサーバーに接続できません

**原因**: Codex MCPサーバーが設定されていないか実行されていません。

**解決策**:
1. Codex MCPサーバーをインストール
2. Claude Codeの設定（`~/.claude/settings.json`）に追加
3. Claude Codeを再起動

### スキルがトリガーされない

**原因**: トリガーキーワードがマッチしていない可能性があります。

**解決策**:
- 明示的なキーワードを使用: "codexでレビュー"、"codex review"
- 明示的な呼び出しを試す: `/codex`
- スキルがインストールされているか確認: `/skills list`

### レスポンス品質が低い

**原因**: コンテキスト不足または不明確なリクエスト。

**解決策**:
- より具体的なリクエストを提供
- 関連ファイルやトピックを明示的に言及
- 制約を追加（例: 「セキュリティに焦点を当てて」）

## ベストプラクティス

### より良い結果を得るために

1. **具体的に**: "レビューして" より "src/api/auth.tsのセキュリティをレビュー"
2. **コンテキストを提供**: 関連する制約や焦点領域を言及
3. **出力をレビュー**: Codexの提案は常にプロジェクトコンテキストでレビュー

### コードレビュー

- より明確なdiffのため、変更をコミットまたはステージ
- 一度に1つの論理的変更をレビュー
- 必要に応じて特定領域に焦点（セキュリティ、パフォーマンス等）

### 技術調査

- 関連する場合は現在の技術スタックバージョンを言及
- 実装制約を指定
- プロジェクトの言語でコード例を依頼

### ドキュメント生成

- ドキュメント生成前にコードを確定
- 対象読者を指定（APIユーザー、コントリビューター等）
- 生成されたドキュメントの正確性と完全性を確認

## ライセンス

MITライセンス - 詳細は[LICENSE](./LICENSE)ファイルを参照してください。

## コントリビュート

コントリビューション歓迎！[ccmpリポジトリ](https://github.com/gendosu/gendosu-claude-plugins)でIssueまたはPRを開いてください。

## サポート

問題や質問がある場合:
- GitHub Issues: https://github.com/gendosu/gendosu-claude-plugins/issues
- ドキュメント: https://github.com/gendosu/gendosu-claude-plugins/tree/main/plugins/codex

## 関連スキル

- **git-operations-specialist** (cccpプラグイン): Git操作と履歴分析
- **review-support-codex** (コマンド): 並行実行によるPR専用レビュー
- **todo-task-run-codex** (コマンド): Codex統合によるタスク実行
