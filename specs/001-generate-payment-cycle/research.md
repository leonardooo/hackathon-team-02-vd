# Research: Generate Payment Cycle

## Decision 1: Preserve legacy batch semantics in a synchronous backend service

**Decision**: Model cycle generation as an application service in the backend that executes the core legacy batch rules synchronously for the selected competence, then persists a `payment_cycle` plus its entries.

**Rationale**: The feature is a modernization of `BATCHPGT.NSN`, whose documented objective is monthly batch payment generation for active beneficiaries. A synchronous operator-triggered service is enough for the workshop slice and keeps behavior transparent for validation and review.

**Alternatives considered**:
- Rebuild the flow as a scheduled-only batch job: rejected because the feature requires an operator-triggered workflow.
- Introduce asynchronous messaging and background orchestration: rejected as unnecessary complexity for the current scope.

## Decision 2: Use PostgreSQL tables that separate cycle state, entry outcomes, and audit history

**Decision**: Represent cycle generation with separate relational tables for `payment_cycle`, `payment_cycle_entry`, and `generation_audit_record`, while mapping beneficiary and payment source data from the legacy `BENEFICIARIO` and `PAGAMENTO` DDMs.

**Rationale**: The feature needs a stable snapshot of who was included or excluded, plus later review and auditability. The legacy architecture notes that storing audit history inside beneficiary records using periodic groups caused severe performance degradation and was later refactored into a separate audit structure.

**Alternatives considered**:
- Store inclusion/exclusion results only in `payment`: rejected because excluded beneficiaries also need explicit outcomes and reasons.
- Embed audit history inside beneficiary rows: rejected because the legacy system already proved this does not scale.

## Decision 3: Expose a minimal REST API plus operator UI

**Decision**: Expose cycle generation and review through `/api/v1/payment-cycles` endpoints and a Next.js operator page under `frontend/app/(operator)/payment-cycles`.

**Rationale**: Repository rules mandate REST conventions and a Next.js 15 frontend. The feature explicitly depends on operators generating a cycle and reviewing exclusions, so both API and UI surfaces are required.

**Alternatives considered**:
- Backend-only implementation: rejected because exclusion review is a user-facing requirement.
- Frontend talking directly to database or server actions only: rejected because backend business rules and auditing must stay server-side and reusable.

## Decision 4: Enforce idempotency at the payment-cycle level, not by reusing raw payment rows

**Decision**: Prevent duplicate generation using a unique active-cycle rule per monthly competence and explicit duplicate checks before writing a new cycle.

**Rationale**: `BATCHPGT.NSN` checks whether payment has already been generated for the same competence and skips duplicates. The modernized flow should preserve that rule at the cycle aggregate level, which is easier for operators to reason about and easier to audit.

**Alternatives considered**:
- Detect duplicates only by checking existing payment records: rejected because the feature centers on cycle lifecycle, not just payment row existence.
- Allow regeneration with silent overwrite: rejected because it violates the stated requirement to prevent conflicting cycles.

## Decision 5: Treat repository-level instructions as temporary constitution authority

**Decision**: Use `.github/copilot-instructions.md` as the effective governing baseline for this plan until `.specify/memory/constitution.md` is ratified with project-specific principles.

**Rationale**: The current constitution file is still the stock template and does not contain enforceable project rules. The repository instructions already define mandatory stack, testing, security, and traceability constraints, which are sufficient to continue planning without reopening the stack choice.

**Alternatives considered**:
- Block planning until constitution is authored: rejected because the repository already carries the necessary technical governance to progress this feature.
- Invent a new constitution inside the plan: rejected because constitution authorship belongs to a separate explicit step.
