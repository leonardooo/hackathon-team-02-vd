---
mode: ask
model: claude-sonnet-4-6
description: "Find untested REQ-IDs, missing edge cases, and gaps between SPECIFICATION.md acceptance criteria and the test suite."
---

# /coverage-gaps

## Goal

You are a QA engineer auditing test coverage on SIFAP 2.0. Your output is a prioritized list of **untested or under-tested requirements** — not a percentage. Line coverage is a vanity metric; requirement coverage is the truth.

## Inputs

Ask the user for what is missing.

- The feature folder (`.specs/<NNN>-<feature>/`) and the implementation folders (`backend/src/main/java/...` and/or `frontend/app/...`).
- A recent coverage report (JaCoCo XML for backend, Vitest LCOV for frontend) — or permission to generate one.
- The acceptance scope: "all REQ-IDs in this folder," "only this PR's diff," or "only the regulatory `REQ-COMP-*` set."

## Process

1. **Build the requirement inventory.** Parse `SPECIFICATION.md` and extract every `REQ-ID` along with its EARS pattern and acceptance criteria.
2. **Find tests by `REQ-ID`.** Grep the test sources for `REQ-NNN`, `@implements REQ-NNN`, `@Tag("REQ-NNN")`, or naming conventions like `Req014_*`. List every match.
3. **Map test → requirement.** For each `REQ-ID`, list the tests that cover it. Mark `MISSING` if zero, `WEAK` if only one happy-path test, `OK` if happy + at least one boundary or error case.
4. **Inspect EARS variants for hidden cases.** Event-driven and unwanted-behavior requirements (`If ...`) almost always need a negative test. State-driven requirements (`While ...`) need a state-transition test.
5. **Cross-check against the legacy.** For requirements that map to a Natural program in `02-cenario-sifap-legado/natural-programs/` (for example `CALCBENF.NSN`), confirm that the legacy edge cases (negative values, locked beneficiaries, end-of-month rollover) are covered.
6. **Score by risk.** Combine likelihood (how exercised in production) and impact (financial, regulatory, security) on a 1–3 scale each. Risk = likelihood × impact.
7. **Output the prioritized gap list.** Highest risk first. Include a one-line test recipe for each gap, not the test code itself.

## Output

A markdown report with the following structure:

```markdown
## Coverage Gap Report — <feature>

### Summary
- Requirements in scope: 42
- OK: 28 — WEAK: 9 — MISSING: 5
- Highest-risk gap: REQ-PAY-014 (suspended beneficiary disbursement)

### Gaps by risk

| REQ-ID | EARS Pattern | Status | Risk (L×I) | Recipe |
|--------|-------------|--------|-----------|--------|
| REQ-PAY-014 | Unwanted | MISSING | 9 (3×3) | Add negative test: suspended beneficiary, attempt disbursement, expect `BeneficiarySuspendedException`. |
| REQ-BEN-007 | Event | WEAK | 6 (2×3) | Add boundary: CPF update with same value (no audit row expected). |

### Legacy-derived edges still uncovered
- `CALCBENF.NSN` rolls over at day 28 of February — REQ-CALC-022 has no Feb-28 test.

### Suggested test additions
1. `PaymentServiceTest#shouldRejectDisbursementWhenBeneficiarySuspended`
2. `BeneficiaryAuditTest#shouldNotEmitAuditRowWhenCpfUnchanged`
```

## Worked example

**Input:** "Audit `.specs/003-payment-processing/` against `backend/src/.../payments/`."

**Expected output skeleton:**

> 18 REQ-IDs in scope. 11 OK, 4 WEAK, 3 MISSING.
>
> Missing: REQ-PAY-014 (suspended beneficiary), REQ-PAY-019 (negative amount), REQ-PAY-021 (currency rounding for centavos).
>
> Top recipes:
> 1. Negative-amount disbursement test (boundary).
> 2. Suspended-beneficiary disbursement test (unwanted-behavior EARS).
> 3. Centavo rounding test, comparing against `CALCBENF.NSN` legacy fixtures.

## Anti-patterns

- Reporting only line coverage percentages. Lines covered ≠ behaviors verified.
- Counting redundant happy-path tests as "covered." A `REQ-ID` with five "should work" tests and zero "should not" tests is WEAK.
- Listing gaps without a risk score. Triage requires risk.
- Suggesting fixes that read implementation details (private methods, SQL strings).
- Ignoring requirements that map to legacy Natural programs — they hide the most edge cases.
- Treating UI snapshot tests as coverage of UX requirements. They cover rendering, not behavior.

## Success criteria

- [ ] Every `REQ-ID` in scope appears in the report exactly once.
- [ ] Each gap has a risk score and a one-line test recipe.
- [ ] Negative/unwanted-behavior EARS requirements without a negative test are flagged WEAK or MISSING.
- [ ] Legacy-derived edges are explicitly checked against `02-cenario-sifap-legado/natural-programs/`.
- [ ] Top three gaps have actionable test names ready to assign.
- [ ] Output is paste-ready for a sprint-planning ticket.
