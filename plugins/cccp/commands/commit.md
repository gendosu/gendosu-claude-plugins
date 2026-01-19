---
description: git stageされている内容でコミット
---

Commits staged changes with an appropriate commit message using the git-operations-specialist agent.

## Core Guidelines

Before starting any task, read and follow `/cccp:key-guidelines`

---

## Agents

- use cccp:git-operations-specialist agent

## Agent Instructions

**IMPORTANT: Use the cccp:git-operations-specialist agent (via Task tool) for ALL git-related operations in this command.**

Analyze the staged changes and safely commit them with an appropriate commit message.

### Required Execution Items

1. **Check Staging Status**: Run `git status` to confirm what changes are staged

2. **Review Staged Changes**: Use `git diff --staged` to review the content of staged changes

3. **Create Commit**: Commit the staged changes with an appropriate commit message

4. **Verify Commit**: Run `git status` after committing to confirm the commit was successful

### Commit Message Guidelines

- Follow the `.gitmessage` template format
- Use appropriate commit type prefixes: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`
- Write clear, concise messages that describe the change
- Use Japanese for commit messages following project conventions

### ⚠️ Important Constraints

- **Never use any `git add` commands** – Only commit what is already staged
- **Use HEREDOC** – Maintain proper formatting of commit messages
- **Stage verification first** – Always check what's staged before committing
- **Single commit** – Create one commit for all currently staged changes

### Example Usage

If you have already staged changes:
```
# Staged files:
- apps/api/src/routes/timeline.ts
- apps/api/src/types/timeline.ts
```

This command will create a single commit containing both files with an appropriate message like:
```
feat: タイムラインAPIのルートと型定義を追加
```
