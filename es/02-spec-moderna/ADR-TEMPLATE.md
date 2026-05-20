---
title: "ADR-XXX — Template"
description: "Template de Architecture Decision Record. Una decisión por archivo. Cada ADR debe nombrar el path no elegido."
locale: "es"
canonical_path: "06-kit-repositorio-times/02-spec-moderna/ADR-TEMPLATE.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "1.0.0"
status: "template"
tags: ["adr", "template", "stage-2", "es"]
---

# ADR-XXX: [Título de la decisión]

**Fecha**: 19/05/2026
**Estado**: Propuesta | Aceptada | Rechazada | Reemplazada por ADR-YYY
**Decisores**: [Nombres de los miembros del equipo involucrados]

## Contexto

> Describe el problema o necesidad que motivó esta decisión.
> Incluye restricciones, requerimientos e información relevante.
> Sé específico — "necesitamos una base de datos" no es suficiente.

[Escribe aquí]

## Opciones consideradas

### Opción 1: [Nombre]
- **Descripción**: [Cómo funcionaría]
- **Ventajas**: [Lista]
- **Desventajas**: [Lista]

### Opción 2: [Nombre]
- **Descripción**: [Cómo funcionaría]
- **Ventajas**: [Lista]
- **Desventajas**: [Lista]

### Opción 3: [Nombre] (opcional)
- **Descripción**: [Cómo funcionaría]
- **Ventajas**: [Lista]
- **Desventajas**: [Lista]

## Decisión

> Declara la decisión tomada de forma clara y directa.
> Ejemplo: "Decidimos usar PostgreSQL 16 como base de datos relacional."

**Decidimos [acción/elección].**

## Justificación

> Explica POR QUÉ se eligió esta opción en lugar de las demás.
> Conecta con requerimientos, restricciones y contexto.

[Escribe aquí]

## Consecuencias

### Positivas
- [Consecuencia positiva 1]
- [Consecuencia positiva 2]

### Negativas
- [Consecuencia negativa 1 — y cómo mitigarla]
- [Consecuencia negativa 2 — y cómo mitigarla]

### Riesgos
- [Riesgo identificado y plan de contingencia]

## Referencias

- [Link o documento relevante]
- [Requerimiento EARS relacionado: REQ-XXX]
- [Regla de negocio relacionada: BR-XXX]

---

> **Tip didáctico:** un ADR sin la sección "Opciones consideradas" no es ADR — es declaración. El valor del ADR está en mostrar **el path no elegido** y por qué. Si un día alguien quiere revertir la decisión, este documento es el único contexto que sobrevive.
