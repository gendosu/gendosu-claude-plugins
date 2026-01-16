# Skill Creator プラグイン

効果的なスキルを作成するための包括的なガイダンスを提供するClaude Codeプラグインです。

## 概要

このプラグインは、[Anthropicの公式スキルリポジトリ](https://github.com/anthropics/skills/tree/main/skills/skill-creator)のskill-creatorスキルを使用してClaude Codeを拡張します。Claudeの機能を拡張するカスタムスキルを設計、実装、パッケージ化するための専門的なガイダンスを提供します。

## 機能

- **包括的なスキル作成ガイド**: 専門知識、ワークフロー、ツール統合を備えた効果的なスキルの作成方法を学習
- **デザインパターン**: プログレッシブディスクロージャ、出力パターン、ワークフロー構造のベストプラクティス
- **ユーティリティスクリプト**: スキルの初期化、検証、パッケージ化のためのツール
- **リファレンスドキュメント**: 出力パターンとワークフロー設計の詳細ガイド

## バンドルされているリソース

### スクリプト

- `init_skill.py` - テンプレートから新しいスキルを初期化
- `package_skill.py` - スキルを配布可能な.skillファイルにパッケージ化
- `quick_validate.py` - スキル構造とメタデータを検証

### リファレンス

- `output-patterns.md` - テンプレートベースおよび例ベースの出力パターン
- `workflows.md` - 順次および条件付きワークフロー構造

## 使用方法

skill-creatorスキルは、新しいスキルの作成や既存のスキルの更新を依頼すると自動的にトリガーされます。

トリガーの例:
- "...のための新しいスキルを作成したい"
- "...するスキルを作りたい"
- "既存のスキルを更新して..."

## インストール

1. このプラグインをClaude Codeのpluginsディレクトリにクローンまたはコピーします:
```bash
cp -r skill-creator ~/.claude/plugins/
```

2. Claude Codeを再起動してプラグインを読み込みます

## プロジェクト構造

```
skill-creator/
├── .claude-plugin/
│   └── plugin.json              # プラグイン設定
├── skills/
│   └── skill-creator/
│       ├── SKILL.md             # メインのスキルドキュメント
│       ├── LICENSE.txt          # Apache License 2.0
│       ├── references/          # リファレンスドキュメント
│       │   ├── output-patterns.md
│       │   └── workflows.md
│       └── scripts/             # ユーティリティスクリプト
│           ├── init_skill.py
│           ├── package_skill.py
│           └── quick_validate.py
├── LICENSE                      # プラグインライセンス
└── README.md                    # このファイル
```

## 前提条件

- [Claude Code](https://claude.com/claude-code)がインストールされていること
- Python 3.7以上（ユーティリティスクリプト用）
- PyYAMLライブラリ（`pip install pyyaml`でインストール）

## ライセンス

このプラグインは、Apache License 2.0でライセンスされているAnthropicのスキルリポジトリのskill-creatorスキルをパッケージ化しています。完全な条件についてはLICENSE.txtを参照してください。

## 謝辞

- [Anthropic Skills Repository](https://github.com/anthropics/skills)のオリジナルスキル
- Claude Codeプラグインエコシステム用に設計
