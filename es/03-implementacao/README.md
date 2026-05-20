---
title: "Stage 3 — Implementation"
description: "Etapa de implementación: construir el prototipo del backend, frontend y base de datos usando Copilot Agent."
locale: "es"
canonical_path: "06-kit-repositorio-times/03-implementacao/README.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "1.0.0"
status: "approved"
tags: ["stage-3", "implementation", "coding", "prototype", "workshop", "es"]
---

# Stage 3 — Implementation

> Construye el prototipo de SIFAP 2.0 — backend Java 21, frontend Next.js 15, base de datos PostgreSQL 16 — usando el modo Agent de GitHub Copilot.

## Dónde encaja en el SDLC

```mermaid
flowchart LR
 classDef done fill:#7FBA00,stroke:#5A8B00,color:#fff
 classDef current fill:#F25022,stroke:#B33816,color:#fff,font-weight:bold
 classDef next fill:#FFF7E0,stroke:#FFB900,color:#0A0A0A

 S1[Stage 1<br/>Discovery]:::done
 S2[Stage 2<br/>Specification]:::done
 S3[Stage 3<br/>Implementation<br/>14:45–17:00]:::current
 S4[Stage 4<br/>Evolution]:::next

 S1 --> S2 --> S3 --> S4
```

**Estás en el Stage 3.** El input son las REQ-IDs y los ADRs del Stage 2. El output: una aplicación que arranca con `docker compose up` y pasa los tests.

## Contenido

| Archivo | Propósito |
|---------|-----------|
| [`GUIDE.md`](GUIDE.md) | Guía paso a paso de este stage |

## Quién lidera

```mermaid
flowchart TB
 classDef lead fill:#7FBA00,stroke:#5A8B00,color:#fff,font-weight:bold
 classDef support fill:#E5F6FD,stroke:#00A4EF,color:#0A0A0A

 P3[Pair 3 · Implementation<br/>TL + Dev<br/>CO-LIDERA — código]:::lead
 P4[Pair 4 · Quality<br/>DBA + QA<br/>CO-LIDERA — esquema, tests]:::lead
 P1[Pair 1 · Vision<br/>on-call para dudas funcionales]:::support
 P2[Pair 2 · Architecture<br/>revisa PRs que tocan contratos]:::support
 P5[Pair 5 · Operations<br/>draft del CI pipeline]:::support
```

## Navegación

| Anterior | Inicio | Siguiente |
|----------|--------|-----------|
| [Stage 2 — Modern Spec](../02-spec-moderna/README.md) | [Kit del Equipo (ES)](../README.md) | [Stage 3 — Guía completa](GUIDE.md) |
