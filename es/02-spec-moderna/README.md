---
title: "Stage 2 — Modern Specification"
description: "Etapa de especificación: escribir requerimientos EARS, crear ADRs y definir la arquitectura del sistema moderno."
locale: "es"
canonical_path: "06-kit-repositorio-times/02-spec-moderna/README.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "1.0.0"
status: "approved"
tags: ["stage-2", "specification", "ears", "adr", "workshop", "es"]
---

# Stage 2 — Modern Specification

> Escribe la especificación modernizada del SIFAP usando notación EARS, crea Architecture Decision Records y define los límites de alcance.

## Dónde encaja en el SDLC

```mermaid
flowchart LR
 classDef done fill:#7FBA00,stroke:#5A8B00,color:#fff
 classDef current fill:#F25022,stroke:#B33816,color:#fff,font-weight:bold
 classDef next fill:#FFF7E0,stroke:#FFB900,color:#0A0A0A
 classDef later fill:#F7F7F4,stroke:#C8C8C0,color:#6B6B6B

 S1[Stage 1<br/>Discovery]:::done
 S2[Stage 2<br/>Specification<br/>13:00–14:30]:::current
 S3[Stage 3<br/>Implementation]:::next
 S4[Stage 4<br/>Evolution]:::later

 S1 --> S2 --> S3 --> S4
```

**Estás en el Stage 2 (Specification del SDLC).** El input vino del Stage 1: el `business-rules-catalog.md` y el `discovery-report.md` que produjeron en arqueología. El output alimenta directamente a los Stages 3 y 4.

## Contenido

| Archivo | Propósito |
|---------|-----------|
| [`GUIDE.md`](GUIDE.md) | Guía paso a paso de este stage |
| [`ADR-TEMPLATE.md`](ADR-TEMPLATE.md) | Template para Architecture Decision Records |
| [`scope-decisions.md`](scope-decisions.md) | Template para decisiones de límites de alcance |

## Quién lidera

```mermaid
flowchart TB
 classDef lead fill:#FFF7E0,stroke:#FFB900,color:#0A0A0A,font-weight:bold
 classDef support fill:#E5F6FD,stroke:#00A4EF,color:#0A0A0A

 P2[Pair 2 · Architecture<br/>EA + SA<br/>LIDERA]:::lead
 P1[Pair 1 · Vision<br/>PO + RE<br/>valida alcance, escribe EARS]:::support
 P5[Pair 5 · Operations<br/>DevOps + TW<br/>pasada de claridad de ADRs]:::support
 P3[Pair 3 · Implementation<br/>TL + Dev<br/>estima complejidad]:::support
 P4[Pair 4 · Quality<br/>DBA + QA<br/>escribe BDD inicial]:::support

 P2 --> H2{Handoff #2<br/>~14:30}
 P1 --> H2
 P5 --> H2
 P3 --> H2
 P4 --> H2

 H2 --> S3[Stage 3 arranca]
```

## Navegación

| Anterior | Inicio | Siguiente |
|----------|--------|-----------|
| [Stage 1 — Archaeology](../01-arqueologia/README.md) | [Kit del Equipo (ES)](../README.md) | [Stage 2 — Guía completa](GUIDE.md) |
