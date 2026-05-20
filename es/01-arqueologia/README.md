---
title: "Stage 1 — Archaeology"
description: "Etapa de análisis de código legado: explora los programas Natural del SIFAP, extrae reglas de negocio y construye el glosario del dominio."
locale: "es"
canonical_path: "06-kit-repositorio-times/01-arqueologia/README.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "1.0.0"
status: "approved"
tags: ["stage-1", "archaeology", "legacy", "analysis", "workshop", "es"]
---

# Stage 1 — Archaeology

> **LEE PRIMERO:** [`LEGACY-EXPLORATION-CHECKLIST.md`](LEGACY-EXPLORATION-CHECKLIST.md) — gate duro antes del Stage 2.
>
> Explora el SIFAP legado con Copilot Chat y Specky Research. Extrae reglas de negocio, construye un glosario y mapea dependencias. Cada artefacto producido aquí alimenta al Stage 2; las specs sin trazabilidad al legado las rechaza el CI.

## Dónde encaja en el SDLC

```mermaid
flowchart LR
 classDef current fill:#F25022,stroke:#B33816,color:#fff,font-weight:bold
 classDef next fill:#FFF7E0,stroke:#FFB900,color:#0A0A0A
 classDef later fill:#F7F7F4,stroke:#C8C8C0,color:#6B6B6B

 S1[Stage 1<br/>Discovery<br/>09:30–12:00]:::current
 S2[Stage 2<br/>Specification]:::next
 S3[Stage 3<br/>Implementation]:::later
 S4[Stage 4<br/>Evolution]:::later

 S1 --> S2 --> S3 --> S4
```

**Estás en el Stage 1.** La salida de este stage alimenta directamente al Stage 2. Sin entrega clara aquí, falla el handoff #1 y todo el equipo se atasca.

## Contenido

| Archivo | Propósito |
|---------|-----------|
| [`LEGACY-EXPLORATION-CHECKLIST.md`](LEGACY-EXPLORATION-CHECKLIST.md) | **GATE DURO.** Propiedad de programas por Pair + DoD para pasar al Stage 2 |
| [`GUIDE.md`](GUIDE.md) | Guía paso a paso de este stage |
| [`glossary.md`](glossary.md) | Template del glosario de términos del dominio |
| [`business-rules-catalog.md`](business-rules-catalog.md) | Catálogo de reglas extraídas (`Programa Fonte` obligatorio) |
| [`dependency-map.md`](dependency-map.md) | Template de mapeo de dependencias del sistema |
| [`discovery-report.md`](discovery-report.md) | Template del reporte de hallazgos |
| [`mysteries-checklist.md`](mysteries-checklist.md) | Checklist de lógica escondida para los equipos |
| [`mysteries-found.md`](mysteries-found.md) | Template para registrar los misterios descubiertos |

El código legado vive en [`../../legacy/`](../../legacy/) (incluido en el kit).

## Quién trabaja aquí (los 5 Pairs en paralelo)

```mermaid
flowchart TB
 classDef lead fill:#F25022,stroke:#B33816,color:#fff
 classDef support fill:#FFF7E0,stroke:#FFB900,color:#0A0A0A

 subgraph PARALLEL["TRABAJO EN PARALELO (3 horas)"]
 P1[Pair 1 · Vision<br/>PO + RE<br/>3 programas Cadastro]:::lead
 P2[Pair 2 · Architecture<br/>EA + SA<br/>3 programas Batch]:::support
 P3[Pair 3 · Implementation<br/>TL + Dev<br/>3 programas Cálculo]:::support
 P4[Pair 4 · Quality<br/>DBA + QA<br/>3 programas Validación<br/>+ 4 DDMs]:::support
 P5[Pair 5 · Operations<br/>DevOps + TW<br/>3 programas Consulta/Reporte<br/>+ voz del glosario]:::support
 end

 P1 -- reglas priorizadas --> H1
 P2 -- mapa de dependencias --> H1
 P3 -- núcleo de cálculo --> H1
 P4 -- validaciones + esquema --> H1
 P5 -- glosario + semilla runbook --> H1

 H1{Handoff #1<br/>~11:45<br/>Facilitador valida<br/>5 artefactos}:::lead
```

## Próximo paso

Abre [`GUIDE.md`](GUIDE.md) y empieza el trabajo de tu Pair. A las ~11:45 un facilitador (cordón azul) valida tus artefactos contra [`LEGACY-EXPLORATION-CHECKLIST.md`](LEGACY-EXPLORATION-CHECKLIST.md). Si algo está rojo, tu Pair no abre el Stage 2.

## Navegación

| Anterior | Inicio | Siguiente |
|----------|--------|-----------|
| [Team Flow (ES)](../TEAM-FLOW.md) | [Kit del Equipo (ES)](../README.md) | [Stage 1 — Guía completa](GUIDE.md) |
