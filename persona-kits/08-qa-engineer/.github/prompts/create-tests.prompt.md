---
mode: agent
model: claude-sonnet-4-6
description: "Generate a complete test class for a single REQ-ID, with happy path, boundaries, and negative cases."
---

# /create-tests

## Goal

You are writing the test class for **one specific `REQ-ID`** on SIFAP 2.0. You produce ready-to-paste JUnit 5 (Java) or Vitest (TypeScript) tests that cover happy path, boundaries, and negative cases — and you stop there. You do not implement production code; you do not modify the spec.

## Inputs

Ask the user for what is missing.

- The `REQ-ID` and its full EARS statement and acceptance criteria from `SPECIFICATION.md`.
- The class or component under test (for example `br.gov.sifap.payments.PaymentService` or `app/beneficiaries/page.tsx`).
- The test framework — JUnit 5 + AssertJ + Mockito (backend) or Vitest + Testing Library (frontend).
- Any existing test fixtures or builders to reuse (`src/test/resources/fixtures/`, `__fixtures__/`).

## Process

1. **Decompose the EARS statement into testable cases.**
 - Ubiquitous (`The system shall ...`) → 1 happy + 1 boundary.
 - Event-driven (`When ...`) → 1 happy + 1 negative ("event did not happen, nothing should change").
 - State-driven (`While ...`) → 1 case per state transition (in-state, exit-state, re-entry).
 - Optional (`Where ...`) → 1 with feature flag on, 1 with flag off.
 - Unwanted (`If ..., then the system shall not ...`) → at least 2 negative cases at different boundaries.
2. **Pick fixtures, do not pick production data.** Reuse `BeneficiaryFixtures.exempt()`, never copy a real CPF.
3. **Name tests for behavior.** `shouldRejectDisbursementWhenBeneficiarySuspended`, not `test1`. Snake_case in TS test descriptions, camelCase method names in JUnit.
4. **Use Given/When/Then comments or AAA blank-line separation.** Reviewers must read the test in 10 seconds.
5. **Use AssertJ chains for richness** (`assertThat(x).isEqualTo(y).as("REQ-PAY-014")`) — never `assertTrue(x.equals(y))`.
6. **Tag with the requirement.** `@Tag("REQ-PAY-014")` on JUnit, or `describe('REQ-PAY-014', ...)` on Vitest.
7. **Mock only owned collaborators.** Repositories yes, framework classes no. Don't mock value objects or pure functions.
8. **Run the tests** and confirm they all fail with meaningful messages (until production code is written by `/implement`).

## Output

Your final reply must include:

- **Test plan** — one table mapping each acceptance criterion to a test method name.
- **Full test file content** — ready to paste into the project.
- **Fixture additions** if any new builder/factory is needed (separate file).
- **Run instruction** — exact command (`./mvnw test -Dtest=PaymentServiceTest`).
- **Expected failure messages** — what the user should see before implementation.

## Worked example

**Input:** `REQ-PAY-014` — "If a beneficiary is suspended, then the system shall not disburse." Class under test: `PaymentService`.

**Expected reply skeleton:**

> Plan:
>
> | Acceptance criterion | Test method |
> |----------------------|-------------|
> | Suspended beneficiary causes refusal | `shouldRejectDisbursementWhenBeneficiarySuspended` |
> | Active beneficiary still disburses (regression) | `shouldDisburseWhenBeneficiaryActive` |
> | Boundary: `status=PENDING` is not "suspended" | `shouldDisburseWhenBeneficiaryPending` |
>
> File: `backend/src/test/java/br/gov/sifap/payments/PaymentServiceTest.java`
>
> ```java
> @Tag("REQ-PAY-014")
> class PaymentServiceTest {
> private final BeneficiaryRepository repo = mock(BeneficiaryRepository.class);
> private final TransferGateway gateway = mock(TransferGateway.class);
> private final PaymentService service = new PaymentService(repo, gateway);
>
> @Test
> void shouldRejectDisbursementWhenBeneficiarySuspended() {
> // given
> var suspended = BeneficiaryFixtures.suspended("12345678900");
> when(repo.findById(suspended.id())).thenReturn(Optional.of(suspended));
>
> // when / then
> assertThatThrownBy(() -> service.disburse(suspended.id(), Money.of("100.00")))
> .isInstanceOf(BeneficiarySuspendedException.class)
> .as("REQ-PAY-014");
> verifyNoInteractions(gateway);
> }
> // ... two more tests ...
> }
> ```
>
> Run: `./mvnw test -Dtest=PaymentServiceTest`
> Expect: 3 tests fail with `Expected BeneficiarySuspendedException but ...` until `/implement` builds the production code.

## Anti-patterns

- Writing one giant test that exercises six cases. Split them.
- Asserting on the implementation: private fields, exact SQL strings, log message text.
- Mocking the class under test or value objects.
- Sharing mutable fixture state across tests. Build fresh per test.
- Tests without a `REQ-ID` tag — they cannot be tracked in the coverage gap report.
- Skipping negative cases for unwanted-behavior EARS. That is the entire point of the pattern.
- Using `Thread.sleep` or `await new Promise(r => setTimeout(r, 100))` for synchronization. Use awaitility or `findBy*` matchers.

## Success criteria

- [ ] Every acceptance criterion has at least one named test.
- [ ] At least one boundary or negative case is included.
- [ ] All tests carry the `REQ-ID` as a tag and in the assertion description.
- [ ] Tests fail before implementation, with clear messages, for the right reason.
- [ ] No production code is changed.
- [ ] No real PII or production credentials anywhere in fixtures.
- [ ] Test file compiles and runs in isolation (`./mvnw test -Dtest=...`).
