---
title: "Stage 2 — Modern Specification"
description: "Stage 2 hub. Read GUIDE.md to do the work; this README explains what each file in the folder is for."
locale: "en"
canonical_path: "06-kit-repositorio-times/02-spec-moderna/README.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "2.0.0"
status: "approved"
tags: ["stage-2", "specification", "ears", "adr", "en"]
---

# Stage 2 — Modern Specification

> Every requirement here MUST trace back to a `.NSN` or `.ddm` file from Stage 1, or be marked `[GREENFIELD]`. CI enforces it. Facilitators sample at Handoff #2 (~14:30).

## Where this fits in the SDLC

```mermaid
flowchart LR
 classDef done fill:#7FBA00,stroke:#5A8500,color:#fff
 classDef current fill:#F25022,stroke:#B33816,color:#fff,font-weight:bold
 classDef next fill:#FFF7E0,stroke:#FFB900,color:#0A0A0A
 classDef later fill:#F7F7F4,stroke:#C8C8C0,color:#6B6B6B

 S1[Stage 1<br/>Done at lunch]:::done
 S2[Stage 2<br/>Specification]:::current
 S3[Stage 3<br/>Implementation]:::next
 S4[Stage 4<br/>Evolution]:::later

 S1 -- H1 --> S2 -- H2 --> S3 --> S4
```

## Who works here

Lead: **Pair 2 (Architecture)**. Pair 1 (Vision) signs off scope. Pair 5 (Operations / Tech Writer) does ADR clarity pass. Pairs 3 and 4 comment on feasibility.

## What's in this folder

| File | Purpose |
|------|---------|
| [`GUIDE.md`](GUIDE.md) | **Start here.** Step-by-step guide for Stage 2 |
| [`ADR-TEMPLATE.md`](ADR-TEMPLATE.md) | Architecture Decision Record template |
| [`scope-decisions.md`](scope-decisions.md) | What to migrate, drop, or evolve |

You'll also produce a `SPECIFICATION.md` (EARS), C4 diagrams, and 3+ ADRs in this folder during Stage 2.

## Quick path

1. Read [`GUIDE.md`](GUIDE.md) (10 min).
2. Open the `business-rules-catalog.md` from Stage 1 — it's your input.
3. Write EARS requirements following the 6 patterns.
4. Draft 3 ADRs from the [`ADR-TEMPLATE.md`](ADR-TEMPLATE.md).
5. Fill [`scope-decisions.md`](scope-decisions.md) with Pair 1's prioritization.

## Next step

When Handoff #2 passes at 14:30, **Pair 3 (Implementation) + Pair 4 (Quality)** open [Stage 3 — Implementation](../03-implementacao/GUIDE.md) in parallel.

## Navigation

| Previous | Home | Next |
|----------|------|------|
| [Stage 1](../01-arqueologia/README.md) | [Kit (EN)](../README.md) | [Stage 2 — Guide](GUIDE.md) |

— Paula
