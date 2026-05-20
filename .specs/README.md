---
title: "Specky SDD Workspace"
description: "Spec-Driven Development pipeline artifacts. One folder per feature."
author: "Requirements Engineer (your team)"
date: "2026-04-29"
version: "1.0.0"
status: "approved"
tags: ["specky", "sdd", "ears", "specifications"]
---

# .specs/

This folder holds Spec-Driven Development artifacts. **One folder per feature**, named `<NNN>-<feature-name>`.

## Pipeline (10 phases)

Each feature folder progresses through the Specky pipeline. See [`cheat-sheets/specky-workflow.md`](../cheat-sheets/specky-workflow.md).

| # | Phase | Artifact |
|---|-------|----------|
| 0 | Init | `CONSTITUTION.md` |
| 1 | Discover | `RESEARCH.md` |
| 2 | Specify | `SPECIFICATION.md` (EARS) |
| 3 | Clarify | `CLARIFICATION-LOG.md` |
| 4 | Design | `DESIGN.md` + `ADRs/` + `diagrams/` |
| 5 | Tasks | `TASKS.md` + `CHECKLIST.md` |
| 6 | Analyze | `ANALYSIS.md` |
| 7 | Implement | code in `backend/` and `frontend/` |
| 8 | Verify | `VERIFICATION.md` (coverage + REQ-ID trace) |
| 9 | Release | PR + deploy notes |

## Branch convention

One branch per spec: `spec/<NNN>-<feature-name>` branched from `develop`.
Implementation branches: `impl/<NNN>-<feature-name>` branched from the spec branch.

## Starter feature

The folder [`001-example-feature/`](001-example-feature/) is a placeholder.
Rename it (or delete it and create a new one) when your team picks its first
feature in Stage 2.

```bash
# Example: rename the placeholder
mv .specs/001-example-feature .specs/001-payment-cycle-generation
```

## Reference

The main workspace has 5 complete reference specs at:
[`workshop-legacy-modernization-datacorp/.specs/`](https://github.com/paulasilvatech/workshop-legacy-modernization-datacorp/tree/main/.specs)

Use them as gold-standard examples of how each artifact should look.
