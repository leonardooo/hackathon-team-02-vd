---
mode: agent
model: claude-opus-4-6
description: "Author CONSTITUTION.md — the non-negotiable rules and principles that govern a SIFAP 2.0 feature build."
---

# /create-constitution

## Goal

You are the enterprise architect authoring `.specs/<NNN>-<feature>/CONSTITUTION.md` — the document that lists the **non-negotiable rules** every contributor agrees to before they read the spec. The constitution is short, explicit, and stable. ADRs make decisions; the constitution sets the rails decisions cannot leave.

## Inputs

Ask the user for what is missing.

- The feature folder (`.specs/<NNN>-<feature>/`).
- The organization-wide constraints already in force (security baseline, Azure-only, OWASP Top 10, LGPD).
- Any prior constitutions to inherit from (a parent feature's CONSTITUTION).
- The team and persona owners assigned to this feature.

## Process

1. **Inherit and adapt.** Start from the project-level constitution and tighten or relax for this feature only with explicit justification.
2. **Group rules by category.**
 - **Stack** — language, framework, runtime versions.
 - **Security** — identity, secrets, network, encryption, OWASP baseline.
 - **Data** — PII handling, retention, residency, encryption at rest.
 - **Operations** — observability, deployment, environments, SLOs.
 - **Process** — branching, code review, testing thresholds, ADR cadence.
 - **Compliance** — LGPD, regulatory, audit logging.
3. **Make every rule testable.** "Use Java 21" is testable (`mvnw --version`); "use modern Java" is not.
4. **Number the rules.** `C1`, `C2` ... so reviewers can cite them.
5. **State the consequence of breaking a rule.** "Build fails," "PR rejected," "InfoSec exception required" — not silence.
6. **Mark mutable vs immutable.** Some rules can be relaxed via ADR with InfoSec sign-off; some require a new constitution.
7. **Date and sign.** Architecture forum date, named approvers, version `1.0.0`. Bumped only when the constitution itself changes.
8. **Keep it short.** Target ≤ 80 lines. If the team cannot remember the constitution, it does not work.

## Output

The deliverable is `.specs/<NNN>-<feature>/CONSTITUTION.md`:

```markdown
# CONSTITUTION — <feature> (<feature-folder>)

- **Version**: 1.0.0
- **Date**: 2026-04-29
- **Approvers**: @paula (enterprise architect), @morgan (technical lead), @infosec-lead
- **Inherits from**: project-level CONSTITUTION.md

## 1. Stack
| ID | Rule | Consequence on breach |
|----|------|----------------------|
| C1 | Backend services run on Java 21 (Temurin) and Spring Boot 3.3 only. | Build fails. |
| C2 | Frontend runs on Next.js 15 with TypeScript `strict: true`. No `any`. | Lint blocks merge. |
| C3 | PostgreSQL 16 is the only system of record for SIFAP data. | InfoSec exception required. |
| C4 | All cloud infra is Azure. No multi-cloud in this feature. | New ADR + architecture forum required. |

## 2. Security
| ID | Rule | Consequence |
|----|------|-------------|
| C5 | Service-to-service auth uses Azure Managed Identity. No client secrets in code or config. | PR blocked. |
| C6 | All secrets read from Key Vault at runtime. No `.env` committed. | Gitleaks blocks merge. |
| C7 | OWASP Top 10 baseline applies — input validation, parameterized SQL, no string-built queries. | PR rejected. |
| C8 | CORS allowlist is explicit. No `*` in production config. | Stage promotion blocked. |

## 3. Data
| ID | Rule | Consequence |
|----|------|-------------|
| C9 | PII columns carry a `COMMENT` flagging them as PII. | DBA review blocks. |
| C10 | No production PII in `dev` or `stage`. Synthetic data only. | InfoSec finding, immediate revert. |
| C11 | Money is `NUMERIC(15,2)`; never `FLOAT`. | DBA review blocks. |
| C12 | Audit log entries are append-only; no `DELETE` or `UPDATE` on `audit_log`. | Migration rejected. |

## 4. Operations
| ID | Rule | Consequence |
|----|------|-------------|
| C13 | Every public endpoint emits a structured log line with `requestId`, `userId`, `latencyMs`. | Code review blocks. |
| C14 | SLO defined for every user-facing endpoint, in REQ-OPS-*. | Spec review blocks. |
| C15 | Deployments to prod require two reviewers and a linked change ticket. | Pipeline blocks. |

## 5. Process
| ID | Rule | Consequence |
|----|------|-------------|
| C16 | One branch per spec — `spec/<NNN>-<name>` from `develop`. No direct commits to `develop`, `stage`, or `main`. | PR rejected. |
| C17 | Every requirement uses EARS notation; every test cites a `REQ-ID`. | Spec review blocks. |
| C18 | Every architectural decision is captured as an ADR before code lands. | Code review blocks. |

## 6. Compliance
| ID | Rule | Consequence |
|----|------|-------------|
| C19 | LGPD subject-rights endpoints (read, delete, export) covered by REQ-COMP-*. | Compliance review blocks release. |
| C20 | TCU/SISP audit trail completeness verified before each release. | Release manager blocks. |

## 7. Mutable vs immutable
- Mutable (relaxable via ADR + InfoSec sign-off): C13–C18.
- Immutable (constitutional change required): C1, C3, C4, C5, C6, C7, C9, C10, C19, C20.

## 8. Amendment process
Open a PR to this file. Architecture forum reviews, version bumped (`1.0.0` → `1.1.0` minor, → `2.0.0` major). New approvers signature required.
```

## Worked example

**Input:** New feature `004-uat-portal`, inherits project constitution, adds two extra rules: WCAG 2.1 AA accessibility, support for SSO via Entra ID.

**Expected reply:** the structure above, with two added rows in the Security section (`C8a` SSO required) and Operations (`C14a` axe-core checks pass), and "Inherits from" naming the project CONSTITUTION.

## Anti-patterns

- Long constitutions nobody reads. Cut to ≤ 80 lines.
- Rules without consequences. Soft rules drift to optional.
- Rules without IDs. Reviewers cannot cite them.
- Mixing principles ("we value quality") with rules ("Java 21 only"). Principles belong elsewhere; the constitution is rules.
- "Best practices" wording. State the rule.
- No mutable/immutable distinction. Every rule looks equally rigid; teams over-comply or revolt.
- No amendment process. Stale constitutions are ignored.

## Success criteria

- [ ] File length ≤ 80 lines (excluding signatures).
- [ ] Every rule has an ID and a consequence on breach.
- [ ] At least one rule per category (Stack, Security, Data, Operations, Process, Compliance).
- [ ] Mutable vs immutable distinction stated.
- [ ] Amendment process documented.
- [ ] Inherits from a parent constitution where one exists.
- [ ] Approvers and date recorded.
- [ ] Version follows semver.
