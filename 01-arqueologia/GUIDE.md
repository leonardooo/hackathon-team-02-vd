---
title: "Stage 1 - Digital Archaeology"
description: "Step-by-step guide for archaeological analysis of the legacy SIFAP system. Exploration is MANDATORY — Stage 2 gate requires legacy traceability on every requirement."
---

# Stage 1 - Digital Archaeology (3 hours)

> **HARD GATE.** You cannot start Stage 2 until your team has read all 15 Natural programs and all 4 DDMs. Every EARS requirement in Stage 2 must trace back to a `.NSN` or `.ddm` file (or be marked `[GREENFIELD]` with justification). See [`LEGACY-EXPLORATION-CHECKLIST.md`](LEGACY-EXPLORATION-CHECKLIST.md) for the verification matrix.
>
> **Why?** In the previous workshop edition some teams skipped this stage and wrote specs from the modernization brief alone. Their prototypes ended up missing 29 years of business rules. This time, the gate is enforced by CI and by facilitator sign-off at H1 (~11:45).

## Objective

Explore the legacy SIFAP system (Natural/Adabas) and extract business rules, dependencies, and "mysteries" — hidden logic without documentation. Output of this stage is the input of Stage 2.

## Where to find the legacy code

The legacy is bundled inside your kit at [`legacy/`](../legacy/):

| Resource | Path | Quantity |
|----------|------|----------|
| Natural programs | [`legacy/natural-programs/`](../legacy/natural-programs/) | 15 .NSN files |
| Adabas DDMs | [`legacy/adabas-ddms/`](../legacy/adabas-ddms/) | 4 .ddm files |
| Partial documentation | [`legacy/legacy-docs/`](../legacy/legacy-docs/) | 3 outdated docs |
| System README | [`legacy/README.md`](../legacy/README.md) | 1 file |
| Terminal demo | [`legacy/demo/sifap-terminal.html`](../legacy/demo/sifap-terminal.html) | open in browser |

## Workflow (3 hours)

### Hour 1 - Reconnaissance (09:15-10:15)

1. **Everyone**: Read the SIFAP README.md (15 min) — understand history, team, criticality
2. **Pair 1 (PO + RE)** with **Pair 5 (DevOps + TW)** as writing voice: open each .NSN and seed the glossary
3. **Pair 2 (EA + SA)**: begin the dependency map — which programs call which?
4. **Pair 4 (DBA + QA)** with **Pair 3 (TL + Dev)** as readers: open the 4 DDMs — map fields to modern entities

### Hour 2 - Extraction (10:15-11:15)

5. **All pairs in parallel**: each pair analyzes 3 .NSN programs — find business rules (15 programs ÷ 5 pairs = 3 each)
6. **Use Copilot Chat**: ask Copilot to explain each program
7. **Document**: for every rule you find, record it in the catalog (Pair 1 owns the catalog)

### Hour 3 - Synthesis (11:15-12:00)

8. **Pair 5 (TW lead)**: consolidate the glossary (minimum 30 terms)
9. **Pair 2 (EA lead)**: finalize the dependency map in Mermaid
10. **Pair 1 (RE lead)**: consolidate the rules catalog
11. **Pair 1 (PO lead)**: prioritize the rules — which to migrate first?
12. **Pair 4 (QA lead)**: list the "mysteries" you found

## Prompts for Copilot Chat

Use these prompts to explore the legacy code:

1. "Explain this Natural program line by line: [paste the code]"
2. "Which business rules are implemented in this code?"
3. "Which DDM fields does this program read and write?"
4. "Find all hardcoded values in this program and explain what they do"
5. "Does this program have any conditional logic that is not documented in the comments?"
6. "Compare CALCBENF.NSN and BATCHPGT.NSN — is there duplicated logic?"
7. "Which programs depend on the BENEFICIARIO DDM?"
8. "Explain the difference between status A, S, C, I, D in the SIFAP context"
9. "Does this code have any rule that looks like a workaround or hack?"
10. "Create a Mermaid diagram of the dependencies among the 15 programs"

## Definition of Done (HARD GATE for Stage 2)

By the end of Stage 1, your team **must** have:

- [ ] Glossary with 30+ terms (file: [`glossary.md`](glossary.md))
- [ ] Business rules catalog with **at least 15 rows, every row with a non-empty `Programa Fonte`** (file: [`business-rules-catalog.md`](business-rules-catalog.md))
- [ ] Dependency map in Mermaid covering **all 15 .NSN programs** (file: [`dependency-map.md`](dependency-map.md))
- [ ] At least 5 mysteries documented with file + line evidence (file: [`mysteries-found.md`](mysteries-found.md))
- [ ] Discovery report with no remaining placeholders (file: [`discovery-report.md`](discovery-report.md))

> **Facilitator check at ~11:45** — a facilitator (blue lanyard) reviews this checklist against your repo. Missing items block the team from opening Stage 2. The CI workflow [`spec-quality.yml`](../.github/workflows/spec-quality.yml) also runs a `legacy-traceability` job that fails the PR if any EARS requirement in `.specs/` lacks a `source_legacy` line.

## Golden Tip - Mystery Hunt!

There are **10 hidden business rules**, **3 easter eggs**, and **4 inconsistencies** planted in the legacy code. Open the `mysteries-checklist.md` file in this directory — it lists what to look for (without giving away the answers!).

Your team is evaluated by the rubric (dimension A1) on the quantity and quality of mysteries found. Total possible: **32 points**.

After 90 minutes, the **facilitator** (organizing team member wearing a blue lanyard, circulating around the room) can give calibrated hints if your team is stuck. Raise your hand!
