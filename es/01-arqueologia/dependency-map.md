---
title: "Mapa de Dependencias — SIFAP Legado"
description: "Usa diagramas Mermaid para mapear las dependencias entre programas Natural y DDMs Adabas. El objetivo es visualizar 'quién llama a quién' y 'quién lee/escribe qué'."
locale: "es"
canonical_path: "06-kit-repositorio-times/01-arqueologia/dependency-map.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "1.0.0"
status: "template"
tags: ["dependencies", "mermaid", "stage-1", "template", "es"]
---

# Mapa de Dependencias — SIFAP Legado

> Usa diagramas Mermaid para mapear las dependencias entre programas Natural y DDMs Adabas. El objetivo es visualizar "quién llama a quién" y "quién lee/escribe qué".

## Cómo pensar en esto

El mapa de dependencias revela los **bounded contexts naturales** del sistema. Un cluster de programas que se llaman entre sí y leen los mismos DDMs es candidato a ser un módulo del monolito modular del Stage 2. Sin el mapa, los bounded contexts se vuelven adivinanza.

## Diagrama de dependencias entre programas

> Reemplaza el ejemplo de abajo por el mapa real de tu equipo.
> Tip: usa `CALLNAT` y `PERFORM` en el código para encontrar llamadas entre programas.

```mermaid
flowchart TD
 subgraph "Programas Online"
 CADBENF["CADBENF.NSN<br/>Cadastro de Beneficiarios"]
 CONBENF["CONBENF.NSN<br/>Consulta de Beneficiarios"]
 REGPGTO["REGPGTO.NSN<br/>Registro de Pagamentos"]
 end

 subgraph "Programas Batch"
 BATCHPGT["BATCHPGT.NSN<br/>Processamento em Lote"]
 end

 subgraph "Subprogramas"
 CALCBENF["CALCBENF.NSN<br/>Calculo de Beneficios"]
 VALCPF["VALCPF.NSN<br/>Validacao de CPF"]
 end

 subgraph "DDMs Adabas"
 DDM_BENEF[("DDM: BENEFICIARIO")]
 DDM_PGTO[("DDM: PAGAMENTO")]
 end

 CADBENF -->|CALLNAT| VALCPF
 CADBENF -->|CALLNAT| CALCBENF
 CADBENF -->|READ/STORE| DDM_BENEF

 REGPGTO -->|CALLNAT| CALCBENF
 REGPGTO -->|READ/STORE| DDM_PGTO

 CONBENF -->|READ| DDM_BENEF

 BATCHPGT -->|CALLNAT| CALCBENF
 BATCHPGT -->|READ/UPDATE| DDM_PGTO
 BATCHPGT -->|READ| DDM_BENEF
```

> **Instrucción**: este es solo un ejemplo inicial con 6 programas.
> Tu equipo debe mapear **los 15 programas** y los **4 DDMs**.

## Diagrama de flujo de datos (DDMs)

```mermaid
flowchart LR
 subgraph "Entrada de Datos"
 UI["Terminal 3270"]
 BATCH["Archivos Batch"]
 end

 subgraph "Procesamiento"
 PROG["Programas Natural"]
 end

 subgraph "Almacenamiento (Adabas)"
 DDM1[("BENEFICIARIO")]
 DDM2[("PAGAMENTO")]
 DDM3[("DDM 3: ???")]
 DDM4[("DDM 4: ???")]
 end

 UI --> PROG
 BATCH --> PROG
 PROG <--> DDM1
 PROG <--> DDM2
 PROG <--> DDM3
 PROG <--> DDM4
```

> Reemplaza "DDM 3: ???" y "DDM 4: ???" por los nombres reales encontrados.

## Tabla de dependencias

| Programa | Llama (CALLNAT) | Lee (READ) DDMs | Escribe (STORE/UPDATE) DDMs | Observaciones |
|----------|-----------------|-----------------|-----------------------------|---------------|
| CADBENF.NSN | | | | |
| CONBENF.NSN | | | | |
| REGPGTO.NSN | | | | |
| BATCHPGT.NSN | | | | |
| CALCBENF.NSN | | | | |
| VALCPF.NSN | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |
| | | | | |

## Dependencias circulares

> Lista aquí cualquier dependencia circular encontrada (programa A llama a B que llama a A):

- Ninguna encontrada hasta ahora.

## Programas huérfanos

> Programas que no son llamados por ningún otro (posibles puntos de entrada o código muerto):

- Por investigar.
