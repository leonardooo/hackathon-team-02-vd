---
title: "Natural Programs - SIFAP Legacy"
description: "Natural/ADABAS source programs that comprise the legacy SIFAP transaction processing system"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-04-23"
version: "1.0.0"
status: "approved"
tags: ["natural", "adabas", "legacy", "sifap", "programs"]
---

# Natural Programs

> Natural source files (`.NSN`) that implement the legacy SIFAP business logic on the mainframe.

## Contents

### Batch Processing
| Program | Description |
|---------|-------------|
| `BATCHCON.NSN` | Batch conciliation - reconciles payments with SIAFI |
| `BATCHPGT.NSN` | Batch payment - generates monthly payment runs |
| `BATCHREL.NSN` | Batch reporting - produces management reports |

### Registration (CRUD)
| Program | Description |
|---------|-------------|
| `CADBENEF.NSN` | Beneficiary registration |
| `CADDEPEND.NSN` | Dependent registration |
| `CADPROG.NSN` | Social program registration |

### Calculation
| Program | Description |
|---------|-------------|
| `CALCBENF.NSN` | Benefit amount calculation |
| `CALCCORR.NSN` | Correction/adjustment calculation |
| `CALCDSCT.NSN` | Discount calculation |

### Query
| Program | Description |
|---------|-------------|
| `CONSBENF.NSN` | Beneficiary lookup/query |

### Validation
| Program | Description |
|---------|-------------|
| `VALBENEF.NSN` | Beneficiary validation rules |
| `VALDOCS.NSN` | Document validation |
| `VALELEG.NSN` | Eligibility validation |

### Reporting
| Program | Description |
|---------|-------------|
| `RELAUDIT.NSN` | Audit report generation |
| `RELPGT.NSN` | Payment report generation |

## Usage

These files are **read-only reference material**. During Stage 1 (Archaeology), teams analyze these programs to extract business rules and map them to Java service classes.

## Navigation

| Parent | Home |
|----------|------|
| [02 - Legacy Scenario](../README.md) | [Workspace Root](../../README.md) |
