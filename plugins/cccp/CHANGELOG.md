# Changelog

All notable changes to the CCCP plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 2026-01-31

### Added

- **git-operations-specialist**: Enhanced Japanese language support with additional trigger words
  - Added "コミット" (commit) trigger word
  - Added "プッシュ" (push) trigger word
  - Added "プルリク" (pull request, short form) trigger word
  - Added "プルリクエスト" (pull request, full form) trigger word

## [2.1.2] - 2026-01-29

### Changed

- **todo-task-run**: Enhanced task runner guidelines to emphasize delegation focus
  - Added explicit guidance to delegate individual work to sub-agents as much as possible
  - Refined critical execution policy description for clarity

## [2.1.1] - 2026-01-29

### Removed

- **todo-task-planning**: Removed obsolete backup file `commands/todo-task-planning.md.backup`
  - Cleanup of temporary backup file that is no longer needed

## [2.1.0] - 2026-01-29

### Added

- **todo-output-template**: New skill file for TODO.md output template examples
  - Complete 82-line template with structure documentation
  - Accessible via `/cccp:todo-output-template` command
  - Extracted from todo-task-planning.md for better maintainability (commit 02b3b5d)

### Changed

- **todo-task-planning**: Simplified documentation from 1,270 lines to 974 lines (23.3% reduction)
  - TypeScript implementation examples reduced by 79.6% (203 lines) while preserving conceptual patterns
    - Explore Agent example: 42→13 lines (commit c034686)
    - Plan Agent example: 115→15 lines (commit 623179a)
    - Project Manager Agent example: 98→24 lines (commit 24addd2)
  - Verification matrices consolidated from 4 matrices to 2 checklists (23 lines reduction) (commit 743665e)
  - Output template replaced with reference to new skill file (72 lines reduction) (commit e7cd820)
  - All critical sections preserved: Phase 0.5 requirements, security patterns, essential verification points

## [2.0.1] - 2026-01-28

### Fixed

- **todo-task-planning**: Phase 3 Step 9 (AskUserQuestion execution) now enforced by triple-layer verification mechanism
  - Layer 1: Enhanced execution conditions with clear IF-THEN-ELSE flow (commit 810d843)
  - Layer 2: Added Phase 4 entrance guard with mandatory checkpoint verification (commit 00e038b)
  - Layer 3: Added Phase 5 comprehensive validation framework with recovery procedures (commit 235035c)
- **todo-task-planning**: Prevented proceeding to Phase 4 without proper question processing
  - Phase 4 now includes entrance guard that blocks execution if AskUserQuestion was not executed
  - Added validation checkpoint requiring user_answered: true before TODO.md updates

## [2.0.0] - 2026-01-27

### Breaking Changes

- **todo-task-run**: Removed PR and git push functionality - now a pure generic task runner
  - Removed `--no-pr` and `--no-push` command arguments
  - Removed PR creation/update functionality (use `/cccp:pull-request` separately)
  - Removed git push operations from task execution workflow
  - Removed git fetch from initial setup
  - Removed `cccp:git-operations-specialist` agent type from classification rules
  - Removed `/cccp:micro-commit` usage from task completion procedures

### Changed

- **todo-task-run**: Simplified to focus purely on task execution
  - Description changed from "Execute tasks from TODO file and create pull request" to "Execute tasks from TODO file - Generic task runner"
  - Renamed "Management phase" to "Execution phase" in workflow documentation
  - Agent classification rules now only include Implementation Tasks and Investigation Tasks
  - Removed Task Execution Examples section (Git operations, implementation, investigation examples)
  - Simplified error recovery to focus on forward-only changes without commit references
  - Japanese labels changed to English (e.g., "Git操作タスク" → removed, "実装タスク" → "Implementation Tasks")

## [1.0.5] - 2026-01-26

### Changed

- **todo-task-planning**: Clarified file creation responsibility and timeline in Phase 0 and Phase 4
  - Added explicit separation of agent vs main executor responsibilities
  - Agents return data as variables (exploration_results, planning_results, strategic_plan)
  - Main Claude executor creates persistent docs/memory files in Phase 4 using Write tool
  - Added detailed file creation instructions in Phase 4 step 9
  - Added file verification procedures in Phase 0.5 with error recovery actions
  - Clarified that strategic_plan is not saved to disk (used as intermediate data)
  - Improved docs/memory files creation reporting requirements in Phase 5

## [1.0.4] - 2026-01-25

### Fixed

- **todo-task-planning**: Removed automatic git commit from planning phase
  - Removed Phase 4 Step 10 which executed cccp:micro-commit after TODO.md update
  - Planning command now focuses purely on task planning without git operations
  - Git operations remain the responsibility of todo-task-run command during task execution
  - Ensures planning commands don't modify git history unexpectedly

## [1.0.3] - 2026-01-24

### Fixed

- **todo-task-run**: Fixed critical issue where session would terminate prematurely with incomplete tasks remaining
  - Added explicit execution policy requiring continuation until ALL tasks are marked complete
  - Added mandatory TODO.md re-read and incomplete task check after each task completion
  - Added session continuation rules preventing premature termination
  - Added Final Completion Process prerequisite check to verify all tasks are complete
  - Added blocker resolution continuation procedure
  - Added execution guarantee documentation clarifying that all tasks will be executed
  - Tasks will now continue executing sequentially until completion or blocker is encountered

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

[2.0.1]: https://github.com/gendosu/gendosu-claude-plugins/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/gendosu/gendosu-claude-plugins/compare/v1.0.5...v2.0.0
[1.0.0]: https://github.com/gendosu/gendosu-claude-plugins/compare/v0.4.1...v1.0.0
[0.4.1]: https://github.com/gendosu/gendosu-claude-plugins/releases/tag/v0.4.1
