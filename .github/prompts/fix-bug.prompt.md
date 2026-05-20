---
mode: agent
model: claude-sonnet-4-6
description: "Reproduce, isolate, and fix a defect with a regression test, while preserving SPECIFICATION.md as the source of truth."
---

# /fix-bug

## Goal

You are a senior developer fixing a defect in SIFAP 2.0. Your fix must (a) be reproducible by a new failing test, (b) be the smallest change that turns that test green, and (c) trace to a real `REQ-ID` — either an existing one or a new one you propose if the bug exposes a missing requirement.

## Inputs

Ask the user for anything missing before starting.

- A bug description: observed vs expected behavior, exact steps, environment.
- A stack trace, log line, or screenshot if available.
- The affected service or page (for example `backend/payments`, `frontend/app/beneficiaries/[id]`).
- The likely related requirement ID (or "unknown — please investigate").

## Process

1. **Reproduce locally first.** Either run the failing scenario or write the smallest test that mirrors the report. If you cannot reproduce, stop and tell the user what is missing.
2. **Write the regression test before any code change.** Name it for the behavior: `should_reject_payment_when_beneficiary_is_suspended`, not `testBug123`. Place it in the same package as the code under test.
3. **Confirm the test fails for the right reason.** Read the assertion error. If the test fails for setup reasons, fix the setup first.
4. **Diagnose, do not patch blindly.** Find the root cause. Read related code, walk the call stack, check the spec. Write 3–5 sentences in your reply explaining the root cause before showing the fix.
5. **Map the fix to a `REQ-ID`.** If an existing requirement covers the correct behavior, cite it. If not, draft a new EARS requirement and propose adding it via `/update-spec` — do not silently change behavior.
6. **Apply the smallest change that makes the test pass.** Do not "improve" the surrounding code. Park unrelated cleanup as TODO comments with a `REQ-ID` reference or a follow-up issue.
7. **Add a second test for the boundary.** One happy-path test is not enough; add an edge case (null, empty, max value, off-by-one).
8. **Run the full suite locally.** `./mvnw verify` or `pnpm test && pnpm lint && pnpm typecheck`.

## Output

Your final reply must include:

- **Root cause** — 3–5 sentences, plain English, no jargon.
- **Linked requirement** — existing `REQ-ID` or "PROPOSED: new REQ-XXX-NNN, see /update-spec".
- **Test files** — the new failing-then-passing test, with full content.
- **Fix files** — the minimal production-code change, with full content or unified diff.
- **Risk assessment** — what else this code path touches, what regressions are plausible.
- **Commit message** following Conventional Commits:
 ```
 fix(payments): reject disbursement when beneficiary is suspended (REQ-PAY-014)

 Root cause: PaymentService did not check beneficiary.status before
 enqueueing the transfer. Adds guard + regression test.

 Refs: BUG-2026-042, REQ-PAY-014
 ```

## Worked example

**Input:** "Disbursements still go out for suspended beneficiaries. Reproduced in stage."

**Expected reply skeleton:**

> Root cause: `PaymentService.disburse()` queries `beneficiary_repository.findById()` but never inspects `beneficiary.status`. The legacy Natural program `CALCBENF.NSN` had this check inline; it was lost in translation.
>
> Linked requirement: REQ-PAY-014 ("If a beneficiary is suspended, then the system shall not disburse").
>
> Tests added: `PaymentServiceTest#shouldRejectDisbursementWhenBeneficiarySuspended`, `PaymentServiceTest#shouldDisburseWhenBeneficiaryActive`.
>
> Fix: 4-line guard in `PaymentService.disburse()`, throws `BeneficiarySuspendedException`.
>
> Risk: The same omission may exist in `BatchPaymentJob`. Filed follow-up T-099.

## Anti-patterns

- Fixing the symptom (catching the exception, swallowing the null) instead of the cause.
- Wrapping the bug in a try/catch that logs and continues. SIFAP must fail loud.
- Adding the fix without a regression test. CI cannot protect what it cannot see.
- Refactoring the surrounding class "while you're in there." Park it.
- Skipping the spec update when the bug exposes ambiguous requirements.
- Pushing the fix straight to `develop`. Always go through `spec/<NNN>-<bug-name>` and PR.

## Success criteria

- [ ] A new test fails before the fix and passes after.
- [ ] Root cause is named in the commit message and PR description.
- [ ] Fix is the smallest change that makes the test pass.
- [ ] At least one boundary/edge test is added beyond the reproduction case.
- [ ] Linked `REQ-ID` is cited or a new one is formally proposed.
- [ ] No unrelated files are modified.
- [ ] Full suite is green locally and in CI.
