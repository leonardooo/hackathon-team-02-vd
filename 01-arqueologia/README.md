---
title: "Stage 1 - Archaeology"
description: "Legacy code analysis stage: explore SIFAP Natural programs, extract business rules, and build domain glossary"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-04-23"
version: "1.0.0"
status: "approved"
tags: ["stage-1", "archaeology", "legacy", "analysis", "workshop"]
---

# Stage 1 - Archaeology

> **READ FIRST:** [`LEGACY-EXPLORATION-CHECKLIST.md`](LEGACY-EXPLORATION-CHECKLIST.md) — hard gate before Stage 2.
>
> Explore the legacy SIFAP system with Copilot Chat and Specky Research. Extract business rules, build a glossary, and map dependencies. Every artifact produced here feeds Stage 2; specs without legacy traceability are rejected by CI.

## Contents

| File | Purpose |
|------|---------|
| [`LEGACY-EXPLORATION-CHECKLIST.md`](LEGACY-EXPLORATION-CHECKLIST.md) | **HARD GATE.** Per-pair program ownership + DoD for moving to Stage 2 |
| `GUIDE.md` | Step-by-step guide for this stage |
| `glossary.md` | Domain term glossary template |
| `business-rules-catalog.md` | Extracted business rules catalog (`Programa Fonte` mandatory) |
| `dependency-map.md` | System dependency mapping template |
| `discovery-report.md` | Research findings report template |
| `mysteries-checklist.md` | Hidden logic checklist for teams |
| `mysteries-found.md` | Template to log discovered mysteries |

The legacy code itself lives at [`../legacy/`](../legacy/) (bundled with the kit).

## Navigation

| Parent | Home |
|----------|------|
| [06 - Team Kit](../README.md) | [Workspace Root](../../README.md) |
