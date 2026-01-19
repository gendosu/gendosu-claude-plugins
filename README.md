# Gendosu Claude Plugins

A plugin marketplace that enhances development efficiency with Claude Code.

## 📦 Overview

Gendosu Claude Plugins is a monorepo providing productivity plugins for Claude Code. It offers skills and commands to streamline daily development work including test-driven development, Git operations, and project management.

## 🚀 Installation

### Install via Marketplace

1. Add the marketplace:
```bash
/plugin marketplace add gendosu/gendosu-claude-plugins
```

2. Install the plugin:
```bash
/plugin install cccp@gendosu-claude-plugins
```

## 📚 Available Plugins

<table>
  <thead>
    <tr>
      <th>Plugin</th>
      <th>Type</th>
      <th>Name</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="7"><strong>CCCP</strong><br>(Claude Code Command Pack)<br><a href="./plugins/cccp/README.md">📖 Details</a></td>
      <td>Agent</td>
      <td>git-operations-specialist</td>
      <td>Specialized Git operations handling (commit, branch, merge, conflict resolution)</td>
    </tr>
    <tr>
      <td>Agent</td>
      <td>project-manager</td>
      <td>Project management support (planning, progress tracking, task coordination, risk assessment, etc.)</td>
    </tr>
    <tr>
      <td>Command</td>
      <td>/cccp:commit</td>
      <td>Create commit with staged changes</td>
    </tr>
    <tr>
      <td>Command</td>
      <td>/cccp:micro-commit</td>
      <td>Split git diff into context-based micro-commits</td>
    </tr>
    <tr>
      <td>Command</td>
      <td>/cccp:todo-task-planning</td>
      <td>Execute task planning based on specified file and manage questions</td>
    </tr>
    <tr>
      <td>Command</td>
      <td>/cccp:todo-task-run</td>
      <td>Execute tasks from TODO file and create pull request</td>
    </tr>
    <tr>
      <td>Skill</td>
      <td>key-guidelines</td>
      <td>Core development principles and standards (DRY, KISS, YAGNI, SOLID, TDD, micro-commits)</td>
    </tr>
    <tr>
      <td rowspan="1"><strong>awesome-statusline</strong><br><a href="./plugins/awesome-statusline/README.md">📖 Details</a></td>
      <td>Skill</td>
      <td>setup-statusline</td>
      <td>Claude Code statusline automatic setup</td>
    </tr>
    <tr>
      <td rowspan="1"><strong>codex</strong><br><a href="./plugins/codex/README.md">📖 Details</a></td>
      <td>Skill</td>
      <td>codex</td>
      <td>Codex MCP integration - Code review, technical research, documentation generation, custom queries</td>
    </tr>
    <tr>
      <td rowspan="1"><strong>skill-creator</strong><br><a href="./plugins/skill-creator/README.md">📖 Details</a></td>
      <td>Skill</td>
      <td>skill-creator</td>
      <td>Comprehensive guide for creating effective Claude Code skills (design patterns, initialization, validation, packaging)</td>
    </tr>
  </tbody>
</table>

## 📝 License

MIT License

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 👤 Author

GENDOSU

## 🔗 Links

- [Marketplace Repository](https://github.com/gendosu/gendosu-claude-plugins)
