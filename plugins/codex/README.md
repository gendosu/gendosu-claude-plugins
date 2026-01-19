# Codex Plugin

Versatile Codex MCP integration plugin for Claude Code that provides comprehensive code review, technical research, documentation generation, and custom query capabilities.

[日本語版はこちら](./README.ja.md)

## Features

- 🔍 **Code Review**: Comprehensive security, design, and quality reviews with automatic context gathering
- 🔬 **Technical Research**: Deep dive into libraries, patterns, and best practices with project context
- 📝 **Documentation Generation**: Auto-generate technical docs, API specs, and comments
- 🎯 **Custom Queries**: Flexible custom prompts for any technical question

## Prerequisites

- **Claude Code** installed
- **Codex MCP Server** configured (REQUIRED)

This plugin requires Codex MCP Server to be set up and configured. The skill will display an error message if MCP is not available.

## Installation

### 1. Add Marketplace

```bash
/plugin marketplace add gendosu/gendosu-claude-plugins
```

### 2. Install Plugin

```bash
/plugin install codex@gendosu-claude-plugins
```

### 3. Verify Installation

```bash
/skills list
```

You should see `codex` in the skills list.

## Usage

### Code Review

Simply ask for a code review and the skill will automatically:
- Get git diff of current changes
- Read changed files
- Detect tech stack
- Read project design principles (CLAUDE.md)
- Construct optimized review prompt
- Execute Codex review

```
codexでレビューして
Review with Codex
```

**Advanced usage:**
```
このファイルをcodexでレビュー: src/api/auth.ts
Review this file with Codex: src/api/auth.ts
```

### Technical Research

Ask for technical research and the skill will:
- Detect project tech stack
- Read existing implementations
- Gather project constraints
- Construct research prompt
- Execute Codex research

```
React 19の新機能を調査して
Research React 19 new features

TypeScriptの依存性注入のベストプラクティスを調査
Research dependency injection best practices in TypeScript
```

### Documentation Generation

Request documentation generation and the skill will:
- Read target code files
- Extract API signatures
- Check existing doc style
- Construct documentation prompt
- Generate Markdown docs

```
このAPIのドキュメントを生成して
Generate documentation for this API

src/utils/auth.tsのドキュメント作成
Create documentation for src/utils/auth.ts
```

### Custom Queries

Ask Codex anything directly:

```
Codexでこのエラーの原因を教えて: TypeError: Cannot read property 'map' of undefined
Using Codex, explain this error: TypeError: Cannot read property 'map' of undefined

/codex TypeScriptの型システムについて詳しく説明して
/codex Explain TypeScript's type system in detail
```

## How It Works

The Codex skill provides significant value over using Codex MCP directly:

### Automatic Context Gathering

- **Tech Stack Detection**: Reads package.json, requirements.txt, etc.
- **Design Principles**: Loads CLAUDE.md and project guidelines
- **Existing Patterns**: Finds similar implementations using Glob/Grep
- **Smart File Reading**: Avoids binary files, respects .gitignore

### Optimized Prompt Construction

For each use case, the skill constructs detailed prompts with:
- Clear objectives
- Project context
- Structured format expectations
- Specific constraints (language, depth, format)

### Enhanced User Experience

- **Natural Language**: Simple requests like "codexでレビューして"
- **Auto-Detection**: Automatically determines use case
- **Formatted Results**: Pretty-printed Markdown output
- **Follow-up Actions**: Suggests next steps (save to docs, further analysis)

## Configuration

No additional configuration needed beyond Codex MCP Server setup.

### Codex MCP Server Setup

Refer to Codex MCP Server documentation for installation and configuration instructions.

## Examples

### Example 1: Quick Code Review

```
User: "codexでレビューして"

→ Skill execution:
1. Get git diff (3 files changed)
2. Read changed files
3. Detect tech stack → TypeScript, React
4. Read CLAUDE.md → Extract design principles
5. Construct review prompt with all context
6. Call mcp__codex__codex
7. Display formatted review results
```

### Example 2: Research with Project Context

```
User: "GraphQLのベストプラクティスを調査"

→ Skill execution:
1. Check package.json → Detect GraphQL version
2. Search for existing GraphQL code → Find patterns
3. Read CLAUDE.md → Get project constraints
4. Construct research prompt with context
5. Call mcp__codex__codex
6. Display research results with implementation examples
```

### Example 3: Documentation Generation

```
User: "src/api/users.tsのドキュメント生成"

→ Skill execution:
1. Read src/api/users.ts
2. Extract function signatures and exports
3. Check existing docs style
4. Construct documentation prompt
5. Call mcp__codex__codex
6. Display Markdown documentation
7. Offer to save to docs/api/users.md
```

## Troubleshooting

### Error: Cannot connect to Codex MCP Server

**Cause**: Codex MCP Server is not configured or not running.

**Solution**:
1. Install Codex MCP Server
2. Add to Claude Code settings (`~/.claude/settings.json`)
3. Restart Claude Code

### Skill Not Triggering

**Cause**: Trigger keywords may not match.

**Solution**:
- Use explicit keywords: "codexでレビュー", "codex review"
- Try explicit invocation: `/codex`
- Check skill is installed: `/skills list`

### Poor Response Quality

**Cause**: Insufficient context or unclear request.

**Solution**:
- Provide more specific requests
- Mention relevant files or topics explicitly
- Add constraints (e.g., "focus on security")

## Best Practices

### For Better Results

1. **Be Specific**: "src/api/auth.tsのセキュリティをレビュー" vs "レビューして"
2. **Provide Context**: Mention relevant constraints or focus areas
3. **Review Output**: Always review Codex suggestions with project context

### For Code Reviews

- Commit or stage changes first for clearer diffs
- Review one logical change at a time
- Focus on specific areas when needed (security, performance, etc.)

### For Technical Research

- Mention current tech stack versions if relevant
- Specify implementation constraints
- Ask for code examples in your project's language

### For Documentation

- Ensure code is finalized before generating docs
- Specify target audience (API users, contributors, etc.)
- Check generated docs for accuracy and completeness

## License

MIT License - see [LICENSE](./LICENSE) file for details.

## Contributing

Contributions welcome! Please open an issue or PR in the [ccmp repository](https://github.com/gendosu/gendosu-claude-plugins).

## Support

For issues or questions:
- GitHub Issues: https://github.com/gendosu/gendosu-claude-plugins/issues
- Documentation: https://github.com/gendosu/gendosu-claude-plugins/tree/main/plugins/codex

## Related Skills

- **git-operations-specialist** (cccp plugin): Git operations and history analysis
- **review-support-codex** (command): PR-specific reviews with parallel execution
- **todo-task-run-codex** (command): Task execution with Codex integration
