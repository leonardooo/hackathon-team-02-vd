# Tasks: Generate Payment Cycle

**Input**: Design documents from `/specs/001-generate-payment-cycle/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/payment-cycle-api.yaml, quickstart.md

**Tests**: No standalone test-writing tasks are included because the current feature spec did not explicitly request TDD. Implementation tasks must still preserve repository testing gates and finish with executable validation.

**Organization**: Tasks are grouped by user story so each story can be implemented and validated independently.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Establish the feature slice locations for backend and frontend work.

- [X] T001 Create backend feature package markers in backend/src/main/java/com/datacorp/sifap/payments/cycle/package-info.java and backend/src/test/java/com/datacorp/sifap/payments/cycle/package-info.java
- [X] T002 [P] Create frontend feature route shell in frontend/app/(operator)/payment-cycles/page.tsx
- [X] T003 [P] Create frontend feature component scaffold in frontend/components/payment-cycles/payment-cycle-layout.tsx and frontend/lib/api/payment-cycles.ts

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Build the shared persistence and application foundation required before any user story can be completed.

**⚠️ CRITICAL**: No user story work should begin until this phase is complete.

- [X] T004 Create base cycle tables migration in backend/src/main/resources/db/migration/V001__create_payment_cycle_core_tables.sql
- [X] T005 [P] Create PaymentCycle aggregate and status enum in backend/src/main/java/com/datacorp/sifap/payments/cycle/domain/model/PaymentCycle.java and backend/src/main/java/com/datacorp/sifap/payments/cycle/domain/model/PaymentCycleStatus.java
- [X] T006 [P] Create PaymentCycleEntry, InclusionStatus, and GenerationAuditRecord in backend/src/main/java/com/datacorp/sifap/payments/cycle/domain/model/PaymentCycleEntry.java, backend/src/main/java/com/datacorp/sifap/payments/cycle/domain/model/InclusionStatus.java, and backend/src/main/java/com/datacorp/sifap/payments/cycle/domain/model/GenerationAuditRecord.java
- [X] T007 [P] Create JPA repositories in backend/src/main/java/com/datacorp/sifap/payments/cycle/infrastructure/persistence/PaymentCycleRepository.java, backend/src/main/java/com/datacorp/sifap/payments/cycle/infrastructure/persistence/PaymentCycleEntryRepository.java, and backend/src/main/java/com/datacorp/sifap/payments/cycle/infrastructure/persistence/GenerationAuditRecordRepository.java
- [X] T008 Create shared backend DTOs in backend/src/main/java/com/datacorp/sifap/payments/cycle/application/dto/GeneratePaymentCycleCommand.java, backend/src/main/java/com/datacorp/sifap/payments/cycle/application/dto/PaymentCycleSummaryDto.java, and backend/src/main/java/com/datacorp/sifap/payments/cycle/interfaces/rest/ErrorResponseDto.java
- [X] T009 Create feature controller skeleton in backend/src/main/java/com/datacorp/sifap/payments/cycle/interfaces/rest/PaymentCycleController.java

**Checkpoint**: Foundation ready for user story implementation.

---

## Phase 3: User Story 1 - Generate a monthly cycle (Priority: P1) 🎯 MVP

**Goal**: Allow an operator to generate a monthly payment cycle for active eligible beneficiaries.

**Independent Test**: Submit a valid competence through the cycle generation flow and confirm that a cycle is created with included entries only for active eligible beneficiaries.

### Implementation for User Story 1

- [X] T010 [P] [US1] Create generation output ports in backend/src/main/java/com/datacorp/sifap/payments/cycle/application/port/out/BeneficiaryEligibilityPort.java and backend/src/main/java/com/datacorp/sifap/payments/cycle/application/port/out/PaymentRecordWriterPort.java
- [X] T011 [P] [US1] Implement eligibility and payment adapters in backend/src/main/java/com/datacorp/sifap/payments/cycle/infrastructure/query/BeneficiaryEligibilityJpaAdapter.java and backend/src/main/java/com/datacorp/sifap/payments/cycle/infrastructure/persistence/PaymentRecordJpaAdapter.java
- [X] T012 [US1] Implement generation domain rules in backend/src/main/java/com/datacorp/sifap/payments/cycle/domain/service/PaymentCycleGenerationDomainService.java
- [X] T013 [US1] Implement the generation use case in backend/src/main/java/com/datacorp/sifap/payments/cycle/application/service/GeneratePaymentCycleService.java
- [X] T014 [US1] Implement POST /api/v1/payment-cycles in backend/src/main/java/com/datacorp/sifap/payments/cycle/interfaces/rest/PaymentCycleController.java
- [X] T015 [P] [US1] Implement generation request client in frontend/lib/api/payment-cycles.ts
- [X] T016 [P] [US1] Implement operator generation form in frontend/components/payment-cycles/payment-cycle-generate-form.tsx
- [X] T017 [US1] Compose the generation page in frontend/app/(operator)/payment-cycles/page.tsx
- [X] T018 [US1] Validate the MVP generation flow in specs/001-generate-payment-cycle/quickstart.md

**Checkpoint**: User Story 1 is independently functional and demonstrable.

---

## Phase 4: User Story 2 - Review exclusions before finalizing use of the cycle (Priority: P2)

**Goal**: Let operators inspect cycle summaries, included counts, excluded counts, and per-beneficiary exclusion reasons.

**Independent Test**: Open a generated cycle and verify that excluded beneficiaries and their reasons are visible separately from included beneficiaries.

### Implementation for User Story 2

- [X] T019 [P] [US2] Create review DTOs in backend/src/main/java/com/datacorp/sifap/payments/cycle/application/dto/PaymentCycleDetailDto.java and backend/src/main/java/com/datacorp/sifap/payments/cycle/application/dto/PaymentCycleEntryDto.java
- [X] T020 [P] [US2] Implement review services in backend/src/main/java/com/datacorp/sifap/payments/cycle/application/service/ListPaymentCyclesService.java, backend/src/main/java/com/datacorp/sifap/payments/cycle/application/service/GetPaymentCycleDetailService.java, and backend/src/main/java/com/datacorp/sifap/payments/cycle/application/service/ListPaymentCycleEntriesService.java
- [X] T021 [US2] Implement GET review endpoints in backend/src/main/java/com/datacorp/sifap/payments/cycle/interfaces/rest/PaymentCycleController.java
- [X] T022 [P] [US2] Implement cycle summary list component in frontend/components/payment-cycles/payment-cycle-summary-list.tsx
- [X] T023 [P] [US2] Implement entry review table in frontend/components/payment-cycles/payment-cycle-entry-table.tsx
- [X] T024 [US2] Extend the frontend API client for list and detail reads in frontend/lib/api/payment-cycles.ts
- [X] T025 [US2] Implement the cycle detail page in frontend/app/(operator)/payment-cycles/[cycleId]/page.tsx

**Checkpoint**: User Story 2 is independently functional and demonstrates exclusion review on top of generated data.

---

## Phase 5: User Story 3 - Prevent duplicate monthly cycles (Priority: P3)

**Goal**: Block conflicting cycle generation for a competence that already has an active generated cycle.

**Independent Test**: Generate a cycle for one competence, submit the same competence again, and verify that the second attempt is rejected with a clear conflict message and audit trace.

### Implementation for User Story 3

- [X] T026 [US3] Add duplicate-cycle protection migration in backend/src/main/resources/db/migration/V002__enforce_unique_active_cycle_per_competence.sql
- [X] T027 [P] [US3] Implement duplicate lookup support in backend/src/main/java/com/datacorp/sifap/payments/cycle/infrastructure/persistence/PaymentCycleRepository.java
- [X] T028 [P] [US3] Extend audit event handling for blocked attempts in backend/src/main/java/com/datacorp/sifap/payments/cycle/domain/model/GenerationAuditRecord.java
- [X] T029 [US3] Enforce duplicate prevention in backend/src/main/java/com/datacorp/sifap/payments/cycle/application/service/GeneratePaymentCycleService.java
- [X] T030 [US3] Return HTTP 409 conflict responses in backend/src/main/java/com/datacorp/sifap/payments/cycle/interfaces/rest/PaymentCycleController.java
- [X] T031 [US3] Surface duplicate-generation feedback in frontend/components/payment-cycles/payment-cycle-generate-form.tsx
- [X] T032 [US3] Document the duplicate-prevention operator flow in specs/001-generate-payment-cycle/quickstart.md

**Checkpoint**: All three user stories are independently functional and reviewable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final hardening, documentation sync, and executable validation.

- [X] T033 [P] Synchronize API documentation in specs/001-generate-payment-cycle/contracts/payment-cycle-api.yaml
- [X] T034 Harden validation and masked logging in backend/src/main/java/com/datacorp/sifap/payments/cycle/interfaces/rest/PaymentCycleController.java and backend/src/main/java/com/datacorp/sifap/payments/cycle/application/service/GeneratePaymentCycleService.java
- [X] T035 Run the repository quality gate from scripts/check.sh

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion; blocks all user stories.
- **User Story 1 (Phase 3)**: Starts only after Foundational is complete.
- **User Story 2 (Phase 4)**: Starts after Foundational is complete and can proceed once User Story 1 creates reviewable cycle data.
- **User Story 3 (Phase 5)**: Starts after Foundational is complete and builds directly on the generation flow from User Story 1.
- **Polish (Phase 6)**: Starts after the desired user stories are complete.

### User Story Dependencies

- **US1**: No dependencies on other user stories; this is the MVP.
- **US2**: Depends on cycle data produced by US1 but remains independently testable once a cycle exists.
- **US3**: Depends on the cycle generation path from US1 because it hardens the same operator action with conflict handling.

### Within Each User Story

- Domain and persistence contracts before application services.
- Application services before REST controller completion.
- Backend API support before frontend integration.
- Story-specific validation after the UI and API flow are connected.

### Parallel Opportunities

- Setup tasks marked `[P]` can run in parallel.
- Foundational entity and repository tasks marked `[P]` can run in parallel.
- In US1, backend adapters and frontend client/form tasks marked `[P]` can run in parallel after foundational work.
- In US2, DTO/service tasks and frontend view components marked `[P]` can run in parallel.
- In US3, repository and audit extension tasks marked `[P]` can run in parallel.

---

## Parallel Example: User Story 1

```bash
# Backend ports and adapters can proceed in parallel:
Task: "Create generation output ports in backend/src/main/java/com/datacorp/sifap/payments/cycle/application/port/out/BeneficiaryEligibilityPort.java and backend/src/main/java/com/datacorp/sifap/payments/cycle/application/port/out/PaymentRecordWriterPort.java"
Task: "Implement eligibility and payment adapters in backend/src/main/java/com/datacorp/sifap/payments/cycle/infrastructure/query/BeneficiaryEligibilityJpaAdapter.java and backend/src/main/java/com/datacorp/sifap/payments/cycle/infrastructure/persistence/PaymentRecordJpaAdapter.java"

# Frontend API and form work can proceed in parallel once the POST contract is stable:
Task: "Implement generation request client in frontend/lib/api/payment-cycles.ts"
Task: "Implement operator generation form in frontend/components/payment-cycles/payment-cycle-generate-form.tsx"
```

---

## Parallel Example: User Story 2

```bash
# Backend read models can proceed in parallel with frontend review widgets:
Task: "Create review DTOs in backend/src/main/java/com/datacorp/sifap/payments/cycle/application/dto/PaymentCycleDetailDto.java and backend/src/main/java/com/datacorp/sifap/payments/cycle/application/dto/PaymentCycleEntryDto.java"
Task: "Implement cycle summary list component in frontend/components/payment-cycles/payment-cycle-summary-list.tsx"
Task: "Implement entry review table in frontend/components/payment-cycles/payment-cycle-entry-table.tsx"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Setup.
2. Complete Foundational work.
3. Complete User Story 1.
4. Validate the generation flow end to end.
5. Stop and review scope before proceeding.

### Incremental Delivery

1. Deliver US1 as the minimal viable cycle generation flow.
2. Add US2 to improve operator review and confidence.
3. Add US3 to harden the generation path against conflicting duplicate runs.
4. Finish with polish and repository-level validation.

### Parallel Team Strategy

1. Technical Lead and DBA complete the foundational schema and backend slice setup.
2. Developer implements US1 backend and frontend flow.
3. QA pairs on validation checkpoints after each story.
4. Once US1 is stable, split work so one contributor handles US2 review reads while another hardens US3 conflict prevention.

---

## Notes

- `[P]` tasks target different files and can run in parallel.
- `[US1]`, `[US2]`, and `[US3]` labels preserve traceability from story to implementation.
- `tasks.md` intentionally omits explicit test-writing tasks because TDD was not explicitly requested in the feature spec.
- Every story still ends with executable validation through `quickstart.md` or `scripts/check.sh`.
