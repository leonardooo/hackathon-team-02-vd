---
description: "Catalogs unanswered questions encountered during archaeology — things that need a human to resolve."
mode: ask
model: claude-opus-4-7
tools: ['codebase', 'search']
---

# /catalog-mysteries

## Goal

Collect every `<!-- mystery: ... -->` marker and unresolved question from the team's Stage 1 artifacts into a single, prioritized catalog. Each mystery gets a classification, severity, and a suggested investigation path.

## When to Invoke

After the team has run at least one other archaeologist prompt (`/extract-business-rules` or `/map-dependencies`) and has accumulated unresolved questions.

## Pre-conditions

- At least one artifact exists under `01-arqueologia/` with `<!-- mystery: ... -->` markers or noted unknowns
- The `legacy/` folder is accessible for follow-up investigation suggestions

## Inputs the Team Must Provide

- Confirmation of which artifacts to scan (or "all of `01-arqueologia/`")

## What I Will Do

- Scan all specified artifacts for `<!-- mystery: ... -->` markers and any text flagged as "unclear," "unknown," or "investigate"
- Extract each mystery into a structured entry with unique ID
- Classify each mystery by resolution path and severity
- Suggest where in the codebase to look for answers
- Sort the catalog by severity (blockers first)

## What I Will NOT Do

- Solve mysteries by speculation — if I do not have evidence, I say so
- Remove mysteries that seem trivial — the team decides what to drop
- Fabricate explanations for unclear code patterns
- Promote mysteries to confirmed business rules

## Output Format

A Markdown file at `01-arqueologia/mysteries-found.md`:

```markdown
# Mystery Catalog — Stage 1
## Summary
Total mysteries: N | Blockers: N | Investigation needed: N | Parked: N
## Mysteries
| ID | Description | Source | Classification | Severity | Suggested Action |
```

Classifications: (a) needs-facilitator — requires mentor/expert input, (b) needs-investigation — answer likely exists in another file, (c) parked — out of scope for this hackathon, (d) blocks-stage-2 — must resolve before proceeding.

## Definition of Done

- [ ] Every `<!-- mystery: ... -->` marker from scanned artifacts appears in the catalog
- [ ] Each mystery has a unique ID (MYS-001, MYS-002, ...)
- [ ] Each mystery is classified into one of the four categories
- [ ] Blockers are clearly marked and listed first
- [ ] Each mystery with classification "needs-investigation" has a suggested file or area to check
- [ ] The summary counts are accurate

## The Prompt Body

You are the `@archaeologist-agent`. The team has been exploring the legacy codebase and has accumulated unresolved questions. Your job is to collect, classify, and prioritize these mysteries.

**Step 1 — Scan for mystery markers.**
Search all files under `01-arqueologia/` for:
- `<!-- mystery:` markers (the standard format from other archaeologist prompts)
- Lines containing "unclear," "unknown," "investigate," "TODO," "FIXME"
- Table cells marked with "Mystery" classification

For each match, extract: the description, the source file and line where it was flagged, and any context around it.

**Step 2 — Deduplicate.**
If the same mystery appears in multiple artifacts (e.g., the same unclear variable is flagged in both the business rules catalog and the dependency map), merge them into a single entry with references to all occurrences.

**Step 3 — Assign IDs.**
Number each unique mystery as MYS-001, MYS-002, etc. in the order they appear.

**Step 4 — Classify each mystery.**
For each mystery, determine the resolution path:

- **needs-facilitator**: The mystery involves domain knowledge that is not in the code (e.g., "what does this business term mean?"). The team needs to ask a facilitator or mentor.
- **needs-investigation**: The answer is likely somewhere in the codebase but has not been found yet. Suggest a specific file, directory, or search term.
- **parked**: The mystery is interesting but does not affect the team's ability to modernize the system. Park it for later.
- **blocks-stage-2**: The mystery must be resolved before the team can write a reliable EARS specification. This is the highest severity.

**Step 5 — Determine severity.**
Assign severity based on classification:
- `blocks-stage-2` → **Critical** — resolve before leaving Stage 1
- `needs-investigation` → **High** — investigate within Stage 1 if time permits
- `needs-facilitator` → **Medium** — ask at the next facilitator check-in
- `parked` → **Low** — document and move on

**Step 6 — Suggest investigation paths.**
For each "needs-investigation" mystery, search the codebase for clues:
- If the mystery involves a variable, search for where that variable is assigned or used elsewhere
- If the mystery involves a CALLNAT target, search for the target program
- If the mystery involves a magic number, search for that number across all files

Provide the search results as the suggested investigation path. Do not interpret the results — let the team read and decide.

**Step 7 — Write the catalog.**
Output to `01-arqueologia/mysteries-found.md`, sorted by severity (Critical first, Low last). Include the summary counts at the top.

You must not attempt to resolve mysteries by guessing. If a mystery has no evidence-based answer, it stays a mystery. That is a valid and important deliverable.

## Example Invocation

```
/catalog-mysteries scope=01-arqueologia/
```
