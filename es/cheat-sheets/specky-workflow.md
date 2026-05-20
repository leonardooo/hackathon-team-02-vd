---
title: "Cheat sheet — Specky SDD v3.4"
description: "Una página. Pipeline SDD, 6 patrones EARS, agentes y comandos de Specky v3.4."
locale: "es"
canonical_path: "06-kit-repositorio-times/cheat-sheets/specky-workflow.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "1.0.0"
tags: ["cheat-sheet", "specky", "SDD", "EARS", "workshop", "es"]
---

# Specky SDD v3.4 — Cheat sheet

> Repo: https://github.com/paulasilvatech/specky | Install: `npm install -g specky-sdd@latest`

## Qué es

Un motor de Spec-Driven Development. 13 agentes, 57 MCP tools, 16 hooks. **El pipeline se aplica** — no te saltas fases.

## Setup rápido

```bash
specky install --ide=copilot # VS Code + Copilot
specky install --ide=claude # Claude Code
specky doctor # Valida la instalación
```

## Los 6 patrones EARS

| # | Patrón | Template | Ejemplo SIFAP |
|---|--------|----------|---------------|
| 1 | **Ubiquitous** | The system shall [action] | The SIFAP shall record an audit entry on every change |
| 2 | **Event-Driven** | When [X], the system shall [action] | When a cycle is generated, create payments for ACTIVE beneficiaries |
| 3 | **State-Driven** | While [X], the system shall [action] | While PENDING, allow cancellation |
| 4 | **Optional** | Where [choice], the system shall [action] | Where the user exports, generate UTF-8 CSV |
| 5 | **Unwanted** | The system shall not [action] | Do not allow DELETE on the audit log |
| 6 | **Complex** | While [X], when [Y], where [Z], the system shall [action] | In December, while ACTIVE, calculate the 13th-month bonus |

Valida: `sdd_validate_ears` (MCP tool) o `@spec-engineer` (agente)

## Pipeline — 10 fases

| # | Fase | Agente | Entregable | Persona dueña | Stage |
|---|------|--------|------------|---------------|-------|
| 0 | Init | `@sdd-init` | CONSTITUTION.md | TL | 2 |
| 1 | Discover | `@research-analyst` | RESEARCH.md | RE + EA | 2 |
| 2 | Specify | `@spec-engineer` | SPECIFICATION.md (EARS) | RE | 2 |
| 3 | Clarify | `@sdd-clarify` | CLARIFICATION-LOG.md | RE + PO | 2 |
| 4 | Design | `@design-architect` | DESIGN.md + C4 + ADRs | SA + EA | 2 |
| 5 | Tasks | `@task-planner` | TASKS.md + CHECKLIST.md | TL | 3 |
| 6 | Analyze | `@quality-reviewer` | ANALYSIS.md | QA | 3 |
| 7 | Implement | `@implementer` | Código | Dev | 3 |
| 8 | Verify | `@test-verifier` | Tests + cobertura | QA | 3 |
| 9 | Release | `@release-engineer` | PR + deploy | DevOps | 4 |

Gates LGTM: después de Specify, Design y Tasks. Revisa antes de avanzar.

## Slash commands

| Comando | Cuándo usar |
|---------|-------------|
| `/specky-migration` | **PRINCIPAL** — modernización SIFAP |
| `/specky-specify` | Escribir requerimientos EARS |
| `/specky-design` | Generar arquitectura + diagramas |
| `/specky-tasks` | Dividir el diseño en tareas |
| `/specky-verify` | Validar tests contra la spec |
| `/specky-release` | Crear el PR final |

## MCP tools más usadas

| Tool | Qué hace |
|------|----------|
| `sdd_init` | Crea `.specs/NNN-feature/` |
| `sdd_write_spec` | Genera SPECIFICATION.md |
| `sdd_validate_ears` | Valida los 6 patrones EARS |
| `sdd_generate_diagram` | Genera C4 en Mermaid |
| `sdd_write_design` | Genera DESIGN.md + ADRs |
| `sdd_write_tasks` | Genera TASKS.md secuenciado |
| `sdd_check_sync` | Detecta drift entre spec y código |

## Hooks que se dispararán

- **no-code-without-spec**: bloquea PRs sin referencia a una spec
- **EARS-linter**: se queja de requerimientos fuera de los 6 patrones
- **ADR-completeness**: exige el "camino no elegido"
- **traceability-check**: ata requerimiento → test

Cuando un hook te bloquea: **lee el mensaje**. Ajusta el artefacto, no fuerces un override.

## Flujo del workshop

```
Stage 2 (2h):
 @specky-orchestrator → Init → Discover → Specify → Clarify → Design
 
Stage 3 (3h):
 @task-planner → Tasks → @implementer → Code → @test-verifier → Verify

Stage 4 (1h30):
 @release-engineer → Release → PR
```

## Tips

- No saltes a Código sin pasar por Specify + Design
- `specky doctor` debe estar todo verde antes de empezar
- Si Specky no está disponible: escribe EARS a mano — el formato es texto plano
- Usa `@specky-orchestrator` para que el pipeline te guíe

---

## Navegación

| Anterior | Inicio |
|----------|--------|
| [Model routing](model-routing.md) | [Kit del Equipo (ES)](../README.md) |

— Paula
