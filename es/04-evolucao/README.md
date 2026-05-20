---
title: "Stage 4 — Evolution"
description: "Etapa de evolución: agregar IaC, pipeline de CI/CD e iterar con flujos agénticos."
locale: "es"
canonical_path: "06-kit-repositorio-times/04-evolucao/README.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "1.0.0"
status: "approved"
tags: ["stage-4", "evolution", "terraform", "cicd", "workshop", "es"]
---

# Stage 4 — Evolution

> Agrega infraestructura como código (Terraform), pipeline de CI/CD (GitHub Actions) e itera usando flujos agénticos.

## Dónde encaja en el SDLC

```mermaid
flowchart LR
 classDef done fill:#7FBA00,stroke:#5A8B00,color:#fff
 classDef current fill:#F25022,stroke:#B33816,color:#fff,font-weight:bold

 S1[Stage 1<br/>Discovery]:::done
 S2[Stage 2<br/>Specification]:::done
 S3[Stage 3<br/>Implementation]:::done
 S4[Stage 4<br/>Evolution<br/>17:15–18:00]:::current
 DEMO[Demo + Retro]:::current

 S3 -- código verde + tests --> S4 --> DEMO
```

## Contenido

| Archivo | Propósito |
|---------|-----------|
| [`GUIDE.md`](GUIDE.md) | Guía paso a paso de este stage |
| [`agent-experience-report.md`](agent-experience-report.md) | Template para documentar los resultados de la interacción con el Agent |

## Quién lidera

```mermaid
flowchart TB
 classDef lead fill:#000000,stroke:#000000,color:#fff,font-weight:bold
 classDef colead fill:#7FBA00,stroke:#5A8B00,color:#fff
 classDef support fill:#E5F6FD,stroke:#00A4EF,color:#0A0A0A

 P5[Pair 5 · Operations<br/>DevOps + TW<br/>LIDERA — Terraform + CI/CD]:::lead
 P3[Pair 3 · Implementation<br/>CO-LIDERA — agent-mode]:::colead
 P4[Pair 4 · Quality<br/>gate final de cobertura]:::support
 P1[Pair 1 · Vision<br/>ensayo del demo]:::support
 P2[Pair 2 · Architecture<br/>valida IaC contra ADRs]:::support
```

## Navegación

| Anterior | Inicio | Siguiente |
|----------|--------|-----------|
| [Stage 3 — Implementation](../03-implementacao/README.md) | [Kit del Equipo (ES)](../README.md) | [Stage 4 — Guía completa](GUIDE.md) |
