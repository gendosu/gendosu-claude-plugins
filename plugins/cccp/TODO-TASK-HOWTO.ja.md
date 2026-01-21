---
title: TODOタスクワークフロー - 包括的ハウツーガイド
description: todo-task-planningとtodo-task-runコマンドを使用した開発タスクの計画と実行の完全ガイド
category: development-workflow
tags:
  - todo-task-planning
  - todo-task-run
  - タスク管理
  - ワークフロー
  - TDD
  - マイクロコミット
created: 2025-01-21
updated: 2025-01-21
language: ja
---

# TODOタスクワークフロー - 包括的ハウツーガイド

## 概要

[Phase 3で完成予定]

## TODO.mdファイルの作成

[Phase 2で完成予定]

### 基本的なTODO.mdフォーマット

[Phase 2.1で完成予定]

### タスク粒度のガイドライン

[Phase 2.2で完成予定]

### TODOタスクにおけるYAGNI原則

[Phase 2.3で完成予定]

### 完全なTODO.md実例

[Phase 2.4で完成予定]

## todo-task-planningコマンドの使用方法

[Phase 3で完成予定]

### コマンド概要

[Phase 3.1で完成予定]

### オプション: --branch と --pr

[Phase 3.2で完成予定]

### Phase 0処理フロー

[Phase 3.3で完成予定]

#### ワークフロー図

```mermaid
graph TD
    A[Phase 0.1: TODOファイル読み込み] --> B[Phase 0.2: Exploreエージェント]
    B --> C[Phase 0.3: Planエージェント]
    C --> D[Phase 0.4: cccp:project-managerエージェント]
    D --> E[Phase 0.5: 結果検証]
    E --> F[Phase 1-5: 実行]
```

### 使用例とベストプラクティス

[Phase 3.4で完成予定]

## todo-task-runコマンドの使用方法

[Phase 4で完成予定]

### コマンド概要

[Phase 4.1で完成予定]

#### ワークフロー図

```mermaid
graph LR
    A[todo-task-planning] --> B[TODO.md作成]
    B --> C[todo-task-run]
    C --> D[タスク実行]
    D --> E[プルリクエスト]
```

### 処理フロー

[Phase 4.2で完成予定]

### オプション: --no-pr と --no-push

[Phase 4.3で完成予定]

### micro-commit連携

[Phase 4.4で完成予定]

## ベストプラクティスと実例

[Phase 5で完成予定]

### 完全なワークフロー例

[Phase 5.1で完成予定]

#### 全体ワークフロー図

```mermaid
graph TD
    A[要件を記述] --> B[todo-task-planningを実行]
    B --> C[TODO.md生成]
    C --> D[タスクをレビュー]
    D --> E[todo-task-runを実行]
    E --> F[タスクが実行される]
    F --> G[プルリクエスト作成]
    G --> H[コードレビュー]
```

### よくある使用パターン

[Phase 5.2で完成予定]

### トラブルシューティング

[Phase 5.3で完成予定]

## 付録

### 参考資料

- [todo-task-planningコマンドドキュメント](commands/todo-task-planning.md)
- [todo-task-runコマンドドキュメント](commands/todo-task-run.md)
- [CCCP README](README.jp.md)
