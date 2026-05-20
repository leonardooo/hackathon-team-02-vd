---
mode: ask
model: claude-opus-4-6
description: "Author a test strategy for a SIFAP 2.0 feature: pyramid layers, framework choices, environments, and exit criteria."
---

# /test-strategy

## Goal

You are a QA lead writing the test strategy for a SIFAP 2.0 feature. The strategy tells the team **what to test, at which layer, with which tool, against which environment, and how we know we are done**. It is approved by the technical lead before implementation starts (Phase 5 of the SDD pipeline) and lives in `.specs/<NNN>-<feature>/TEST-STRATEGY.md`.

## Inputs

Ask the user for what is missing.

- The feature folder (`.specs/<NNN>-<feature>/`) with `SPECIFICATION.md` and `DESIGN.md` already approved.
- The risk profile: financial (`high`), regulatory (`high`), batch (`medium`), read-only (`low`).
- Constraints: time budget, parallel CI minutes, available environments (`local`, `dev`, `stage`, `prod-shadow`).
- Any non-functional requirements with measurable thresholds (latency p95, throughput, RPO/RTO).

## Process

1. **Classify each `REQ-ID` by test layer.** Use the test pyramid:
 - **Unit** — pure functions, calculators, validators (most of `REQ-CALC-*`).
 - **Integration** — adapters: repositories, queues, external services (most of `REQ-PAY-*`).
 - **Contract** — API consumer/provider tests (frontend ↔ backend, backend ↔ external Adabas wrapper).
 - **End-to-end** — critical user journeys only (registration, disbursement, audit query).
 - **Non-functional** — performance, security, accessibility, observability.
2. **Choose tools per layer.** JUnit 5 + AssertJ + Mockito (unit/integration backend), Testcontainers (integration), Pact (contract), Playwright (E2E), k6 (load), OWASP ZAP (security baseline), axe-core (a11y).
3. **Define test data strategy.** Synthetic data for happy paths, anonymized legacy snapshots for edge cases, deterministic seeds for property-based tests. No production PII in any environment.
4. **Map tests to environments.** Unit/integration on every push (CI). Contract on PR to `develop`. E2E nightly in `stage`. Performance weekly in `prod-shadow`.
5. **Set exit criteria.** Per layer: minimum coverage of `REQ-IDs` (not lines), max flakiness rate, max p95 runtime.
6. **Identify risks and mitigations.** Flaky external dependencies, slow test suites, data leakage, environment drift.
7. **Write the strategy as `TEST-STRATEGY.md`.**

## Output

The deliverable is a markdown file with this structure:

```markdown
# Test Strategy — <feature> (REQ-<DOMAIN>-*)

## 1. Scope
In scope: REQ-PAY-001 .. REQ-PAY-024
Out of scope: legacy compatibility tests (covered by `.specs/002-legacy-bridge`)

## 2. Risk profile
Financial: high — every disbursement is auditable.
Regulatory: high — SISP / TCU audit trail required.

## 3. Test pyramid

| Layer | Framework | Coverage target | Where it runs |
|--------------|--------------------------|---------------------------|---------------|
| Unit | JUnit 5 + AssertJ | 100% of `REQ-CALC-*` | every push |
| Integration | Spring Boot Test + Testcontainers (Postgres 16) | 100% of `REQ-PAY-*` adapters | every push |
| Contract | Pact (consumer-driven) | every API endpoint | PR to develop |
| E2E | Playwright | 5 happy-path journeys | nightly stage |
| Performance | k6 | p95 < 250 ms disburse | weekly |
| Security | OWASP ZAP baseline + Trivy | every release candidate | nightly |
| Accessibility| axe-core | WCAG 2.1 AA on key pages | every push |

## 4. Data strategy
- Synthetic JSON fixtures in `src/test/resources/fixtures/`.
- Anonymized snapshots from `02-cenario-sifap-legado/` for legacy regression cases.
- No production PII anywhere — `dev` and `stage` use synthetic data only.

## 5. Environments
local → dev (CI) → stage (nightly E2E) → prod-shadow (perf + chaos)

## 6. Exit criteria
- 100% of REQ-IDs have at least one direct test.
- 0 critical or high security findings.
- p95 latency under defined threshold for 7 consecutive nightly runs.
- Flakiness rate < 1% over the last 50 runs.

## 7. Risks
- Adabas legacy bridge is single-vendor; mock it for CI, hit it once nightly.
- Test data refresh from legacy is manual; automate by Sprint 4.

## 8. Schedule
Sprint 1: unit + integration scaffolding. Sprint 2: contract + E2E. Sprint 3: perf + security.
```

## Worked example

**Input:** Feature `003-payment-processing`, financial high-risk, 24 REQ-IDs, four-week timeline.

**Expected output:** the markdown above, populated with the 24 REQ-IDs grouped by layer, three named perf scenarios (single disburse, batch of 10k, retry storm), and a 6-line risk register.

## Anti-patterns

- A 100%-line-coverage target with no requirement-coverage target. Lines are easy, behaviors are not.
- E2E tests for everything. They are slow, flaky, and a poor place to verify branching logic.
- Skipping the contract layer between frontend and backend. PR breakage will cost more than it saves.
- Using production data in any non-prod environment. LGPD / regulatory risk.
- Defining exit criteria as "all tests pass" — that is a tautology.
- Choosing tools the team has not used before, mid-sprint. Strategy reflects reality.

## Success criteria

- [ ] Every `REQ-ID` is mapped to exactly one primary layer (with optional secondary).
- [ ] Each layer has a named tool, a coverage target, and a runtime budget.
- [ ] Data strategy explicitly forbids production PII in non-prod.
- [ ] Exit criteria are measurable and time-bounded.
- [ ] Risks have named owners and mitigation dates.
- [ ] The document is short enough (< 3 pages) that the whole team will actually read it.
