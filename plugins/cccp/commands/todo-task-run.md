---
description: Execute tasks from TODO file - Generic task runner [/todo-task-run xxx]
mode: run
arguments:
  - name: file_path
    type: string
    required: true
    description: Path to the TODO file to execute
---

## 📋 Development Rules

### 🚨 Guardrails (Prohibited Actions)

**CRITICAL - Forward-Only Policy:**
- ❌ **NEVER use `git reset`, `git restore`, `git revert`, or any rollback commands**
- ✅ **Always move forward**: Fix errors with new changes, not by undoing previous ones

### Task Completion Procedure

**IMPORTANT**: When completing a task, be sure to follow these steps:

1. **Update checkbox immediately after task execution** - Change `- [ ]` to `- [x]` to mark completion
2. **Document related files** - List names of created/modified files

## 📚 Reference Documentation

- [Related Documentation List](@docs)

## Core Guidelines

Before starting any task, read and follow `/cccp:key-guidelines`

## Command Overview

The `/cccp:todo-task-run` command is designed as a **generic task runner** - it takes a pre-existing TODO.md file and systematically executes ALL tasks defined within it until completion.

### Role and Responsibility
- **Complete Execution**: Execute ALL tasks in TODO.md sequentially until every task is marked `- [x]`
- **Progress Management**: Orchestrate task execution, manage progress, and coordinate the overall workflow
- **Continuous Operation**: Continue executing tasks until completion or blocker - NEVER stop prematurely
- **Not for planning**: This command does NOT create tasks or convert requirements into actionable items
- **Task planning**: Use `/cccp:todo-task-planning` to convert requirements into a structured TODO.md before using this command
- **Task Runner Focus**: Act as a task runner, delegating individual work to sub-agents as much as possible

### Execution Guarantee
This command guarantees:
1. ✅ **Every task will be executed** in sequential order
2. ✅ **No tasks will be skipped** unless explicitly blocked
3. ✅ **Session continues until all tasks are complete** or a blocker is encountered
4. ✅ **Incomplete tasks will NOT be left unfinished** without user awareness

### Relationship with todo-task-planning
1. **Planning phase** (`/cccp:todo-task-planning`): Analyze requirements → Create TODO.md with actionable tasks
2. **Execution phase** (this command): Orchestrate task execution → Manage progress → Integrate completion status → Coordinate overall workflow

### Command Invocation
```
/cccp:todo-task-run TODO.md
```

## Processing Flow

**⚠️ CRITICAL EXECUTION POLICY**:

This command MUST execute ALL tasks in TODO.md sequentially, completing every task:
- ✅ **Execute tasks one by one** in the order they appear
- ✅ **After each task completion, check for remaining incomplete tasks**
- ✅ **Continue executing until ALL tasks are marked `- [x]`**
- ❌ **NEVER end the session while incomplete tasks remain**
- ❌ **NEVER skip tasks unless explicitly blocked**

**Session Continuation Rule**:
The session ONLY ends when ONE of these conditions is met:
1. ✅ All tasks in TODO.md are marked `- [x]` (complete)
2. 🚧 A task is blocked and requires user intervention
3. ❌ An unrecoverable error occurs

### Prerequisites

#### Input Contract
This command expects a TODO.md file with the following format:
- Tasks must be written as markdown checkboxes (`- [ ]` for incomplete, `- [x]` for complete)
- The file should contain actionable task items
- No strict schema validation is required - the command adapts to your task structure

### Initial Setup (Using Task Tool)
- Read TODO.md file specified in $ARGUMENTS
- **Classify each task by agent type**:
  - Scan task descriptions for keywords (explore, investigate, implement, etc.)
  - Pre-determine agent type for each task based on Agent Classification Rules
  - Identify task dependencies (which tasks need results from previous tasks)
  - Log classification results for transparency

### Agent Classification Rules

When executing tasks, select the appropriate agent based on task characteristics:

- **Implementation Tasks** (implement, add, create, update features) → Use general-purpose agent
  - Examples: Adding new features, modifying existing code, creating files
  - Standard implementation work without specific agent requirements

- **Investigation Tasks** (explore, investigate, research) → Use `Explore` agent
  - Examples: Codebase exploration, finding files, analyzing patterns
  - Specialized in comprehensive codebase analysis and discovery

### Memory File Initialization

**CRITICAL**: Before starting task execution, initialize memory system:

#### 1. Variable Initialization
At the start of task execution, declare context accumulation variables:
```
TASK_CONTEXT = {}  # Store context across tasks
MEMORY_FILES = {}  # Track active memory file paths
INVESTIGATION_FINDINGS = []  # Accumulate investigation results
```

#### 2. Progress Tracking File Creation
Create `/docs/memory/todo-task-run-progress.md` immediately when tasks begin:
- **Timing**: Create at the start of first task execution
- **Purpose**: Track task execution history, decisions, and context across the entire workflow
- **Content**: Record task status, implementation notes, blockers, and cross-task dependencies

#### 3. Load Existing Memory Files
Before executing any task, check and load relevant existing memory files:
- **Planning files**: `/docs/memory/planning/*.md` - Contains task breakdown and strategy
- **Exploration files**: `/docs/memory/explorations/*.md` - Contains codebase analysis results
- **Pattern files**: `/docs/memory/patterns/*.md` - Contains reusable technical patterns
- **Investigation files**: `/docs/memory/investigation-*.md` - Contains previous problem-solving insights

#### 4. Context Accumulation Strategy
As tasks progress:
- Store task execution results in `TASK_CONTEXT` for use in subsequent tasks
- Reference previous task outputs to inform current task decisions
- Update progress file with new learnings and context changes
- Link related memory files to build comprehensive understanding

### Task Execution: Sequential Task Tool Orchestration

**⚠️ CRITICAL: Sequential Execution Pattern Required**

All tasks MUST be executed sequentially using the Task tool. Each task's results inform the next task's context.

#### Execution Pattern Overview

```typescript
// Sequential execution pattern
const task_1_result = await Task({ subagent_type: "[agent_type]", ... });
// ⚠️ WAIT for task_1 to complete, THEN proceed
const task_2_result = await Task({ subagent_type: "[agent_type]", ... });
// ⚠️ WAIT for task_2 to complete, THEN proceed
const task_3_result = await Task({ subagent_type: "[agent_type]", ... });

// ❌ WRONG: Parallel execution (DO NOT DO THIS)
Promise.all([
  Task({ subagent_type: "...", ... }),
  Task({ subagent_type: "...", ... })  // Tasks must be sequential!
]);
```

#### Task Classification and Agent Selection

Before executing each task, determine the appropriate agent based on task characteristics (see "Agent Classification Rules" section):

- **Implementation Tasks** → `subagent_type: "general-purpose"` (or omit parameter)
- **Investigation Tasks** → `subagent_type: "Explore"`

#### Task Tool Execution Template

For each incomplete task (`- [ ]`) in TODO.md, execute using this pattern:

```typescript
const task_N_result = await Task({
  subagent_type: "[determined_agent_type]",  // From classification rules
  description: "Execute task N: [task title from TODO.md]",
  prompt: `
    ## 📋 Development Rules (MUST Follow)

    ### 🚨 Guardrails (Prohibited Actions)
    **CRITICAL - Forward-Only Policy:**
    - ❌ NEVER use \`git reset\`, \`git restore\`, \`git revert\`, or any rollback commands
    - ✅ Always move forward: Fix errors with new changes, not by undoing previous ones

    ### Task Completion Procedure
    1. Update checkbox immediately after task execution (\`- [ ]\` → \`- [x]\`)
    2. Document related files (list names of created/modified files)

    ## Task Context
    **Current Task:** [Full task description from TODO.md]
    **Task Number:** N of [total_tasks]
    **Target File:** ${$ARGUMENTS}

    ## Previous Task Results
    ${task_N-1_result?.summary || "This is the first task"}
    ${task_N-1_result?.files_modified || ""}
    ${task_N-1_result?.key_findings || ""}

    ## Memory Files
    - Progress: /docs/memory/todo-task-run-progress.md
    ${MEMORY_FILES.planning || ""}
    ${MEMORY_FILES.exploration || ""}
    ${MEMORY_FILES.patterns || ""}

    ## Task-Specific Instructions

    ### For Investigation Tasks (Explore agent):
    1. Create investigation memory file at start:
       - Path: \`/docs/memory/investigation-YYYY-MM-DD-{topic}.md\`
       - Record findings immediately during investigation
       - Save technical patterns in \`/docs/memory/patterns/\`
    2. Document discoveries and insights for future reference
    3. Include links to related documentation

    ### For Implementation Tasks (General-purpose agent):
    1. Follow existing code patterns discovered in exploration
    2. Adhere to YAGNI principle (implement only what's necessary)
    3. Reference memory files for context and technical patterns
    4. Update implementation status in progress memory file

    ## Required Steps After Task Completion

    1. **Update TODO.md file** (${$ARGUMENTS})
       - Change completed task: \`- [ ]\` → \`- [x]\`
       - Add related file information below task
       - Record implementation details and notes
       - Format example:
         \`\`\`markdown
         - [x] Task title
           - Files: \`path/to/file1.rb\`, \`path/to/file2.rb\`
           - Notes: Brief description of implementation
         \`\`\`

    2. **Save investigation results** (for investigation tasks)
       - Consolidate insights in investigation memory file
       - Record technical discoveries for future reference
       - Link to related documentation and patterns

    3. **Update progress memory file**
       - Record task completion status in \`/docs/memory/todo-task-run-progress.md\`
       - Note any blockers, decisions, or context changes
       - Accumulate learnings for next task

    4. **Report results**
       - Summarize changes made
       - List modified/created files with absolute paths
       - Note any issues or blockers encountered
       - Provide context for next task

    ## Expected Output Format

    Return structured results for context accumulation:

    \`\`\`typescript
    {
      summary: "Brief description of what was accomplished",
      files_modified: ["absolute/path/to/file1", "absolute/path/to/file2"],
      key_findings: "Important discoveries or decisions (for investigation tasks)",
      blockers: "Any issues encountered (if applicable)",
      context_for_next_task: "Information needed by subsequent tasks"
    }
    \`\`\`
  `
});
```

#### Context Accumulation Between Tasks

**Critical Pattern**: Each task's results must be passed to the next task through the `prompt` parameter.

```typescript
// Task 1
const task_1_result = await Task({
  subagent_type: "Explore",
  description: "Investigate codebase for feature X",
  prompt: `[instructions]`
});

// Task 2 receives task_1_result in context
const task_2_result = await Task({
  subagent_type: "general-purpose",
  description: "Implement feature X based on investigation",
  prompt: `
    ## Previous Task Results
    ${task_1_result.summary}

    Files discovered: ${task_1_result.files_modified.join(', ')}
    Key findings: ${task_1_result.key_findings}

    [rest of task 2 instructions]
  `
});
```

#### Verification Gates After Each Task

**⚠️ MANDATORY**: After each Task tool execution, verify success before proceeding:

```typescript
const task_N_result = await Task({ ... });

// Verification gate
if (!task_N_result || task_N_result.blockers) {
  // Handle error:
  // 1. Mark task with 🚧 in TODO.md
  // 2. Record blocker in progress memory file
  // 3. Report to user with details
  // 4. STOP execution until blocker is resolved

  throw new Error(`Task N blocked: ${task_N_result.blockers}`);
}

// Verify expected outputs exist
if (!task_N_result.summary || !task_N_result.files_modified) {
  // Task completed but didn't return expected format
  // Log warning but continue if non-critical
}

// ✅ Verification passed, proceed to next task
const task_N+1_result = await Task({ ... });
```

#### Error Handling Protocol

When a task encounters an error or blocker:

**CRITICAL - Forward-Only Error Recovery:**
- ❌ **NEVER use `git reset`, `git restore`, `git revert`** to undo errors
- ✅ **Create new changes to fix errors** - Keep the history transparent
- ✅ **If code is broken, fix it forward** - Add corrections, don't erase mistakes

**Error Recovery Steps:**

1. **Mark task status in TODO.md**:
   ```markdown
   - [ ] 🚧 Task title (BLOCKED: reason for blockage)
   ```

2. **Record in progress memory file**:
   ```markdown
   ## Task N - BLOCKED
   - **Blocker**: [Detailed description]
   - **Attempted solutions**: [What was tried]
   - **Next steps**: [How to resolve]
   - **Recovery approach**: Fix with new changes, not rollback
   ```

3. **Report to user**:
   - Clear description of the blocker
   - Impact on subsequent tasks
   - Recommended resolution steps
   - Plan for forward-only fix

4. **STOP execution**:
   - DO NOT proceed to next task
   - DO NOT rollback changes
   - Wait for user intervention or blocker resolution

5. **After blocker resolution**:
   - Once the user resolves the blocker or provides guidance
   - Re-read TODO.md to check current task status
   - If task is now unblocked, resume execution from that task
   - Continue with normal Task Execution Loop
   - **IMPORTANT**: DO NOT skip remaining tasks - continue until ALL tasks are complete

#### Task Execution Loop

Repeat the Task tool pattern for each incomplete task until:
- All tasks are marked `- [x]` (completed), OR
- A task is blocked with `🚧` marker (stop and report)

**Execution Flow**:
1. Read TODO.md and identify next incomplete task (`- [ ]`)
2. Classify task and determine `subagent_type`
3. Execute Task tool with accumulated context
4. Verify task completion (verification gate)
5. Update TODO.md status (`- [ ]` → `- [x]`)
6. Store task result for next task's context
7. **CRITICAL: After each task completion, IMMEDIATELY re-read TODO.md and check for remaining incomplete tasks**
8. **If ANY incomplete tasks remain (`- [ ]`), IMMEDIATELY continue to next task (return to step 1)**
9. **ONLY proceed to "Final Completion Process" when ALL tasks are marked `- [x]`**

**⚠️ MANDATORY CONTINUATION CHECK**:

After completing EACH task, you MUST:
```typescript
// After task_N execution and TODO.md update
const todo_content = await Read({ file_path: $ARGUMENTS });
const has_incomplete_tasks = todo_content.includes('- [ ]');

if (has_incomplete_tasks) {
  // ✅ Continue to next task immediately
  // DO NOT proceed to Final Completion Process
  // DO NOT end the session
  const next_task_result = await Task({ ... });
} else {
  // ✅ All tasks complete - proceed to Final Completion Process
  // Only now can you proceed to final steps
}
```

**Session Continuation Rules**:
- ❌ **NEVER end the session while incomplete tasks (`- [ ]`) remain in TODO.md**
- ❌ **DO NOT proceed to "Final Completion Process" if ANY task is incomplete**
- ✅ **ALWAYS re-read TODO.md after each task to check for incomplete tasks**
- ✅ **IMMEDIATELY continue to next task if incomplete tasks exist**
- ✅ **ONLY proceed to final steps when ALL tasks are marked `- [x]`**

### Error Handling and Investigation

When encountering errors or unexpected issues during task execution:

**CRITICAL - Forward-Only Error Recovery:**
- ❌ **NEVER use `git reset`, `git restore`, `git revert`** to undo errors
- ✅ **Always fix forward with new changes** - Preserve complete history
- ✅ **Document the fix** - Record why the error occurred and how it was resolved

#### Hybrid Investigation Approach
1. **Reference existing memory files**: Check `/docs/memory/` for previous investigations on similar issues
2. **Investigate as needed**: If no relevant documentation exists or the issue is novel, conduct investigation
3. **Document findings**: Record new insights in appropriate memory files for future reference

#### Error Recovery Workflow
1. **Identify the error**: Understand the root cause through debugging or investigation
2. **Consult documentation**: Review existing memory files and reference documentation
3. **Resolve the issue**: Apply fixes based on documented patterns or new solutions
   - **IMPORTANT**: Create new changes for fixes, do not rollback
4. **Update memory**: If new patterns or solutions emerge, document them in `/docs/memory/patterns/`
   - Record what went wrong and how it was fixed
   - Document lessons learned for future tasks
5. **Continue execution**: Resume task execution after resolving the error

#### When to Create Memory Files
- **New technical patterns**: Document reusable solutions in `/docs/memory/patterns/`
- **Complex investigations**: Create investigation files when debugging takes significant effort
- **System insights**: Record important technical discoveries about the codebase or infrastructure

### Final Completion Process (Using Task Tool)

**⚠️ CRITICAL PREREQUISITE CHECK**:

Before proceeding to this section, you MUST verify:
```typescript
const todo_content = await Read({ file_path: $ARGUMENTS });
const has_incomplete_tasks = todo_content.includes('- [ ]');

if (has_incomplete_tasks) {
  // ❌ STOP - Cannot proceed to Final Completion Process
  // ✅ Return to Task Execution Loop immediately
  throw new Error("Cannot proceed to Final Completion Process - incomplete tasks remain in TODO.md");
}

// ✅ All tasks complete - safe to proceed
```

**ONLY proceed with final completion steps if ALL of these conditions are met**:
1. ✅ All tasks in TODO.md are marked `- [x]` (NO `- [ ]` remains)
2. ✅ No tasks are blocked with `🚧` marker
3. ✅ Task execution loop has completed fully

**Required steps upon all tasks completion**:
1. **Final update of file specified in $ARGUMENTS**:
   - Confirm all tasks are in completed state (`- [x]`)
   - Add completion date/time and overall implementation summary
   - Record reference information for future maintenance
2. **Final consolidation of investigation results**:
   - Final organization of all investigation results in memory file
   - Record project-wide impact and future prospects
   - Prepare in a form that can be utilized as reference information for similar tasks

**Final Report to User**:

After completing all final steps, provide a comprehensive summary:
- ✅ Total tasks completed: [N] out of [N]
- ✅ All tasks status: Complete
- ✅ Files modified: [List of all files]
- ✅ Next steps: [If applicable]
