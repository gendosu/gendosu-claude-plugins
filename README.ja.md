# Gendosu Claude Plugins

Claude Codeの開発効率を向上させるプラグインマーケットプレイスです。

## 📦 概要

Gendosu Claude Pluginsは、Claude Code向けの生産性向上プラグインを提供するモノレポです。テスト駆動開発、Git操作、プロジェクト管理など、日々の開発作業を効率化するスキルやコマンドを提供します。

## 🚀 インストール方法

### マーケットプレイス経由でのインストール

1. マーケットプレイスを追加:
```bash
/plugin marketplace add gendosu/gendosu-claude-plugins
```

2. プラグインをインストール:
```bash
/plugin install cccp@gendosu-claude-plugins
```

## 📚 プラグイン一覧

<table>
  <thead>
    <tr>
      <th>プラグイン</th>
      <th>タイプ</th>
      <th>名前</th>
      <th>説明</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="7"><strong>CCCP</strong><br>(Claude Code Command Pack)<br><a href="./plugins/cccp/README.md">📖 詳細</a></td>
      <td>Agent</td>
      <td>git-operations-specialist</td>
      <td>Git操作を専門的に処理（コミット、ブランチ、マージ、競合解決）</td>
    </tr>
    <tr>
      <td>Agent</td>
      <td>project-manager</td>
      <td>プロジェクト管理支援（計画、進捗追跡、タスク調整、リスク評価など）</td>
    </tr>
    <tr>
      <td>Command</td>
      <td>/cccp:commit</td>
      <td>git stageされている内容でコミット作成</td>
    </tr>
    <tr>
      <td>Command</td>
      <td>/cccp:micro-commit</td>
      <td>git差分をコンテキストごとに分けてマイクロコミット</td>
    </tr>
    <tr>
      <td>Command</td>
      <td>/cccp:todo-task-planning</td>
      <td>指定されたファイルを基にタスクプランニングを実行し、質問管理も行う</td>
    </tr>
    <tr>
      <td>Command</td>
      <td>/cccp:todo-task-run</td>
      <td>TODOファイルからタスクを実行し、プルリクエスト作成</td>
    </tr>
    <tr>
      <td>Skill</td>
      <td>key-guidelines</td>
      <td>開発の基本原則と標準（DRY、KISS、YAGNI、SOLID、TDD、マイクロコミット）</td>
    </tr>
    <tr>
      <td rowspan="1"><strong>awesome-statusline</strong><br><a href="./plugins/awesome-statusline/README.md">📖 詳細</a></td>
      <td>Skill</td>
      <td>setup-statusline</td>
      <td>Claude Code ステータスライン自動セットアップ</td>
    </tr>
    <tr>
      <td rowspan="1"><strong>codex</strong><br><a href="./plugins/codex/README.md">📖 詳細</a></td>
      <td>Skill</td>
      <td>codex</td>
      <td>Codex MCP連携 - コードレビュー、技術調査、ドキュメント生成、カスタムクエリ</td>
    </tr>
    <tr>
      <td rowspan="1"><strong>skill-creator</strong><br><a href="./plugins/skill-creator/README.md">📖 詳細</a></td>
      <td>Skill</td>
      <td>skill-creator</td>
      <td>効果的なClaude Codeスキル作成のための包括的ガイド（設計パターン、初期化、検証、パッケージ化）</td>
    </tr>
  </tbody>
</table>

## 📝 ライセンス

MIT License

## 👥 コントリビューション

コントリビューションを歓迎します！お気軽にPull Requestを提出してください。

## 👤 作者

GENDOSU

## 🔗 リンク

- [マーケットプレイスリポジトリ](https://github.com/gendosu/gendosu-claude-plugins)
