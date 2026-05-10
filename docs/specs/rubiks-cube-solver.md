# Rubik's Cube Solver & Learning App — Specification (v1.1)

## 1. Overview

This project implements a full Rubik's Cube domain model, solver, scramble
generator, and a teaching-oriented UI. The system is built using
Spec‑Driven Development (SDD): each feature is defined as a task (Dx),
implemented in isolation, and validated with tests.

Goals:
- Represent a 3×3 Rubik's Cube in code.
- Validate cube states.
- Solve valid cube states deterministically.
- Provide a UI to edit, validate, and solve a cube.
- Support step‑by‑step playback of the solution.
- Guide the user through solving via a structured teaching mode.

The spec is the single source of truth.  
All implementation work must reference specific tasks in this document.

---

## 2. Domain Model

### 2.1 Cube

- A standard 3×3 Rubik’s Cube with 6 faces.
- Faces: U (up), D (down), L (left), R (right), F (front), B (back).
- Each face has 9 stickers (3×3).
- Colours are abstracted as enums or identifiers (WHITE, YELLOW, RED, ORANGE, BLUE, GREEN).

Constraints:
- Representation must be:
  - Immutable (operations return new instances).
  - Serializable (JSON or simple map structure).

### 2.2 Moves

- Basic face turns:
  - U, D, L, R, F, B
  - Modifiers: clockwise, counter‑clockwise (prime), double (180°)
- Internal representation:
  - MoveFace (U, D, L, R, F, B)
  - MoveRotation (cw, ccw, double)

### 2.3 Scramble

- A scramble is a sequence of moves.
- Must be:
  - Valid (no illegal tokens).
  - Reasonably constrained in length (e.g. 20–30 moves).

---

## 3. Core Capabilities

### 3.1 Cube Representation (D1)

- Represent a 3×3 cube with:
  - 6 faces.
  - 9 stickers per face.
- Provide:
  - A solved cube constructor.
  - A constructor from a provided state.
  - Methods to inspect faces and stickers.

Acceptance criteria:
- Can create a solved cube.
- Can create a cube from a provided state structure.
- Can read back faces and stickers deterministically.

---

### 3.2 Move Application (D2)

- Apply a single move to a cube and return a new cube.
- Apply a sequence of moves to a cube and return a new cube.

Acceptance criteria:
- Known sequences produce expected states.
- Applying a move followed by its inverse returns to solved.

---

### 3.3 Cube UI (D3)

Goal:  
Provide a simple 2D visualisation of the cube for debugging, manual testing, and verifying D1–D2 behaviour.

Requirements:
1. Display all 6 faces in a fixed 2D layout:

       [ U ]
   [ L ][ F ][ R ][ B ]
       [ D ]

2. Each face is a 3×3 grid of coloured squares.
3. Colours must match `CubeColour`.
4. UI must update when moves are applied.
5. Provide buttons for all 18 basic moves:
   - U, D, L, R, F, B
   - U’, D’, L’, R’, F’, B’
   - U2, D2, L2, R2, F2, B2
6. Provide a “Reset” button.
7. UI must use only:
   - Cube
   - Move
   - applyMove
   - applyMoves
8. No animations in v1.
9. No 3D rendering in v1.
10. Implemented in Flutter using Material widgets.

Acceptance criteria:
- UI rebuilds after moves.
- Reset restores solved state.
- Move buttons produce domain‑equivalent results.
- Layout reflects cube state accurately.

---

### 3.4 State Validation (D4)

- Validate whether a cube state is:
  - Structurally valid (correct colour counts).
  - Potentially solvable (basic checks only).

Acceptance criteria:
- Invalid colour counts rejected.
- Impossible states rejected.
- Valid states pass.

---

### 3.5 Solver (D5)

Goal:  
Compute a deterministic solution sequence for a valid cube.

Requirements:
- Use a simple beginner‑style method in v1.
- Must:
  - Always solve valid states.
  - Be deterministic.
- Solver must output:
  - A flat move list.
  - A structured breakdown for teaching mode (D7).

Acceptance criteria:
- Known scrambles are solved correctly.
- Invalid or unsolvable cubes return an error.

---

### 3.6 Scramble Generator (D6)

- Generate a random scramble sequence.

Constraints:
- No immediate inverses (R then R’).
- No same‑face repeats (R then R2).
- Configurable length.
- Must use MoveFace + MoveRotation.

Acceptance criteria:
- Scrambles are syntactically valid.
- Scrambling a solved cube yields a non‑solved state.
- Solver can solve the scrambled cube.

---

### 3.7 Teaching Mode (D7)

Goal:  
Guide the user through solving the cube step‑by‑step using the solver’s
structured output. Teaching Mode explains what each stage does, what the
user should look for, and how the cube changes after each step.

Requirements:
1. Teaching Mode must present the solution as a sequence of labelled stages:
   - Cross
   - First Layer Corners
   - Second Layer
   - OLL
   - PLL

2. Each stage must include:
   - A human‑readable description of the goal.
   - What pattern or configuration the user should look for.
   - The algorithm (list of moves) for that stage.
   - The expected cube state after the stage.
   - Optional hints or tips.

3. UI must support:
   - “Next Step”
   - “Previous Step”
   - “Show Me” (auto‑apply the stage’s moves)
   - “Explain Again”

4. The cube visualiser must highlight:
   - The face being manipulated
   - The pieces involved in the step (e.g., edges for Cross)

5. Teaching Mode must work with:
   - Scrambles generated by D6
   - Arbitrary valid cube states

Acceptance criteria:
- Teaching Mode walks through the entire solution deterministically.
- Each step updates the cube UI correctly.
- Explanations match the solver’s structured breakdown.
- A user can complete a full solve using Teaching Mode alone.

---

### 3.8 Full Application UI (D8)

Goal:  
Provide the complete user interface for editing, validating, scrambling,
solving, and learning to solve the cube. This UI replaces the debug-only
visualiser from D3 with a user-facing experience.

Requirements:
1. Implement the following screens using Flutter + Material:
   
   **U1 — Cube Editor Screen**
   - Visual 2D cube representation (from D3)
   - Ability to select a face and set sticker colours
   - Actions:
     - Validate cube (A1)
     - Solve cube (A2)
     - Apply random scramble (A3)
     - Reset to solved

   **U2 — Validation Feedback**
   - Display validation result from D4
   - If invalid:
     - Show list of issues
     - Highlight affected stickers (optional v1.1)
   - If valid:
     - Show success message

   **U3 — Solver Playback**
   - Display solver output from D5
   - Show move list
   - Step-by-step playback:
     - Next / previous move
     - Auto-play (optional)
   - Update cube visualiser as moves are applied

   **U4 — Teaching Mode**
   - Use structured solver output from D7
   - Show:
     - Stage name (Cross, F2L, OLL, PLL)
     - Explanation text
     - Expected pattern
     - Moves for the stage
   - Controls:
     - Next step
     - Previous step
     - Show Me (auto-apply stage)
     - Explain Again

2. UI must use only the public application layer:
   - A1 Validate Cube
   - A2 Solve Cube
   - A3 Generate Scramble

3. UI must not contain domain logic.

4. Must support hot reload and run on:
   - iOS simulator
   - Android emulator
   - macOS (optional)

Acceptance criteria:
- All screens function end-to-end using D1–D7.
- Cube editor can create any valid or invalid state.
- Validation feedback matches D4.
- Solver playback matches D5 output.
- Teaching mode follows the structured breakdown from D7.
- No domain logic appears in UI code.

---

## 4. Application Layer

### 4.1 Use Cases

#### A1 — Validate Cube
Input: cube state  
Output: valid/invalid + errors

#### A2 — Solve Cube
Input: cube state  
Output: solution sequence or error

#### A3 — Generate Scramble
Input: optional length  
Output: scramble sequence

---

## 5. UI Layer (Flutter)

### 5.1 Screens

#### U1 — Cube Editor Screen
- Visual cube representation
- Set sticker colours
- Validate, solve, reset, scramble

#### U2 — Validation Feedback
- Show validation success or list of errors

#### U3 — Solver Playback
- Show solution list
- Step‑by‑step playback
- Next / previous / auto‑play

---

## 6. Non‑Functional Requirements

- Domain logic must be pure Dart.
- Deterministic behaviour.
- Fully testable (unit + integration).

---

## 7. Tasks

### Domain (D)
- D1 — Cube representation  
- D2 — Move application  
- D3 — Cube UI  
- D4 — State validation  
- D5 — Solver  
- D6 — Scramble generator  
- D7 — Teaching mode  

### Application (A)
- A1 — Validate cube  
- A2 — Solve cube  
- A3 — Generate scramble  

### UI (U)
- U1 — Cube editor  
- U2 — Validation feedback  
- U3 — Solver playback  

---

## 8. Out of Scope (v1)

- Optimal solving (Kociemba, Thistlethwaite)
- Performance optimisation
- Other cube sizes (2×2, 4×4, etc.)
- Online features or cloud sync

---

## 9. Notes for Implementation

- All work must reference a task ID (e.g., D1, D2, U1).
- If implementation reveals missing details:
  - Pause
  - Propose a spec update
  - Get approval before changing behaviour
