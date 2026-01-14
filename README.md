# CCMP - Claude Code Marketplace

A collection of development utility plugins for Claude Code.

## Overview

CCMP (Claude Code Marketplace) is a monorepo containing productivity plugins for Claude Code. It provides skills and commands to streamline your daily development workflow.

## Available Plugins

<table>
<thead>
  <tr>
    <th>Plugin Name</th>
    <th>Description</th>
    <th>Type</th>
    <th>Feature Name</th>
    <th>Version</th>
    <th>Documentation</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td rowspan="7"><strong>CCCP</strong><br>(Claude Code Command Pack)</td>
    <td rowspan="7">Git operations specialist agents and micro-commit commands for test-driven development workflows</td>
    <td>Agent</td>
    <td>git-operations-specialist - Comprehensive Git operations (commit, branch, merge, conflict resolution)</td>
    <td rowspan="7">0.3.0</td>
    <td rowspan="7"><a href="./plugins/cccp/README.md">README</a></td>
  </tr>
  <tr>
    <td>Agent</td>
    <td>project-manager - Overall project management</td>
  </tr>
  <tr>
    <td>Command</td>
    <td>commit - Commit with staged changes</td>
  </tr>
  <tr>
    <td>Command</td>
    <td>micro-commit - Context-based micro-commit splitting</td>
  </tr>
  <tr>
    <td>Command</td>
    <td>todo-task-planning - Task planning execution</td>
  </tr>
  <tr>
    <td>Command</td>
    <td>todo-task-run - Execute tasks from TODO file and create PR</td>
  </tr>
  <tr>
    <td>Skill</td>
    <td>key-guidelines - Development guideline reference</td>
  </tr>
  <tr>
    <td rowspan="1"><strong>awesome-statusline</strong></td>
    <td rowspan="1">Claude Code statusline automatic setup skill</td>
    <td>Skill</td>
    <td>setup-statusline - Automatic statusline setup</td>
    <td rowspan="1">0.1.0</td>
    <td rowspan="1"><a href="./plugins/awesome-statusline/README.md">README</a></td>
  </tr>
  <tr>
    <td rowspan="1"><strong>codex</strong></td>
    <td rowspan="1">Codex MCP integration plugin - Code review, technical research, documentation generation</td>
    <td>Skill</td>
    <td>codex - Code review, technical research, documentation generation, custom queries</td>
    <td rowspan="1">0.1.1</td>
    <td rowspan="1"><a href="./plugins/codex/README.md">README</a></td>
  </tr>
</tbody>
</table>

## Installation

### Add Marketplace

```bash
/plugin marketplace add gendosu/ccmp
```

### Install Plugin

```bash
/plugin install cccp@gendosu-claude-plugins
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

**GENDOSU**

## Repository

[https://github.com/gendosu/ccmp](https://github.com/gendosu/ccmp)
