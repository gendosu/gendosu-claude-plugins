---
description: Execute task planning based on the specified file and manage questions[/cccp:todo-task-planning file_path --pr --branch branch_name]
mode: plan
arguments:
  - name: file_path
    type: string
    required: true
    description: Path to the file for task planning execution
  - name: pr
    type: boolean
    required: false
    description: Create a pull request after task completion. When specified, tasks will include branch creation (auto-generated if --branch not specified), commits, and PR creation
  - name: branch
    type: string
    required: false
    description: Branch name to create and use for task execution. Creates the specified branch and commits all changes to it. Can be used independently or with --pr option
---

## 🎯 Command Overview

This command reads the specified file ($ARGUMENTS) and performs comprehensive task planning.
It can be executed repeatedly on the same file and also manages, confirms, and updates questions.

**Important**: This command is designed to be executed repeatedly.
Do not question the fact that the same command will be executed multiple times; analyze and plan with a fresh perspective each time.

**Important**: The file specified in $ARGUMENTS will be the TODO management file.
Avoid including specifications and research results in this file as much as possible; use docs/memory to store research results.
Also, do not excessively abbreviate research results; retain them.
Check each time whether you have researched something in the past.
Do not neglect checking to avoid duplicating research results and tasks.

## 🔀 Branch and PR Options Usage

### Option Behavior

**`--branch [branch_name]` option:**
- **Adds a branch creation task at the beginning of the task list**
- If `branch_name` is provided: Uses the specified branch name
- If `branch_name` is omitted: Auto-generates branch name following Git naming conventions
- All commits during task execution will be made to this branch
- Can be used independently without `--pr`
- Useful when you want to work on a feature branch but don't need a PR yet

**Branch name auto-generation rules:**
- Analyzes TODO file content to determine branch type and purpose
- Follows Git naming conventions: `{type}/{descriptive-name}`
- Types: `feature/`, `bugfix/`, `refactor/`, `chore/`, `docs/`
- Format: lowercase, hyphen-separated, English
- Example: `feature/actionlog-email-notification`

**`--pr` option:**
- Includes all `--branch` functionality (branch creation and commits)
- **Adds a pull request creation task at the end of the task list**
- If `--branch` is not specified, a branch name will be auto-generated
- The PR will include all changes made during task execution
- If PR template instructions exist in CLAUDE.md or similar files, those templates will be used

### Usage Examples

```bash
# Example 1: Create branch with auto-generated name (no PR)
/cccp:todo-task-planning TODO.md --branch
# → Generates branch name like: feature/actionlog-notification

# Example 2: Create branch with specific name (no PR)
/cccp:todo-task-planning docs/todos/feature-x.md --branch feature/user-auth

# Example 3: Create PR with auto-generated branch name
/cccp:todo-task-planning docs/todos/feature-x.md --pr
# → Auto-generates branch name and creates PR

# Example 4: Create PR with specific branch name
/cccp:todo-task-planning docs/todos/feature-x.md --pr --branch feature/user-auth

# Example 5: Basic task planning (no branch, no PR)
/cccp:todo-task-planning docs/todos/feature-x.md
```

### Implementation Guidance

When these options are specified, the task planning should include:

**For `--branch` option:**
- **Branch Name Determination:**
  - If branch name is provided: Use as-is (validate against naming conventions)
  - If branch name is omitted: Auto-generate following this logic:
    1. Read TODO file title and content
    2. Determine branch type based on task nature:
       - `feature/` - New functionality implementation
       - `bugfix/` - Bug fixes, issue resolution
       - `refactor/` - Code restructuring without behavior change
       - `chore/` - Development environment, dependencies, tooling
       - `docs/` - Documentation updates
    3. Extract key feature/issue name from TODO (2-4 words max)
    4. Convert to lowercase, hyphen-separated English
    5. Format: `{type}/{descriptive-name}`
    6. Example: "ActionLog Email Notification" → `feature/actionlog-email-notification`
- Task to create the determined/generated branch at the beginning
- All modification tasks should indicate they will be committed to this branch
- No PR-related tasks

**For `--pr` option:**
- Task to create a branch (using specified name or auto-generated)
- All modification tasks with commit instructions
- Final task to create a pull request with proper description
- PR description should summarize all changes made

## 📚 Reference Documentation

- [Related Document List](@docs)

## Core Guidelines

Before starting any task, read and follow `/cccp:key-guidelines`

## 🚨 Important Implementation Requirements

**Optional**: This command can directly update the $ARGUMENTS file (the file specified as a parameter)
- **Main Claude executor** (not an agent) uses MultiEdit or Edit tool to update files
- After calling agents in Phase 0, update the $ARGUMENTS file with those results in Phase 4
- Add new task planning results in a structured format while preserving existing content
- After file update is complete, confirm, verify, and report the updated content

## 🔄 Processing Flow

### Phase 0: Multi-Agent Orchestration (Main Claude Executor)

**⚠️ CRITICAL: Sequential Execution Required**

The agents in Phase 0 MUST be executed in the following order:
1. Phase 0.1: TODO File Reading
2. Phase 0.2: Explore Agent
3. Phase 0.3: Plan Agent
4. Phase 0.4: cccp:project-manager Agent
5. Phase 0.5: Verification

**DO NOT execute agents in parallel.** Each phase depends on the results of the previous phase:
- Phase 0.3 (Plan) requires `exploration_results` from Phase 0.2 (Explore)
- Phase 0.4 (cccp:project-manager) requires both `exploration_results` and `planning_results`

**Execution Pattern:**
```typescript
// ✅ CORRECT: Sequential execution
const exploration_results = await Task({ subagent_type: "Explore", ... });
// Wait for Explore to complete, THEN proceed
const planning_results = await Task({ subagent_type: "Plan", ... });
// Wait for Plan to complete, THEN proceed
const strategic_plan = await Task({ subagent_type: "cccp:project-manager", ... });

// ❌ WRONG: Parallel execution (DO NOT DO THIS)
Promise.all([
  Task({ subagent_type: "Explore", ... }),
  Task({ subagent_type: "Plan", ... })  // Plan cannot start before Explore completes!
]);
```

#### Phase 0.1: TODO File Reading and Context Extraction

1. **Reading $ARGUMENTS File**
   - Read the specified file with Read tool
   - Extract information on tasks, requirements, and tech stack
   - Determine exploration thoroughness (quick/medium/very thorough)

2. **Git Workflow Options Preparation**
   - Check `--branch` and `--pr` options from command-line arguments
   - Prepare the following variables (used in subsequent agent calls):
     - `HAS_BRANCH_OPTION`: true if `--branch` option is specified
     - `HAS_PR_OPTION`: true if `--pr` option is specified
     - `BRANCH_NAME`: Branch name (as-is if specified, auto-generated in next step if not)
     - `IS_AUTO_GENERATED`: true if branch name was auto-generated

3. **Branch Name Generation (if --branch option specified without value)**
   - Read TODO file title and overview
   - Determine branch type:
     - `feature/` - New functionality (default for most implementations)
     - `bugfix/` - Bug fixes mentioned in TODO
     - `refactor/` - Code restructuring mentioned
     - `chore/` - Tooling, dependencies, environment setup
     - `docs/` - Documentation-focused tasks
   - Extract key feature name (2-4 words)
   - Convert to lowercase, hyphen-separated English
   - Validate against Git naming conventions
   - Set generated branch name to `BRANCH_NAME` variable and set `IS_AUTO_GENERATED = true`
   - Example: "ActionLog通知実装" → `feature/actionlog-notification`

4. **Context Preparation for Exploration**
   - Identify feature areas and related keywords
   - Determine exploration scope (file patterns, directories)
   - Check existing docs/memory research results (to avoid duplicate research)

#### Phase 0.2: Calling Explore Agent

**Purpose**: Discover related files, patterns, and dependencies through comprehensive codebase exploration

**Task tool execution example**:
```typescript
// Conceptual example - Explore agent for codebase investigation
const exploration_result = await Task({
  subagent_type: "Explore",
  description: "Codebase exploration for [feature name]",
  prompt: `
    Investigate [feature area] in the codebase.

    Focus on: related files, dependencies, test coverage, existing patterns.
    Thoroughness: [quick/medium/very thorough]

    Return: key files, patterns, tech stack, blockers, recommendations.
  `
});
```

**Saving Results**:
- **Agent responsibility**:
  - Return structured data in variable `exploration_results` containing:
    - `summary`: Overall findings summary (required)
    - `files`: Array of {path, purpose, importance} objects
    - `patterns`: Existing patterns and conventions
    - `tech_stack`: Technologies and frameworks used
    - `blockers`: Potential blockers and constraints
    - `recommendations`: Recommendations for planning phase
  - **IMPORTANT**: Agent does NOT create files directly (Task tool limitation)

- **Main Claude executor responsibility** (executed in Phase 4):
  - **MANDATORY**: Use Write tool to create `docs/memory/explorations/YYYY-MM-DD-[feature]-exploration.md`
  - Format: Transform exploration_results data into structured markdown
  - Sections: Summary, Key Discoveries, Patterns, Tech Stack, Blockers, Recommendations
  - Verification: File creation will be confirmed in Phase 0.5

**⚠️ WAIT: Verify Explore Agent Completion**

Before proceeding to Phase 0.3, ensure:
- [ ] Explore agent Task tool has completed successfully
- [ ] `exploration_results` variable contains valid data
- [ ] `docs/memory/explorations/` file has been created
- [ ] NO errors occurred during exploration

**ONLY after confirming the above, proceed to Phase 0.3 (Plan Agent).**

#### Phase 0.3: Calling Plan Agent

**Purpose**: Design implementation strategy based on exploration results

**⚠️ MANDATORY PRECONDITION: Phase 0.2 Explore Agent MUST Be Completed First**

**DO NOT proceed with Phase 0.3 unless ALL of the following are confirmed:**
- ✅ Phase 0.2 Explore agent has successfully completed
- ✅ `exploration_results` variable exists and contains data
- ✅ Exploration file saved: `docs/memory/explorations/YYYY-MM-DD-[feature]-exploration.md`
- ✅ No errors occurred during exploration

**Why This Matters:**
The Plan agent requires exploration results (`exploration_results.summary`, `exploration_results.files`, `exploration_results.patterns`, `exploration_results.tech_stack`) to create an accurate implementation plan. Running Plan before Explore completes will result in incomplete or incorrect planning.

**ONLY after confirming the above, execute the Plan agent Task tool.**

**Task tool execution example**:
```typescript
// ⚠️ IMPORTANT: This Task call MUST happen AFTER Phase 0.2 (Explore) completes
// The exploration_results variable must be populated before calling the Plan agent
// DO NOT call this Task in parallel with the Explore agent Task

// Verify exploration_results exists before proceeding
if (!exploration_results) {
  throw new Error("Cannot proceed to Plan agent: exploration_results not found. Phase 0.2 must complete first.");
}

Task({
  subagent_type: "Plan",
  description: "Implementation planning for [feature name]",
  prompt: `
    # Implementation Planning Request

    ## Context from Exploration Results

    ### Summary
    ${exploration_results.summary}

    ### Key Files
    ${exploration_results.files.map(f => \`- \${f.path}: \${f.purpose}\`).join('\\n')}

    ### Existing Patterns
    ${exploration_results.patterns}

    ### Tech Stack
    ${exploration_results.tech_stack}

    ### Detailed Information
    Full exploration results: docs/memory/explorations/[DATE]-[feature]-exploration.md

    ## Git Workflow Requirements

    ${HAS_BRANCH_OPTION ? `
    ### Branch Creation Requirements
    - **--branch option is specified**
    - Branch name: \`${BRANCH_NAME}\` ${IS_AUTO_GENERATED ? '(auto-generated)' : '(user-specified)'}
    - **IMPORTANT**: Include a task to create this branch as the **FIRST task** in the task list
    - Task format example:
      \`\`\`markdown
      ### Phase 0: Branch Creation ✅

      - [ ] ✅ **Create branch**
        - Command: \`git checkout -b ${BRANCH_NAME}\`
        - 📋 All changes will be committed to this branch
        - Estimated time: 1 minute
      \`\`\`
    - **IMPORTANT**: Do NOT include 📁 file references in branch creation tasks (this is a Git operation, not a file operation)
    - All implementation tasks should be planned assuming work will be done on this branch
    ` : '- Branch option is not specified'}

    ${HAS_PR_OPTION ? `
    ### Pull Request Creation Requirements
    - **--pr option is specified**
    - **IMPORTANT**: Include a task to create a pull request as the **LAST task** in the task list
    - The PR creation task should include:
      - Committing all changes
      - Creating PR description (including development reason, development content, impact)
      - Executing \`gh pr create\` command
    - **IMPORTANT**: Do NOT include 📁 file references in PR creation tasks (this is a Git operation, not a file operation)
    - If PR template instructions exist in CLAUDE.md or similar files, specify to follow them
    ` : '- PR option is not specified'}

    ## Planning Goals
    Design a detailed plan to implement the following feature:
    [Feature description]

    ## Items to Include in Plan

    1. **Implementation Approach**
       - Overall implementation strategy (2-3 paragraphs)
       - Selected architecture patterns
       - Alignment with existing codebase

    2. **Step-by-Step Tasks**
       - Specific implementation steps
       - Deliverables for each step
       - Dependencies and execution order
       - **IMPORTANT**: If --branch option is specified, include branch creation task first
       - **IMPORTANT**: If --pr option is specified, include PR creation task last
       - **Git Commit Task Description Rules**:
         - ❌ Avoid: Writing detailed git commands (e.g., \`git add file && git commit -m "message"\`)
         - ✅ Recommended: Write only concise instruction \`Execute cccp:micro-commit\`
         - Reason: cccp:micro-commit automatically creates appropriate context-based commits

    3. **Critical Files**
       - Files that need to be created or modified
       - Role and changes for each file

    4. **Trade-offs and Decisions**
       - Comparison when multiple options exist
       - Reasons and rationale for selection

    5. **Risks and Mitigation**
       - Technical risks
       - Impact on performance, security, maintainability
       - Measures to mitigate risks

    6. **Feasibility Assessment**
       Attach the following markers to each task:
       - ✅ Ready: Clear specs, technical issues clarified, immediately executable
       - ⏳ Pending: Waiting for dependencies (specify concrete waiting reason and release condition)
       - 🔍 Research: Research required (specify concrete research items and methods)
       - 🚧 Blocked: Specs/technical details unclear (specify concrete blockers and resolution steps)

    ## Deliverable Format
    - Markdown document
    - Task list in checklist format
    - 📁 icon for file references
    - 📊 icon for technical rationale
  `
})
```

**Saving Results**:
- **Agent responsibility**:
  - Return structured data in variable `planning_results` containing:
    - `approach_summary`: Implementation strategy (2-3 paragraphs)
    - `tasks`: Array of task objects with descriptions and dependencies
    - `critical_files`: Files to create/modify with their roles
    - `trade_offs`: Technical trade-offs analysis
    - `risks`: Potential risks and mitigation strategies
    - `feasibility`: Task categorization by status (✅⏳🔍🚧)
  - **IMPORTANT**: Agent does NOT create files directly (Task tool limitation)

- **Main Claude executor responsibility** (executed in Phase 4):
  - **MANDATORY**: Use Write tool to create `docs/memory/planning/YYYY-MM-DD-[feature]-plan.md`
  - Format: Transform planning_results data into structured markdown
  - Sections: Approach, Task Breakdown, Critical Files, Trade-offs, Risks and Mitigation, Feasibility Assessment
  - Verification: File creation will be confirmed in Phase 0.5

#### Phase 0.4: Calling cccp:project-manager Agent

**Purpose**: Integrate exploration and planning results and organize strategically

**⚠️ MANDATORY PRECONDITION: Both Phase 0.2 AND Phase 0.3 MUST Be Completed First**

**DO NOT proceed with Phase 0.4 unless ALL of the following are confirmed:**
- ✅ Phase 0.2 Explore agent has successfully completed
- ✅ Phase 0.3 Plan agent has successfully completed
- ✅ Both `exploration_results` and `planning_results` variables exist
- ✅ Both exploration and planning files exist in `docs/memory/`
- ✅ No errors occurred during exploration or planning

**Sequential Dependency Chain:**
```
Phase 0.2 (Explore) → exploration_results
                          ↓
Phase 0.3 (Plan) → planning_results
                          ↓
Phase 0.4 (cccp:project-manager) → strategic_plan
```

**ONLY after confirming the above, execute the cccp:project-manager agent Task tool.**

**Task tool execution example**:
```typescript
Task({
  subagent_type: "cccp:project-manager",
  description: "Strategic organization for [feature name]",
  prompt: `
    # Strategic Project Planning Request

    ## Context

    ### Exploration Results Summary
    ${exploration_results.summary}

    Details: docs/memory/explorations/[DATE]-[feature]-exploration.md

    ### Planning Results Summary
    ${planning_results.approach_summary}

    Task count: ${planning_results.tasks.length}
    Details: docs/memory/planning/[DATE]-[feature]-plan.md

    ## Goals

    1. **Organization by Feasibility**
       - Prioritize ✅ Ready tasks
       - Clarify dependencies of ⏳ Pending tasks
       - Create research plan for 🔍 Research tasks
       - Propose solutions for 🚧 Blocked tasks

    2. **User Question Extraction**
       - Points where specs are unclear
       - Points with technical choices
       - Points requiring UI/UX decisions
       - Prepare structured options for use with AskUserQuestion tool

    3. **Checklist Structure Preparation**
       - Task list in checklist format (\`- [ ]\`)
       - Feasibility markers on each task (✅⏳🔍🚧)
       - **For implementation tasks with file operations**: Include file references (📁) and rationale (📊)
       - **For tasks without file operations** (branch creation, PR creation, Git operations, etc.): Do NOT include file references (📁)
       - Nested subtasks (2-space indent)
       - **Git Commit Task Description Rules**:
         - ❌ Avoid: Writing detailed git commands (e.g., \`git add Gemfile.lock && git commit -m "..."\`)
         - ✅ Recommended: Write only concise instruction \`Execute cccp:micro-commit\`
         - Reason: cccp:micro-commit automatically creates appropriate context-based commits, so manual git commands are not needed
       - **Task Granularity Requirements**:
         - Each task targets one file or one feature
         - Tasks are completable in 30 min - 2 hours
         - Dependencies are clearly identifiable
         - Avoid overly broad tasks without specific targets

    4. **YAGNI Principle Validation**
       - Include only tasks directly necessary for the objective
       - Exclude the following:
         - Refactoring (improving or organizing existing code)
         - Adding or enhancing logs
         - Adding tests (supplementing tests for existing features)
         - Strengthening error handling (improving existing features)
         - Adding or updating documentation
         - Performance optimization
         - Code quality improvement
         - Security strengthening (when not essential for new features)
         - Additional work for pursuing perfection

    ## Expected Deliverables

    1. **tasks_by_feasibility**
       ```typescript
       {
         ready: Task[],      // ✅ Immediately executable
         pending: Task[],    // ⏳ Waiting for dependencies
         research: Task[],   // 🔍 Research required
         blocked: Task[]     // 🚧 Blocked
       }
       ```

    2. **user_questions**
       ```typescript
       {
         question: string,
         header: string,  // max 12 chars
         options: [
           { label: string, description: string }
         ],
         multiSelect: boolean
       }[]
       ```

    3. **checklist_structure**
       - Complete task structure in checklist format
       - Organized by category
       - With markers and icons

    4. **implementation_recommendations**
       - Next action items
       - Risks and mitigation
       - Quality metrics
  `
})
```

**Saving Results**:
- **Agent responsibility**:
  - Return structured data in variable `strategic_plan` containing:
    - `tasks_by_feasibility`: {ready: [], pending: [], research: [], blocked: []}
    - `user_questions`: Array of question objects with options (for AskUserQuestion tool)
    - `checklist_structure`: Complete markdown checklist format
    - `implementation_recommendations`: Next action items and quality metrics

- **Note**: strategic_plan is NOT saved to disk
  - **Reason**: Used as intermediate data structure for organizing tasks in Phase 4
  - **Persistence**: Strategic plan data (tasks, questions, checklist) are integrated into $ARGUMENTS file in Phase 4
  - **Reference**: Exploration and planning files already provide persistent storage of analysis results

#### Phase 0.5: Result Verification and Preparation

1. **Agent Execution Verification**
   - **⚠️ Verify Sequential Execution Order**
     - [ ] Phase 0.2 (Explore) completed FIRST
     - [ ] Phase 0.3 (Plan) completed SECOND (after Explore)
     - [ ] Phase 0.4 (cccp:project-manager) completed THIRD (after Plan)
   - **Confirm all agents completed successfully**
     - [ ] No errors in Explore agent execution
     - [ ] No errors in Plan agent execution
     - [ ] No errors in cccp:project-manager agent execution
   - **Verify Variable Dependencies**
     - [ ] `exploration_results` exists and contains valid data
     - [ ] `planning_results` exists and contains valid data
     - [ ] `strategic_plan` exists and contains valid data
   - **Report to user if there are errors**
     - Clearly state which phase failed
     - Explain the impact on subsequent phases
     - Recommend corrective action

2. **docs/memory File Confirmation**
   - [ ] **Check if exploration file exists**: `docs/memory/explorations/YYYY-MM-DD-[feature]-exploration.md`
     - **If NOT exists**: 🚨 CRITICAL ERROR - Exploration file must be created
       - Action: Create file immediately using Write tool with exploration_results data
       - Format: Structured markdown with Summary, Files, Patterns, Tech Stack, Blockers, Recommendations sections
       - Verify exploration_results variable has valid data before creating file
   - [ ] **Check if planning file exists**: `docs/memory/planning/YYYY-MM-DD-[feature]-plan.md`
     - **If NOT exists**: 🚨 CRITICAL ERROR - Planning file must be created
       - Action: Create file immediately using Write tool with planning_results data
       - Format: Structured markdown with Approach, Tasks, Critical Files, Trade-offs, Risks, Feasibility sections
       - Verify planning_results variable has valid data before creating file
   - [ ] **Verify file contents are complete**
     - Exploration file: Must contain summary, files list, patterns, tech_stack, blockers, recommendations
     - Planning file: Must contain approach, tasks, critical_files, trade_offs, risks, feasibility
   - [ ] **Report to user if files were NOT created in Phase 4**
     - State which files are missing and why
     - Confirm files have been created as recovery action

3. **Preparation for Next Phase**
   - If `strategic_plan.user_questions` exists, use in Phase 3
   - Use `strategic_plan.checklist_structure` in Phase 4
   - Retain `exploration_results` and `planning_results` as reference information

4. **Proceed to Phase 1**
   - Execute existing phases using agent results

---

### Phase 1: Thorough File Analysis and Existing Status Confirmation

1. **$ARGUMENTS File Reading**
   - Read the specified file and analyze its content in detail
   - Confirm existing tasks, questions, and progress status
   - Detect changes since the last execution
   - Confirm the progress status of related existing tasks
   - Identify duplicate tasks and related tasks

2. **Utilizing Phase 0 Results**
   - **Referencing Exploration Results**
     - Check key files, patterns, dependencies from `exploration_results` variable
     - Reference `docs/memory/explorations/YYYY-MM-DD-[feature]-exploration.md`
     - Utilize research results conducted by Explore agent in Phase 0.2
   - **Duplicate Check**: Check existing research results in docs/memory to avoid duplicate research
   - **Additional Research**: Conduct supplementary research if information is missing from Phase 0

### Phase 2: Thorough Task Analysis, Breakdown, Design, and Verification

3. **Utilizing Phase 0 Planning Results**
   - **Referencing Planning Results**
     - Check implementation approach, task breakdown, critical files from `planning_results` variable
     - Reference `docs/memory/planning/YYYY-MM-DD-[feature]-plan.md`
     - Utilize implementation strategy designed by Plan agent in Phase 0.3
   - **Utilizing Strategic Plan**
     - Get tasks by feasibility, user questions, checklist structure from `strategic_plan`
     - Utilize strategic plan organized by cccp:project-manager agent in Phase 0.4
   - **Existing Research Check**: Check past analysis results in docs/memory to avoid duplicate analysis

4. **Scientific Analysis of Implementation Feasibility**
   - **✅ Ready**: Clear specifications, technical issues clarified, related files confirmed, immediately executable
   - **⏳ Pending**: Waiting for dependencies, specify concrete waiting reasons and release conditions
   - **🔍 Research**: Research required, specify concrete research items and methods
   - **🚧 Blocked**: Important specifications/technical details unclear, specify concrete blocking factors and resolution steps
   - **Verification Basis**: Record files and research results that served as the basis for each determination

5. **Task Breakdown (Minimal Implementation Focus)**
   - **🚨 Most Important Constraint**: Extract only tasks directly necessary to achieve the objective. Do NOT include:
     - Refactoring (improving or organizing existing code)
     - Adding or enhancing logs
     - Adding tests (supplementing tests for existing functions)
     - Strengthening error handling (improving existing functions)
     - Adding or updating documentation
     - Performance optimization
     - Code quality improvement
     - Security strengthening (when not essential for new features)
     - Additional work for pursuing perfection
   - **Required**: Concretely specify the implementation target files for each task
   - Break down complex tasks into implementation units (file units, function units)
   - Determine execution order considering dependencies (specify prerequisites)
   - **Task Granularity Guidelines**:
     - ✅ **One file, one feature per task**: Each task should focus on a single file or feature
     - ✅ **Completable in 30 min - 2 hours**: Tasks should be small enough to complete in one focused session
     - ✅ **Clear dependencies**: Dependencies between tasks must be easily identifiable
     - ❌ **Too broad**: Avoid tasks like "implement XX feature" without specific file/function targets

### Phase 3: Thorough Question Management, User Confirmation, and Specification Recommendations

6. **Question Extraction (Only What Is Necessary to Achieve the Objective)**
   - **Utilizing Phase 0 Strategic Plan**
     - Check extracted questions from `strategic_plan.user_questions`
     - Base on questions identified by cccp:project-manager agent in Phase 0.4
   - **🚨 Important Constraint**: Extract only questions that are truly necessary to achieve the objective
   - **Required**: Extract concrete unclear points from the researched files and implementation
   - **Duplicate Question Check**: Check past question history in docs/memory to avoid duplicates
   - Extract new unclear points and questions
   - Confirm the status of existing questions (answered/unanswered)
   - Organize questions by category (specification/technology/UI/UX/other)
   - Analyze the impact scope and urgency of questions
   - **Save Question History**: Save question and answer history in docs/memory/questions
   - **🎯 User Question UI**: When you have questions for the user, ALWAYS use the AskUserQuestion tool
     - `strategic_plan.user_questions` already contains structured options
     - Present questions with clear options for the user to select from
     - Provide 2-4 concrete answer choices with descriptions
     - Use multiSelect: true when multiple answers can be selected
     - Set concise headers (max 12 chars) for each question
     - This provides a better UX than asking questions in plain text
   - **🚨 CRITICAL: Thorough Questioning Protocol**
     - When you have questions or uncertainties, keep asking using AskUserQuestion tool until all doubts are resolved
     - Never proceed with assumptions - always confirm unclear points with the user
     - When multiple interpretations are possible, present options and ask the user to choose
     - Do not move to the next phase until all questions and uncertainties are completely resolved

7. **Evidence-Based Specification Recommendations**
   - **Required**: Present concrete recommended specifications based on research results
   - **Existing Recommendation Check**: Check past recommendations in docs/memory to maintain consistency
   - Recommended plan based on existing codebase patterns
   - Proposal of implementation policy considering technical constraints
   - Comparison and evaluation when there are multiple options
   - Specify recommendation reasons and rationale (including reference files and implementation examples)
   - Provide judgment materials with specified risks and benefits
   - **Save Recommendation History**: Save specification recommendations and rationale in docs/memory/recommendations
   - **🎯 User Question UI for Recommendations**: When presenting multiple options to the user, use AskUserQuestion tool
     - Present each option as a selectable choice with clear descriptions
     - Include pros/cons or trade-offs in the option descriptions
     - This allows users to make informed decisions easily

8. **Structural Update of $ARGUMENTS File**
   - Add new questions
   - Update the status of existing questions
   - Specify confirmation items necessary for task execution
   - Record reference information for the next execution
   - **Record Research Rationale**: Specify referenced files and code (details saved in docs/memory)
   - Record recommended specifications and selection reasons in a structured manner (details saved in docs/memory)
   - **docs/memory Reference Information**: Record file paths of related research and analysis results

9. **AskUserQuestion Tool Execution (MANDATORY BEFORE PHASE 4)**

   **⚠️ CRITICAL EXECUTION POLICY**:

   This step enforces a mandatory question extraction and user interaction checkpoint. You MUST evaluate execution conditions and follow the corresponding workflow.

   ### Execution Condition Decision Flow

   ```
   IF (questions extracted in step 6) THEN
       → CONDITION A: Execute AskUserQuestion tool (MANDATORY)
   ELSE
       → CONDITION B: No questions exist (MANDATORY documentation required)
   END IF
   ```

   ---

   ### CONDITION A: Questions Exist (MANDATORY Execution)

   **Triggers**:
   - `strategic_plan.user_questions` exists and contains questions
   - Questions were extracted during Phase 3 analysis
   - Unclear specifications or multiple valid approaches identified

   **🚨 MANDATORY**: You MUST execute AskUserQuestion tool before proceeding to Phase 4

   **Execution Steps**:
   - [ ] Present each question using AskUserQuestion tool with **required parameters**:
     - `header` (string, max 12 chars): Concise question identifier
     - `question` (string): Clear question text with context
     - `options` (array): 2-4 structured choice objects with:
       - `label` (string): Short option identifier
       - `description` (string): Explain implications of each choice
     - `multiSelect` (boolean): Set `true` when multiple answers can be selected
   - [ ] Wait for user responses - **DO NOT proceed to Phase 4 until answered**
   - [ ] Validate that all questions received responses

   **After Receiving Answers**:
   - [ ] **MANDATORY**: Record user responses in `docs/memory/questions/YYYY-MM-DD-[feature]-answers.md`
     - Format: Structured markdown with question headers, selected options, and rationale
     - Example structure:
       ```markdown
       # User Decisions - [Feature Name]
       Date: YYYY-MM-DD

       ## Question 1: [Header]
       **Selected**: [Option Label]
       **Rationale**: [Why this choice was made]

       ## Question 2: [Header]
       **Selected**: [Option Label(s)]
       **Rationale**: [Decision context]
       ```
   - [ ] Update task planning based on user decisions
   - [ ] Resolve any 🚧 Blocked or 🔍 Research tasks that depended on answers

   **Error Handling**:
   - If AskUserQuestion tool fails → **STOP execution** and report error to user
   - If questions.md file creation fails → Retry once, then escalate to user
   - Do NOT proceed to Phase 4 if any question remains unanswered

   ---

   ### CONDITION B: No Questions (MANDATORY Documentation)

   **⚠️ MANDATORY**: If there are genuinely no questions or uncertainties:
   - [ ] Proceed directly to Phase 4
   - [ ] **REQUIRED**: Document in Phase 5 summary why no questions were needed
   - [ ] Explain what made the requirements clear enough to skip user interaction

   ---

   ### Why This Matters

   **Risks of Skipping Questions**:
   - **Incorrect Assumptions**: Proceeding without clarification can lead to implementing wrong features or using inappropriate technical approaches
   - **Wasted Development Effort**: Building features based on misunderstood requirements results in rework and delays
   - **Context Loss**: Without recorded user decisions, future maintainers cannot understand why specific implementation choices were made
   - **User Misalignment**: Skipping user validation means missed opportunities to catch requirement mismatches early

   This checkpoint ensures alignment between user intent and implementation strategy before significant development effort begins.

---

## 🚨 CRITICAL GATE: MANDATORY PHASE 4 ENTRANCE REQUIREMENTS

**PURPOSE**: Prevent execution of Phase 4 without completing Phase 3 question processing when questions exist.

### Checkpoint 1: Questions Processing Status

**Verification Point**: Before entering Phase 4, verify the execution state of Phase 3 Step 9 conditions.

**Required Verification**:
- [ ] Check if `strategic_plan.user_questions` exists (from Phase 3 Step 6)
- [ ] If questions exist, verify AskUserQuestion tool was executed
- [ ] Confirm all questions received user responses

### Checkpoint 2: Evidence Verification

**File System Evidence**:

```
IF questions were extracted in Phase 3 Step 6 THEN
    → Expected: docs/memory/questions/YYYY-MM-DD-[feature]-answers.md file EXISTS
    → Status: AskUserQuestion tool MUST have been executed
ELSE
    → Expected: No questions.md file (questions did not exist)
    → Status: AskUserQuestion tool execution NOT required
END IF
```

**⚠️ Truth Table: PASS/FAIL Criteria**

| questions.md Expected | AskUserQuestion Executed | Result | Action |
|----------------------|--------------------------|--------|---------|
| ✅ Yes (questions exist) | ✅ Yes (tool executed) | **PASS** | Proceed to Phase 4 |
| ✅ Yes (questions exist) | ❌ No (tool NOT executed) | **FAIL** | Return to Phase 3 Step 9 |
| ❌ No (no questions) | ❌ No (tool NOT executed) | **PASS** | Proceed to Phase 4 |
| ❌ No (no questions) | ✅ Yes (tool executed) | **ANOMALY** | Investigate logic error |

### Action on Failure

**IF Checkpoint FAILS** (questions exist but AskUserQuestion was not executed):

1. **STOP immediately** - Do NOT proceed to Phase 4
2. **Return to Phase 3 Step 9** - Execute CONDITION A as defined in Phase 3 Step 9
3. **Execute AskUserQuestion tool** - Present all questions to user
4. **Wait for responses** - Do NOT continue until all questions are answered
5. **Create questions.md file** - Document user responses in `docs/memory/questions/`
6. **Re-verify** - Return to this checkpoint and verify PASS criteria

**WHY THIS MATTERS**: Skipping user question validation causes cascading failures in Phase 5 verification (questions.md file will be missing when expected) and risks misalignment between implementation and user intent.

---

### Phase 4: $ARGUMENTS File Update

**⚠️ MANDATORY PRECONDITION**: All questions extracted in Phase 3 MUST be answered via AskUserQuestion tool before starting this phase. If questions exist but were not answered, STOP and return to Phase 3 step 9.

#### File Creation Responsibility and Timeline

**🚨 CRITICAL: docs/memory Files Must Be Created in This Phase**

The following files MUST be created by the Main Claude executor (NOT by agents) in Phase 4:

1. **Exploration results file** (from Phase 0.2):
   - [ ] **Create** `docs/memory/explorations/YYYY-MM-DD-[feature]-exploration.md`
   - Source: `exploration_results` variable returned by Explore agent
   - Tool: Use Write tool
   - Format: Structured markdown with sections: Summary, Key Discoveries, Patterns, Tech Stack, Blockers, Recommendations

2. **Planning results file** (from Phase 0.3):
   - [ ] **Create** `docs/memory/planning/YYYY-MM-DD-[feature]-plan.md`
   - Source: `planning_results` variable returned by Plan agent
   - Tool: Use Write tool
   - Format: Structured markdown with sections: Approach, Task Breakdown, Critical Files, Trade-offs, Risks, Feasibility

3. **User answers file** (from Phase 3, if AskUserQuestion was executed):
   - [ ] **Create** `docs/memory/questions/YYYY-MM-DD-[feature]-answers.md` (if user questions existed)
   - Source: User responses from AskUserQuestion tool
   - Tool: Use Write tool
   - Format: Q&A format with questions and selected answers

**Timeline:**
- **Phase 0.2-0.4**: Agents return data as variables (`exploration_results`, `planning_results`, `strategic_plan`)
- **Phase 0.5**: Verify agent completion and data variables exist
- **👉 Phase 4 (THIS PHASE)**: Main Claude executor creates persistent docs/memory files using Write tool
- **Phase 5**: Verify file creation and report to user

**Why Agents Cannot Create Files:**
- Task tool agents run in isolated processes
- Agent-created files do not persist to Main Claude executor's filesystem
- Main Claude executor must explicitly use Write tool to create persistent files

9. **Create docs/memory Files (EXECUTE FIRST)**
    - **⚠️ MANDATORY FIRST STEP**: Before updating $ARGUMENTS file, create all docs/memory files
    - [ ] **Create exploration file** using Write tool:
      - Path: `docs/memory/explorations/YYYY-MM-DD-[feature]-exploration.md`
      - Source data: `exploration_results` variable from Phase 0.2
      - Format: Markdown with sections: Summary, Key Discoveries, Patterns, Tech Stack, Blockers, Recommendations
    - [ ] **Create planning file** using Write tool:
      - Path: `docs/memory/planning/YYYY-MM-DD-[feature]-plan.md`
      - Source data: `planning_results` variable from Phase 0.3
      - Format: Markdown with sections: Approach, Task Breakdown, Critical Files, Trade-offs, Risks, Feasibility
    - [ ] **Create questions file** (if user questions existed) using Write tool:
      - Path: `docs/memory/questions/YYYY-MM-DD-[feature]-answers.md`
      - Source data: User responses from AskUserQuestion tool in Phase 3
      - Format: Q&A format with questions and user's selected answers
    - [ ] **Verify all files were created successfully**
      - Use Bash tool with `ls -la` to confirm file existence
      - Report any file creation failures as CRITICAL ERROR

10. **Thorough Update of $ARGUMENTS File**
    - **🔀 Branch Creation Task (when --branch or --pr option is specified)**
      - **Add branch creation task as the FIRST task** in the task list section
      - Task format example:
        ```markdown
        ### Phase 0: ブランチ作成 ✅

        - [ ] ✅ **ブランチを作成**
          - コマンド: `git checkout -b [branch_name]`
          - 📋 このブランチで全ての変更をコミット
          - 推定時間: 1分
        ```
      - Replace `[branch_name]` with the actual branch name (specified or auto-generated)
      - Place this section before all other task phases
    - **🔀 PR Creation Task (only when --pr option is specified)**
      - **IMPORTANT**: Add PR creation task as the **LAST task** in the task list ONLY when `--pr` option is specified
      - **IMPORTANT**: Do NOT add PR creation task when only `--branch` is specified
      - Task format example:
        ```markdown
        ### Phase 4: PRとマージ ✅/⏳

        - [ ] ✅ 4.1 PRテンプレートに従ったPR作成
          - [ ] `.github/PULL_REQUEST_TEMPLATE.md` 読み込み
          - [ ] PR本文作成（開発理由、開発内容、影響内容を含む）
          - [ ] `gh pr create --title "..." --body "..."` 実行

        - [ ] ⏳ 4.2 レビューとマージ
          - [ ] チームレビュー待機
          - [ ] 承認後マージ実行 `gh pr merge`
        ```
      - Do not include 📁 file references in PR creation tasks (because it's a Git operation task)
    - **Integrating Phase 0 Results**
      - Update file based on `strategic_plan.checklist_structure`
      - Include links to docs/memory:
        - `docs/memory/explorations/YYYY-MM-DD-[feature]-exploration.md`
        - `docs/memory/planning/YYYY-MM-DD-[feature]-plan.md`
      - Record next actions from `strategic_plan.implementation_recommendations`
    - **Required**: Directly update the $ARGUMENTS file (specified file)
    - **Complete Checklist Format**: Describe all tasks in Markdown checklist format with `- [ ]`
    - **Status Display**: Clearly indicate completed `- [x]`, in progress `- [🔄]`, waiting `- [ ]`
    - **Structured Sections**: Maintain checklist format within each category as well
    - **Nested Subtasks**: Create subtask checklists with indentation (2 spaces)
    - Display implementation feasibility indicators (✅⏳🔍🚧) on tasks
    - Describe confirmation items in checklist format as well
    - **Record Research Trail**: Specify referenced and analyzed file paths (detailed research results saved in docs/memory)
    - **Technical Rationale**: Record technical information that served as the basis for determination (detailed analysis saved in docs/memory)
    - **docs/memory Reference**: Record file paths of related research, analysis, and recommendation results
    - Record progress rate and update date
    - Add links to related documents and files
    - Add structured new sections while preserving existing content

### Phase 5: Thorough Verification and Feedback

11. **Multi-faceted Update Result Verification**
    - **Required**: Reload and confirm the updated file
    - Verify the consistency and completeness of tasks
    - Check for missing or duplicate questions
    - **AskUserQuestion Execution Verification**:
      - [ ] Confirm AskUserQuestion tool was executed for all extracted questions in Phase 3
      - [ ] Verify user responses were recorded in `docs/memory/questions/YYYY-MM-DD-[feature]-answers.md`
      - [ ] If questions existed but AskUserQuestion was NOT executed, this is a CRITICAL ERROR - report to user
      - [ ] If no questions existed, document this fact in Phase 5 summary
    - **Questions Processing Integrity Validation** (references Phase 3 Step 9 + Phase 4 Entrance Guard):
      - [ ] **Cross-reference validation**: Compare questions.md file against AskUserQuestion execution history
      - [ ] **Completeness check**: Verify ALL questions in questions.md have recorded answers
        - ✅ **SUCCESS**: All questions have documented answers → Proceed to Step 11
        - 🚨 **FAILURE**: One or more questions lack answers → Execute recovery procedure below
        - ⚠️ **GRAY ZONE**: Questions marked unnecessary without documentation → Return to Phase 3 Step 9
      - [ ] **Recovery procedure on validation failure**:

        **STEP 1: STOP Processing**
        - [ ] Halt Phase 5 Step 11 immediately - Do NOT proceed to final summary
        - [ ] Suspend all pending verification tasks
        - [ ] Mark current execution as "RECOVERY MODE"

        **STEP 2: DOCUMENT GAP (Evidence Collection)**
        - [ ] Identify missing questions by comparing:
          - Source: `docs/memory/questions/YYYY-MM-DD-[feature]-questions.md` (expected questions)
          - Target: `docs/memory/questions/YYYY-MM-DD-[feature]-answers.md` (recorded answers)
        - [ ] Create gap analysis report with:
          - Total questions count: [N]
          - Answered questions count: [M]
          - Missing questions count: [N - M]
          - Specific missing question IDs/text: [List each unanswered question]
        - [ ] Record gap in execution log with timestamp and context

        **STEP 3: ROLLBACK to Phase 3 Step 9**
        - [ ] Navigate to Phase 3 Step 9: "Questions Extraction and User Interaction"
        - [ ] Execute CONDITION A with **ONLY missing questions**:
          - Load unanswered questions from gap analysis
          - Execute AskUserQuestion tool for each missing question
          - Wait for user responses (do NOT proceed without answers)
          - Append new answers to existing answers.md file (preserve previous answers)
        - [ ] **Verification after rollback**:
          - Re-run completeness check (questions count = answers count)
          - Confirm 1:1 mapping achieved
          - If still failing → Escalate to user with detailed error report

        **STEP 4: RESUME Phase 5**
        - [ ] Return to Phase 5 Step 11 verification point
        - [ ] Re-execute "Questions Processing Integrity Validation"
        - [ ] Expected result: SUCCESS (all questions answered)
        - [ ] Continue to Step 12 (Comprehensive Execution Summary)

        **Common Failure Scenarios**:
        - **Scenario 1**: AskUserQuestion tool was executed but answers.md file was not created
          - Root cause: File write failure or incorrect file path
          - Recovery: Re-execute AskUserQuestion, verify file creation explicitly
        - **Scenario 2**: Some questions were skipped during Phase 3 execution
          - Root cause: Conditional logic error or incomplete iteration
          - Recovery: Compare questions.md line-by-line against answers.md entries
        - **Scenario 3**: Answers file exists but contains incomplete responses
          - Root cause: User response not properly recorded or partial execution
          - Recovery: Identify incomplete entries, re-ask specific questions
        - **Scenario 4**: Questions file was updated after answers were recorded
          - Root cause: Phase 3 re-execution without Phase 4 entrance guard check
          - Recovery: Use timestamp comparison, re-ask only newly added questions
      - [ ] **Quantified Validation Criteria Matrix**:

        **📊 Measurable Success/Failure Thresholds**

        | Metric | Measurement Method | Success Threshold | Failure Threshold |
        |--------|-------------------|-------------------|-------------------|
        | **Question Count** | `grep -c "^##" questions.md` | N questions | N questions |
        | **Answer Count** | `grep -c "^##" answers.md` | N answers | M answers (M < N) |
        | **1:1 Mapping** | `question_count == answer_count` | ✅ True | ❌ False |
        | **Completeness** | All questions have non-empty answers | ✅ 100% | ❌ <100% |
        | **File Existence** | Both questions.md and answers.md exist | ✅ Both exist | ❌ Missing answers.md |

        **⚠️ Validation Decision Matrix**

        | Questions Exist | Answers File Exists | Question Count == Answer Count | All Answers Complete | Verdict | Action |
        |----------------|--------------------|---------------------------------|---------------------|---------|--------|
        | ✅ Yes | ✅ Yes | ✅ Yes (1:1 mapping) | ✅ Yes (100%) | **SUCCESS** | Proceed to Step 11 |
        | ✅ Yes | ✅ Yes | ✅ Yes (1:1 mapping) | ❌ No (incomplete) | **FAILURE** | Execute recovery procedure |
        | ✅ Yes | ✅ Yes | ❌ No (gap exists) | N/A | **FAILURE** | Execute recovery procedure |
        | ✅ Yes | ❌ No | N/A | N/A | **FAILURE** | Execute recovery procedure |
        | ✅ Yes | ⚠️ Yes (but empty) | ❌ No (0 answers) | ❌ No | **FAILURE** | Execute recovery procedure |
        | ❌ No | ❌ No | N/A | N/A | **SUCCESS** | No questions needed, proceed |
        | ❌ No | ✅ Yes | N/A | N/A | **ANOMALY** | Investigate unexpected answers file |

        **🔍 Gray Zone Scenarios** (Require Human Judgment → Return to Phase 3 Step 9)

        | Scenario | Detection Method | Indicator | Resolution |
        |----------|------------------|-----------|------------|
        | **Questions marked unnecessary** | Questions file exists but answers file states "No questions needed" | answers.md contains disclaimer instead of 1:1 answers | Return to Phase 3 Step 9 to re-evaluate necessity |
        | **Partial execution claim** | Question count matches answer count, but answers contain TODO/placeholder text | Answers contain strings like "TBD", "[待機中]", "TODO" | Execute recovery procedure to complete answers |
        | **Timestamp mismatch** | Questions file modified after answers file created | `questions.md mtime > answers.md mtime` | Return to Phase 3 Step 9 to process new questions |
        | **Format inconsistency** | Question headers don't match answer headers | Header text mismatch between files | Execute recovery procedure to align headers |
    - **Technical Consistency Verification**: Reconfirm whether the proposed tasks are technically executable
    - **Dependency Verification**: Confirm whether dependencies between tasks are correctly set
    - **Research Rationale Verification**: Confirm whether there are any omissions in the recorded research results

12. **Comprehensive Execution Summary Provision**
    - **Research Performance**: Report the number of researched files and directories
    - **Analysis Results**: Report the number of newly created tasks and their classification
    - **Verification Status**: Report identified questions and confirmation items
    - **docs/memory Files Creation Report** (MANDATORY):
      - [ ] **Exploration file**: Confirm `docs/memory/explorations/YYYY-MM-DD-[feature]-exploration.md` was created
        - If NOT created: Report as CRITICAL ERROR with explanation
        - If created: Report file size and confirm contents
      - [ ] **Planning file**: Confirm `docs/memory/planning/YYYY-MM-DD-[feature]-plan.md` was created
        - If NOT created: Report as CRITICAL ERROR with explanation
        - If created: Report file size and confirm contents
      - [ ] **Questions file** (if applicable): Confirm `docs/memory/questions/YYYY-MM-DD-[feature]-answers.md` was created (if user questions existed)
        - Report whether this file was needed and created
    - **AskUserQuestion Execution Report** (MANDATORY):
      - Report whether AskUserQuestion tool was executed
      - If executed: Report number of questions asked and answers received
      - If not executed: Explicitly state "No questions required" with justification
      - Report location of recorded answers: `docs/memory/questions/YYYY-MM-DD-[feature]-answers.md`
      - **Questions Processing Integrity Status**:
        - Report validation result: SUCCESS / FAILURE / GRAY ZONE (as defined in Questions Processing Integrity Validation)
        - If FAILURE: Report gap details (missing question count, specific IDs)
        - If recovery executed: Report rollback to Phase 3 Step 9 and re-execution results
        - Confirm 1:1 mapping achieved: Questions count = Answers count
    - **Technical Insights**: Report discovered technical issues, constraints, and opportunities
    - **Recommended Actions**: Concretely specify the next action items
    - **Improvement Proposals**: Propose improvements for iterative execution
    - **Update Confirmation**: Confirm and report that the $ARGUMENTS file has been updated normally
    - **Quality Indicators**: Self-evaluate the thoroughness of research, accuracy of analysis, and practicality of proposals

## 🎛️ Thorough Iterative Execution Support Features

- **Detailed Difference Detection**: Automatically detect and analyze changes since the last execution
- **Research History Management**: Record and utilize past researched files and results (utilize docs/memory)
- **Question Status Management**: Mark, organize, and follow up on answered questions (refer to docs/memory/questions)
- **Task Evolution Management**: Adjust, split, and merge according to existing task progress (avoid duplicate tasks)
- **Learning and Improvement Function**: Propose improvements and efficiency from past execution history (utilize docs/memory/lessons)
- **Research Optimization**: Avoid duplicate research and supplement insufficient research (check entire docs/memory)
- **Duplicate Check Function**: Thoroughly avoid duplication of tasks, research, questions, and recommendations

## 🔧 Agent Usage Best Practices

### When to Use Explore Agent (Phase 0.2)
Used by main Claude executor in Phase 0.2:
- **Codebase exploration**: Finding files, patterns, or keywords across the project
- **Relationship discovery**: Understanding how components/models/controllers relate
- **File structure analysis**: Mapping out project organization
- **Dependency identification**: Finding what files depend on or are used by others
- **Test file discovery**: Locating corresponding test files
- Set thoroughness: "quick" for simple searches, "medium" for standard exploration, "very thorough" for comprehensive analysis

### When to Use Plan Agent (Phase 0.3)
Used by main Claude executor in Phase 0.3:
- **Implementation strategy**: Designing how to implement a feature
- **Architecture decisions**: Choosing between different approaches
- **Impact analysis**: Evaluating changes across multiple files
- **Technical design**: Creating detailed implementation plans
- **Trade-off evaluation**: Comparing different solutions
- The Plan agent builds on Explore agent findings to create actionable plans

### When to Use cccp:project-manager Agent (Phase 0.4)
Used by main Claude executor in Phase 0.4:
- **Strategic organization**: Organizing tasks by feasibility (✅⏳🔍🚧)
- **User question extraction**: Identifying specification ambiguities
- **Checklist structure preparation**: Creating structured checklist format
- **YAGNI validation**: Ensuring only necessary tasks are included
- The cccp:project-manager agent integrates Explore and Plan results into actionable structure

### Workflow Example (Phase 0)
1. **Phase 0.2: Explore Agent** → Find all salary-related files and their relationships (thoroughness: medium)
2. **Phase 0.3: Plan Agent** → Design implementation approach for adding calculation period feature
3. **Phase 0.4: cccp:project-manager Agent** → Organize tasks by feasibility and prepare checklist structure
4. **Phase 1-5** → Use agent results to execute remaining phases and update $ARGUMENTS file

### ⚠️ Common Mistakes to Avoid

**❌ WRONG: Parallel Agent Execution**
```typescript
// DO NOT DO THIS - agents will run in parallel
const [explore, plan] = await Promise.all([
  Task({ subagent_type: "Explore", ... }),
  Task({ subagent_type: "Plan", ... })  // Plan needs exploration_results!
]);
```

**✅ CORRECT: Sequential Agent Execution**
```typescript
// Execute agents one by one, waiting for each to complete
const exploration_results = await Task({
  subagent_type: "Explore",
  ...
});

// Verify exploration completed successfully
if (!exploration_results) {
  throw new Error("Explore agent failed");
}

// NOW we can safely run Plan agent
const planning_results = await Task({
  subagent_type: "Plan",
  prompt: `
    ## Context from Exploration Results
    ${exploration_results.summary}
    ...
  `
});

// Verify planning completed successfully
if (!planning_results) {
  throw new Error("Plan agent failed");
}

// NOW we can safely run cccp:project-manager agent
const strategic_plan = await Task({
  subagent_type: "cccp:project-manager",
  prompt: `
    ## Context
    ### Exploration Results Summary
    ${exploration_results.summary}

    ### Planning Results Summary
    ${planning_results.approach_summary}
    ...
  `
});
```

**Key Points:**
- Wait for each agent to complete before starting the next
- Verify results exist before passing them to the next agent
- Handle errors at each stage to prevent cascading failures

## 📋 Output Format Example

**Note**: The following is an example when `--branch` option is specified. In practice, include only tasks directly necessary to achieve the objective.

**Differences by Option**:
- **`--branch` only**: Phase 0 (Branch Creation) is added, Phase 4 (PR and Merge) is NOT added
- **`--pr`**: Both Phase 0 (Branch Creation) and Phase 4 (PR and Merge) are added
- **No options**: Neither Phase 0 nor Phase 4 is added

```markdown
## 📊 Thorough Execution Summary
- [ ] **Research Performance**: 18 files and 5 directories researched and completed
- [ ] **Technical Analysis**: Confirmed Nuxt.js 3.x + MySQL configuration
- [ ] New tasks: 6 (✅3, ⏳1, 🔍1, 🚧1)
- [ ] **Research Rationale**: Detailed analysis of 8 files, confirmation of 3 technical constraints
- [ ] **Duplicate Check**: Avoided duplication of 4 past researches, 2 questions, 1 task
- [ ] **docs/memory saved**: analysis/2025-01-15-auth-flow.md, questions/auth-questions.md
- [x] **Updated file**: $ARGUMENTS file (directly updated and verified)

## 📋 Task List (Complete Checklist Format)

### Phase 0: ブランチ作成 ✅ (when --branch option is specified)

- [ ] ✅ **ブランチを作成**
  - コマンド: `git checkout -b feature/actionlog-notification`
  - 📋 このブランチで全ての変更をコミット
  - 推定時間: 1分

### 🎯 Ready Tasks (✅ Immediately Executable)
- [ ] ✅ API authentication system implementation 📁`src/api/auth/` 📊Authentication flow confirmed
  - [ ] Implement login endpoint - Create `auth/login.ts`
    - 💡 Use Express.js POST handler pattern from `auth/register.ts`
    - 💡 Validate credentials with bcrypt, generate JWT token
    - 💡 Return { token, user } on success, 401 on failure
  - [ ] Implement token verification middleware - Create `middleware/auth.ts`
    - 💡 Follow middleware pattern in `middleware/logger.ts`
    - 💡 Use jsonwebtoken.verify() to validate token from Authorization header
    - 💡 Attach decoded user to req.user for downstream handlers
  - [ ] Add session management - Extend `utils/session.ts`
    - 💡 Add createSession() and destroySession() methods
    - 💡 Use Redis client pattern from `utils/cache.ts`
- [ ] ✅ Database schema update 📁`prisma/schema.prisma` 📊MySQL support
  - [ ] Update Prisma schema - Add new model definitions
    - 💡 Follow existing User model pattern (id, createdAt, updatedAt fields)
    - 💡 Add Session model with userId foreign key relation
  - [ ] Generate migration - Execute `npx prisma migrate dev`
    - 💡 Run after schema changes, provide descriptive migration name
- [🔄] ✅ User profile page implementation 📁`pages/user/profile.vue` - In progress
  - [x] Basic profile display ✓ `components/UserProfile.vue` completed
  - [ ] Add profile edit functionality - Create `components/UserProfileEdit.vue`
    - 💡 Copy form structure from `components/UserProfile.vue`
    - 💡 Add v-model bindings for editable fields (name, email, bio)
    - 💡 Call PATCH /api/user/:id with updated data on submit
- [ ] ✅ Commit after implementation complete
  - 💡 Execute cccp:micro-commit to commit changes by context
  - 💡 Estimated time: 2-3 minutes

### ⏳ Pending Tasks (Waiting for Dependencies)
- [ ] ⏳ Frontend UI integration 📁`components/` - After API completion (waiting for `auth/login.ts` completion)
  - [ ] Login form component - Create `components/LoginForm.vue`
  - [ ] API client setup - Configure `composables/useApi.ts`

### 🔍 Research Tasks (Research Required)
- [ ] 🔍 Third-party API integration 📊To research: API documentation and authentication method
  - [ ] Review API documentation - Check endpoints and rate limits
  - [ ] Determine authentication approach - OAuth vs API key

### 🚧 Blocked Tasks (Blocked)
- [ ] 🚧 Payment integration 📊Blocking factor: Payment provider not decided, Stripe vs PayPal
  - [ ] Payment provider selection - Compare pricing and features
  - [ ] Payment flow design - Determine checkout process

## ❓ Questions Requiring Confirmation (Checklist Format with Research Rationale)
- [ ] [Specification] What authentication method should be used? 📊Current status: Session-based auth implemented, token-based TBD
- [ ] [UI] What is the design system color palette? 📊Current status: Basic Tailwind config, custom theme not set
- [ ] [UX] What are the detailed specifications of the user flow? 📊Current status: Only basic authentication flow implemented

## 🎯 Next Actions (Checklist Format)
- [ ] Collect answers to blocker questions, confirm authentication approach
- [ ] Start implementation from ✅Ready tasks, progress step-by-step
- [ ] Confirm and adjust dependencies
```
