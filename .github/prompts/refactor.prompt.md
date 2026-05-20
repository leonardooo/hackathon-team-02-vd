---
mode: agent
model: claude-sonnet-4-6
description: "Refactor code under green tests without changing observable behavior or breaking REQ-ID traceability."
---

# /refactor

## Goal

You are improving the internal structure of SIFAP 2.0 code without changing what it does. A refactor that changes behavior is not a refactor — it is a feature change and belongs in `/implement` or `/fix-bug`. Your output must leave every existing test green and every `REQ-ID` link intact.

## Inputs

Ask the user for anything missing.

- The target file, package, or component (for example `backend/src/main/java/br/gov/sifap/payments/PaymentService.java`).
- The motivation: code smell observed (long method, duplication, primitive obsession, feature envy, etc.).
- Any constraints from `DESIGN.md` or ADRs that limit your moves (for example "controllers must stay thin").
- The current test coverage of the area (run a coverage report if unknown).

## Process

1. **Confirm the safety net.** If line coverage of the target is below 80%, write characterization tests first. A refactor without tests is a rewrite.
2. **Name the smell precisely.** Pick from the catalog (Long Method, Large Class, Primitive Obsession, Data Clumps, Feature Envy, Shotgun Surgery, Divergent Change). Vague justifications like "make it cleaner" are rejected.
3. **Pick one refactoring move from the Fowler catalog** — Extract Method, Extract Class, Replace Conditional with Polymorphism, Introduce Parameter Object, etc. One move per commit.
4. **Run tests before any change.** Confirm green. If they are red or skipped, fix that first; do not refactor on broken builds.
5. **Apply the move.** Use the IDE's refactor tools where possible (Extract Method, Rename, Move). Manual edits must preserve method signatures unless the move is "Change Function Declaration."
6. **Run tests after every micro-step.** Tests stay green at every commit. If they go red, revert and take a smaller step.
7. **Preserve traceability.** Every `@implements REQ-NNN` annotation must move with its method. Do not delete or merge them silently.
8. **Stop when the smell is gone.** Resist the urge to refactor neighboring code. Each refactor is one chat, one PR, one smell.

## Output

Your final reply must include:

- **Smell named** — exact catalog entry plus 1–2 lines of evidence.
- **Refactoring chosen** — exact catalog entry, plus why it fits.
- **Diff or before/after** for each file touched.
- **Test results** — confirmation that the same set of tests passes (paste the summary).
- **Behavior preservation note** — "Public API unchanged. No new throws clauses. No DB migration. No new env var."
- **Commit message** following Conventional Commits with the `refactor:` type:
 ```
 refactor(payments): extract DisbursementCalculator from PaymentService

 Reduces PaymentService from 412 to 287 lines; isolates pure calculation
 for easier testing. No behavior change.

 Refs: REQ-PAY-014 (annotation moved to DisbursementCalculator.calculate)
 ```

## Worked example

**Input:** "`PaymentService` is 400+ lines and mixes orchestration with calculation."

**Expected reply skeleton:**

> Smell: Large Class — `PaymentService` has 14 methods spanning 412 lines, two unrelated responsibilities (orchestration of repositories vs disbursement math).
>
> Refactor: Extract Class — pull the four pure calculation methods into a new `DisbursementCalculator`. `PaymentService` collaborates with it via constructor injection.
>
> Behavior preservation: All 38 existing tests in `PaymentServiceTest` still pass without modification. No public method signatures change. No DB or config touched.
>
> Files: `PaymentService.java` (modified), `DisbursementCalculator.java` (new), `DisbursementCalculatorTest.java` (new — moved 11 tests across).

## Anti-patterns

- Refactoring without tests. That is a rewrite under another name.
- Making "small improvements" to neighboring code. Stay in scope.
- Changing behavior under the guise of refactoring. If output changes, it is not a refactor.
- Renaming public APIs without a migration plan or deprecation notice.
- Bundling refactor + feature in the same PR. Reviewers cannot reason about it.
- Refactoring code with a pending `/fix-bug` — fix first, then refactor on a clean baseline.

## Success criteria

- [ ] All previously-passing tests still pass with the same names.
- [ ] No public API change, no new exception, no new dependency.
- [ ] Coverage did not decrease.
- [ ] One smell, one move, one PR.
- [ ] All `@implements REQ-NNN` annotations are still present and correct.
- [ ] Commit message uses `refactor:` type and explicitly states "no behavior change."
