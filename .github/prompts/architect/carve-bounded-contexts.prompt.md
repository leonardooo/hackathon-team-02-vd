---
description: "Evaluates the carving hypotheses from Stage 1 and decides on bounded contexts for the Modular Monolith."
mode: ask
model: claude-opus-4-7
tools: ['codebase', 'search']
---

# /carve-bounded-contexts

## Goal

Transform the carving hypotheses from the Stage 1 discovery report into evaluated, decided bounded contexts. Each context gets a name, responsibilities, owned data, and inter-context communication rules.

## When to Invoke

At the start of Stage 2, immediately after reviewing the discovery report from Stage 1.

## Pre-conditions

- `01-arqueologia/discovery-report.md` exists with at least 3 carving hypotheses
- The team has reviewed the discovery report and is ready to make architectural decisions

## Inputs the Team Must Provide

- Path to the discovery report
- Any additional constraints or preferences (e.g., "we want to keep payments and enrollment separate")

## What I Will Do

- Read the discovery report's carving hypotheses
- Evaluate each hypothesis against three criteria: cohesion, coupling, and change frequency
- Present the analysis to the team for each hypothesis
- Document rejections with reasoning
- Formalize accepted contexts with names, responsibilities, and data ownership

## What I Will NOT Do

- Auto-decide which hypotheses to accept — the team makes the final call
- Propose microservices — this is a Modular Monolith
- Fabricate business context for the hypotheses — I work only with what Stage 1 discovered
- Skip the evaluation criteria — every hypothesis gets the full analysis

## Output Format

A Markdown file at `02-spec-moderna/bounded-contexts.md`:

```markdown
# Bounded Context Map
## Evaluation Criteria
## Hypothesis Evaluations
### [Hypothesis Name] — ACCEPTED / REJECTED
## Final Bounded Contexts
### [Context Name]
- Responsibility:
- Owned data (DDMs/tables):
- Public interface:
- Why it's its own context:
## Inter-Context Communication
## Mermaid Context Map Diagram
```

## Definition of Done

- [ ] Every hypothesis from the discovery report is evaluated against all three criteria
- [ ] Rejected hypotheses have documented reasoning
- [ ] 2-5 bounded contexts are finalized with names in business language
- [ ] Each context has: responsibility paragraph, owned data list, public interface outline
- [ ] A Mermaid context map diagram shows relationships between contexts
- [ ] No context is an isolated island — communication paths are defined

## The Prompt Body

You are the `@architect-agent`. The team is beginning Stage 2 and needs to decide on bounded contexts for the Modular Monolith.

**Step 1 — Read the discovery report.**
Open `01-arqueologia/discovery-report.md`. Extract the carving hypotheses section. List each hypothesis with its name, included programs, owned DDMs, and rationale.

**Step 2 — Evaluate against three criteria.**
For each hypothesis, analyze:

**Cohesion** — Do the business rules within this group relate to the same business capability? Check by reviewing the confirmed rules from `01-arqueologia/business-rules-catalog.md` that fall within this group. High cohesion = strong candidate.

**Coupling** — How many dependencies cross this boundary? Check the dependency map at `01-arqueologia/dependency-map.md`. Count edges that would cross between this context and others. Low coupling = strong candidate. High coupling suggests the boundary may be in the wrong place.

**Change frequency** — In the legacy system, which programs in this group were likely modified together? Use file naming patterns and call relationships as proxies. Programs that call each other heavily likely change together and belong in the same context.

Present each evaluation as a scorecard: High/Medium/Low for each criterion.

**Step 3 — Present to the team for decision.**
For each hypothesis, present:
- The scorecard
- A recommendation (accept, reject, or merge with another hypothesis)
- The reasoning

Then ask the team: "Do you accept this recommendation? If not, what would you change?"

The team makes the final decision. If the team overrides your recommendation, document their reasoning.

**Step 4 — Formalize accepted contexts.**
For each accepted bounded context, write:
- **Name**: A business-language name (e.g., "Payment Processing," not "payment-svc")
- **Responsibility**: 1 paragraph describing what this context owns
- **Owned data**: Which DDMs/tables belong exclusively to this context
- **Public interface**: What operations this context exposes to other contexts (method signatures or event names — not implementation)
- **Why it's its own context**: 1 sentence linking back to the evaluation criteria

**Step 5 — Define inter-context communication.**
For each pair of contexts that need to communicate, specify:
- The direction (A calls B, or bidirectional)
- The mechanism: in-process method call via interface, domain event, or shared kernel type
- The data exchanged (IDs only? Full DTOs? Events?)

Reinforce: this is a Modular Monolith. Communication is in-process, not over HTTP between services.

**Step 6 — Draw the context map.**
Create a Mermaid diagram showing all contexts as boxes, with labeled arrows for communication relationships. Use the kit's color palette: fill `#0f172a`, stroke `#334155`, text `#e2e8f0`.

**Step 7 — Write the output.**
Write to `02-spec-moderna/bounded-contexts.md`.

## Example Invocation

```
/carve-bounded-contexts report=01-arqueologia/discovery-report.md
```
