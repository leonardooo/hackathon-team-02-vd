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

## 6. Planning handoff

After this plan is approved:

1. Run `/speckit.tasks`
2. Review generated tasks for REQ-ID and legacy traceability coverage
3. Distribute implementation across Developer, DBA, and QA roles