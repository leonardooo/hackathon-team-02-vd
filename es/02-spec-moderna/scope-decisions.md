---
title: "Decisiones de Alcance — SIFAP 2.0"
description: "Para cada funcionalidad encontrada en el Stage 1, decide: Migrar, Descartar o Evolucionar."
locale: "es"
canonical_path: "06-kit-repositorio-times/02-spec-moderna/scope-decisions.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "1.0.0"
status: "template"
tags: ["scope", "decisions", "stage-2", "template", "es"]
---

# Decisiones de Alcance — SIFAP 2.0

> Para cada funcionalidad encontrada en el Stage 1, decide: **Migrar**, **Descartar** o **Evolucionar**.
>
> - **Migrar**: traerla al SIFAP 2.0 tal cual está (misma lógica, nueva tecnología)
> - **Descartar**: no traerla — funcionalidad obsoleta o innecesaria
> - **Evolucionar**: traerla Y mejorarla (nueva UX, nuevo flujo, nueva capacidad)

## Cómo pensar en esto

No vas a poder migrar todo en 2 horas de código en el Stage 3. Aceptar eso es lo primero. Lo segundo es ser **explícito** sobre lo que queda fuera — si el Stage 3 implementa una función que el PO descartó, gastaron tiempo en vano.

**Equipo**: [Nombre del equipo]
**Fecha**: 19/05/2026
**Pair 1 (Product Owner) responsable**: [Nombre]

---

## Decisiones por funcionalidad

| # | Funcionalidad | Decisión | Justificación | Regla de negocio (BR-XXX) | Prioridad |
|---|---------------|----------|---------------|---------------------------|-----------|
| 1 | Cadastro de Beneficiarios | Migrar / Descartar / Evolucionar | | | Alta / Media / Baja |
| 2 | Consulta de Beneficiarios | | | | |
| 3 | Registro de Pagos | | | | |
| 4 | Procesamiento Batch | | | | |
| 5 | Cálculo de Beneficios | | | | |
| 6 | Validación de CPF | | | | |
| 7 | Reportes | | | | |
| 8 | Auditoría | | | | |
| 9 | Gestión de Usuarios | | | | |
| 10 | | | | | |
| 11 | | | | | |
| 12 | | | | | |

> Agrega líneas por cada funcionalidad identificada.

---

## Funcionalidades nuevas (no existen en el legado)

> Lista funcionalidades que el SIFAP 2.0 debería tener y que no existen en el sistema legado:

| # | Funcionalidad nueva | Justificación | Prioridad | Complejidad |
|---|---------------------|---------------|-----------|-------------|
| N1 | | | | |
| N2 | | | | |
| N3 | | | | |

---

## Resumen de alcance

| Decisión | Cantidad | Porcentaje |
|----------|----------|------------|
| Migrar | | |
| Descartar | | |
| Evolucionar | | |
| **Total** | | 100% |

## Riesgos de alcance

> Lista los riesgos de las decisiones de alcance tomadas:

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| | Alta / Media / Baja | Alto / Medio / Bajo | |

## Aprobación

- [ ] Pair 1 (Product Owner) aprobó las decisiones de alcance
- [ ] Pair 2 (Enterprise Architect) validó la viabilidad técnica
- [ ] El equipo concordó con las prioridades

---

> **Sin este archivo firmado, el Stage 3 no arranca.** El PO es la persona única que firma el alcance — no es decisión por consenso, es decisión por rol.
