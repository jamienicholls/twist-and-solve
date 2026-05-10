# Rubik's Cube Solver & Learning App — Specification (v1.2)

## 1. Overview

This project implements a full Rubik's Cube domain model, solver, scramble generator, and a teaching‑oriented UI. The system is built using Spec‑Driven Development (SDD): each feature is defined as a task (Dx), implemented in isolation, and validated with tests.

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
  - `MoveFace` (U, D, L, R, F, B)
  - `MoveRotation` (cw, ccw, half)

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

### 3.3 Cube UI (Debug Visualiser) (D3)

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
5. Provide buttons for all 18 basic moves.  
6. Provide a “Reset” button.  
7. UI must use only:
   - `Cube`
   - `Move`
   - `applyMove`
   - `applyMoves`
8. No animations or 3D rendering in v1.  
9. Implemented in Flutter using Material widgets.

Acceptance criteria:
- UI rebuilds after moves.
- Reset restores solved state.
- Move buttons produce domain‑equivalent results.
- Layout reflects cube state accurately.

---

## 3.4 State Validation (D4)

- Validate whether a cube state is:
  - Structurally valid (correct colour counts).
  - Potentially solvable (basic checks only).

Acceptance criteria:
- Invalid colour counts rejected.
- Impossible states rejected.
- Valid states pass.

---

## 3.5 Solver (D5)

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

## 3.6 Scramble Generator (D6)

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

## 3.7 Teaching Mode (D7)

Teaching Mode is **part domain, part UI**.  
D7 defines the *data model* for teaching; D8 defines how it is displayed.

### 3.7.1 Domain Responsibilities (D7‑Domain)

The domain layer must produce a structured teaching breakdown alongside the solver output.

**Separation from D5:** `SolveResult` (the solver output) is unchanged. The teaching breakdown is a separate type, `TeachingBreakdown`, built from a `SolveResult` + the initial `Cube`. `SolveStep` (phase + flat move list) remains the solver's internal structure; `TeachingStage` is the teaching layer's richer view of each phase.

Each `TeachingStage` must include:

- `stageName` — e.g., "White Cross"
- `description` — what the stage accomplishes
- `patternHint` — what the user should look for
- `moves` — list of `Move`
- `expectedState` — cube state after applying the stage's moves
- `highlights` — data describing which stickers/faces the UI should highlight

#### Highlight Model

```dart
class Highlight {
  final Face? activeFace;         // primary face of interest, e.g. Face.U
  final Set<StickerRef> stickers; // specific stickers the UI should highlight
}

class StickerRef {
  final Face face;   // use Face (not MoveFace) — sticker lookup uses Face
  final int row;     // 0–2
  final int col;     // 0–2
}
```

Note: `StickerRef` uses `Face`, not `MoveFace`, because sticker positions are resolved on the cube (which is indexed by `Face`). `MoveFace` is for move instructions only.

#### TeachingBreakdown

```dart
class TeachingBreakdown {
  final List<TeachingStage> stages;

  /// Build a TeachingBreakdown from a SolveResult and the cube state
  /// at the moment solve() was called.
  static TeachingBreakdown fromSolveResult(Cube initial, SolveResult result);
}
```

- Domain provides *data only* — no rendering logic.  
- UI uses this to visually highlight relevant pieces.

#### Explain Again

- Domain does nothing.  
- UI simply re-renders the current stage using the same data.

---

### 3.7.2 UI Responsibilities (D7‑UI)

Handled in D8:

- Render stage name, description, pattern hint.
- Render cube with highlighted stickers.
- Provide controls:
  - Next Step
  - Previous Step
  - Show Me
  - Explain Again
- Update cube view as moves are applied.

---

### 3.7.3 Acceptance Criteria

- Domain returns deterministic, structured teaching data.
- Each stage includes description, pattern hint, moves, expected state, and highlights.
- UI can render all stages using only the data provided.
- “Explain Again” performs no state change.

---

## 3.8 Full Application UI (D8)

Goal:  
Provide the complete user interface for editing, validating, scrambling, solving, and learning to solve the cube.

### Screens

#### U1 — Cube Editor Screen
- Visual 2D cube representation (from D3)
- Select face + set sticker colours
- Actions:
  - Validate cube (A1)
  - Solve cube (A2)
  - Apply random scramble (A3)
  - Reset to solved

#### U2 — Validation Feedback
- Display validation result from D4
- If invalid:
  - Show list of issues
  - (Optional) Highlight affected stickers
- If valid:
  - Show success message

#### U3 — Solver Playback
- Display solver output from D5
- Show move list + current step
- Controls:
  - Next / previous move
  - Auto‑play (optional)
- Cube view updates as moves are applied

#### U4 — Teaching Mode Screen
- Uses structured solver output from D7
- Shows:
  - Stage name
  - Explanation text
  - Expected pattern
  - Moves for the stage
- Controls:
  - Next step
  - Previous step
  - Show Me
  - Explain Again
- Cube view highlights relevant faces/pieces

### Constraints

- UI must use only:
  - A1 Validate Cube
  - A2 Solve Cube
  - A3 Generate Scramble
- UI must not contain domain logic.
- Must support:
  - iOS simulator
  - Android emulator
  - macOS (optional)

### Acceptance Criteria

- All screens function end‑to‑end using D1–D7.
- Cube editor can create any valid or invalid state.
- Validation feedback matches D4.
- Solver playback matches D5 output.
- Teaching mode follows D7.
- No domain logic appears in UI code.

---

## 4. Application Layer

### 4.1 Use Cases

#### A1 — Validate Cube  
Input: cube state  
Output: valid/invalid + errors

#### A2 — Solve Cube  
Input: cube state  
Output: solution sequence + teaching breakdown, or error

#### A3 — Generate Scramble  
Input: optional length  
Output: scramble sequence

### 4.2 Ordering Requirements

The application layer (A1–A3) must be implemented **before** D8.

- U1 requires A1, A2, A3  
- U2 requires A1  
- U3 requires A2  
- U4 requires A2  

D8 must not begin until A1–A3 are complete.

---

## 5. UI Layer (Flutter)

The UI layer is the user‑facing implementation of D3 and D8.

### Screens

- U1 — Cube Editor  
- U2 — Validation Feedback  
- U3 — Solver Playback  
- U4 — Teaching Mode  

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
- D3 — Cube UI (debug visualiser)  
- D4 — State validation  
- D5 — Solver  
- D6 — Scramble generator  
- D7 — Teaching mode  
- D8 — Full application UI  

### Application (A)
- A1 — Validate cube  
- A2 — Solve cube  
- A3 — Generate scramble  

### UI (U)
- U1 — Cube editor  
- U2 — Validation feedback  
- U3 — Solver playback  
- U4 — Teaching mode  

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
  - Pause.
  - Propose a spec update.
  - Get approval before changing behaviour.
