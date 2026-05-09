# Rubik’s Cube Solver — Specification (v1.0)

## 1. Overview

This project is a Rubik’s Cube solver built with Flutter + Dart, using Spec‑Driven Development (SDD).

Goals:
- Represent a 3×3 Rubik’s Cube in code.
- Validate cube states.
- Solve valid cube states deterministically.
- Provide a UI to edit, validate, and solve a cube.
- Support step‑by‑step playback of the solution.

The spec is the single source of truth. All implementation work must reference specific tasks in this document.

---

## 2. Domain Model

### 2.1 Cube

- A standard 3×3 Rubik’s Cube with 6 faces.
- Faces: U (up), D (down), L (left), R (right), F (front), B (back).
- Each face has 9 stickers (3×3).
- Colours are abstracted as enums or string identifiers (e.g. WHITE, YELLOW, RED, ORANGE, BLUE, GREEN).

Constraints:
- The cube representation must be:
    - Immutable or treated immutably (operations return new instances).
    - Serializable (to/from JSON or a simple map structure).

### 2.2 Moves

- Basic face turns:
    - U, D, L, R, F, B
    - With modifiers: normal (90° clockwise), prime (counter‑clockwise), double (180°).
- Internal representation:
    - A move type (U, D, L, R, F, B).
    - A rotation (clockwise, counter‑clockwise, double).

### 2.3 Scramble

- A scramble is a sequence of moves.
- Must be:
    - Valid (no impossible tokens).
    - Reasonably constrained in length (e.g. 20–30 moves for random scrambles).

---

## 3. Core Capabilities

### 3.1 Cube Representation (D1)

- Represent a 3×3 cube with:
    - 6 faces.
    - 9 stickers per face.
- Provide:
    - A way to construct:
        - A solved cube.
        - A cube from a given state (e.g. from UI input).
    - A way to inspect:
        - Individual faces.
        - Individual stickers.

Acceptance criteria:
- Can create a solved cube.
- Can create a cube from a provided state structure.
- Can read back faces and stickers deterministically.

### 3.2 Move Application (D2)

- Apply a single move to a cube and return a new cube.
- Apply a sequence of moves to a cube and return a new cube.

Acceptance criteria:
- Applying a known sequence to a solved cube yields the expected state (to be defined in tests).
- Applying the inverse sequence returns the cube to solved state.

### 3.3 State Validation (D3)

- Validate whether a given cube state is:
    - Structurally valid (correct counts of each colour).
    - Potentially solvable (basic checks; full group‑theory validation not required in v1).

Acceptance criteria:
- Invalid colour counts are rejected.
- Obvious impossible states are rejected (e.g. too many of one colour).
- Valid states pass.

### 3.4 Solver (D4)

- Given a valid cube state, compute a solution sequence of moves.
- v1 may use:
    - A simple layer‑by‑layer or beginner‑style algorithm.
    - Not necessarily optimal, but must:
        - Always solve valid states within a reasonable move count.
        - Be deterministic for the same input.

Acceptance criteria:
- For a set of known scrambles, solver returns a sequence that solves the cube when applied.
- Solver returns an error or failure state if the cube is invalid or unsolvable.

### 3.5 Scramble Generator (D5)

- Generate a random scramble sequence.
- Constraints:
    - No redundant immediate inverses (e.g. R followed by R’).
    - Reasonable length (configurable, with a default).

Acceptance criteria:
- Generated scrambles are syntactically valid.
- Applying a scramble to a solved cube yields a non‑solved state.
- Applying the solver to that state returns the cube to solved.

---

## 4. Application Layer

### 4.1 Use Cases

#### A1 — Validate Cube State

Input:
- Cube state (from UI).

Output:
- Valid / invalid.
- If invalid, a list of validation errors.

#### A2 — Solve Cube

Input:
- Cube state.

Output:
- Either:
    - A solution sequence of moves, or
    - An error (invalid or unsolvable).

#### A3 — Generate Scramble

Input:
- Optional length parameter.

Output:
- A scramble sequence.

---

## 5. UI Layer (Flutter)

### 5.1 Screens

#### U1 — Cube Editor Screen

- Visual representation of the cube.
- Ability to:
    - Select a face.
    - Set sticker colours.
- Actions:
    - Validate cube.
    - Solve cube.
    - Reset to solved.
    - Apply random scramble.

#### U2 — Validation Feedback

- Show validation result:
    - Success: “Cube is valid.”
    - Failure: list of issues (e.g. “Too many RED stickers”).

#### U3 — Solver Playback

- After solving:
    - Show the solution as a list of moves.
    - Allow step‑by‑step playback:
        - Next / previous move.
        - Optional auto‑play.

---

## 6. Non‑Functional Requirements

- All domain logic (core) must be:
    - Pure Dart.
    - Free of Flutter imports.
- Deterministic behaviour:
    - Same input → same output.
- Testable:
    - Unit tests for domain.
    - Basic integration tests for application layer.

---

## 7. Tasks

### Domain (D)

- D1 — Cube representation
- D2 — Move application
- D3 — State validation
- D4 — Solver implementation
- D5 — Scramble generator

### Application (A)

- A1 — Validate cube use case
- A2 — Solve cube use case
- A3 — Generate scramble use case

### UI (U)

- U1 — Cube editor screen
- U2 — Validation feedback
- U3 — Solver playback UI

---

## 8. Out of Scope (v1)

- Optimal solving (e.g. Kociemba, Thistlethwaite).
- Performance optimisation for very low‑end devices.
- 2×2, 4×4, or other cube sizes.
- Online features or cloud sync.

---

## 9. Notes for Implementation

- All work must reference a specific task ID (e.g. D1, D2, U1).
- If implementation reveals missing details:
    - Pause.
    - Propose a spec update.
    - Get approval before changing behaviour.
