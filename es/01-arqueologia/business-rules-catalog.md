---
title: "Catálogo de Reglas de Negocio — SIFAP Legado"
description: "Registra aquí todas las reglas de negocio extraídas del código Natural/Adabas. Cada regla debe tener trazabilidad al código fuente."
locale: "es"
canonical_path: "06-kit-repositorio-times/01-arqueologia/business-rules-catalog.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "1.0.0"
status: "template"
tags: ["catalog", "business-rules", "stage-1", "template", "es"]
---

# Catálogo de Reglas de Negocio — SIFAP Legado

> Registra aquí todas las reglas de negocio extraídas del código Natural/Adabas.
> Cada regla debe tener trazabilidad al código fuente.
>
> **REGLA DURA:** las líneas con `Programa Fonte` vacío son **inválidas** y no cuentan para el gate del Stage 2. Usa el formato `legacy/natural-programs/ARCHIVO.NSN#L<inicio>-L<fin>` siempre que sea posible. Mínimo aceptado: el nombre del archivo .NSN.

## Cómo pensar en esto

Una regla de negocio no es cualquier línea de código. Es una **decisión del dominio**: algo que el negocio decidió que el sistema haga de cierta manera. Un `IF` que limita a 30% el descuento — eso es regla. Un `READ LOGICAL` que carga un cursor — eso es plomería, ignóralo.

## Niveles de riesgo

| Nivel | Descripción |
|-------|-------------|
| **CRÍTICO** | Regla financiera o de seguridad — el error causa pérdida directa |
| **ALTO** | Regla de negocio central — afecta al flujo principal |
| **MEDIO** | Regla de validación o formato — afecta a la calidad de los datos |
| **BAJO** | Regla de presentación o conveniencia — impacto limitado |

## Reglas encontradas

| ID | Regla de Negocio | Programa Fonte | Campos DDM | Nivel de Riesgo | Notas |
|----|------------------|----------------|------------|-----------------|-------|
| BR-001 | | | | | |
| BR-002 | | | | | |
| BR-003 | | | | | |
| BR-004 | | | | | |
| BR-005 | | | | | |
| BR-006 | | | | | |
| BR-007 | | | | | |
| BR-008 | | | | | |
| BR-009 | | | | | |
| BR-010 | | | | | |
| BR-011 | | | | | |
| BR-012 | | | | | |
| BR-013 | | | | | |
| BR-014 | | | | | |
| BR-015 | | | | | |

> Agrega más líneas según necesites. Recuerda: hay **10 reglas escondidas** en el código.

## Ejemplo de línea bien hecha (no borrar)

| BR-EX1 | El descuento total no puede exceder 30% del valor bruto, excepto descuentos judiciales (tipo J) | `legacy/natural-programs/CALCDSCT.NSN#L142-L148` | `PAGAMENTO.VLR-BRUTO`, `PAGAMENTO.VLR-TOTAL-DSCT`, `PAGAMENTO.TIPO-DSCT` | CRÍTICO | Regla financiera. Violarla causa pérdida. Tipo 'J' = excepción legal. |

## Reglas por categoría

### Cálculos financieros
<!-- Lista aquí las reglas relacionadas a cálculos de valores, beneficios, etc. -->

### Validaciones de estado
<!-- Lista aquí las reglas de transición de estado (A, S, C, I, D) -->

### Reglas de autorización
<!-- Lista aquí las reglas de quién puede hacer qué -->

### Reglas de negocio temporales
<!-- Lista aquí reglas con plazos, fechas-límite, períodos -->

## Resumen estadístico

- Total de reglas encontradas: ___
- Reglas críticas: ___
- Reglas con duplicación: ___
- Reglas sin documentación (escondidas): ___
