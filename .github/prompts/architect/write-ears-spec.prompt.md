---
description: "Translates confirmed business rules into EARS notation requirements for the modern system."
mode: ask
model: claude-opus-4-7
tools: ['codebase', 'search']
---

# /write-ears-spec

## Goal

Transform confirmed business rules from Stage 1 into formal EARS requirements with unique REQ-IDs, pattern classification, acceptance criteria, and full traceability to source. Mysteries and inferred rules are excluded from the spec but documented separately.

## When to Invoke

After the bounded contexts have been decided (`/carve-bounded-contexts`), so requirements can be organized by context.

## Pre-conditions

- `01-arqueologia/business-rules-catalog.md` exists with classified rules
- `02-spec-moderna/bounded-contexts.md` exists with finalized contexts

## Inputs the Team Must Provide

- Confirmation of which rules to include (confirmed rules only, or also selected inferred rules the team is willing to promote)
- Any additional requirements not from legacy code (e.g., "the system must have a REST API" — new capabilities)

## What I Will Do

- Filter the business rules catalog to confirmed rules only (unless team promotes specific inferred rules)
- For each rule, write 1-3 EARS requirement statements
- Assign unique REQ-IDs in format `REQ-NNN`
- Map each requirement to its bounded context
- Write acceptance criteria for each requirement
- Separate mysteries and open questions into a dedicated section

## What I Will NOT Do

- Create requirements without source traceability — every REQ traces to a confirmed rule
- Promote mysteries to requirements — mysteries stay in the open questions section
- Fabricate acceptance criteria that cannot be tested — each criterion must be verifiable
- Skip EARS pattern validation — every requirement must match one of the 6 patterns

## Output Format

A Markdown file at `02-spec-moderna/SPECIFICATION.md`:

```markdown
# SPECIFICATION — Modern System
## Bounded Context: [Name]
### REQ-001: [Statement]
- EARS Pattern: [pattern]
- Source: [rule #, file, line]
- Acceptance Criteria:
  - [ ] ...
...
## Open Questions (Not Requirements Yet)
## Traceability Matrix
```

## Definition of Done

- [ ] At least 10 EARS requirements exist with unique REQ-IDs
- [ ] Every requirement cites its source rule and legacy file
- [ ] Every requirement has at least 2 acceptance criteria
- [ ] Requirements are grouped by bounded context
- [ ] Mysteries appear only in "Open Questions," never as requirements
- [ ] A traceability matrix links every REQ to its source rule

## The Prompt Body

You are the `@architect-agent`. The team needs to write the EARS specification for the modern system based on what was discovered in Stage 1.

**Step 1 — Load confirmed rules.**
Read `01-arqueologia/business-rules-catalog.md`. Filter to rules classified as "confirmed" only. List them with their source references.

If the team wants to promote specific "inferred" rules, ask for explicit confirmation per rule. Each promoted rule must include a note: "Promoted from inferred — team decision, [reason]."

**Step 2 — Map rules to bounded contexts.**
Read `02-spec-moderna/bounded-contexts.md`. For each confirmed rule, determine which bounded context owns it based on the data and programs involved. If a rule spans multiple contexts, flag it for discussion — it may need to be split or assigned to a coordinating layer.

**Step 3 — Write EARS requirement statements.**
For each rule, write 1-3 requirement statements following EARS patterns:

- **Ubiquitous**: "The system shall [action]." — Always applies, no trigger.
- **Event-driven**: "When [event], the system shall [action]." — Triggered by a specific event.
- **State-driven**: "While [state], the system shall [action]." — Active during a state.
- **Optional**: "Where [condition], the system shall [action]." — Only when condition holds.
- **Unwanted**: "If [unwanted condition], then the system shall [action]." — Error/rejection handling.
- **Complex**: "While [state], when [event], the system shall [action]." — Combination.

Validate each statement against the pattern. If a statement does not fit any pattern cleanly, rephrase it until it does or split it into multiple requirements.

**Step 4 — Assign REQ-IDs.**
Number requirements sequentially: REQ-001, REQ-002, etc. Group by bounded context.

**Step 5 — Write acceptance criteria.**
For each requirement, write at least 2 testable acceptance criteria. Each criterion must be:
- Specific (not "the system works correctly")
- Measurable (has a pass/fail condition)
- Traceable (links back to the requirement)

Format: `Given [precondition], when [action], then [expected result]`.

**Step 6 — Handle open questions.**
For every mystery from `01-arqueologia/mysteries-found.md` that is classified as "blocks-stage-2," add it to the "Open Questions" section. Do not convert it to a requirement. Note what information is needed to resolve it.

**Step 7 — Build traceability matrix.**
Create a table linking: `| REQ-ID | EARS Pattern | Source Rule # | Source File | Bounded Context |`.

**Step 8 — Write to file.**
Output to `02-spec-moderna/SPECIFICATION.md`. If the file already exists, ask the team whether to overwrite or append.

## Example Invocation

```
/write-ears-spec rules=01-arqueologia/business-rules-catalog.md contexts=02-spec-moderna/bounded-contexts.md
```
