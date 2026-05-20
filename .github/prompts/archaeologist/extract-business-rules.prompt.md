---
description: "Extracts business rules from a Natural program by reading IF/THEN/ELSE blocks and confirming with documentation."
mode: ask
model: claude-opus-4-7
tools: ['codebase', 'search']
---

# /extract-business-rules

## Goal

Read a chosen Natural program and extract every candidate business rule by identifying conditional logic (IF/THEN/ELSE, DECIDE, AT BREAK). Each rule is stated in plain English, traced to source, and classified as confirmed or mystery.

## When to Invoke

After the team has completed the initial inventory (`/archaeology-kickoff`) and chosen a program to read.

## Pre-conditions

- `01-arqueologia/inventory.md` exists
- The team has selected a specific Natural program file to analyze
- The `legacy/` folder is accessible

## Inputs the Team Must Provide

- The full path to the Natural program to analyze (e.g., `legacy/programs/PGXXXXXX.nat`)
- Any available documentation paths in `legacy/docs/` (optional — used for confirmation)

## What I Will Do

- Read the specified program top to bottom
- Identify every conditional block: `IF...THEN...ELSE...END-IF`, `DECIDE ON`, `AT BREAK OF`, and comparison operators
- For each conditional block, formulate a candidate business rule in plain English
- Cross-reference against documentation in `legacy/docs/` if available
- Classify each rule as **confirmed** (documentation match), **inferred** (code-only, no doc support), or **mystery** (logic unclear)
- Draft EARS notation candidates for confirmed rules

## What I Will NOT Do

- Infer rules from program names or variable names alone — I read the actual logic
- Fabricate explanations for unclear code — mysteries stay mysteries
- Summarize the entire program in one pass — I work block by block
- Reference knowledge about any specific legacy system — I read only what the team shows me
- Auto-promote inferred rules to confirmed status

## Output Format

Append to `01-arqueologia/business-rules-catalog.md`:

```markdown
## Rules from [filename]

| # | Rule Statement | EARS Candidate | Source | Classification | Notes |
|---|---|---|---|---|---|
| 1 | When X, the system shall Y | Event-driven | file.nat:L42-58 | Confirmed | Matches doc section 3.2 |
| 2 | If Z, the system shall reject | Unwanted | file.nat:L73-81 | Mystery | <!-- mystery: unclear what triggers Z --> |
```

## Definition of Done

- [ ] Every IF/THEN/ELSE, DECIDE, and AT BREAK block in the program has been examined
- [ ] Each candidate rule has a file path and line number range
- [ ] Confirmed rules cite the documentation section that supports them
- [ ] Inferred rules are clearly marked and not treated as facts
- [ ] Mysteries have `<!-- mystery: ... -->` markers with a description of what is unknown
- [ ] At least one EARS notation candidate exists per confirmed rule

## The Prompt Body

You are the `@archaeologist-agent`. The team has chosen a Natural program to analyze for business rules. You will read it systematically and extract every conditional business rule.

**Step 1 — Read DEFINE DATA.**
Open the specified file. Read the `DEFINE DATA` section first. List every variable with its type, length, and any comment. This establishes the vocabulary for understanding conditions later.

**Step 2 — Identify conditional blocks.**
Scan the program for every instance of:
- `IF ... THEN ... [ELSE ...] END-IF`
- `DECIDE ON FIRST/EVERY VALUE OF`
- `AT BREAK OF`
- Comparison operators used with literals (numeric values, string constants, date values)

For each block, record: start line, end line, the condition expression, the action taken in each branch.

**Step 3 — Formulate candidate rules.**
For each conditional block, write a business rule statement in plain English. Follow this pattern:
- Start with the condition: "When [condition]..." or "If [condition]..."
- State the action: "...the system shall [action]"
- Include the else branch if it exists: "Otherwise, the system shall [alternative action]"

**Step 4 — Attempt EARS classification.**
For each rule, propose which EARS pattern it matches:
- **Ubiquitous**: Always true, no trigger → "The system shall..."
- **Event-driven**: Triggered by an event → "When [event], the system shall..."
- **State-driven**: Active while in a state → "While [state], the system shall..."
- **Optional**: Conditional on a feature/config → "Where [condition], the system shall..."
- **Unwanted**: Error handling or rejection → "If [unwanted condition], then the system shall..."

**Step 5 — Cross-reference with documentation.**
If the team provided documentation paths, search those files for keywords matching the variable names or literal values in the conditions. For each match found, upgrade the rule to "confirmed" and cite the documentation section. For each rule without documentation support, classify as "inferred."

**Step 6 — Flag mysteries.**
For any conditional block where:
- The variable names are cryptic and the condition's intent is unclear
- The literal values have no obvious meaning (magic numbers)
- The logic seems contradictory or redundant

Mark it as `<!-- mystery: [description of what is unclear] -->` and add it to the catalog with classification "mystery."

**Step 7 — Output results.**
Append the results to `01-arqueologia/business-rules-catalog.md`. If the file does not exist, create it with a header. Each rule entry must have: rule number, plain English statement, EARS candidate, source file and line range, classification, and notes.

Do not infer rules from program names or file organization. Read the actual code. If a block's purpose is genuinely unclear after careful reading, it is a mystery — not a rule.

## Example Invocation

```
/extract-business-rules file=legacy/programs/PGMAIN01.nat docs=legacy/docs/
```
