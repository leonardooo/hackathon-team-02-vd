---
mode: ask
model: claude-opus-4-6
description: "Detect contradictions between requirements in SPECIFICATION.md — same feature, different rules — before they become bugs in production."
---

# /contradiction-check

## Goal

You are the requirements engineer auditing `SPECIFICATION.md` for **contradictions**: pairs of requirements that cannot both be satisfied. Contradictions discovered now are spec corrections; contradictions discovered in production are incidents. The deliverable is a list of conflict candidates with evidence, severity, and a proposed resolution.

## Inputs

Ask the user for what is missing.

- The spec file (`.specs/<NNN>-<feature>/SPECIFICATION.md`).
- Any related parent specs whose REQ-IDs are referenced by this one.
- The CONSTITUTION (`.specs/<NNN>-<feature>/CONSTITUTION.md`) — contradictions must also be checked against constitutional rules.
- Any clarification log already produced by `/clarify`.

## Process

1. **Index every requirement.** For each `REQ-ID`, capture: EARS pattern, trigger (event/state/condition), action, actor, outcome, and quantitative thresholds.
2. **Pair-scan within each domain.** Group REQ-IDs by domain (`PAY-*`, `BEN-*`, etc.). Compare each pair. Cross-domain pairs come second.
3. **Look for the four classic contradictions.**
 - **Direct contradiction** — REQ-A says "the system shall X under condition C"; REQ-B says "the system shall not X under condition C."
 - **Threshold conflict** — REQ-A says "respond within 200 ms"; REQ-B says "perform 5 sequential checks each up to 80 ms" — the budgets cannot both hold.
 - **State conflict** — REQ-A allows action while in state S1; REQ-B forbids it during overlapping state S2 ⊆ S1.
 - **Actor conflict** — REQ-A grants permission to role R1; REQ-B forbids the same operation to role R2 where R2 ⊇ R1.
4. **Check against the CONSTITUTION.** Any requirement that violates a constitutional rule is a contradiction with the constitution itself (typically C-rules on security, data, or compliance).
5. **Check against legacy invariants.** If a REQ contradicts behavior the legacy SIFAP enforces (documented in `02-cenario-sifap-legado/legacy-docs/REGRAS-NEGOCIO-2012.md`), flag it as a regression risk.
6. **Score severity.**
 - **Critical** — direct contradiction, no satisfying implementation possible.
 - **Major** — threshold or state conflict resolvable only by changing one REQ.
 - **Minor** — terminology mismatch hiding a real agreement.
7. **Propose resolutions.** For each finding, suggest one of: (a) merge REQs, (b) split REQs by sub-condition, (c) tighten one REQ's scope, (d) escalate to product owner.

## Output

A markdown report:

```markdown
## Contradiction Report — <feature>

### Summary
- Requirements scanned: 47
- Findings: 6 (Critical 1, Major 3, Minor 2)
- Highest-severity: REQ-PAY-014 vs REQ-PAY-019

### Critical
| # | REQ-A | REQ-B | Type | Evidence | Proposed resolution |
|---|-------|-------|------|----------|---------------------|
| 1 | REQ-PAY-014 ("If beneficiary suspended, then the system shall not disburse") | REQ-PAY-019 ("When a recurring schedule fires, the system shall disburse to all enrolled beneficiaries") | Direct contradiction (overlap when suspended beneficiary is enrolled in recurring schedule) | EARS unwanted vs event-driven; state `SUSPENDED` not excluded in REQ-PAY-019 | Tighten REQ-PAY-019: "...to all enrolled beneficiaries except those in `SUSPENDED` state. (See REQ-PAY-014.)" |

### Major
| # | REQ-A | REQ-B | Type | Evidence | Proposed resolution |
|---|-------|-------|------|----------|---------------------|
| 2 | REQ-PAY-006 ("respond to /payments within 250 ms p95") | REQ-PAY-008 + REQ-PAY-009 (two sequential 200 ms external calls) | Threshold conflict | 200 + 200 > 250 | Either parallelize (new ADR) or relax REQ-PAY-006 to 500 ms; route to product. |

### Minor
| # | REQ-A | REQ-B | Type | Evidence | Proposed resolution |
|---|-------|-------|------|----------|---------------------|
| 3 | REQ-BEN-007 uses "user" | REQ-BEN-008 uses "beneficiary" | Terminology drift | Same actor in both | Replace "user" with "beneficiary" globally. |

### Constitutional conflicts
| # | REQ | Rule | Conflict |
|---|-----|------|---------|
| — | none found | | |

### Legacy regression risks
| # | REQ | Legacy invariant | Conflict |
|---|-----|------------------|---------|
| 4 | REQ-PAY-021 ("round to 2 decimal places, half-up") | `CALCBENF.NSN` rounds half-down for negative balances | Behavior change risk; flag for product. |

### Recommended next step
Resolve Critical and Major before Phase 2 sign-off. Bring (1) and (2) to product owner.
```

## Worked example

**Input:** Audit `.specs/003-payment-processing/SPECIFICATION.md` (47 REQs).

**Expected reply:** the structure above, with one critical contradiction between unwanted-behavior and event-driven REQs, two threshold conflicts, and one legacy regression flag for rounding behavior.

## Anti-patterns

- Reporting "the spec is contradictory" without naming pairs. Reviewers cannot act.
- Only checking within a single domain. Many contradictions cross domains.
- Ignoring the constitution. Constitutional conflicts are higher severity than peer-REQ conflicts.
- Confusing ambiguity with contradiction. Ambiguity is for `/clarify`; contradiction is incompatibility.
- Resolving silently in your head. Always surface and route — even when "obvious."
- Skipping legacy regression checks. SIFAP modernization lives or dies on legacy fidelity.
- Treating threshold conflicts as "can fix in design." If the math does not add up, the REQ is wrong.

## Success criteria

- [ ] Every finding cites two REQ-IDs (or a REQ-ID and a constitutional rule, or a REQ-ID and a legacy invariant).
- [ ] Findings classified by type (Direct / Threshold / State / Actor) and severity (Critical / Major / Minor).
- [ ] Each finding has a one-line proposed resolution.
- [ ] Constitutional conflicts checked.
- [ ] Legacy regression risks checked against `02-cenario-sifap-legado/legacy-docs/`.
- [ ] Critical and Major findings flagged for resolution before phase sign-off.
- [ ] Output is paste-ready into the spec PR or a clarification ticket.
