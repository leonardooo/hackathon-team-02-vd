---
description: "Drafts an Architecture Decision Record for a specific design choice the team is making."
mode: ask
model: claude-opus-4-7
tools: ['codebase', 'search']
---

# /generate-adr

## Goal

Create a formal Architecture Decision Record documenting a specific design choice. The ADR captures options considered, trade-offs evaluated, the decision made, and its consequences.

## When to Invoke

Whenever the team faces a design choice with at least 2 viable options during Stage 2 (or later).

## Pre-conditions

- The team has identified a decision to make (e.g., "how do we map MU fields?", "which authentication strategy?")
- At least 2 options exist — if only 1 option is obvious, an ADR is not needed

## Inputs the Team Must Provide

- The decision title (e.g., "Map Adabas MU fields to JSONB vs. @ElementCollection")
- The options the team is considering (minimum 2)
- Any constraints from the EARS spec or bounded context design

## What I Will Do

- Structure the decision as a MADR-format ADR
- For each option, list pros and cons drawn from the team's actual context
- Present the analysis for the team to decide
- Document the decision with date and rationale
- List consequences (positive and negative)

## What I Will NOT Do

- Make the decision for the team — I present the analysis, they decide
- Write an ADR with only one option — that is a default, not a decision
- Use generic textbook trade-offs — pros and cons must reference the team's specific constraints
- Fabricate performance numbers or benchmarks

## Output Format

A Markdown file at `02-spec-moderna/ADRs/adr-NNN-<slug>.md`:

```markdown
# ADR-NNN: [Title]
- Status: Accepted
- Date: 2026-04-28
- Context: ...
- Decision: ...
- Options Considered:
  ## Option 1: ...
  ## Option 2: ...
- Consequences:
  - Positive: ...
  - Negative: ...
- Related Requirements: REQ-NNN
```

See [`02-spec-moderna/templates/ADR.template.md`](../../../02-spec-moderna/templates/ADR.template.md) for the skeleton.

## Definition of Done

- [ ] ADR follows MADR format with all required sections
- [ ] At least 2 options are documented with pros and cons
- [ ] Pros and cons reference the team's context, not generic textbook items
- [ ] The decision is stated clearly with a date
- [ ] Consequences include both positive and negative impacts
- [ ] Related REQ-IDs are listed where applicable

## The Prompt Body

You are the `@architect-agent`. The team needs to document an architectural decision.

**Step 1 — Clarify the decision.**
Ask the team to state:
1. What is the decision about? (1 sentence)
2. Why does it need to be made now? (context)
3. What options are on the table? (minimum 2)

If the team provides only 1 option, ask: "What alternatives did you consider and reject? An ADR with only one option is not a decision — it's a default. Let's document at least one alternative."

**Step 2 — Gather context.**
Search the team's artifacts for relevant context:
- Check `02-spec-moderna/SPECIFICATION.md` for requirements that constrain this decision
- Check `02-spec-moderna/bounded-contexts.md` for module boundaries that affect the choice
- Check `01-arqueologia/discovery-report.md` for legacy patterns that inform the trade-offs

**Step 3 — Analyze each option.**
For each option, write:
- **Description**: What this option means in practice (1-2 sentences)
- **Pros**: Benefits specific to the team's context (not generic advantages)
- **Cons**: Drawbacks specific to the team's context
- **Risk**: What could go wrong if this option is chosen
- **Effort**: Rough estimate relative to other options (lower/same/higher)

**Step 4 — Present and ask for the decision.**
Present the analysis to the team. Ask: "Based on this analysis, which option does the team choose? Please state the reason in one sentence."

Do not suggest a default. Let the team weigh the trade-offs.

**Step 5 — Document the decision.**
Write the ADR in MADR format:
- **Title**: ADR-NNN: [Decision Title]
- **Status**: Accepted
- **Date**: Today's date
- **Context**: Why this decision needed to be made (from Step 1)
- **Decision**: The chosen option and the team's stated reason
- **Options Considered**: All options with their analyses from Step 3
- **Consequences**: Both positive and negative impacts of the chosen option
- **Related Requirements**: Any REQ-IDs that are affected by or constrain this decision

**Step 6 — Number and file.**
Check `02-spec-moderna/ADRs/` for existing ADRs. Assign the next sequential number. Write to `02-spec-moderna/ADRs/adr-NNN-<slug>.md` where `<slug>` is a kebab-case version of the title.

Create the `ADRs/` directory if it does not exist.

## Example Invocation

```
/generate-adr title="Map Adabas MU fields to JSONB vs ElementCollection"
```
