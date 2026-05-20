---
title: "Checklist de Misterios — ¿Cuánto descubrió tu equipo?"
description: "Lista de los misterios plantados en el código legado del SIFAP. Encuéntralos todos para sumar puntos."
locale: "es"
canonical_path: "06-kit-repositorio-times/01-arqueologia/mysteries-checklist.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "1.0.0"
status: "approved"
tags: ["mysteries", "checklist", "stage-1", "es"]
---

# Checklist de Misterios del SIFAP

> Hay **10 reglas de negocio escondidas** y **3 easter eggs** plantados en el código legado. Cuanto más encuentre tu equipo, mejor la nota en la rúbrica (dimensión A1).

## Cómo funciona

- Cada misterio vale 1–3 puntos según la dificultad
- Total posible: **32 puntos**
- Los misterios están distribuidos en los 15 programas .NSN y en los 4 DDMs
- Ningún misterio está documentado en los `legacy-docs/` (¡los docs están desactualizados a propósito!)

## Cómo pensar en esto

Los misterios no son curiosidades — son **reglas que sobreviven** en el sistema porque alguien las codeó y nadie las documentó. Si las migras sin saberlas, se rompen. La cacería existe para entrenar al equipo en algo real: el código es la única fuente de verdad de un sistema legado.

## Reglas de negocio escondidas (10)

Marca [x] cuando encuentres:

- [ ] **MYS-001** (★★): Un programa modifica silenciosamente el estado del beneficiario basándose en un criterio demográfico. ¿Dónde? ¿Por qué?
- [ ] **MYS-002** (★): Un límite numérico está hardcoded en el código pero contradice la capacidad definida en el DDM. ¿Cuál es el límite? ¿En qué programa?
- [ ] **MYS-003** (★★★): Una variable misteriosa se usa en cálculos pero nunca fue documentada — nadie sabe de dónde vino la constante. ¿Qué variable?
- [ ] **MYS-004** (★★★): En un mes específico del año, el cálculo de beneficio cambia completamente. ¿Qué mes? ¿Qué cambia?
- [ ] **MYS-005** (★★★): El sistema usa una técnica de redondeo que causa pérdida sistemática de centavos. ¿Qué técnica? ¿Dónde?
- [ ] **MYS-006** (★★): Un tipo de descuento ignora una regla de límite que se aplica a todos los demás. ¿Qué tipo? ¿Por qué?
- [ ] **MYS-007** (★): Ciertos CPFs se aceptan sin validación real. ¿Cuáles? ¿Es bug o feature?
- [ ] **MYS-008** (★): Los beneficiarios de una región específica se saltan TODAS las verificaciones de elegibilidad. ¿Qué región?
- [ ] **MYS-009** (★★): El procesamiento batch sigue un orden que no es el más lógico, pero que se volvió dependencia de otros sistemas. ¿Qué orden?
- [ ] **MYS-010** (★★★): Un tipo de evento de auditoría se oculta sistemáticamente de los reportes. ¿Qué tipo? ¿Es intencional o bug?

## Easter eggs (3)

- [ ] **EGG-001** (★): Un bloque de código comentado referencia una política económica de los años 90 que nunca se removió. ¿Qué política?
- [ ] **EGG-002** (★): Un programa tiene una función de validación especial que acepta ciertos documentos sin verificación. Parece un backdoor de pruebas. ¿Dónde?
- [ ] **EGG-003** (★): Código muerto referencia una integración con una empresa que ya no existe. ¿Qué empresa?

## Inconsistencias entre documentación y código (bonus)

- [ ] **INC-001**: Un límite documentado diverge de lo que el código permite
- [ ] **INC-002**: El documento de arquitectura original no menciona una estructura de datos que se agregó después
- [ ] **INC-003**: Reglas críticas de cálculo no aparecen en ningún documento
- [ ] **INC-004**: Dos programas usan métodos de redondeo diferentes para el mismo tipo de valor

## Puntuación

| Rango | Clasificación |
|-------|---------------|
| 26–32 puntos | Excelente — ¡arqueología completa! |
| 18–25 puntos | Sólido — buen trabajo de investigación |
| 10–17 puntos | Satisfactorio — encontraron lo básico |
| 0–9 puntos | Hay que mejorar — exploren más a fondo |

## Tips

- Usa **Copilot Chat** para preguntar sobre cada programa: "¿Hay alguna lógica escondida en este código?"
- Compara lo que la **documentación dice** con lo que el **código hace** — las inconsistencias son intencionales
- Los DDMs también traen pistas en sus comentarios
- Si se atascan, levanten la mano — el facilitador puede dar una pista calibrada después de 90 minutos

## Próximo paso

Cada misterio que confirmes va al archivo [`mysteries-found.md`](mysteries-found.md) con archivo + línea + impacto. Sin evidencia no cuenta.
