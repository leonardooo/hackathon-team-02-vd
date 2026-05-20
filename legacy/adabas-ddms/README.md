---
title: "Adabas DDM Files - SIFAP Legacy"
description: "Data Definition Module files describing the Adabas database structure used by the legacy SIFAP system"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-04-23"
version: "1.0.0"
status: "approved"
tags: ["adabas", "ddm", "legacy", "sifap", "database"]
---

# Adabas DDM Files

> Data Definition Modules describing the physical and logical structure of the Adabas database used by the legacy SIFAP system.

## Contents

| File | Description |
|------|-------------|
| `BENEFICIARIO.ddm` | Beneficiary master record - personal data, documents, enrollment |
| `PAGAMENTO.ddm` | Payment transaction record - amounts, dates, statuses |
| `PROGRAMA-SOCIAL.ddm` | Social program definitions - rules, thresholds, eligibility |
| `AUDITORIA.ddm` | Audit trail - who changed what, when |

## Usage

These files are **read-only reference material** for workshop teams during the Archaeology stage (Stage 1). Map each DDM field to a JPA entity field in the modernized system.

## Navigation

| Parent | Home |
|----------|------|
| [02 - Legacy Scenario](../README.md) | [Workspace Root](../../README.md) |
