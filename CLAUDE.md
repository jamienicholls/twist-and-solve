# CLAUDE.md (v1.0)
Project: Rubik’s Cube Solver (Flutter + Dart)
Methodology: Spec‑Driven Development (SDD)
Author: Jamie Nicholls
AI Assistant: Claude Code

---

# 1. Purpose
This file defines how Claude should behave when working inside this repository. Claude must follow the spec-first workflow, treat the spec as the single source of truth, and avoid making architectural decisions unless explicitly defined in the spec. Claude must act as a senior engineer executing tasks from the spec, not as a chatbot improvising solutions.

---

# 2. Core Rules

## 2.1 Spec is the source of truth
- Claude must always load and follow the spec in `docs/specs/rubiks-cube-solver.md`.
- If code and spec disagree, update the spec first, then update the code.
- Claude must never invent features, architecture, or behaviour not defined in the spec.

## 2.2 No code without a task
- Claude must only write code when explicitly asked to implement a specific task from the spec.
- Claude must not generate code during exploration, planning, or architecture discussions.

## 2.3 Keep changes scoped
- When implementing a task, Claude must modify only the files relevant to that task.
- Claude must not refactor unrelated code unless the spec explicitly requires it.

## 2.4 Ask for clarification when needed
If the spec is ambiguous, Claude must ask for clarification instead of guessing.

---

# 3. Repository Structure
Claude must respect and maintain the following structure:

/
├── CLAUDE.md
├── README.md
├── docs/
│   ├── specs/
│   │   └── rubiks-cube-solver.md
│   └── dev-log/
├── lib/
│   ├── core/
│   ├── application/
│   ├── ui/
│   └── infrastructure/
└── test/

If new files are needed, Claude must propose them and wait for approval.

---

# 4. Development Workflow (SDD)

## 4.1 Exploration Phase
When asked to explore, Claude must:
- Read the spec
- Analyse architecture
- Ask clarifying questions
Claude must NOT write code in this phase.

## 4.2 Spec Phase
When asked to update or refine the spec:
- Claude must propose structured changes
- Claude must not write code
- Claude must ensure tasks are atomic and testable

## 4.3 Implementation Phase
When asked to implement a task:
- Claude must load the spec
- Claude must implement only the requested task
- Claude must update only the relevant files
- Claude must include tests when appropriate
- Claude must summarise changes after generating code

## 4.4 Review Phase
When asked to review:
- Claude must check code against the spec
- Claude must identify inconsistencies
- Claude must not rewrite code unless asked

---

# 5. Coding Standards

## 5.1 Language & Framework
- Dart for all core logic
- Flutter for UI
- No platform-specific code unless approved

## 5.2 Architecture
Claude must follow the layered architecture defined in the spec:
- Domain layer
- Application layer
- UI layer
- Infrastructure layer

## 5.3 Style
- Idiomatic Dart
- Clear naming
- Pure functions where possible
- No global state
- No magic numbers

## 5.4 Testing
- Every domain feature must include unit tests
- Known scrambles must be used as fixtures
- Tests must be deterministic

---

# 6. Task Execution Format

## 6.1 Before coding
Claude must output:

Loaded spec: <spec section>
Implementing task: <task ID and title>
Files to modify: <list>
Plan:
- Step 1
- Step 2
- Step 3

## 6.2 Code output
Claude must output code in separate blocks per file.

## 6.3 After coding
Claude must output:

Summary:
- Implemented <task>
- Added/modified <files>
- Added tests (if applicable)

---

# 7. Forbidden Behaviours
Claude must never:
- Invent architecture not in the spec
- Add dependencies without approval
- Modify unrelated files
- Generate code during planning
- Change the spec without being asked
- Implement multiple tasks at once
- Produce placeholder code

---

# 8. When the Spec Is Missing Something
Claude must:
1. Identify the gap
2. Propose options
3. Ask for a decision
4. Wait for confirmation

---

# 9. When Updating the Spec
Claude must:
- Keep sections structured
- Maintain task numbering
- Update acceptance criteria if needed
- Avoid mixing spec updates with code changes

---

# 10. Commit Message Guidance
Claude must suggest commit messages in this format:

feat(domain): implement cube representation (D1)
fix(domain): correct move rotation logic (D2)
docs(spec): update solver algorithm section

---

# 11. Claude CLI Usage
Claude must optimise for CLI workflows:
- Use `claude edit` for file-scoped changes
- Use `claude apply` for multi-file tasks
- Use `claude read` to load context
- Use `claude plan` for task planning

---

# 12. Final Rule
If the user request conflicts with the spec or this CLAUDE.md, Claude must:
1. Point out the conflict
2. Propose a resolution
3. Wait for confirmation
