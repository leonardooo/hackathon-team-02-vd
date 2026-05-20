---
mode: agent
model: claude-sonnet-4-6
description: "Drive a feature through one strict red-green-refactor TDD cycle. One failing test, smallest passing code, then refactor."
---

# /tdd

## Goal

You will produce one complete TDD cycle for a single behavior on SIFAP 2.0. The deliverable is three commits — `red`, `green`, `refactor` — each on its own. No production code is written without a failing test, and no test is written that immediately passes.

## Inputs

Ask the user for what is missing.

- The behavior to drive out, in plain English (for example "calculate ICMS for tax-exempt beneficiaries").
- The linked `REQ-ID` from `SPECIFICATION.md`.
- The target file or class. If it does not exist, say so — TDD also drives design, so creation is fine.
- The test framework — JUnit 5 + AssertJ for Java, Vitest + Testing Library for TypeScript.

## Process

You execute exactly three phases. Do not collapse them.

### Phase 1 — RED (write the failing test)

1. Pick the **simplest non-trivial case** for the behavior. Not the empty case, not the catastrophic one — the smallest case that exercises real logic.
2. Name the test after the behavior, not the method: `calculatesIcmsAsZeroForTaxExemptBeneficiary`, not `test1`.
3. Use Given/When/Then or Arrange/Act/Assert structure with blank lines between sections.
4. Run the test. Confirm it fails. Read the failure message and confirm it fails for the expected reason (compile error, assertion mismatch — not setup error).
5. Commit: `test(taxes): red — icms is zero for tax-exempt beneficiary`.

### Phase 2 — GREEN (smallest code to pass)

6. Write the **smallest amount of production code** that makes the test pass. "Fake it till you make it" is allowed: returning a hardcoded value is acceptable on the first cycle.
7. Run the single test. Confirm green. Run the full suite. Confirm still green.
8. Commit: `feat(taxes): green — implement REQ-TAX-009 (minimal)`.

### Phase 3 — REFACTOR (improve under green)

9. Look for duplication, names that lie, primitive obsession. Apply one small Fowler move (Extract Method, Inline Variable, Rename).
10. Run all tests after every micro-step. They must stay green.
11. Stop when the design is good enough for the next cycle, not perfect.
12. Commit: `refactor(taxes): extract ExemptionPolicy from TaxCalculator`.

## Output

Your final reply must include:

- **The behavior driven out** — one sentence.
- **The three commits** — message, files touched, test result for each.
- **The test file** — full content.
- **The production code** — full content after the refactor phase.
- **Next cycle hint** — what test you would write next (boundary, error, second variation). Do not implement it.

## Worked example

**Input:** Behavior — "ICMS is zero when the beneficiary is flagged tax-exempt." REQ-TAX-009.

**Expected reply skeleton:**

> Behavior: `TaxCalculator.icms(beneficiary, amount)` returns `BigDecimal.ZERO` when `beneficiary.isTaxExempt()` is true.
>
> RED commit: added `TaxCalculatorTest#calculatesIcmsAsZeroForTaxExemptBeneficiary`. Failed with `NullPointerException` (class did not exist).
>
> GREEN commit: created `TaxCalculator` with a one-line `icms` method returning `ZERO`. Test passes. Full suite green (47 tests).
>
> REFACTOR commit: extracted `ExemptionPolicy` interface — anticipates state-exempt and federal-exempt variants without implementing them yet.
>
> Next cycle hint: write a test for a non-exempt beneficiary with a non-zero ICMS rate. That will force `icms` to actually look at `amount`.

## Anti-patterns

- Writing the test and the code together. That is verification, not TDD.
- Skipping the refactor phase. Most of the design value lives there.
- Two failing tests at once. One red at a time.
- Testing private methods. Test through the public interface.
- Writing a giant first test that covers six cases. Take smaller steps.
- Mocking everything. A test that mocks every collaborator tests nothing.
- "Refactoring" by changing behavior. If the test changes, you cheated.

## Success criteria

- [ ] Three separate commits exist: `test:` (red), `feat:` (green), `refactor:`.
- [ ] The red commit is reproducibly red — you can check out that commit and the build fails.
- [ ] The green commit is the minimum to pass — one method, hardcoded if needed.
- [ ] The refactor commit changes structure, not behavior. Test names and assertions are unchanged.
- [ ] The full suite is green at the end.
- [ ] The behavior driven out maps to exactly one acceptance criterion of one `REQ-ID`.
