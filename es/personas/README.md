---
title: "Personas — Kit del Equipo"
description: "Definiciones de persona específicas por rol para cada miembro del equipo del workshop. Definen expertise de dominio, responsabilidades y comportamiento del agente Copilot."
locale: "es"
canonical_path: "06-kit-repositorio-times/personas/README.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "1.0.0"
status: "approved"
tags: ["personas", "copilot", "roles", "workshop", "team-kit", "es"]
---

# Personas

> Cartas de persona específicas por rol para cada miembro del equipo. Definen expertise de dominio, responsabilidades y comportamiento del agente Copilot para el workshop.

## Cómo pensar en esto

Cada persona del equipo viste **dos** personas durante el día (un Pair). Las cartas existen para que sepas, en cada momento, **qué se espera de ti y qué herramienta usar**. Sin la carta, eres "un dev haciendo cosas"; con la carta, eres una pieza específica del equipo que se conecta con otras piezas específicas vía handoffs.

## Contenido

| Archivo | Rol | SDLC | Pair |
|---------|-----|------|------|
| [`01-product-owner.md`](01-product-owner.md) | Product Owner — priorización de backlog y alineación con stakeholders | Discovery + Specification | Pair 1 |
| [`02-requirements-engineer.md`](02-requirements-engineer.md) | Requirements Engineer — notación EARS y escritura de specs | Specification | Pair 1 |
| [`03-enterprise-architect.md`](03-enterprise-architect.md) | Enterprise Architect — decisiones de diseño a nivel sistema | Specification + Design | Pair 2 |
| [`04-software-architect.md`](04-software-architect.md) | Software Architect — arquitectura a nivel componente | Design | Pair 2 |
| [`05-technical-lead.md`](05-technical-lead.md) | Technical Lead — estándares de código y coordinación de equipo | Implementation | Pair 3 |
| [`06-developer.md`](06-developer.md) | Developer — implementación y testing | Implementation | Pair 3 |
| [`07-dba.md`](07-dba.md) | DBA — diseño de base de datos y migraciones | Implementation | Pair 4 |
| [`08-qa-engineer.md`](08-qa-engineer.md) | QA Engineer — estrategia de testing y cobertura | Implementation | Pair 4 |
| [`09-devops-engineer.md`](09-devops-engineer.md) | DevOps Engineer — CI/CD, IaC y deployment | Cross-cutting + Evolution | Pair 5 |
| [`10-tech-writer.md`](10-tech-writer.md) | Tech Writer — documentación y ADRs | Cross-cutting | Pair 5 |

## Mapa visual de Pairs

```mermaid
flowchart TB
 classDef p1 fill:#F25022,stroke:#B33816,color:#fff
 classDef p2 fill:#FFB900,stroke:#B38500,color:#0A0A0A
 classDef p3 fill:#7FBA00,stroke:#5A8B00,color:#fff
 classDef p4 fill:#00A4EF,stroke:#0078A8,color:#fff
 classDef p5 fill:#000000,stroke:#000000,color:#fff

 P1[Pair 1 · Vision<br/>PO + RE]:::p1
 P2[Pair 2 · Architecture<br/>EA + SA]:::p2
 P3[Pair 3 · Implementation<br/>TL + Dev]:::p3
 P4[Pair 4 · Quality<br/>DBA + QA]:::p4
 P5[Pair 5 · Operations<br/>DevOps + TW]:::p5

 P1 --> P2 --> P3
 P2 --> P4
 P3 --> P5
 P4 --> P5
```

## Persona Kits extendidos

Para implementaciones completas de persona con agentes custom, prompts y configs MCP, ver [`../../persona-kits/`](../../persona-kits/).

## Navegación

| Anterior | Inicio | Siguiente |
|----------|--------|-----------|
| [Team Flow (ES)](../TEAM-FLOW.md) | [Kit del Equipo (ES)](../README.md) | [Product Owner](01-product-owner.md) |
