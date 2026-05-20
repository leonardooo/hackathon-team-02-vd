---
mode: ask
model: claude-sonnet-4-6
description: "Convert informal requirements to EARS notation with mandatory legacy traceability"
---

# /ears-convert

## Hard pre-check (workshop SIFAP)
Before writing any EARS, **demand a legacy source** for each input statement. Acceptable sources:
- a file in `legacy/natural-programs/*.NSN` (preferred, with line range)
- a file in `legacy/adabas-ddms/*.ddm`
- the literal marker `[GREENFIELD]` with a one-line justification

If the user provides a statement **without** identifying a legacy source, do NOT produce an EARS. Respond:

> "I cannot emit this EARS yet. Please tell me which file in `legacy/` is the source (e.g. `legacy/natural-programs/BATCHPGT.NSN`), or mark it `[GREENFIELD]` with a one-line justification. CI rejects EARS without `source_legacy`."

Only after every statement has an acceptable source, proceed to the steps below.

## Task
Convert a list of informal requirements into EARS notation, classify each by pattern, attach the legacy source, and flag anything that cannot be expressed in EARS.

## Steps
1. For each input statement, identify the pattern: Ubiquitous, Event-driven, State-driven, Optional, Unwanted, or Complex.
2. Rewrite the statement using the correct EARS template:
 - Ubiquitous: `The system shall ...`
 - Event-driven: `WHEN <trigger> the system shall ...`
 - State-driven: `WHILE <state> the system shall ...`
 - Optional: `WHERE <feature> is included the system shall ...`
 - Unwanted: `IF <undesired> THEN the system shall ...`
 - Complex: combine the above with `AND / OR` inside the trigger clause.
3. Assign a REQ-ID in the format `REQ-<DOMAIN>-NNN`.
4. Attach the `source_legacy:` line provided by the user (do not invent it).
5. If a requirement cannot be made testable (vague, contradictory, or metric-free), flag it as `NEEDS-CLARIFICATION` with the specific ambiguity.

## Output
For every requirement, emit the YAML block below (not a flat table) so the CI `legacy-traceability` job can parse it:

```yaml
REQ-<DOMAIN>-NNN:
 pattern: <ubiquitous|event-driven|state-driven|optional|unwanted|complex>
 text: "<EARS statement>"
 source_legacy: <legacy path with line range, or [GREENFIELD] + justification>
 original: "<verbatim input>"
 notes: "<optional, e.g. NEEDS-CLARIFICATION reason>"
```

## Quality Gate
- [ ] 100% of input statements processed
- [ ] **Every emitted REQ-ID has a non-empty `source_legacy:` line**
- [ ] No EARS statement contains words like "appropriate", "reasonable", "fast" without a metric
- [ ] Every REQ-ID is unique
- [ ] `NEEDS-CLARIFICATION` items have a specific question attached
