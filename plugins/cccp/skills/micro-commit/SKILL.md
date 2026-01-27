---
name: micro-commit
description: Split git changes into context-based micro-commits using Lucas Rocha's methodology. Use when user wants to commit changes as multiple logical micro-commits instead of a single monolithic commit.
trigger:
  - マイクロコミット
  - micro-commit
  - split changes
  - 変更を分けてコミット
  - 分割コミット
---

# Micro-Commit Skill

This skill implements **Lucas Rocha's micro-commit methodology**, which emphasizes breaking down changes into small, logical, and independently meaningful commits.

## Core Guidelines

Before starting any task, read and follow `/cccp:key-guidelines`

---

## Your Responsibilities

You will directly execute all git operations using the Bash tool. Follow these steps carefully:

### Step 1: Check Current Status

Run `git status --porcelain` to identify all unstaged and staged changes.

```bash
git status --porcelain
```

### Step 2: Analyze and Group Changes

Analyze the changes and group them logically using one of these strategies:

#### Grouping Strategy

**By File Type**: Group similar file types together
- Example: All TypeScript files, all config files, all markdown files

**By Feature**: Group files that implement the same feature
- Example: All files related to user authentication

**By Layer**: Group by architectural layer
- Example: API changes, frontend changes, database changes, config changes

**By Purpose**: Group by the purpose of changes
- Example: New features, bug fixes, refactoring, documentation, tests

### Step 3: Create Micro-Commits

For each logical group, execute the following:

1. **Stage files explicitly** using `git add <file1> <file2> ...`
2. **Create commit** with a clear, focused message
3. **Verify success** by checking the output

### Step 4: Generate Commit Messages

Create commit messages following these guidelines:

- Follow Conventional Commits format: `type(scope): subject`
- Use appropriate type prefixes: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`
- Write in Japanese (unless user specifies otherwise)
- Each commit should describe ONE logical change
- Add Co-Authored-By footer: `Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>`

### Step 5: Final Verification

After all commits, run `git status` to confirm no changes remain uncommitted, and display a summary of created commits.

## Important Constraints

- **Stage files explicitly** - Always use `git add <file>` for each group before committing
- **Use HEREDOC for commit messages** - Ensures proper formatting and special character handling
- **Japanese commit messages** - Unless user specifies otherwise
- **One context per commit** - Each commit represents a single logical change
- **Sequential processing** - Process one group at a time, verify each commit before moving to next
- **Never skip hooks** - Do not use `--no-verify` or similar flags

## Git Operations

### Adding Files to Staging

```bash
git add file1.ts file2.ts
```

### Creating Commits with HEREDOC

Always use HEREDOC format to ensure proper formatting of multi-line commit messages:

```bash
git commit -m "$(cat <<'EOF'
feat(scope): subject line in Japanese

Optional body explaining the change in more detail.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

### Checking Status

```bash
git status
```

### Viewing Recent Commits

```bash
git log --oneline -n 5
```

## Examples

### Example 1: Basic File Type Grouping

**Scenario**: Changes to TypeScript files, config files, and docs

```bash
# Check status
git status --porcelain

# Group 1: TypeScript changes
git add src/app.ts src/utils.ts
git commit -m "$(cat <<'EOF'
feat(core): ユーザー認証機能を追加

- src/app.ts: 認証ミドルウェアを統合
- src/utils.ts: トークン検証ユーティリティを追加

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"

# Group 2: Config changes
git add tsconfig.json package.json
git commit -m "$(cat <<'EOF'
chore(config): TypeScript設定を更新

- tsconfig.json: strict modeを有効化
- package.json: 認証ライブラリを追加

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"

# Group 3: Documentation
git add README.md
git commit -m "$(cat <<'EOF'
docs(readme): 認証機能のドキュメントを追加

新しい認証フローの使用方法を説明

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"

# Verify
git status
```

### Example 2: Feature-Based Grouping

**Scenario**: Multiple files implementing a single feature

```bash
# All files for API endpoint feature
git add apps/api/src/routes/timeline.ts apps/api/src/controllers/timeline.ts apps/api/src/models/timeline.ts
git commit -m "$(cat <<'EOF'
feat(api): タイムライン取得APIエンドポイントを追加

- routes: /api/timeline エンドポイントを定義
- controllers: タイムラインデータ取得ロジックを実装
- models: Timelineモデルを追加

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"

# UI components for the same feature
git add apps/dashboard/src/components/Timeline.tsx apps/dashboard/src/types/timeline.ts
git commit -m "$(cat <<'EOF'
feat(ui): タイムラインコンポーネントを追加

- Timeline.tsx: タイムライン表示コンポーネント
- timeline.ts: タイムライン型定義

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

### Example 3: Layer-Based Grouping

**Scenario**: Changes across different architectural layers

```bash
# Database layer
git add apps/api/src/migrations/*.sql apps/api/src/models/*.ts
git commit -m "$(cat <<'EOF'
feat(db): ユーザーテーブルにロール列を追加

- migrations: role列追加のマイグレーション
- models: Userモデルにroleプロパティを追加

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"

# API layer
git add apps/api/src/routes/*.ts apps/api/src/controllers/*.ts
git commit -m "$(cat <<'EOF'
feat(api): ロールベースのアクセス制御を実装

- routes: 管理者専用エンドポイントを追加
- controllers: ロール検証ロジックを実装

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"

# Frontend layer
git add apps/dashboard/src/components/*.tsx apps/dashboard/src/hooks/*.ts
git commit -m "$(cat <<'EOF'
feat(ui): 管理者ダッシュボードUIを追加

- components: AdminDashboard コンポーネント
- hooks: useAdminAccess フック

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

## Error Handling

### If git add fails:
- Check if files exist: `ls -la <file>`
- Verify file paths are correct
- Report error to user

### If git commit fails:
- Check for pre-commit hooks: Review the error message
- If hook fails: Fix the issue, re-stage files, create a NEW commit (never use `--amend` unless explicitly requested)
- Report the issue to user and ask for guidance

### If no changes detected:
- Inform user there are no changes to commit
- Show `git status` output

### If commit message format is invalid:
- Review Conventional Commits format
- Regenerate message with proper format
- Retry commit

## Summary Output

After all commits are created, provide a summary:

```
✅ マイクロコミット完了

作成されたコミット:
1. feat(core): ユーザー認証機能を追加
2. chore(config): TypeScript設定を更新
3. docs(readme): 認証機能のドキュメントを追加

全ての変更がコミットされました。
```
