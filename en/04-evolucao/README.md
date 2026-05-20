---
title: "Stage 4 — Evolution"
description: "Stage 4 hub. Add infrastructure as code, CI/CD, and Copilot Agent Mode delegation. Pair 5 (DevOps + Tech Writer) leads."
locale: "en"
canonical_path: "06-kit-repositorio-times/04-evolucao/README.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "2.0.0"
status: "approved"
tags: ["stage-4", "evolution", "terraform", "cicd", "agent-mode", "en"]
---

# Stage 4 — Evolution

> Add infrastructure as code (Terraform), CI/CD pipeline (GitHub Actions), and iterate using GitHub Copilot Agent Mode.

## Where this fits in the SDLC

```mermaid
flowchart LR
 classDef done fill:#7FBA00,stroke:#5A8500,color:#fff
 classDef current fill:#F25022,stroke:#B33816,color:#fff,font-weight:bold
 classDef next fill:#FFF7E0,stroke:#FFB900,color:#0A0A0A

 S2[Stage 2<br/>Done]:::done
 S3[Stage 3<br/>Done]:::done
 S4[Stage 4<br/>Evolution<br/>17:15–18:00]:::current
 DEMO[Demo + Retro]:::next

 S2 --> S3 -- H3 --> S4 --> DEMO
```

## Who works here

**Pair 5 (DevOps + Tech Writer)** leads. **Pair 3 (TL + Dev)** co-leads on the Agent Mode delegation. **Pair 4 (QA)** runs the final coverage gate.

## What's in this folder

| File | Purpose |
|------|---------|
| [`GUIDE.md`](GUIDE.md) | **Start here.** Step-by-step Stage 4 guide |
| [`agent-experience-report.md`](agent-experience-report.md) | Template for documenting your team's Copilot Agent experience |

## Quick path

1. Read [`GUIDE.md`](GUIDE.md) (10 min).
2. Write 2 GitHub Issues following the format in the guide.
3. Trigger Copilot Agent Mode on those Issues.
4. Review the generated PRs; merge at least one.
5. Explore Terraform in [`../../../05-terraform-azure/`](../../../05-terraform-azure/) (no `terraform apply` — just `plan`).
6. Fill [`agent-experience-report.md`](agent-experience-report.md) honestly.

## Next step

At 18:00, demo time. Pair 1 (PO) narrates; Pair 3 (Dev) drives; everyone rehearsed.

## Navigation

| Previous | Home | Next |
|----------|------|------|
| [Stage 3](../03-implementacao/README.md) | [Kit (EN)](../README.md) | [Stage 4 — Guide](GUIDE.md) |

— Paula
