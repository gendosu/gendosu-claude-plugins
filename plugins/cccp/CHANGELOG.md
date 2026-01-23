# Changelog

All notable changes to the CCCP plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-01-23

### Fixed

- **todo-task-planning**: Fixed critical issue where AskUserQuestion tool was not being executed despite being documented as mandatory
  - Added explicit Phase 3 step 9: "AskUserQuestion Tool Execution (MANDATORY BEFORE PHASE 4)"
  - Added mandatory precondition to Phase 4 requiring all questions to be answered before proceeding
  - Added AskUserQuestion execution verification in Phase 5 (steps 11 and 12)
  - Questions will now always be presented to users via AskUserQuestion tool instead of only being written to TODO files
  - User responses will be recorded in `docs/memory/questions/YYYY-MM-DD-[feature]-answers.md`

## [1.0.0] - 2026-01-18

### Breaking Changes

- **todo-task-run**: Removed planning functionality from execution command
  - Planning responsibilities moved exclusively to `todo-task-planning` command
  - `todo-task-run` now focuses solely on executing pre-created TODO.md files
  - Users must use two-phase workflow: planning → execution

### Changed

- **todo-task-run**: Clarified execution-only mode with explicit `mode: run` declaration
- **todo-task-run**: Removed Task Creation section and TDD conversion guidelines
- **todo-task-run**: Removed Investigation Results Storage Guidelines section
- **todo-task-run**: Simplified setup procedure to focus on TODO.md input contract

### Added

- **todo-task-run**: Command Overview section explaining execution mode and relationship with todo-task-planning
- **todo-task-run**: Prerequisites section documenting TODO.md input contract
- **todo-task-run**: Error Handling section with hybrid investigation approach
- **README**: Two-phase workflow documentation with clear planning/execution separation
- **README**: Workflow diagram showing complete task lifecycle

### Removed

- **todo-task-run**: Planning-related guidelines (moved to todo-task-planning)
- **todo-task-run**: Investigation guidelines (replaced with hybrid approach in Error Handling)

## [0.4.1] - 2025-01-XX

### Added

- Initial version with git-operations-specialist agent
- commit, micro-commit, pull-request commands
- todo-task-planning and todo-task-run commands
- project-manager agent
- key-guidelines skill

[1.0.0]: https://github.com/gendosu/gendosu-claude-plugins/compare/v0.4.1...v1.0.0
[0.4.1]: https://github.com/gendosu/gendosu-claude-plugins/releases/tag/v0.4.1
