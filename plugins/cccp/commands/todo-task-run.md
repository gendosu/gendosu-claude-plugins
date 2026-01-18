---
description: Execute tasks from TODO file and create pull request [/todo-task-run xxx]
mode: run
arguments:
  - name: file_path
    type: string
    required: true
    description: Path to the TODO file to execute
  - name: no-pr
    description: Skip pull request creation (--no-pr)
    type: boolean
    required: false
  - name: no-push
    description: Skip git push operations (--no-push)
    type: boolean
    required: false
---

## context

- Pull Request Template
  @.github/PULL_REQUEST_TEMPLATE.md

## 📋 Development Rules

### 🚨 Lucas Rocha's micro-commit (Details: CLAUDE.md)
- One change per commit, strict adherence to test-driven change cycle

### Task Completion Procedure

**IMPORTANT**: When completing a task, be sure to follow these steps:

1. **Check task** - Change `- [ ]` to `- [x]`
2. **Document related files** - List names of created/modified files

## 📚 Reference Documentation

- [Related Documentation List](@docs)

## Core Guidelines

Before starting any task, read and follow `/cccp:key-guidelines`

## Command Overview

The `/cccp:todo-task-run` command is designed for **execution mode** - it takes a pre-existing TODO.md file and systematically executes the tasks defined within it.

### Role and Responsibility
- **Execution**: Execute tasks from TODO.md, manage git operations, create/update pull requests
- **Not for planning**: This command does NOT create tasks or convert requirements into actionable items
- **Task planning**: Use `/cccp:todo-task-planning` to convert requirements into a structured TODO.md before using this command

### Relationship with todo-task-planning
1. **Planning phase** (`/cccp:todo-task-planning`): Analyze requirements → Create TODO.md with actionable tasks
2. **Execution phase** (this command): Read TODO.md → Execute tasks → Track progress → Create PR

### Command Invocation
```
/cccp:todo-task-run TODO.md
/cccp:todo-task-run TODO.md --no-pr
/cccp:todo-task-run TODO.md --no-push
/cccp:todo-task-run TODO.md --no-pr --no-push
```

## Processing Flow

### Prerequisites

#### Input Contract
This command expects a TODO.md file with the following format:
- Tasks must be written as markdown checkboxes (`- [ ]` for incomplete, `- [x]` for complete)
- The file should contain actionable task items
- No strict schema validation is required - the command adapts to your task structure

### Initial Setup (Using Task Tool)
- Read TODO.md file specified in $ARGUMENTS
- Execute `git fetch -a -p`
- **Only when --no-pr flag is NOT specified**:
  - Create branch from origin/develop
  - Create empty commit with [skip ci]
  - If an open pull request is already linked to the issue
    - Review already implemented content and continue implementation
  - Create pull request (convert todos into checklist)
    - Pull request template: @.github/PULL_REQUEST_TEMPLATE.md
- **When --no-pr flag is specified**: Continue work on current branch as is

### Task Execution (Use separate Task Tool for each process)
- Recite the contents of `## 📋 Rules` before execution
- Execute each task sequentially
- **Additional steps for investigation tasks**:
  - Create `/docs/memory/investigation-YYYY-MM-DD-{topic}.md` file at investigation start
  - Record important findings and insights immediately to memory file even during investigation
  - Save technical patterns and reusable knowledge categorized in `/docs/memory/patterns/`
- **Required steps after each task completion**:
  1. Commit changes (with appropriate commit message)
     Use /cccp:micro-commit command
  2. **Only when --no-push flag is NOT specified**: Push to remote with `git push`
  3. **Only when --no-pr flag is NOT specified**: Update PR checklist (`- [ ]` → `- [x]`)
  4. **Update file specified in $ARGUMENTS**:
     - Change completed task from `- [ ]` to `- [x]`
     - Add related file information
     - Record implementation details and notes
  5. **Save investigation results**:
     - Consolidate and organize insights from investigation into memory file
     - Record technical discoveries and problem-solving methods for future reference
     - Include links to related documentation and reference materials
  6. Report implemented content and update results
- Repeat until no incomplete tasks remain
- Use return values from previously executed tasks appropriately for information needed for next task execution

### Error Handling and Investigation

When encountering errors or unexpected issues during task execution:

#### Hybrid Investigation Approach
1. **Reference existing memory files**: Check `/docs/memory/` for previous investigations on similar issues
2. **Investigate as needed**: If no relevant documentation exists or the issue is novel, conduct investigation
3. **Document findings**: Record new insights in appropriate memory files for future reference

#### Error Recovery Workflow
1. **Identify the error**: Understand the root cause through debugging or investigation
2. **Consult documentation**: Review existing memory files and reference documentation
3. **Resolve the issue**: Apply fixes based on documented patterns or new solutions
4. **Update memory**: If new patterns or solutions emerge, document them in `/docs/memory/patterns/`
5. **Continue execution**: Resume task execution after resolving the error

#### When to Create Memory Files
- **New technical patterns**: Document reusable solutions in `/docs/memory/patterns/`
- **Complex investigations**: Create investigation files when debugging takes significant effort
- **System insights**: Record important technical discoveries about the codebase or infrastructure

### Final Completion Process (Using Task Tool)
**Required steps upon all tasks completion**:
1. **Only when --no-push flag is NOT specified**: **Final push confirmation** - Confirm all changes are pushed to remote with `git push`
2. **Final update of file specified in $ARGUMENTS**:
   - Confirm all tasks are in completed state (`- [x]`)
   - Add completion date/time and overall implementation summary
   - Record reference information for future maintenance
3. **Final consolidation of investigation results**:
   - Final organization of all investigation results in memory file
   - Record project-wide impact and future prospects
   - Prepare in a form that can be utilized as reference information for similar tasks
4. **Only when --no-pr flag is NOT specified**:
   - **Update PR title/description**: Update to comprehensive description reflecting implementation content
     - Details of implemented features
     - Quality metrics (number of tests, coverage, etc.)
     - List of main changed files
     - Technical value and effectiveness
     - Summary of important insights from investigation
   - **Completion report comment**: Add detailed completion comment to pull request
   - **Final confirmation**: Present PR page URL and report review readiness
