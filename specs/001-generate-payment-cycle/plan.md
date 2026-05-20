# Implementation Plan: Generate Payment Cycle

**Branch**: `[001-generate-payment-cycle]` | **Date**: 2026-05-20 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-generate-payment-cycle/spec.md`

## Summary

Implement monthly payment cycle generation as a web-backed operator workflow that preserves the core semantics of the legacy `BATCHPGT.NSN` batch: process active beneficiaries, prevent duplicate generation for the same competence, persist auditable payment-cycle results, and expose reviewable inclusion and exclusion outcomes through a REST API and an operator-facing Next.js screen.

## Technical Context

**Language/Version**: Java 21 for backend services; TypeScript 5 (strict) for frontend

**Primary Dependencies**: Spring Boot 3.3, Spring Web, Spring Validation, Spring Data JPA, PostgreSQL driver, Flyway, Next.js 15 App Router, Tailwind CSS, shadcn/ui

**Storage**: PostgreSQL 16 for operational data; Flyway-managed schema migrations

**Testing**: JUnit 5 + Testcontainers for backend; Vitest + Testing Library for frontend

**Target Platform**: Linux containers run locally with Docker Compose and in GitHub Actions CI

**Project Type**: Web application with modular-monolith backend plus Next.js operator frontend

**Performance Goals**: Complete cycle generation for workshop-scale datasets in under 5 minutes, preserve deterministic results for the same source data, and keep cycle summary retrieval under 2 seconds for standard operator queries

**Constraints**: Preserve legacy eligibility semantics from `BATCHPGT.NSN`; prevent duplicate active cycles per competence; never log sensitive beneficiary data unmasked; keep audit records separate from beneficiary state to avoid legacy-style performance degradation

**Scale/Scope**: Designed around legacy scale signals of millions of beneficiary records and monthly batch processing, but implementation scope for this feature is limited to cycle generation, review, and duplicate prevention

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Initial Gate

| Gate | Status | Notes |
|------|--------|-------|
| Stack compliance | PASS | Matches repository mandate: Java 21 + Spring Boot 3.3, Next.js 15, PostgreSQL 16, Docker Compose, Terraform-ready conventions |
| Security and data handling | PASS | Plan keeps validation at system boundaries, avoids wildcard CORS assumptions, and keeps audit data separate from sensitive logs |
| Legacy traceability input available | PASS | Feature traces to `legacy/natural-programs/BATCHPGT.NSN`, `legacy/adabas-ddms/BENEFICIARIO.ddm`, `legacy/adabas-ddms/PAGAMENTO.ddm`, and the archaeology checklist rule for active beneficiaries |
| Project constitution maturity | CONDITIONAL | `.specify/memory/constitution.md` is still the stock template, so repository-level rules from `.github/copilot-instructions.md` are treated as governing constraints for this plan |

### Post-Design Re-check

| Gate | Status | Notes |
|------|--------|-------|
| Design stays within mandated stack | PASS | No extra runtime stack introduced beyond Spring Boot, PostgreSQL, Next.js, and Flyway |
| Design preserves traceability | PASS | Data model and API contract map directly to cycle generation, duplicate prevention, exclusion review, and audit requirements |
| Design avoids unjustified complexity | PASS | Uses one backend bounded context for payment cycles plus existing beneficiary/payment concepts; no event bus or asynchronous orchestration introduced |
| Constitution-specific violations | NONE | No plan exceptions require override approval; remaining gap is ratifying a real project constitution before implementation phase |

## Project Structure

### Documentation (this feature)

```text
specs/001-generate-payment-cycle/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── payment-cycle-api.yaml
└── tasks.md
```

### Source Code (repository root)

```text
backend/
├── src/main/java/.../payments/cycle/
│   ├── domain/
│   ├── application/
│   ├── infrastructure/
│   └── interfaces/rest/
├── src/main/resources/db/migration/
└── src/test/java/.../payments/cycle/

frontend/
├── app/(operator)/payment-cycles/
├── components/payment-cycles/
├── lib/api/
└── tests/

infra/
└── reference Terraform modules remain external to this feature slice
```

**Structure Decision**: Use the workshop's intended web-application split: a Spring Boot modular monolith backend and a Next.js operator frontend. The backend feature slice lives under a payment-cycle bounded context so business rules, persistence, and REST endpoints stay aligned. The frontend adds an operator flow for cycle generation and review without introducing a separate client-specific backend.

## Complexity Tracking

No constitution violations require justification at planning time.
