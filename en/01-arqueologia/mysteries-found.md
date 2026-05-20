---
title: "Mysteries Found — SIFAP Legacy"
description: "Log of hidden rules, workarounds, and inconsistencies your team discovered while reading the legacy. Minimum 5 to pass the Stage 2 gate."
locale: "en"
canonical_path: "06-kit-repositorio-times/01-arqueologia/mysteries-found.md"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-05-18"
version: "2.0.0"
status: "template"
tags: ["stage-1", "archaeology", "mysteries", "template", "en"]
---

# Mysteries Found — SIFAP Legacy

> Record every piece of logic, behavior, or code your team couldn't explain. "Mysteries" are code blocks without documentation, with non-obvious logic, or that look like workarounds.

## Where this fits in the SDLC

```mermaid
flowchart LR
 classDef current fill:#F25022,stroke:#B33816,color:#fff
 classDef next fill:#FFF7E0,stroke:#FFB900,color:#0A0A0A

 HUNT[mysteries-checklist.md]:::next
 FOUND[This file]:::current

 HUNT --> FOUND
```

## Who works here

**Pair 4 (QA)** consolidates. Every pair contributes mysteries from their 3 programs.

## What counts as a "mystery"?

- Code that does something unexpected with no comment explaining why
- Hardcoded values with no explanation (magic numbers)
- Conditional logic that looks like a workaround or hack
- DDM fields that no program uses
- Programs that exist but nobody calls
- Behavior that diverges between what docs say and what code does
- Easter eggs left by the original developers

## Confidence levels

| Level | Meaning |
|-------|---------|
| **HIGH** | We're sure something is off here |
| **MEDIUM** | Looks suspicious, but there might be an explanation |
| **LOW** | Could be intentional, but we couldn't confirm |

## Mysteries catalog

| ID | Description | Where found | Potential impact | Confidence |
|----|-------------|-------------|------------------|------------|
| MYS-001 | | | | |
| MYS-002 | | | | |
| MYS-003 | | | | |
| MYS-004 | | | | |
| MYS-005 | | | | |
| MYS-006 | | | | |
| MYS-007 | | | | |
| MYS-008 | | | | |
| MYS-009 | | | | |
| MYS-010 | | | | |

## Mystery details

### MYS-001: [Mystery title]

- **File**: [file name and lines]
- **Code snippet**:
```natural
* Paste the relevant snippet here
```
- **What we expected**: [expected behavior]
- **What the code does**: [actual behavior]
- **Team hypothesis**: [best guess]
- **Risk if ignored**: [what can go wrong in the migration]

---

> Copy the block above for each mystery found.

## Easter eggs

> Hint: there are **3 easter eggs** hidden in the legacy code. Log the ones you find:

1. [ ] Easter Egg 1: ___
2. [ ] Easter Egg 2: ___
3. [ ] Easter Egg 3: ___

## Common pitfalls

| ❌ | ✅ |
|----|----|
| Vague "the calculation is weird" entry | Pinpoint file + line + expected vs actual |
| Logging an implementation quirk as a mystery | Mystery = domain behavior; quirks of Natural syntax don't count |
| Forgetting impact | Every mystery has a 1-line "what breaks in migration" |

## How you know you're done

- [ ] At least 5 mysteries documented
- [ ] Each has file + line range
- [ ] Each has impact stated
- [ ] At least 1 easter egg attempted

## Summary

- Total mysteries found: ___
- High confidence: ___
- Medium confidence: ___
- Low confidence: ___
- Easter eggs found: ___ / 3

## Next step

Pair 1 (Vision) cites the high-confidence mysteries in `discovery-report.md` as risks for Stage 2. Pair 4 (QA) carries the rule-shaped mysteries forward as **test scenarios** in Stage 3.

## Navigation

| Previous | Home | Next |
|----------|------|------|
| [Mysteries Checklist](mysteries-checklist.md) | [Stage 1](README.md) | [Discovery Report](discovery-report.md) |
