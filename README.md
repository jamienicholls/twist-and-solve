# Rubik’s Cube Solver — Spec‑Driven Development (SDD)

A fully offline, deterministic Rubik’s Cube solver built using Flutter + Dart and developed using Spec‑Driven Development (SDD) with Claude Code.

This project is both:
- A real, functional cube solver with a visual UI
- A learning journey into SDD, agent‑assisted development, and clean architecture

---

## 🚀 Project Goals

- Build a cross‑platform Rubik’s Cube solver with:
    - Cube state editor
    - State validation
    - Deterministic solving algorithm
    - Step‑by‑step playback
    - Optional animations

- Learn and document Spec‑Driven Development (SDD):
    - Specs as the single source of truth
    - Task‑based implementation
    - Architecture‑first workflow
    - Claude Code as a deterministic executor

- Produce a blog series on SDD and agentic workflows.

---

## 🧱 Architecture Overview

This project uses a layered architecture:

    lib/
    ├── core/            # Domain logic (cube model, moves, solver)
    ├── application/     # Use cases (validate, solve, scramble)
    ├── ui/              # Flutter UI
    └── infrastructure/  # Storage, adapters

- Domain layer → Pure logic, no Flutter imports  
- Application layer → Orchestrates domain  
- UI layer → Flutter widgets, screens, animations  
- Infrastructure → Persistence, adapters  

---

## 📐 Spec‑Driven Development Workflow

This project follows a strict SDD workflow:

1. Write or update the spec  
   Located at: `docs/specs/rubiks-cube-solver.md`

2. Approve tasks  
   Each task is atomic and testable.

3. Implement tasks using Claude Code  
   Only implement what the spec defines.

4. Commit after each task  
   Commit messages follow the format:

       feat(domain): implement cube representation (D1)

5. Document progress  
   Dev logs live in: `docs/dev-log/`

---

## 📄 Key Files

- `CLAUDE.md`  
  Defines how Claude Code behaves in this repo.

- `docs/specs/rubiks-cube-solver.md`  
  The full project specification.

- `docs/dev-log/`  
  Running notes that will become the blog series.

---

## 🧪 Testing

Tests live under:

    test/
    ├── core/
    ├── application/
    └── fixtures/

All domain logic must be:
- Deterministic  
- Fully unit‑tested  
- Validated using known scrambles  

Note: the current v1 solver uses bounded phase search (depth limits + timeout guard)
to keep the UI responsive on difficult manual states.

---

## 🛣️ Roadmap

- [x] D1 — Cube representation  
- [x] D2 — Move application  
- [x] D3 — Cube UI (debug visualiser)  
- [x] D4 — State validation  
- [x] D5 — Phase-based deterministic solver  
- [x] D6 — Scramble generator  
- [x] D7 — Teaching mode domain model  
- [x] D8 — Full application UI  
- [x] A1 — Validate cube use case  
- [x] A2 — Solve cube use case  
- [x] A3 — Generate scramble use case  
- [x] U1 — Cube editor screen  
- [x] U2 — Validation feedback screen  
- [x] U3 — Solver playback screen  
- [x] U4 — Teaching mode screen  
- [ ] Next — Stronger physical solvability validation (parity/orientation)  
- [ ] Next — More complete solving strategy for hard manual states  

---

## ✍️ Blog Series

This project will be documented on `blog.jamienicholls.co.nz` as a multi‑part series covering:

- What SDD is  
- How Claude Code fits into modern engineering  
- Architecture decisions  
- Building the solver  
- Lessons learned  

---

## 📦 License

MIT — free to use, modify, and learn from.

---

## 🙌 Author

Jamie Nicholls  
Systems Engineer • Architect • Automation & AI Enthusiast
