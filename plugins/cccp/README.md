# CCCP - Claude Code Command Pack

A plugin for Claude Code that provides Git operations specialist agent and various Git workflow commands.

## Overview

This plugin extends Claude Code with powerful Git workflow tools:

- **git-operations-specialist agent**: Expert Git operations including history analysis, conflict resolution, branch strategy, and GitHub CLI operations
- **project-manager agent**: Project management and task organization specialist
- **commit command**: Commit staged changes with appropriate commit messages
- **micro-commit command**: Create fine-grained commits following Lucas Rocha's micro-commit methodology
- **pull-request command**: Create or update pull requests for the current branch
- **todo-task-planning command**: Plan and organize tasks with todo lists
- **todo-task-run command**: Execute planned tasks from todo lists

## Prerequisites

- [Claude Code](https://claude.com/claude-code) installed
- Git (version 2.0 or higher)
- [GitHub CLI (gh)](https://cli.github.com/) for GitHub operations

## Installation

1. Clone this repository or download the plugin files:
```bash
git clone https://github.com/gendosu/cccp.git
```

2. Install the plugin in Claude Code:
```bash
# Copy the plugin to Claude Code's plugins directory
cp -r cccp ~/.claude/plugins/
```

3. Restart Claude Code to load the plugin

## Features

### Git Operations Specialist Agent

The `git-operations-specialist` agent provides:

- **Git History Analysis**: Analyze commit history, branch relationships, and file changes
- **Conflict Resolution**: Guide through merge conflicts with appropriate strategies
- **Branch Strategy**: Recommend and implement branching workflows (GitFlow, GitHub Flow)
- **Advanced Git Operations**: Interactive rebase, cherry-picking, stash management, reflog operations
- **GitHub CLI Operations**: PR creation/management, issue tracking, API operations

### Commands

#### Commit Command (`/commit`)
- Commit staged changes with appropriate commit messages
- Follows conventional commit format and project guidelines

#### Micro-Commit Command (`/micro-commit`)
- Create fine-grained commits following test-driven development cycles
- Group related changes logically
- Maintain clean and meaningful commit history
- Follow one change per commit principle

#### Pull Request Command (`/pull-request`)
- Create new pull requests for the current branch
- Update existing pull requests with latest changes
- Link pull requests to GitHub issues
- Automatically generate PR titles and descriptions

#### Todo Task Commands (`/todo-task-planning`, `/todo-task-run`)
- Plan and organize complex tasks
- Execute tasks with proper tracking
- Maintain task lists and progress

## Usage

### Using the Git Operations Specialist

The agent is automatically invoked when you request Git-related assistance:

```
"Analyze the git history for this feature branch"
"Help me resolve this merge conflict"
"Create a pull request for the current branch"
"Suggest a branching strategy for this project"
```

### Using Commands

Invoke any command by using the slash command syntax:

```
/commit              # Commit staged changes
/micro-commit        # Create fine-grained commits
/pull-request        # Create or update pull request
/pull-request 123    # Create PR linked to issue #123
/todo-task-planning  # Plan tasks with todo list
/todo-task-run       # Execute planned tasks
```

## Project Structure

```
cccp/
├── .claude-plugin/
│   └── plugin.json                    # Plugin configuration
├── agents/
│   ├── git-operations-specialist.md   # Git operations agent
│   └── project-manager.md             # Project management agent
├── commands/
│   ├── commit.md                      # Commit command
│   ├── micro-commit.md                # Micro-commit command
│   ├── pull-request.md                # Pull request command
│   ├── todo-task-planning.md          # Task planning command
│   └── todo-task-run.md               # Task execution command
├── skills/
│   └── key-guidelines/
│       └── SKILL.md                   # Core guidelines skill
├── LICENSE                            # MIT License
└── README.md                          # This file
```

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Based on Git best practices and workflows
- Implements Lucas Rocha's micro-commit methodology
- Designed for Claude Code plugin ecosystem
