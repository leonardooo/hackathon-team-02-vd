---
description: "Synthesizes Stage 1 outputs into a single discovery report ready for Stage 2 handoff."
mode: ask
model: claude-opus-4-7
tools: ['codebase', 'search']
---

# /discovery-report

## Goal

Aggregate all Stage 1 artifacts into a single discovery report that serves as the handoff document to Stage 2. The report must be self-contained: anyone reading it should understand what the team found without needing to open individual artifacts.

## When to Invoke

At the end of Stage 1, after the team has completed the inventory, business rules extraction, dependency mapping, and mystery catalog.

## Pre-conditions

All four Stage 1 artifacts must exist:
- `01-arqueologia/inventory.md` (from `/archaeology-kickoff`)
- `01-arqueologia/business-rules-catalog.md` (from `/extract-business-rules`)
- `01-arqueologia/dependency-map.md` (from `/map-dependencies`)
- `01-arqueologia/mysteries-found.md` (from `/catalog-mysteries`)

If any artifact is missing or empty, the agent will refuse to generate the report and list what is missing.

## Inputs the Team Must Provide

- Confirmation that all four artifacts are complete (or acknowledgment of gaps)
- The team name for the report header

## What I Will Do

- Verify all four input artifacts exist and are non-empty
- Write an executive summary (5 sentences max) covering what was found
- Organize findings into "confirmed" and "risky" categories
- Propose 3-5 bounded context carving hypotheses based on dependency clusters
- Cross-reference mysteries against business rules to identify highest-risk gaps

## What I Will NOT Do

- Generate the report if any input artifact is missing — I will list what is needed
- Decide on bounded contexts — I propose hypotheses for the architect to evaluate
- Fill in gaps by guessing — if the team did not find something, it stays unfound
- Add new analysis beyond what the artifacts contain — I synthesize, not discover

## Output Format

A Markdown file at `01-arqueologia/discovery-report.md`:

```markdown
# Discovery Report — Stage 1
## Executive Summary (5 sentences max)
## What We Know (Confirmed)
### Business Rules (confirmed only)
### Dependencies (verified edges)
### Data Structures (documented DDMs)
## What Is Risky
### Mysteries that Block Stage 2
### Rules with Weak Evidence
## Recommended Carving Hypotheses
### Hypothesis 1: [Name] — [1-line rationale]
...
## Source Artifacts
## Team Sign-off
```

## Definition of Done

- [ ] Report exists and is under 3 pages when printed
- [ ] Executive summary is exactly 5 sentences or fewer
- [ ] Every claim in the "What We Know" section references a source artifact by relative path
- [ ] Mysteries that block Stage 2 are prominently listed with their MYS-IDs
- [ ] 3-5 carving hypotheses are proposed, each with a name and 1-line rationale
- [ ] Hypotheses are explicitly labeled as hypotheses, not decisions

## The Prompt Body

You are the `@archaeologist-agent`. Stage 1 is ending. The team needs a single document that captures everything they discovered, ready for the `@architect-agent` to use in Stage 2.

**Step 1 — Verify inputs.**
Check that all four required artifacts exist under `01-arqueologia/`:
1. `inventory.md`
2. `business-rules-catalog.md`
3. `dependency-map.md`
4. `mysteries-found.md`

If any file is missing or empty, stop immediately. List the missing artifacts and tell the team which prompt to run to create them. Do not proceed with a partial report.

**Step 2 — Write the executive summary.**
Read all four artifacts. Write exactly 5 sentences or fewer that answer:
1. How large is the legacy codebase? (programs, DDMs, lines of code if counted)
2. How many confirmed business rules were found?
3. How connected is the system? (dense call graph vs. isolated programs)
4. What is the biggest risk going into Stage 2? (the most critical mystery)
5. What is the team's confidence level for modernization? (high/medium/low, based on evidence)

**Step 3 — Build the "What We Know" section.**
From the business rules catalog, extract only rules classified as "confirmed." List them with their EARS notation candidates and source references.

From the dependency map, list verified program-to-program and program-to-data edges. Include the total counts.

From the inventory, summarize the DDM structures documented.

Every statement must cite its source artifact: `[See business-rules-catalog.md, Rule #3](business-rules-catalog.md)`.

**Step 4 — Build the "What Is Risky" section.**
From the mystery catalog, extract all mysteries classified as "blocks-stage-2." List them with their MYS-IDs, descriptions, and suggested resolution paths.

From the business rules catalog, extract rules classified as "inferred" (code-only, no documentation support). These are not confirmed — they carry risk if used as the basis for requirements.

**Step 5 — Propose carving hypotheses.**
Analyze the dependency map for clusters — groups of programs that are tightly connected to each other but loosely connected to other groups. Each cluster is a candidate bounded context.

For each hypothesis, provide:
- A name in business language (not technical jargon)
- Which programs belong to it
- Which DDMs it owns
- A 1-line rationale for why this is a natural boundary

Propose 3-5 hypotheses. Explicitly label them as hypotheses, not decisions. The `@architect-agent` in Stage 2 will evaluate and decide.

**Step 6 — List source artifacts.**
At the bottom of the report, list all four source artifacts with relative paths so anyone can navigate to the details.

**Step 7 — Add team sign-off.**
Add a section for the team to sign off: "Reviewed by: [names], Date: [date], Confidence: [high/medium/low]". Leave blank for the team to fill in.

Write the complete report to `01-arqueologia/discovery-report.md`. The report must be self-contained and under 3 pages when printed.

## Example Invocation

```
/discovery-report team="Team 07"
```
