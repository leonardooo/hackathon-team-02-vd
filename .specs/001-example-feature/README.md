---
title: "Example Feature — Placeholder"
description: "Placeholder folder demonstrating the Specky SDD artifact layout. Rename or replace when your team picks its first feature."
author: "Specky"
date: "2026-04-29"
version: "0.0.1"
status: "placeholder"
tags: ["specky", "sdd", "example"]
---

# 001 — Example Feature (placeholder)

> Delete or rename this folder when your team picks a real feature in Stage 2.
>
> The artifacts below are the canonical Specky outputs — keep this list as a
> reference for what to produce in each phase.

## Required artifacts (in order)

- [ ] `CONSTITUTION.md` — non-negotiable team rules (Phase 0)
- [ ] `RESEARCH.md` — discovery findings from Stage 1 (Phase 1)
- [ ] `SPECIFICATION.md` — EARS requirements with REQ-IDs (Phase 2)
- [ ] `CLARIFICATION-LOG.md` — Q&A with stakeholders (Phase 3)
- [ ] `DESIGN.md` — architecture, data, API (Phase 4)
- [ ] `ADRs/` — one file per decision (Phase 4)
- [ ] `diagrams/` — Mermaid C4 diagrams (Phase 4)
- [ ] `TASKS.md` — implementation task list with REQ-IDs (Phase 5)
- [ ] `CHECKLIST.md` — done criteria (Phase 5)
- [ ] `ANALYSIS.md` — gate review by Quality Reviewer (Phase 6)
- [ ] `VERIFICATION.md` — test coverage + traceability report (Phase 8)

## How to start

1. Pick a feature scope with the Product Owner.
2. Rename this folder: `mv 001-example-feature 001-your-feature-name`
3. Open the [Specification issue template](../../.github/ISSUE_TEMPLATE/spec.yml).
4. Run the Specky pipeline starting at Phase 0:

 ```bash
 /specky-init 001-your-feature-name
 ```

## Reference

Look at any of the 5 complete specs in [`workshop-legacy-modernization-datacorp/.specs/`](https://github.com/paulasilvatech/workshop-legacy-modernization-datacorp/tree/main/.specs) for examples of fully-populated artifacts.
