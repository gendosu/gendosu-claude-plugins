# TODO Task Plugin 開発ガイド

**作成日**: 2026-01-24
**対象読者**: Claude Code CLI + cccp plugin ユーザー

---

## 第1章: 概要と導入

### 1.1 TODO Task Pluginとは

TODO Task Pluginは、Claude Code CLIとcccp@gendosu-claude-pluginsを組み合わせたタスク駆動開発の自動化ツールです。開発者が要件ファイルに記述した内容を読み取り、タスク計画の生成（`todo-task-planning`）から実装の実行とプルリクエスト作成（`todo-task-run`）まで、一連の開発ワークフローを自動化します。

このプラグインは、手動でタスクリストを作成・管理し、各タスクごとにGitコマンドを実行する従来のフローを置き換えます。開発者は要件を記述するだけで、タスクの分解、実行、コミット、PR作成までが自動的に処理されます。

### 1.2 解決する課題

従来の開発フローでは、以下の課題が発生していました。

**手動タスク管理の負荷**:
- タスクの粒度を決定し、チェックリストを手動で作成
- タスクごとに実行状態を記録し、更新する作業が必要
- タスクの順序や依存関係を管理する負担

**Git操作の煩雑さ**:
- 各タスク完了後に手動でgit add、git commit、git pushを実行
- コミットメッセージの作成に時間を要する
- ブランチ作成やPR作成の手順を毎回実施

**ワークフロー全体の非効率性**:
- タスク実行とGit操作の切り替えによる集中力の分散
- 実装に集中すべき時間が管理作業に浪費される

TODO Task Pluginはこれらの課題を解決します。要件ファイルを入力として与えるだけで、タスク計画の自動生成、実行、コミット、PR作成までが一貫して処理されます。

### 1.3 得られる効果

TODO Task Pluginを使用することで、以下の効果が得られます。

**開発効率の向上**:
- タスク計画生成からPR作成までの自動化により、管理作業時間を削減
- 要件記述に集中し、実装とGit操作はプラグインに任せる

**一貫性のあるワークフロー**:
- ブランチ命名、コミットメッセージ生成、タスク実行順序が自動的に標準化
- チーム全体で統一されたタスク管理手法を採用可能

**タスクの可視化**:
- チェックリスト形式のTODOファイルにより、進捗状況が明確
- タスク完了状態がリアルタイムで更新される

### 1.4 基本ワークフロー

TODO Task Pluginの基本的なワークフローは以下の通りです。

```dot
digraph workflow {
  rankdir=LR;
  node [shape=box, style=rounded];

  requirements [label="要件ファイル作成\n(TODO.md等)"];
  planning [label="todo-task-planning\n実行"];
  todo_file [label="TODOファイル生成\n(チェックリスト形式)"];
  review [label="TODOファイル\n確認・編集"];
  run [label="todo-task-run\n実行"];
  pr [label="実装完了\nPR作成"];

  requirements -> planning [label="入力"];
  planning -> todo_file [label="生成"];
  todo_file -> review [label="確認"];
  review -> run [label="実行"];
  run -> pr [label="完了"];
}
```

**ワークフロー説明**:

1. **要件ファイル作成**: 開発者が実装すべき機能やタスクの内容を要件ファイル（例: `TODO.md`）に記述
2. **todo-task-planning実行**: planningコマンドで要件ファイルを読み取り、タスク計画を自動生成
3. **TODOファイル生成**: チェックリスト形式のTODOファイルが生成される（例: `TODO.md`として保存）
4. **TODOファイル確認・編集**: 生成されたタスクリストを確認し、必要に応じて微調整
5. **todo-task-run実行**: runコマンドでTODOファイルを読み取り、タスクを順次実行
6. **実装完了・PR作成**: すべてのタスクが完了すると、自動的にプルリクエストが作成される

このワークフローにより、開発者は要件の記述とタスク確認のみに集中し、実装からPR作成までの手順はプラグインが自動処理します。

---

## 第2章: 基本概念

TODO Task Pluginで生成されるタスクファイルは、特定の構造とマーカーを使用して、タスクの実行可能性と進捗状況を明確に管理します。この章では、タスク管理の基本要素であるFeasibility Markers、タスク構造、チェックリスト形式の要件について説明します。

### 2.1 Feasibility Markers（実行可能性マーカー）

Feasibility Markersは、各タスクの実行可能性を示すステータス表示です。タスクの現在の状態を明確にし、次に取るべきアクションを判断するために使用されます。

#### ✅ Ready（即実行可能）

タスクの仕様が明確で、技術的な課題が解決済み、依存関係がすべて満たされている状態を示します。このマーカーが付与されたタスクは、即座に実行を開始できます。

**使用例**:
```markdown
✅ Ready
- [x] ユーザー認証APIのエンドポイント実装
  - `/api/auth/login` (POST) を追加
  - JWT トークン生成機能を実装
  - 📁 Files: `src/api/auth.ts`, `src/utils/jwt.ts`
```

**適用条件**:
- 仕様が具体的に定義されている
- 必要な技術情報がすべて揃っている
- 依存する他のタスクが完了している
- 実装方法が明確である

#### ⏳ Pending（依存タスク待ち）

他のタスクの完了を待っている状態を示します。依存関係が解消されるまで実行できません。マーカーには具体的な待機理由と解除条件を記載します。

**使用例**:
```markdown
⏳ Pending
- [ ] ユーザープロフィール画面の実装
  - 待機理由: ユーザー認証APIの完成を待つ
  - 解除条件: `/api/auth/login` エンドポイントの動作確認完了
  - 📁 Files: `src/pages/Profile.tsx`
```

**適用条件**:
- 他のタスクに依存している
- 依存タスクが完了していない
- 待機理由が明確である
- 解除条件が具体的に定義されている

#### 🔍 Research（調査必要）

タスクを実行する前に調査や検証が必要な状態を示します。具体的な調査項目と調査方法を記載します。

**使用例**:
```markdown
🔍 Research
- [ ] データベーススキーマの最適化
  - 調査項目: インデックス設定の最適化方法
  - 調査方法: 既存クエリのパフォーマンス測定、スロークエリログの分析
  - 📊 技術的根拠: 現在のクエリ応答時間が200ms超、目標は50ms以下
```

**適用条件**:
- 技術的な選択肢が複数ある
- パフォーマンスやセキュリティの検証が必要
- 既存実装の調査が必要
- 調査項目と方法が明確である

#### 🚧 Blocked（仕様/技術詳細不明）

仕様が不明確、または技術的な詳細が決定していない状態を示します。ブロッカーの内容と解決手順を具体的に記載します。

**使用例**:
```markdown
🚧 Blocked
- [ ] 決済システムの統合
  - ブロッカー: 使用する決済プロバイダーが未決定
  - 解決手順:
    1. ビジネス要件の確認（対応通貨、手数料）
    2. 候補プロバイダーの比較（Stripe, PayPal）
    3. セキュリティ要件の検証
  - 📊 技術的根拠: PCI DSS準拠が必須
```

**適用条件**:
- 仕様が明確でない
- 技術的な実現可能性が不明
- ビジネス要件が確定していない
- ブロッカー解決のための手順が定義されている

### 2.2 タスク構造

TODO Task Pluginで生成されるタスクファイルは、階層的なチェックリスト形式で構成されます。各タスクには、実装内容、ファイル参照、技術的根拠を含めることができます。

#### 基本構造

タスクは以下の要素で構成されます。

**構造例**:
```markdown
✅ Ready
- [ ] メインタスク
  - サブタスク1の説明
  - サブタスク2の説明
  - 📁 Files: `src/components/Component.tsx`
  - 📊 技術的根拠: パフォーマンス要件の記載

  - [ ] ネストされたサブタスク1
    - 詳細な実装内容
    - 📁 Files: `src/utils/helper.ts`

  - [ ] ネストされたサブタスク2
    - 詳細な実装内容
    - 📁 Files: `src/api/endpoints.ts`
```

#### ネストされたサブタスク

サブタスクは2スペースのインデントで階層化します。親タスクの完了には、すべてのサブタスクの完了が必要です。

**ネスト例**:
```markdown
- [ ] ユーザー認証機能の実装
  - 📁 Files: `src/auth/`

  - [ ] ログイン機能
    - `/api/auth/login` エンドポイントを実装
    - JWT トークン生成
    - 📁 Files: `src/auth/login.ts`

  - [ ] ログアウト機能
    - `/api/auth/logout` エンドポイントを実装
    - トークン無効化処理
    - 📁 Files: `src/auth/logout.ts`
```

#### ファイル参照（📁アイコン）

実装対象のファイルパスを明示します。複数ファイルの場合はカンマ区切りで記載します。

**記載例**:
```markdown
- 📁 Files: `src/components/Header.tsx`, `src/styles/header.css`
```

#### 技術的根拠（📊アイコン）

タスクの技術的な背景や要件を記載します。パフォーマンス目標、セキュリティ要件、技術選定理由などを含めます。

**記載例**:
```markdown
- 📊 技術的根拠: API応答時間を100ms以下に保つため、キャッシュ機構を導入
```

### 2.3 チェックリスト形式の要件

TODO Task Pluginは、Markdownのチェックボックス形式でタスクの進捗を管理します。タスクの実行状態は、チェックボックスの状態で明確に表現されます。

#### Markdownチェックボックスの必須要件

すべてのタスクは、以下の形式で記載する必要があります。

**未完了タスク**:
```markdown
- [ ] タスクの説明
```

**完了タスク**:
```markdown
- [x] タスクの説明
```

この形式を維持しないと、`todo-task-run`コマンドがタスクを正しく認識できません。

#### 完了時の更新手順

タスクが完了したら、チェックボックスを手動で更新します。

**更新手順**:
1. 該当タスクのチェックボックスを見つける
2. `- [ ]` を `- [x]` に変更
3. ファイルを保存

**更新例**:
```markdown
# 実行前
- [ ] ユーザー登録APIの実装

# 実行後
- [x] ユーザー登録APIの実装
```

#### ファイル情報の記録方法

タスク完了時には、作成または変更したファイルの情報を記録します。

**記録形式**:
```markdown
- [x] ユーザー登録APIの実装
  - Files: `src/api/register.ts` (作成), `src/api/index.ts` (変更)
  - Notes: JWT トークン生成機能を追加
```

#### 実装メモの書き方

タスク実行中に発見した重要な情報や、次のタスクへの引き継ぎ事項を記録します。

**記録例**:
```markdown
- [x] データベーススキーマの設計
  - Files: `db/schema.sql`
  - Notes: users テーブルに email カラムを追加（unique制約付き）
  - Notes: 次タスクでマイグレーションスクリプト作成が必要
```

#### 実例: 完全なタスクフロー

以下は、タスクの作成から完了までの実例です。

**初期状態（planning生成直後）**:
```markdown
✅ Ready
- [ ] ログイン画面のUI実装
  - ユーザー名とパスワードの入力フィールド
  - ログインボタン
  - 📁 Files: `src/pages/Login.tsx`
  - 📊 技術的根拠: React + TypeScript、Material-UI使用
```

**実行中**:
```markdown
✅ Ready
- [ ] ログイン画面のUI実装（実行中）
  - ユーザー名とパスワードの入力フィールド
  - ログインボタン
  - 📁 Files: `src/pages/Login.tsx`
  - 📊 技術的根拠: React + TypeScript、Material-UI使用
```

**完了後**:
```markdown
✅ Ready
- [x] ログイン画面のUI実装
  - ユーザー名とパスワードの入力フィールド
  - ログインボタン
  - 📁 Files: `src/pages/Login.tsx` (作成), `src/App.tsx` (変更)
  - 📊 技術的根拠: React + TypeScript、Material-UI使用
  - Notes: バリデーション機能を追加、エラーメッセージ表示を実装
```

この構造により、タスクの実行状態、関連ファイル、実装内容が明確に記録され、プロジェクトの進捗を正確に追跡できます。

---

## 第3章: todo-task-planning 詳細ガイド

`todo-task-planning`コマンドは、要件ファイルを読み取り、実行可能なタスクリストを自動生成するコマンドです。開発者が要件を記述したファイルを入力として与えると、チェックリスト形式のTODOファイルが生成されます。このコマンドは、タスクの分解、実行順序の決定、Feasibility Markersの付与を自動的に実行し、開発計画の立案作業を効率化します。

### 3.1 コマンド構文

`todo-task-planning`コマンドの基本構文は以下の通りです。

```bash
/cccp:todo-task-planning <file_path> [--pr] [--branch <branch_name>]
```

**構文要素**:
- `<file_path>`: 要件を記述したファイルのパス（必須）
- `[--pr]`: プルリクエスト作成タスクを追加するフラグ（オプション）
- `[--branch <branch_name>]`: 作業ブランチ名を指定（オプション）

### 3.2 パラメータ詳細

`todo-task-planning`コマンドのパラメータは、以下の表に示す通りです。

| パラメータ | 種類 | 型 | 説明 | デフォルト値 |
|-----------|------|-----|------|-------------|
| `file_path` | 必須 | String | タスク計画の基となる要件ファイルのパス。相対パスまたは絶対パスで指定 | - |
| `--pr` | オプション | Flag | 最終タスクとしてプルリクエスト作成タスクを追加する。指定すると、すべてのタスク完了後にPR作成タスクがTODOリストに含まれる | false |
| `--branch` | オプション | String | 作業用のブランチ名を指定。値を指定しない場合（`--branch`のみ）、要件ファイル名から自動生成される | 自動生成 |

**パラメータの詳細説明**:

- **file_path**: 要件ファイルのパスを指定します。Markdown形式のファイルが推奨されますが、テキストファイルでも動作します。ファイルには、実装すべき機能、修正すべきバグ、または開発タスクの説明を記述します。

- **--pr**: このフラグを指定すると、生成されるTODOファイルの最後に「プルリクエストを作成」タスクが追加されます。チーム開発でレビュープロセスが必要な場合に使用します。

- **--branch**: 作業ブランチ名を指定します。値を省略して`--branch`のみを指定した場合、要件ファイル名から自動的にブランチ名が生成されます（例: `requirements.md` → `feature/requirements`）。明示的にブランチ名を指定する場合は、`--branch feature/user-auth`のように記述します。

### 3.3 実行例

`todo-task-planning`コマンドの実行例を4つのパターンで示します。

#### 例1: 基本実行（パラメータなし）

要件ファイルのみを指定し、TODOファイルを生成する基本的な使用例です。

**実行コマンド**:
```bash
/cccp:todo-task-planning requirements.md
```

**実行結果**:
- `requirements.md`を読み取り、タスクリストを生成
- TODOファイルが`TODO.md`として保存される
- ブランチ作成タスクとPR作成タスクは含まれない

**生成されるタスクリストのサンプル**:
```markdown
## タスクリスト

✅ Ready
- [ ] ユーザー認証APIの実装
  - `/api/auth/login` エンドポイントを作成
  - JWT トークン生成機能を実装
  - 📁 Files: `src/api/auth.ts`, `src/utils/jwt.ts`

✅ Ready
- [ ] ログイン画面のUI実装
  - ユーザー名とパスワードの入力フィールド
  - ログインボタン
  - 📁 Files: `src/pages/Login.tsx`
```

#### 例2: PR作成付き

プルリクエスト作成タスクを含めてTODOファイルを生成する例です。

**実行コマンド**:
```bash
/cccp:todo-task-planning requirements.md --pr
```

**実行結果**:
- タスクリストの最後に「プルリクエストを作成」タスクが追加される
- すべてのタスク完了後、PR作成を実行

**生成されるタスクリストのサンプル**:
```markdown
## タスクリスト

✅ Ready
- [ ] ユーザー認証APIの実装
  - 📁 Files: `src/api/auth.ts`

✅ Ready
- [ ] ログイン画面のUI実装
  - 📁 Files: `src/pages/Login.tsx`

⏳ Pending
- [ ] プルリクエストを作成
  - 待機理由: すべての実装タスクの完了
  - 解除条件: ユーザー認証API、ログイン画面UIの実装完了
```

#### 例3: ブランチ名指定

作業ブランチ名を明示的に指定してTODOファイルを生成する例です。

**実行コマンド**:
```bash
/cccp:todo-task-planning requirements.md --branch feature/user-auth
```

**実行結果**:
- ブランチ作成タスクがタスクリストの最初に追加される
- ブランチ名は`feature/user-auth`として指定される

**生成されるタスクリストのサンプル**:
```markdown
## タスクリスト

✅ Ready
- [ ] ブランチを作成
  - ブランチ名: `feature/user-auth`
  - mainブランチから分岐

✅ Ready
- [ ] ユーザー認証APIの実装
  - 📁 Files: `src/api/auth.ts`

✅ Ready
- [ ] ログイン画面のUI実装
  - 📁 Files: `src/pages/Login.tsx`
```

#### 例4: ブランチ名自動生成

ブランチ名を自動生成し、PR作成タスクも含める例です。

**実行コマンド**:
```bash
/cccp:todo-task-planning user-feature-spec.md --pr --branch
```

**実行結果**:
- ブランチ名が要件ファイル名から自動生成される（例: `feature/user-feature-spec`）
- ブランチ作成タスクとPR作成タスクの両方が含まれる

**生成されるタスクリストのサンプル**:
```markdown
## タスクリスト

✅ Ready
- [ ] ブランチを作成
  - ブランチ名: `feature/user-feature-spec`（自動生成）
  - mainブランチから分岐

✅ Ready
- [ ] ユーザー認証APIの実装
  - 📁 Files: `src/api/auth.ts`

✅ Ready
- [ ] ログイン画面のUI実装
  - 📁 Files: `src/pages/Login.tsx`

⏳ Pending
- [ ] プルリクエストを作成
  - 待機理由: すべての実装タスクの完了
  - 解除条件: ユーザー認証API、ログイン画面UIの実装完了
```

### 3.4 動作フロー

`todo-task-planning`コマンドの実行時には、以下の処理フローが順次実行されます。

**Phase 0.1: Explore エージェント（調査フェーズ）**
1. 指定された要件ファイルを読み取る
2. 関連する既存のプロジェクトファイルを調査
3. 技術スタック、プロジェクト構造、既存実装を分析
4. 調査結果を`docs/memory/explorations/`ディレクトリに保存

**Phase 0.2: Plan エージェント（計画フェーズ）**
1. Explore エージェントの調査結果を読み取る
2. 要件を分析し、タスクを分解
3. タスクの依存関係を解析し、実行順序を決定
4. 各タスクにFeasibility Markersを付与
5. 計画結果を`docs/memory/planning/`ディレクトリに保存

**Phase 0.3: cccp:project-manager エージェント（質問管理フェーズ）**
1. Plan エージェントの計画結果を読み取る
2. 不明確な要件や技術的詳細に関する質問を生成
3. 質問をユーザーに提示し、回答を収集
4. 回答を`docs/memory/questions/`ディレクトリに保存

**Phase 0.4: TODOファイル生成**
1. 計画結果と質問への回答を統合
2. チェックリスト形式のTODOファイルを生成
3. ブランチ作成タスク、PR作成タスクを追加（オプション指定時）
4. TODOファイルを指定されたパスに保存

**Phase 0.5: 保存と確認**
1. 生成されたTODOファイルをユーザーに提示
2. 調査結果、計画結果、質問回答を`docs/memory/`以下に保存
3. 処理完了を通知

### 3.5 生成されるTODOファイルの構造

`todo-task-planning`コマンドで生成されるTODOファイルは、以下の4つのセクションで構成されます。

#### 実行サマリーセクション

TODOファイルの冒頭には、実行サマリーが記載されます。

**サンプル**:
```markdown
## 📊 実行サマリー（2026-01-24更新）

- [x] **Phase 0完了**: Explore, Plan, cccp:project-manager エージェント実行完了
- [x] **調査完了**: 5ファイル調査
- [x] **計画完了**: 3フェーズ8タスクの実装計画策定
- [x] **ユーザー質問解決**: 2質問回答完了
- [x] **docs/memory保存**: exploration, planning, answers ファイル作成済
- [x] **ブランチ**: `feature/user-auth` (作成予定)
- [ ] **総推定工数**: 2時間30分
```

#### タスクリストセクション

実行すべきタスクがチェックリスト形式で記載されます。タスクはPhaseごとにグループ化され、各タスクにはFeasibility Markersが付与されます。

**サンプル**:
```markdown
## 📋 タスクリスト

### Phase 1: 環境セットアップ (10分) ✅

✅ Ready
- [ ] **ブランチを作成**
  - Branch: `feature/user-auth`
  - Status: 作成予定
  - 推定時間: 1分

### Phase 2: ユーザー認証API実装 (1時間) ⏳

✅ Ready
- [ ] **ログインエンドポイントの実装**
  - `/api/auth/login` (POST) を実装
  - リクエストボディ: `{ username: string, password: string }`
  - レスポンス: `{ token: string }`
  - 📁 Files: `src/api/auth.ts`
  - 📊 技術的根拠: JWT トークンを使用し、有効期限は24時間
  - 推定時間: 30分

🔍 Research
- [ ] **パスワードハッシュ化方式の選定**
  - 調査項目: bcrypt または argon2 の比較
  - 調査方法: セキュリティ要件、パフォーマンスベンチマーク
  - 📊 技術的根拠: OWASP推奨のハッシュ化アルゴリズム採用
  - 推定時間: 15分
```

#### 質問履歴セクション

プロジェクトマネージャーエージェントが生成した質問と、その回答が記録されます。

**サンプル**:
```markdown
## ❓ 質問履歴（解決済み）

- [x] **認証方式**: JWT トークンを使用（セッション管理は不使用）
- [x] **トークン有効期限**: 24時間（リフレッシュトークンは次フェーズで実装）

📁 **詳細**: `docs/memory/questions/2026-01-24-user-auth-answers.md`
```

#### 参照ドキュメントセクション

調査結果、計画結果、質問回答ファイルへのリンクが記載されます。

**サンプル**:
```markdown
## 📚 参照ドキュメント

- 📁 **Exploration結果**: `docs/memory/explorations/2026-01-24-user-auth-exploration.md`
- 📁 **Planning結果**: `docs/memory/planning/2026-01-24-user-auth-plan.md`
- 📁 **技術仕様**: `requirements.md` (要件ファイル)
- 📁 **既存実装参考**: `src/api/existing-api.ts`
```

この構造により、タスクの実行計画、進捗状況、参照情報がすべて一元管理され、開発作業を効率的に進めることができます。

---

## 第4章: todo-task-run 詳細ガイド

`todo-task-run`コマンドは、`todo-task-planning`で生成されたTODOファイルを読み取り、タスクを順次実行するコマンドです。すべてのタスクが完了すると、自動的にプルリクエストを作成します。このコマンドは、タスクの実行、進捗管理、Git操作、PR作成までを一貫して処理し、開発ワークフローを完全自動化します。

### 4.1 コマンド構文

`todo-task-run`コマンドの基本構文は以下の通りです。

```bash
/cccp:todo-task-run <todo_file_path> [--no-pr] [--no-push]
```

**構文要素**:
- `<todo_file_path>`: 実行するTODOファイルのパス（必須）
- `[--no-pr]`: プルリクエスト作成/更新をスキップするフラグ（オプション）
- `[--no-push]`: リモートへのpushをスキップするフラグ（オプション）

### 4.2 パラメータ詳細

`todo-task-run`コマンドのパラメータは、以下の表に示す通りです。

| パラメータ | 種類 | 型 | 説明 | デフォルト値 |
|-----------|------|-----|------|-------------|
| `todo_file_path` | 必須 | String | 実行するTODOファイルのパス。相対パスまたは絶対パスで指定 | - |
| `--no-pr` | オプション | Flag | プルリクエストの作成/更新をスキップ。指定すると、PRを作成せず現在のブランチで作業を継続 | false |
| `--no-push` | オプション | Flag | リモートリポジトリへのpushをスキップ。指定すると、コミットはローカルのみに保存される | false |

**パラメータの詳細説明**:

- **todo_file_path**: 実行対象のTODOファイルパスを指定します。`todo-task-planning`で生成されたチェックリスト形式のファイルが必要です。ファイルには、実行可能なタスク（`- [ ]`形式）が含まれている必要があります。

- **--no-pr**: このフラグを指定すると、プルリクエストの作成/更新がスキップされます。ローカルでの検証や、手動でPRを作成したい場合に使用します。

- **--no-push**: このフラグを指定すると、リモートリポジトリへのpushがスキップされます。ローカル環境でタスクを実行し、コミットをローカルに保存したまま、後から手動でpushする場合に使用します。

### 4.3 実行例

`todo-task-run`コマンドの実行例を2つのパターンで示します。

#### 例1: 基本実行（PR作成とpush有効）

TODOファイルを読み取り、タスクを実行し、PRを自動作成する基本的な使用例です。

**実行コマンド**:
```bash
/cccp:todo-task-run TODO.md
```

**実行結果**:
- `TODO.md`内のチェックリストを順次実行
- 各タスク完了後、自動的にコミット
- すべてのタスク完了後、リモートにpush
- プルリクエストを自動作成/更新

**処理内容**:
1. TODOファイルを読み取り、未完了タスク（`- [ ]`）を抽出
2. 各タスクをTask toolで登録し、エージェントに割り当て
3. タスク完了ごとにチェックボックスを`- [x]`に更新
4. 最終的にリモートブランチにpush
5. GitHubにプルリクエストを作成

#### 例2: ローカル開発（PR作成とpush無効）

PRを作成せず、ローカル環境でタスクを実行する例です。

**実行コマンド**:
```bash
/cccp:todo-task-run TODO.md --no-pr --no-push
```

**実行結果**:
- `TODO.md`内のチェックリストを順次実行
- 各タスク完了後、ローカルブランチにコミット
- リモートへのpushはスキップ
- プルリクエストは作成されない

**処理内容**:
1. TODOファイルを読み取り、未完了タスク（`- [ ]`）を抽出
2. 各タスクを順次実行
3. タスク完了ごとにチェックボックスを`- [x]`に更新
4. コミットはローカルのみに保存
5. 開発者が手動でpushとPR作成を実行

### 4.4 動作フロー

`todo-task-run`コマンドの実行時には、以下の処理フローが順次実行されます。

**Phase 1: 前提条件の確認**
1. TODOファイルが存在し、チェックリスト形式であることを確認
2. Gitリポジトリの状態を確認（変更がないことを確認）
3. 現在のブランチを取得

**Phase 2: 初期セットアップ**
1. リモートリポジトリから最新の状態をfetch
2. `--no-pr`が指定されていない場合、既存のPRを検索
3. PRが存在する場合は継続、存在しない場合は新規作成の準備
4. Memory Files（進捗管理ファイル）を初期化

**Phase 3: タスク実行ループ**
1. TODOファイルを読み取り、未完了タスク（`- [ ]`）を抽出
2. 各タスクをTask toolに登録
3. タスクをエージェントに分類（Explore、Plan、Implementation）
4. タスクを順次実行
5. 各タスク完了後、チェックボックスを`- [x]`に更新
6. タスク完了ごとにコミット（`/cccp:micro-commit`使用）

**Phase 4: 完了処理**
1. すべてのタスクが完了したことを確認
2. `--no-push`が指定されていない場合、リモートにpush
3. `--no-pr`が指定されていない場合、PRを作成/更新
4. TODOファイルの最終更新を保存
5. 完了メッセージをユーザーに通知

### 4.5 PR作成オプションの動作

`todo-task-run`コマンドは、PR作成とpushの動作を2つのフラグで制御します。

#### デフォルト（`--no-pr`なし、`--no-push`なし）

プルリクエストを自動作成し、リモートリポジトリにpushする標準動作です。

**動作**:
- タスク完了後、リモートブランチにpush
- GitHubにプルリクエストを作成
- 既存のPRがある場合は更新

**使用シーン**:
- チーム開発でレビュープロセスが必要な場合
- CI/CDパイプラインをトリガーしたい場合
- 作業内容を即座にチームに共有したい場合

#### `--no-pr`指定時

プルリクエストの作成/更新をスキップし、ブランチへのpushのみ実行します。

**動作**:
- タスク完了後、リモートブランチにpush
- プルリクエストは作成されない
- 開発者が後から手動でPRを作成

**使用シーン**:
- PRのタイトルや説明を手動でカスタマイズしたい場合
- 複数のタスクセットを完了してから一括でPRを作成したい場合
- PR作成タイミングを自分で制御したい場合

#### `--no-push`指定時

リモートへのpushをスキップし、コミットをローカルのみに保存します。

**動作**:
- タスク完了後、ローカルブランチにコミット
- リモートへのpushはスキップ
- プルリクエストは作成されない

**使用シーン**:
- ローカル環境でタスクを検証してからpushしたい場合
- ネットワーク接続が不安定な環境で作業する場合
- 複数のタスクセットを完了してから一括でpushしたい場合

#### `--no-pr --no-push`併用時

完全にローカル環境でタスクを実行し、コミットもpushもスキップします。

**動作**:
- タスク完了後、ローカルブランチにコミット
- リモートへのpushはスキップ
- プルリクエストは作成されない

**使用シーン**:
- 実装を完全にローカルで完結させたい場合
- 後から手動でpushとPRを作成したい場合
- オフライン環境で作業する場合

### 4.6 TODOファイル構造要件

`todo-task-run`コマンドが正しく動作するためには、TODOファイルが以下の構造要件を満たす必要があります。

#### Markdownチェックリスト形式必須

すべてのタスクは、Markdownチェックボックス形式で記載する必要があります。

**必須形式**:
```markdown
- [ ] タスクの説明
```

**完了後の形式**:
```markdown
- [x] タスクの説明
```

この形式を維持しないと、コマンドがタスクを認識できません。

#### タスク記述の推奨フォーマット

タスクの説明は、具体的で実行可能な内容を記載します。

**推奨フォーマット**:
```markdown
- [ ] **タスク名**
  - 実装内容の詳細
  - 技術的な要件
  - 📁 Files: `src/path/to/file.ts`
  - 📊 技術的根拠: パフォーマンス要件やセキュリティ要件
```

**記載例**:
```markdown
- [ ] **ログイン機能の実装**
  - `/api/auth/login` エンドポイントを作成
  - JWT トークン生成機能を実装
  - 📁 Files: `src/api/auth.ts`, `src/utils/jwt.ts`
  - 📊 技術的根拠: セキュアなトークン管理のためJWT使用
```

#### Feasibility Markersの使用

タスクの実行可能性を示すFeasibility Markersを使用します（詳細は第2章を参照）。

**使用可能なマーカー**:
- `✅ Ready`: 即実行可能
- `⏳ Pending`: 依存タスク待ち
- `🔍 Research`: 調査必要
- `🚧 Blocked`: 仕様/技術詳細不明

**マーカー付きタスク例**:
```markdown
✅ Ready
- [ ] データベース接続の実装
  - PostgreSQL接続を設定
  - 📁 Files: `src/db/connection.ts`

⏳ Pending
- [ ] ユーザー登録APIの実装
  - 待機理由: データベース接続の完成を待つ
  - 解除条件: PostgreSQL接続テスト完了
```

#### ファイル参照と技術的根拠の記載方法

タスクには、実装対象のファイルパスと技術的な根拠を明記します。

**ファイル参照の記載**:
```markdown
- 📁 Files: `src/components/Header.tsx`, `src/styles/header.css`
```

**技術的根拠の記載**:
```markdown
- 📊 技術的根拠: API応答時間を100ms以下に保つため、キャッシュ機構を導入
```

**完全なタスク例**:
```markdown
✅ Ready
- [ ] **キャッシュ機構の実装**
  - Redisクライアントを設定
  - キャッシュミドルウェアを作成
  - 📁 Files: `src/cache/redis.ts`, `src/middleware/cache.ts`
  - 📊 技術的根拠: API応答時間を100ms以下に保つため、Redisキャッシュを使用

  - [ ] Redis接続設定
    - Redis接続パラメータを環境変数から読み込む
    - 📁 Files: `src/cache/redis.ts`

  - [ ] キャッシュミドルウェア作成
    - Express用のキャッシュミドルウェアを実装
    - 📁 Files: `src/middleware/cache.ts`
```

この構造により、`todo-task-run`コマンドはタスクを正確に認識し、実行順序を判断し、適切なエージェントに割り当てることができます。

---

## 第5章: 実践ワークフローとベストプラクティス

TODO Task Pluginを効果的に活用するための実践的なワークフローとベストプラクティスを、具体的なシナリオとともに説明します。この章では、3つの実践シナリオ、よくある誤り、推奨されるベストプラクティスを示します。

### 5.1 実践シナリオ1: 新機能追加

新しいユーザー認証機能を追加する際のフルワークフローを示します。

#### ワークフロー

**ステップ1: ブランチ作成**

現在のmainブランチから新しいfeatureブランチを作成します。

```bash
git checkout main
git pull origin main
git checkout -b feature/user-auth
```

**ステップ2: 要件ファイル作成**

要件を`TODO.md`ファイルに記述します。

```markdown
# ユーザー認証機能の追加

## 要件
- ログインエンドポイント（/api/auth/login）を実装
- JWTトークンを使用した認証機構
- トークン有効期限は24時間
- パスワードはbcryptでハッシュ化

## 技術スタック
- Express.js
- jsonwebtoken
- bcrypt

## 実装対象ファイル
- src/api/auth.ts（新規作成）
- src/middleware/auth.ts（新規作成）
- src/utils/jwt.ts（新規作成）
```

**ステップ3: todo-task-planning実行**

要件ファイルからタスク計画を生成します。

```bash
/cccp:todo-task-planning TODO.md --pr
```

**ステップ4: 生成されたTODOファイル確認**

生成されたTODOファイルを確認し、必要に応じて微調整します。

```markdown
## タスクリスト

### Phase 1: 環境セットアップ

✅ Ready
- [ ] **依存パッケージのインストール**
  - jsonwebtoken, bcrypt, @types/jsonwebtokenをインストール
  - 📁 Files: `package.json`

### Phase 2: JWT認証機能実装

✅ Ready
- [ ] **JWT生成・検証ユーティリティの実装**
  - トークン生成関数（generateToken）
  - トークン検証関数（verifyToken）
  - 有効期限: 24時間
  - 📁 Files: `src/utils/jwt.ts`
  - 📊 技術的根拠: JWT標準仕様に準拠、HS256アルゴリズム使用

✅ Ready
- [ ] **ログインエンドポイントの実装**
  - POST /api/auth/login
  - リクエスト: { username: string, password: string }
  - レスポンス: { token: string }
  - 📁 Files: `src/api/auth.ts`
  - 📊 技術的根拠: bcryptでパスワード照合、成功時にJWT発行

### Phase 3: 認証ミドルウェア実装

✅ Ready
- [ ] **認証ミドルウェアの実装**
  - トークン検証ミドルウェア（authenticateToken）
  - Authorizationヘッダーからトークン抽出
  - 📁 Files: `src/middleware/auth.ts`

⏳ Pending
- [ ] **プルリクエストを作成**
  - 待機理由: すべての実装タスクの完了
  - 解除条件: JWT、ログインAPI、ミドルウェアの実装完了
```

**ステップ5: todo-task-run実行**

生成されたタスクリストを実行します。

```bash
/cccp:todo-task-run TODO.md
```

**ステップ6: PR確認とレビュー依頼**

自動作成されたプルリクエストを確認し、チームメンバーにレビューを依頼します。

```bash
# PRのURLが自動的に出力されます
# https://github.com/your-org/your-repo/pull/123
```

このワークフローにより、要件記述からPR作成までの全プロセスが自動化され、開発者は実装とレビューに集中できます。

### 5.2 実践シナリオ2: バグ修正

既存のログイン機能にバグが発見された場合の修正ワークフローを示します。

#### ワークフロー

**ステップ1: 既存ブランチで作業**

既存のfeatureブランチまたは新しいbugfixブランチで作業します。

```bash
git checkout -b bugfix/login-token-expiry
```

**ステップ2: バグ報告を要件ファイルに記述**

バグの内容と修正要件を`BUG-FIX.md`に記述します。

```markdown
# ログイン機能のバグ修正

## バグ内容
- JWTトークンの有効期限が正しく設定されていない
- 現在の実装では有効期限が1時間になっている

## 修正要件
- トークン有効期限を24時間に修正
- 環境変数（JWT_EXPIRY）で有効期限を設定可能にする

## 影響範囲
- src/utils/jwt.ts
- .env.example
```

**ステップ3: todo-task-planning実行**

修正タスクの計画を生成します（ブランチは既存を使用）。

```bash
/cccp:todo-task-planning BUG-FIX.md --pr
```

**ステップ4: 生成されたTODOファイル確認**

```markdown
## タスクリスト

✅ Ready
- [ ] **環境変数の追加**
  - JWT_EXPIRY環境変数を追加
  - デフォルト値: "24h"
  - 📁 Files: `.env.example`

✅ Ready
- [ ] **JWT生成関数の修正**
  - 有効期限を環境変数から読み取るように変更
  - expiresIn: process.env.JWT_EXPIRY || "24h"
  - 📁 Files: `src/utils/jwt.ts`
  - 📊 技術的根拠: 環境ごとに有効期限を変更可能にする

🔍 Research
- [ ] **既存テストの確認と修正**
  - 調査項目: 既存のJWT生成テストの確認
  - 調査方法: test/utils/jwt.test.tsを読み取り
  - 修正内容: モックした環境変数でテスト

⏳ Pending
- [ ] **プルリクエストを作成**
  - 待機理由: すべての修正タスクの完了
  - 解除条件: 環境変数追加、JWT修正、テスト修正完了
```

**ステップ5: todo-task-run実行**

```bash
/cccp:todo-task-run BUG-FIX.md
```

このワークフローでは、既存ブランチでのバグ修正をタスク計画化し、体系的に修正を実施します。

### 5.3 実践シナリオ3: 複数タスクの並行管理

複数の独立した機能開発を並行して進める場合のワークフローを示します。

#### ワークフロー

**ステップ1: 複数の要件ファイル作成**

異なる機能ごとに要件ファイルを作成します。

```bash
# 要件ファイル構成
requirements/
├── feature-a-user-profile.md
├── feature-b-dashboard.md
└── feature-c-notifications.md
```

**ステップ2: 各要件に対してplanningを実行**

異なるブランチ名を指定して、それぞれのタスク計画を生成します。

```bash
# Feature A: ユーザープロフィール機能
/cccp:todo-task-planning requirements/feature-a-user-profile.md --pr --branch feature/user-profile

# Feature B: ダッシュボード機能
/cccp:todo-task-planning requirements/feature-b-dashboard.md --pr --branch feature/dashboard

# Feature C: 通知機能
/cccp:todo-task-planning requirements/feature-c-notifications.md --pr --branch feature/notifications
```

**ステップ3: 生成されたTODOファイルの構成**

各要件に対して独立したTODOファイルが生成されます。

```bash
# 生成されたTODOファイル
TODO-user-profile.md
TODO-dashboard.md
TODO-notifications.md
```

**ステップ4: 優先度順にrun実行**

優先度の高い機能から順次実行します。

```bash
# 優先度1: ユーザープロフィール機能
git checkout -b feature/user-profile
/cccp:todo-task-run TODO-user-profile.md

# 優先度2: ダッシュボード機能
git checkout main
git pull origin main
git checkout -b feature/dashboard
/cccp:todo-task-run TODO-dashboard.md

# 優先度3: 通知機能
git checkout main
git pull origin main
git checkout -b feature/notifications
/cccp:todo-task-run TODO-notifications.md
```

**ステップ5: 各PRの進捗追跡**

生成された各PRの進捗を追跡します。

```bash
# PRの一覧確認
gh pr list

# 出力例:
# #123  feature/user-profile      ユーザープロフィール機能の実装
# #124  feature/dashboard         ダッシュボード機能の実装
# #125  feature/notifications     通知機能の実装
```

このワークフローにより、複数の機能開発を並行して管理し、それぞれ独立したブランチとPRで進捗を追跡できます。

### 5.4 よくある誤り

TODO Task Pluginを使用する際によくある誤りと、その対処法を示します。

#### ❌ 誤り1: TODOファイルにチェックリスト形式を使わない

**問題**:
`todo-task-planning`で生成されたTODOファイルを編集する際に、チェックリスト形式（`- [ ]`）を削除または変更してしまうケースです。

**発生する理由**:
手動編集時にMarkdownの構造を意識せず、通常の箇条書き（`-`のみ）や番号付きリスト（`1.`）に変更してしまうためです。

**対処法**:
- TODOファイルのタスクは必ず`- [ ]`形式を維持する
- タスクの内容や説明のみを編集し、チェックボックス形式は変更しない
- タスクを追加する場合も同じ形式に従う

```markdown
# ❌ 誤った編集
- ログイン機能の実装

# ✅ 正しい編集
- [ ] ログイン機能の実装
```

#### ❌ 誤り2: Feasibility Markersを付けずにタスクを記述

**問題**:
TODOファイルにタスクを手動追加する際、Feasibility Markers（✅ Ready、⏳ Pending、🔍 Research、🚧 Blocked）を付けずに記述してしまうケースです。

**発生する理由**:
Feasibility Markersの意味や重要性を理解していないためです。

**対処法**:
- タスクの実行可能性を評価し、適切なFeasibility Markerを付与する
- 即座に実行可能なタスクには`✅ Ready`を付ける
- 依存関係があるタスクには`⏳ Pending`を付け、待機理由と解除条件を明記する

```markdown
# ❌ 誤った記述（Markerなし）
- [ ] データベース接続の実装

# ✅ 正しい記述
✅ Ready
- [ ] データベース接続の実装
  - PostgreSQL接続を設定
  - 📁 Files: `src/db/connection.ts`
```

#### ❌ 誤り3: タスク粒度が大きすぎる

**問題**:
1つのタスクに複数の実装内容を詰め込みすぎて、実行時間が2時間以上になってしまうケースです。

**発生する理由**:
タスク分解の原則を理解せず、大きな機能単位でタスクを記述してしまうためです。

**対処法**:
- タスクは30分から2時間で完了できる粒度に分割する
- 大きな機能は、サブタスクを使って階層的に分解する
- 各タスクが単一の責任を持つように分割する

```markdown
# ❌ 誤った粒度（大きすぎる）
✅ Ready
- [ ] ユーザー管理機能の実装
  - ユーザー登録、ログイン、プロフィール編集、パスワード変更

# ✅ 正しい粒度
✅ Ready
- [ ] ユーザー登録機能の実装
  - POST /api/users/register
  - 📁 Files: `src/api/users.ts`

✅ Ready
- [ ] ログイン機能の実装
  - POST /api/auth/login
  - 📁 Files: `src/api/auth.ts`

⏳ Pending
- [ ] プロフィール編集機能の実装
  - 待機理由: ユーザー登録とログインの完成を待つ
  - 📁 Files: `src/api/profile.ts`
```

#### ❌ 誤り4: ファイル参照（📁）や技術的根拠（📊）を省略

**問題**:
タスクに実装対象ファイルや技術的な根拠を記載せず、曖昧なタスク記述になってしまうケースです。

**発生する理由**:
ファイル参照や技術的根拠の重要性を理解していないためです。

**対処法**:
- すべてのタスクに実装対象ファイル（📁 Files）を明記する
- 技術的な判断が必要なタスクには技術的根拠（📊）を記載する
- ファイルパスは具体的に記述する

```markdown
# ❌ 誤った記述（ファイル参照なし）
✅ Ready
- [ ] キャッシュ機構の実装
  - Redisを使用する

# ✅ 正しい記述
✅ Ready
- [ ] キャッシュ機構の実装
  - Redisクライアントを設定
  - キャッシュミドルウェアを作成
  - 📁 Files: `src/cache/redis.ts`, `src/middleware/cache.ts`
  - 📊 技術的根拠: API応答時間を100ms以下に保つため、Redisキャッシュを使用
```

#### ❌ 誤り5: `--no-pr`と`--pr`オプションの混同

**問題**:
`todo-task-planning`の`--pr`オプションの意味を誤解し、PR作成タイミングを誤るケースです。

**発生する理由**:
`--pr`オプションが「PR作成タスクを追加する」のではなく、「即座にPRを作成する」と誤解しているためです。

**対処法**:
- `--pr`オプションは「PR作成タスクをTODOリストに追加する」フラグであることを理解する
- 実際のPR作成は`todo-task-run`実行時に行われる
- PRを作成しない場合は`--no-pr`オプションを使用する

```bash
# ❌ 誤った理解
# 「--prを指定すると即座にPRが作成される」→ 誤り

# ✅ 正しい理解
# 「--prを指定すると、TODOリストにPR作成タスクが追加される」
/cccp:todo-task-planning TODO.md --pr
# → TODOファイルに「プルリクエストを作成」タスクが追加される

# 実際のPR作成はrunコマンド実行時
/cccp:todo-task-run TODO.md
# → すべてのタスク完了後、PRが自動作成される
```

#### ❌ 誤り6: Git操作をロールバックする

**問題**:
タスク実行中にエラーが発生した際、`git reset`や`git revert`でコミットをロールバックしてしまうケースです。

**発生する理由**:
前進のみのGit操作ルールを理解していないためです。

**対処法**:
- エラーが発生した場合、ロールバックではなく修正を新しいコミットとして追加する
- `git reset`、`git restore`、`git revert`は使用しない
- 修正が必要な場合は、修正内容を新しいタスクとして追加し、実行する

```bash
# ❌ 誤った対処（ロールバック）
git reset --hard HEAD~1

# ✅ 正しい対処（前進のみ）
# 修正内容をTODOファイルに追加
✅ Ready
- [ ] ログイン機能のバグ修正
  - トークン生成ロジックの修正
  - 📁 Files: `src/utils/jwt.ts`

# 修正を実行
/cccp:todo-task-run TODO.md
```

#### ❌ 誤り7: 複数のTODOファイルを同時に実行

**問題**:
異なるブランチのTODOファイルを、ブランチを切り替えずに連続して実行してしまうケースです。

**発生する理由**:
ブランチの管理とTODOファイルの対応関係を理解していないためです。

**対処法**:
- 1つのブランチに対して1つのTODOファイルを実行する
- 別のTODOファイルを実行する際は、必ずブランチを切り替える
- 現在のブランチ状態を確認してから実行する

```bash
# ❌ 誤った実行（ブランチ切り替えなし）
/cccp:todo-task-run TODO-feature-a.md
/cccp:todo-task-run TODO-feature-b.md  # ← 同じブランチで別のTODOを実行してしまう

# ✅ 正しい実行
git checkout -b feature/feature-a
/cccp:todo-task-run TODO-feature-a.md

git checkout main
git pull origin main
git checkout -b feature/feature-b
/cccp:todo-task-run TODO-feature-b.md
```

### 5.5 ベストプラクティス

TODO Task Pluginを効果的に活用するための推奨事項を示します。

#### ✅ プラクティス1: タスクは30分-2時間で完了できる粒度に分割

**理由**:
タスク粒度が適切であると、進捗管理がしやすく、エラー発生時の影響範囲が限定され、コミット履歴が明確になります。

**実践方法**:
- 大きな機能は複数のサブタスクに分解する
- 各タスクが単一の責任を持つように分割する
- タスク実行時間が2時間を超える場合は、さらに細分化する

```markdown
# ✅ 適切な粒度
✅ Ready
- [ ] **JWT生成ユーティリティの実装**
  - トークン生成関数（generateToken）
  - 推定時間: 30分
  - 📁 Files: `src/utils/jwt.ts`

✅ Ready
- [ ] **JWT検証ユーティリティの実装**
  - トークン検証関数（verifyToken）
  - 推定時間: 30分
  - 📁 Files: `src/utils/jwt.ts`
```

#### ✅ プラクティス2: Feasibility Markersで実行可能性を明示

**理由**:
タスクの実行可能性を明確にすることで、実行順序の判断が容易になり、依存関係の管理が正確になります。

**実践方法**:
- すべてのタスクに適切なFeasibility Markerを付与する
- `⏳ Pending`には待機理由と解除条件を必ず記載する
- `🔍 Research`には調査項目と調査方法を記載する
- `🚧 Blocked`にはブロッカーの内容と解決手順を記載する

```markdown
# ✅ 適切なFeasibility Markers
✅ Ready
- [ ] データベース接続の実装
  - 📁 Files: `src/db/connection.ts`

⏳ Pending
- [ ] ユーザー登録APIの実装
  - 待機理由: データベース接続の完成を待つ
  - 解除条件: PostgreSQL接続テスト完了
  - 📁 Files: `src/api/users.ts`
```

#### ✅ プラクティス3: 実装対象ファイルを具体的に指定

**理由**:
ファイルパスを明示することで、実装範囲が明確になり、コードレビュー時に変更箇所を特定しやすくなります。

**実践方法**:
- すべてのタスクに📁 Filesを記載する
- ファイルパスは相対パスで具体的に記述する
- 複数ファイルの場合はカンマ区切りで列挙する
- 新規作成ファイルと既存ファイルの変更を区別する

```markdown
# ✅ 具体的なファイル指定
✅ Ready
- [ ] **キャッシュ機構の実装**
  - Redisクライアントを設定
  - キャッシュミドルウェアを作成
  - 📁 Files: `src/cache/redis.ts` (新規作成), `src/middleware/cache.ts` (新規作成), `src/app.ts` (変更)
```

#### ✅ プラクティス4: Git操作は前進のみ（ロールバック禁止）

**理由**:
前進のみのGit操作により、すべての変更履歴が保持され、問題発生時の原因追跡が容易になります。

**実践方法**:
- `git reset`、`git restore`、`git revert`を使用しない
- エラーが発生した場合は、修正を新しいコミットとして追加する
- コミット履歴は常に前進させる
- やり直しが必要な場合は、修正タスクを追加して実行する

```bash
# ✅ 前進のみのGit操作
# エラーが発生した場合
# 1. 修正内容をTODOファイルに追加
✅ Ready
- [ ] ログイン機能のバグ修正
  - トークン生成ロジックの修正

# 2. 修正を実行（新しいコミットとして追加）
/cccp:todo-task-run TODO.md
```

#### ✅ プラクティス5: cccp:micro-commitで適切な粒度でコミット

**理由**:
適切な粒度のコミットにより、変更履歴が明確になり、レビューが容易になり、問題発生時のロールフォワードが正確になります。

**実践方法**:
- `/cccp:micro-commit`スキルを使用して、コンテキストベースのコミットメッセージを自動生成する
- 1つのタスク完了ごとに1つのコミットを作成する
- コミットメッセージは具体的で、変更内容を明確に示す
- 手動でgit commitを実行しない

```bash
# ✅ micro-commitの使用
# タスク完了後
/cccp:micro-commit

# 自動的に以下が実行される:
# 1. 変更ファイルの検出
# 2. 変更内容の分析
# 3. コンテキストベースのコミットメッセージ生成
# 4. コミット作成
```

#### ✅ プラクティス6: 技術的根拠で判断の背景を記録

**理由**:
技術的な判断の背景を記録することで、後からレビューする際に意図が明確になり、技術的な議論の土台が形成されます。

**実践方法**:
- パフォーマンス要件、セキュリティ要件、技術選定理由を📊 技術的根拠に記載する
- 具体的な数値や基準を含める
- 技術的な制約や依存関係を明記する

```markdown
# ✅ 技術的根拠の記載
✅ Ready
- [ ] **キャッシュ機構の実装**
  - Redisクライアントを設定
  - 📁 Files: `src/cache/redis.ts`
  - 📊 技術的根拠: API応答時間を100ms以下に保つため、Redisキャッシュを使用。現在の応答時間は平均200ms、目標は50ms以下。
```

#### ✅ プラクティス7: planningで生成されたTODOは必ず確認してから実行

**理由**:
自動生成されたタスクリストを確認することで、タスクの妥当性を検証し、実行順序を調整し、不要なタスクを削除できます。

**実践方法**:
- `todo-task-planning`実行後、生成されたTODOファイルを必ず確認する
- タスクの実行順序が適切か確認する
- 不要なタスクや重複するタスクを削除する
- タスクの内容が具体的で実行可能か検証する
- 必要に応じてタスクを追加・修正する

```bash
# ✅ planningとrunの間に確認を挟む
/cccp:todo-task-planning TODO.md --pr

# 生成されたTODOファイルを確認・編集
# - タスクの妥当性チェック
# - 実行順序の調整
# - 不要なタスクの削除

# 確認後に実行
/cccp:todo-task-run TODO.md
```

これらのベストプラクティスを遵守することで、TODO Task Pluginを効果的に活用し、効率的で保守性の高い開発ワークフローを実現できます。

---

## 第6章: Quick Reference

TODO Task Pluginを効率的に使用するための早見表とチェックリストを提供します。この章では、コマンドのパターン、パラメータ一覧、Feasibility Markersの使い分け、実行前の確認項目を表形式でまとめています。

### 6.1 コマンド早見表

#### todo-task-planning コマンドパターン

| パターン | コマンド | 使用シーン | 生成内容 |
|---------|---------|-----------|---------|
| 基本実行 | `/cccp:todo-task-planning <file_path>` | TODOファイルのみを生成したい場合 | タスクリストのみ（ブランチ作成タスク、PR作成タスクなし） |
| PR作成付き | `/cccp:todo-task-planning <file_path> --pr` | タスク完了後にPRを作成したい場合 | タスクリスト + PR作成タスク |
| ブランチ指定 | `/cccp:todo-task-planning <file_path> --branch <branch_name>` | 特定のブランチ名で作業したい場合 | ブランチ作成タスク + タスクリスト |
| ブランチ自動生成 | `/cccp:todo-task-planning <file_path> --pr --branch` | ブランチ名を自動生成し、PR作成も行いたい場合 | ブランチ作成タスク + タスクリスト + PR作成タスク（ブランチ名は要件ファイル名から自動生成） |

**使用例**:
```bash
# 基本実行
/cccp:todo-task-planning requirements.md

# PR作成付き
/cccp:todo-task-planning requirements.md --pr

# ブランチ名指定
/cccp:todo-task-planning requirements.md --branch feature/user-auth

# ブランチ自動生成 + PR作成
/cccp:todo-task-planning user-feature-spec.md --pr --branch
```

#### todo-task-run コマンドパターン

| パターン | コマンド | 使用シーン | 動作内容 |
|---------|---------|-----------|---------|
| 基本実行 | `/cccp:todo-task-run <todo_file_path>` | TODOファイルを実行し、PRを自動作成したい場合 | タスク実行 → コミット → push → PR作成/更新 |
| PR無効 | `/cccp:todo-task-run <todo_file_path> --no-pr` | PRを手動で作成したい場合 | タスク実行 → コミット → push（PRは作成されない） |
| push無効 | `/cccp:todo-task-run <todo_file_path> --no-push` | ローカルでコミットし、後からpushしたい場合 | タスク実行 → コミット（pushとPR作成はスキップ） |
| 完全ローカル | `/cccp:todo-task-run <todo_file_path> --no-pr --no-push` | 完全にローカル環境で実行したい場合 | タスク実行 → コミット（pushとPR作成は両方スキップ） |

**使用例**:
```bash
# 基本実行（PR自動作成）
/cccp:todo-task-run TODO.md

# PR無効（手動でPRを作成）
/cccp:todo-task-run TODO.md --no-pr

# push無効（ローカルで検証後にpush）
/cccp:todo-task-run TODO.md --no-push

# 完全ローカル（オフライン作業）
/cccp:todo-task-run TODO.md --no-pr --no-push
```

### 6.2 パラメータ完全一覧

#### todo-task-planning パラメータ

| パラメータ | 型 | 必須/任意 | デフォルト値 | 説明 |
|-----------|-----|----------|-------------|------|
| `file_path` | String | 必須 | - | タスク計画の基となる要件ファイルのパス。相対パスまたは絶対パスで指定。Markdown形式推奨。 |
| `--pr` | Flag | 任意 | false | 最終タスクとしてプルリクエスト作成タスクを追加。指定すると、すべてのタスク完了後にPR作成タスクがTODOリストに含まれる。 |
| `--branch` | String | 任意 | 自動生成 | 作業用のブランチ名を指定。値を指定しない場合（`--branch`のみ）、要件ファイル名から自動生成される（例: `requirements.md` → `feature/requirements`）。 |

**パラメータ組み合わせ例**:
```bash
# file_pathのみ（必須パラメータ）
/cccp:todo-task-planning requirements.md

# file_path + --pr
/cccp:todo-task-planning requirements.md --pr

# file_path + --branch（値指定）
/cccp:todo-task-planning requirements.md --branch feature/user-auth

# file_path + --pr + --branch（値省略）
/cccp:todo-task-planning requirements.md --pr --branch
```

#### todo-task-run パラメータ

| パラメータ | 型 | 必須/任意 | デフォルト値 | 説明 |
|-----------|-----|----------|-------------|------|
| `todo_file_path` | String | 必須 | - | 実行するTODOファイルのパス。相対パスまたは絶対パスで指定。`todo-task-planning`で生成されたチェックリスト形式のファイルが必要。 |
| `--no-pr` | Flag | 任意 | false | プルリクエストの作成/更新をスキップ。指定すると、PRを作成せず現在のブランチで作業を継続。 |
| `--no-push` | Flag | 任意 | false | リモートリポジトリへのpushをスキップ。指定すると、コミットはローカルのみに保存される。 |

**パラメータ組み合わせ例**:
```bash
# todo_file_pathのみ（デフォルト: PR作成、push実行）
/cccp:todo-task-run TODO.md

# todo_file_path + --no-pr（PR作成スキップ）
/cccp:todo-task-run TODO.md --no-pr

# todo_file_path + --no-push（pushスキップ）
/cccp:todo-task-run TODO.md --no-push

# todo_file_path + --no-pr + --no-push（完全ローカル実行）
/cccp:todo-task-run TODO.md --no-pr --no-push
```

### 6.3 Feasibility Markers 早見表

Feasibility Markersは、各タスクの実行可能性を示すステータス表示です（詳細は第2章を参照）。

| マーカー | 意味 | 使用条件 | 使用例 |
|---------|------|---------|-------|
| ✅ Ready | 即実行可能 | 仕様が明確で、技術的な課題が解決済み、依存関係がすべて満たされている | `✅ Ready`<br>`- [ ] ユーザー認証APIの実装`<br>`  - 📁 Files: src/api/auth.ts` |
| ⏳ Pending | 依存タスク待ち | 他のタスクの完了を待っている。待機理由と解除条件を記載する | `⏳ Pending`<br>`- [ ] プロフィール画面の実装`<br>`  - 待機理由: 認証APIの完成を待つ`<br>`  - 解除条件: /api/auth/login の動作確認完了` |
| 🔍 Research | 調査必要 | タスクを実行する前に調査や検証が必要。調査項目と調査方法を記載する | `🔍 Research`<br>`- [ ] データベーススキーマの最適化`<br>`  - 調査項目: インデックス設定の最適化方法`<br>`  - 調査方法: スロークエリログの分析` |
| 🚧 Blocked | 仕様/技術詳細不明 | 仕様が不明確、または技術的な詳細が決定していない。ブロッカーの内容と解決手順を記載する | `🚧 Blocked`<br>`- [ ] 決済システムの統合`<br>`  - ブロッカー: 決済プロバイダーが未決定`<br>`  - 解決手順: ビジネス要件の確認、候補の比較` |

**Feasibility Markers選択フローチャート**:
```
タスクを記述する
    ↓
仕様は明確か？ ─── No → 🚧 Blocked
    ↓ Yes
調査が必要か？ ─── Yes → 🔍 Research
    ↓ No
依存タスクがあるか？ ─── Yes → ⏳ Pending
    ↓ No
✅ Ready
```

### 6.4 実行前チェックリスト

#### todo-task-planning 実行前チェックリスト

planningコマンドを実行する前に、以下の項目を確認してください。

- [ ] 要件ファイルが具体的に記述されているか（「何を」「どのように」「なぜ」が明記されている）
- [ ] 技術スタックや実装対象ファイルが要件ファイルに含まれているか
- [ ] ブランチ名を指定する場合、既存ブランチと重複していないか（`git branch`で確認）
- [ ] PR作成が必要かどうか判断しているか（`--pr`フラグの使用判断）
- [ ] 要件ファイルのパスが正しいか（相対パスまたは絶対パス）

**確認コマンド**:
```bash
# 既存ブランチの確認
git branch -a

# 現在のブランチ状態確認
git status

# 要件ファイルの存在確認
ls -la requirements.md
```

#### todo-task-run 実行前チェックリスト

runコマンドを実行する前に、以下の項目を確認してください。

- [ ] TODOファイルがチェックリスト形式（`- [ ]`）で記述されているか
- [ ] planningで生成されたTODOファイルを確認・編集したか
- [ ] タスクの実行順序が適切か（依存関係が正しく設定されている）
- [ ] 実装対象ファイル（📁 Files）が各タスクに記載されているか
- [ ] Feasibility Markersが適切に付与されているか
- [ ] Git作業ディレクトリがクリーンか（未コミットの変更がない）
- [ ] 現在のブランチが意図したブランチか
- [ ] PR作成オプション（`--no-pr`、`--no-push`）の使用を判断したか

**確認コマンド**:
```bash
# Git作業ディレクトリの状態確認
git status

# 現在のブランチ確認
git branch --show-current

# TODOファイルの内容確認
cat TODO.md | head -50

# チェックリスト形式の確認（`- [ ]`の数をカウント）
grep -c "^- \[ \]" TODO.md
```

**実行前の最終確認**:
```markdown
✅ 実行前チェック完了
- [x] TODOファイルの構造確認済み
- [x] タスク実行順序確認済み
- [x] Git状態クリーン確認済み
- [x] ブランチ確認済み
- [x] PR作成オプション判断済み

→ todo-task-run実行可能
```

このQuick Referenceを活用することで、TODO Task Pluginの効果的な使用が可能になり、実行時のエラーを未然に防ぐことができます。

---

