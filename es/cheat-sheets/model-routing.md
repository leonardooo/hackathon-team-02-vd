---
title: "Cheat sheet — Model routing de Claude en Copilot"
description: "Una página. Cuándo usar Claude Haiku 4.5, Sonnet 4.6 u Opus 4.6 dentro de GitHub Copilot. Reglas simples, casos comunes."
locale: "es"
canonical_path: "06-kit-repositorio-times/cheat-sheets/model-routing.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "1.0.0"
tags: ["cheat-sheet", "copilot", "claude", "model-routing", "workshop", "es"]
---

# Model routing de Claude — Cheat sheet

## Regla maestra

> Modelo más grande = más capaz y más lento. Usa el más chico que resuelva tu caso. Reserva Opus para decisiones, no para producción en batch.

## Los tres modelos

| Modelo | Cuándo usar | Costo relativo | Velocidad |
|--------|-------------|----------------|-----------|
| **Haiku 4.5** | Tarea mecánica, transformación simple, contexto chico | Bajo | Rápido |
| **Sonnet 4.6** | Default del día a día. Código, tests, refactor, explicación | Medio | Medio |
| **Opus 4.6** | Decisión arquitectónica, análisis de impacto, discusión de trade-offs | Alto | Lento |

## Casos comunes por persona

### Product Owner / Requirements Engineer
- Escribir una user story → **Sonnet**.
- Refinar EARS ya escritas → **Haiku**.
- Discutir si un requerimiento es v1 o v2 → **Opus** (una vez, decides, sigues).

### Arquitectos (Enterprise + Software)
- Dibujar C4 con Mermaid → **Sonnet**.
- Elegir entre dos patrones (hexagonal vs capas) → **Opus**.
- Generar una variación sintáctica de un diagrama existente → **Haiku**.

### Technical Lead
- Revisar un PR de tamaño medio → **Sonnet**.
- Decidir el estándar del proyecto (estilo de transacción, por ejemplo) → **Opus** al inicio; **Sonnet** después para aplicarlo.
- Responder "¿esto compila?" → **Haiku**.

### Developer
- Generar una implementación de service → **Sonnet**.
- Escribir un test unitario simple → **Haiku**.
- Debatir la estructura de una clase antes de escribirla → **Opus**.

### DBA
- Traducir un DDM Adabas → SQL → **Sonnet** (con Opus para el caso más raro).
- Generar DDL repetitivo → **Haiku**.
- Decidir la estrategia de particionamiento de `payment` → **Opus**.

### QA Engineer
- Generar esqueleto JUnit 5 → **Haiku**.
- Escribir test de integración no trivial → **Sonnet**.
- Decidir si un escenario amerita Testcontainers vs mock → **Opus**.

### DevOps Engineer
- Generar YAML estándar de GitHub Actions → **Sonnet**.
- Ajustar comandos triviales en el workflow → **Haiku**.
- Decidir la topología Azure → **Opus**.

### Tech Writer
- Revisar el estilo del README → **Haiku**.
- Redactar un ADR → **Sonnet**.
- Decidir la estructura global de documentación → **Opus**, una vez.

## Señales de que estás en el modelo equivocado

- **Esperas 30 segundos por una respuesta trivial** → bájale a un modelo más chico.
- **La respuesta fue superficial en una decisión crítica** → súbele a Opus.
- **La respuesta es correcta pero querías discusión** → súbele a Opus.
- **Estás encadenando prompts para que Opus genere 400 archivos** → bájale a Sonnet o Haiku.

## Tip de Paula

No trates a Opus como "el bueno" y a Haiku como "el malo". Opus en tarea mecánica es desperdicio; Haiku en decisión es riesgo. El modelo correcto es el más barato que no te falla.

---

## Navegación

| Anterior | Inicio | Siguiente |
|----------|--------|-----------|
| [Copilot 3 modos](copilot-3-modes.md) | [Kit del Equipo (ES)](../README.md) | [Specky workflow](specky-workflow.md) |

— Paula
