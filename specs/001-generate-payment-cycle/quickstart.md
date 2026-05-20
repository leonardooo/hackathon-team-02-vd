# Quickstart: Generate Payment Cycle

## Prerequisites

- Docker Desktop or Docker Engine running
- Java 21 available for backend work
- Node.js 20 and `pnpm` available for frontend work
- Specky and Specify already initialized in this repository

## 1. Start local dependencies

```bash
docker compose up -d
```

## 2. Implement backend slice

Expected backend locations for this feature:

- `backend/src/main/java/.../payments/cycle/`
- `backend/src/main/resources/db/migration/`
- `backend/src/test/java/.../payments/cycle/`

Run backend verification:

```bash
cd backend
./mvnw -B verify
```

## 3. Implement frontend slice

Expected frontend locations for this feature:

- `frontend/app/(operator)/payment-cycles/`
- `frontend/components/payment-cycles/`
- `frontend/lib/api/`
- `frontend/tests/`

Run frontend verification:

```bash
cd frontend
pnpm install
pnpm lint
pnpm typecheck
pnpm test --run
```

## 4. Run the repository quality gate

From repository root:

```bash
./scripts/check.sh
```

## 5. Feature verification targets

- Creating a cycle for a competence with active and suspended beneficiaries results in entries only for active eligible beneficiaries
- Attempting to generate a second cycle for the same competence returns a duplicate-prevention response
- Cycle details show included and excluded counts and per-beneficiary exclusion reasons

### MVP validation script (US1)

1. Open the operator screen and submit `competence=202605`, `initiatedBy=operator`.
2. Confirm API returns `201` and payload has `status=GENERATED`.
3. Open the cycle detail endpoint and validate included and excluded counters.

### Duplicate-prevention script (US3)

1. Re-submit the same competence used in the first successful generation.
2. Confirm API returns `409` with code `DUPLICATE_CYCLE`.
3. Confirm the audit table contains a `BLOCKED_DUPLICATE` event for the same competence.

## 7. MVP validation execution evidence

Execution date: 2026-05-20

- Controller route handlers confirmed for generation and review endpoints.
- Frontend API functions confirmed for generate/list/detail/entries workflow.
- Duplicate-prevention logic confirmed with competence lookup and blocked audit event registration.
- Migration guarantees confirmed for core tables and unique active-cycle index.
- Repository quality gate executed successfully (`scripts/check.sh`, summary: 4 passed, 0 failed).

Validation mode: scaffold-mode structural verification in this repository state.

## 6. Planning handoff

After this plan is approved:

1. Run `/speckit.tasks`
2. Review generated tasks for REQ-ID and legacy traceability coverage
3. Distribute implementation across Developer, DBA, and QA roles
