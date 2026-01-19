# CCCP - Claude Code Command Pack

A plugin for Claude Code that provides Git operations specialist agent, Git workflow commands, and task planning and execution workflow (todo-task-planning/todo-task-run).

## Overview

This plugin provides Claude Code with an integrated development support centered on task planning and execution workflow (todo-task-planning/todo-task-run), complemented by Git operation commands:

| Feature | Type | Description | Options |
|---------|------|-------------|---------|
| **git-operations-specialist** | Agent | Expert Git operations including history analysis, conflict resolution, branch strategy, and GitHub CLI operations | - |
| **project-manager** | Agent | Project management and task organization specialist | - |
| **commit** | Command | Commit staged changes with appropriate commit messages | - |
| **micro-commit** | Command | Create fine-grained commits following Lucas Rocha's micro-commit methodology | - |
| **pull-request** | Command | Create or update pull requests for the current branch | `<issue-number>` - Specify issue number |
| **todo-task-planning** | Command | Plan and organize tasks with todo lists | `<filepath>` - TODO file path<br>`--pr` - Create PR<br>`--branch [name]` - Create branch |
| **todo-task-run** | Command | Execute planned tasks from todo lists | `<filepath>` - TODO file path<br>`--no-pr` - Skip PR creation |

## Prerequisites

- [Claude Code](https://claude.com/claude-code) installed
- Git (version 2.0 or higher)
- [GitHub CLI (gh)](https://cli.github.com/) for GitHub operations

## Installation

Run the following commands in Claude Code to add the gendosu-claude-plugins marketplace and install the CCCP plugin:

**Step 1: Add gendosu-claude-plugins marketplace**
```bash
/plugin marketplace add gendosu/gendosu-claude-plugins
```

**Step 2: Install CCCP plugin**
```bash
/plugin install cccp@gendosu-claude-plugins
```

Alternatively, use the interactive interface:
```bash
/plugin
```

Search for `cccp` in the `Discover` tab and install it.

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

#### Todo Task Workflow

This plugin provides a two-phase workflow for task management:

**Phase 1: Planning (`/cccp:todo-task-planning`)**
- Analyze requirements and convert them into actionable tasks
- Create structured TODO.md with checkbox-based task lists
- Use TDD methodology to break down complex requirements
- Define clear task dependencies and priorities

**Phase 2: Execution (`/cccp:todo-task-run`)**
- Execute tasks from pre-created TODO.md file
- Manage git operations (branch creation, commits, pushes)
- Create and update pull requests with task progress
- Track completion by updating checkbox status

**Workflow Diagram:**
```
Requirements → /cccp:todo-task-planning → TODO.md → /cccp:todo-task-run → Pull Request
```

**Implementation Example:**

**Step 1: Create TODO.md** - Write down what you want to do
```markdown
Change email field name to account on login page
```

**Step 2: Run task planning**
```bash
/cccp:todo-task-planning TODO.md
```
This command analyzes the requirements and automatically generates an executable task list.

**Step 3: Run task execution**
```bash
/cccp:todo-task-run TODO.md
```
This command executes the generated tasks.

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
/cccp:commit                           # Commit staged changes
/cccp:micro-commit                     # Create fine-grained commits
/cccp:pull-request                     # Create or update pull request
/cccp:pull-request 123                 # Create PR linked to issue #123

# Two-phase task workflow:
/cccp:todo-task-planning TODO.md       # Phase 1: Plan and create TODO.md
/cccp:todo-task-run TODO.md            # Phase 2: Execute tasks from TODO.md
/cccp:todo-task-run TODO.md --no-pr    # Execute without creating PR
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
