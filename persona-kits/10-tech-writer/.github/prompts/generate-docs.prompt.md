---
mode: agent
model: claude-sonnet-4-6
description: "Generate developer-facing documentation (README, runbook, API reference, ADR scaffold) for a SIFAP 2.0 module."
---

# /generate-docs

## Goal

You are the technical writer producing one of four document types for a SIFAP 2.0 module: a **README**, a **runbook**, an **API reference**, or an **ADR scaffold**. Your output uses the project's standard frontmatter, terminology, and tone. Each document is short, navigable, and ground-truth — no marketing language, no aspirational claims.

## Inputs

Ask the user for what is missing.

- The document type — `readme`, `runbook`, `api-reference`, or `adr`.
- The target module — folder under `04-prototipo-sifap-moderno/`, `05-terraform-azure/modules/`, or another scoped area.
- The audience — "new contributor (week 1)," "on-call SRE at 03:00," or "external API consumer."
- The linked `REQ-ID` set if applicable.

## Process

1. **Choose the right template.** README for "what is this and how do I run it." Runbook for "production is broken at 03:00, what do I do." API reference for "I am consuming this from another service." ADR for "we are choosing X over Y and need to record why."
2. **Source from code, not memory.** Open `pom.xml`, `package.json`, `application.yml`, controller classes, OpenAPI spec, migrations. Quote exact strings.
3. **Use SIFAP terminology consistently.**
 - "Beneficiary" not "user" (when domain).
 - "Disbursement" not "payment" (when SIFAP-specific).
 - "Audit log" not "activity log."
 - Names match Portuguese-Brazilian SIFAP usage where they exist; explanations are in English.
4. **Apply the standard frontmatter.**
 ```yaml
 ---
 title: "Disburse-retry runbook"
 audience: "on-call SRE"
 last_reviewed: "2026-04-29"
 owner: "@alex"
 linked_reqs: [REQ-PAY-014, REQ-OPS-031]
 ---
 ```
5. **Hold to length budgets.** README ≤ 1 page (~80 lines). Runbook ≤ 1 page per scenario. API reference is per endpoint. ADR ≤ 2 pages.
6. **Include verification.** Every command in the doc must be runnable. If the doc says `./mvnw -pl payments verify`, the reviewer must be able to copy-paste it.
7. **Cross-link.** README → CODEMAP, SPECIFICATION, runbook. Runbook → dashboard URLs, alert names. ADR → superseded/superseding ADRs.
8. **Stamp with last-reviewed date.** Drift starts the moment a doc is written.

## Output

The deliverable is the document file in the project's docs tree:

- README → `<module-folder>/README.md`
- Runbook → `docs/runbooks/<short-slug>.md`
- API reference → `docs/api/<service>/<endpoint-slug>.md`
- ADR → `.specs/<NNN>-<feature>/ADRs/<NNNN>-<title>.md`

### README template (module)

```markdown
---
title: "payments"
audience: "new contributor"
last_reviewed: "<YYYY-MM-DD>"
owner: "@alex"
linked_reqs: [REQ-PAY-001..024]
---

# payments

Disburse, retry, and reconcile SIFAP beneficiary payments.

## Quick start
```bash
cd 04-prototipo-sifap-moderno/backend
./mvnw -pl payments spring-boot:run
```

## Public API
| Method | Path | Purpose |
|--------|------|---------|
| POST | /api/v1/payments | Create disbursement |
| GET | /api/v1/payments/{id} | Read disbursement |
| POST | /api/v1/payments/{id}/retry | Retry failed disbursement |

## Persistent state
- Tables: `payment`, `payment_attempt`, `disbursement_lock`.
- Queues: `payments-out` (Service Bus).

## Tests
- `./mvnw -pl payments test`
- Integration: `./mvnw -pl payments verify -Pintegration`

## Legacy lineage
Replaces `CALCBENF.NSN`, `CALCDSCT.NSN`, `BATCHPGT.NSN`.

## See also
- `docs/CODEMAP.md`
- `.specs/003-payment-processing/SPECIFICATION.md`
- `docs/runbooks/disburse-retry.md`
```

### Runbook template

```markdown
---
title: "Disburse-retry runbook"
audience: "on-call SRE"
last_reviewed: "<YYYY-MM-DD>"
owner: "@alex"
severity_default: "SEV-2"
linked_reqs: [REQ-PAY-014, REQ-OPS-031]
---

# Disburse-retry — beneficiary disbursement is stuck

## When you would see this
Alert: `pay-be-retry-stuck-15m`, dashboard `Payments > Retries`, ticket "disbursement not received."

## Severity
SEV-2 if isolated to one beneficiary. SEV-1 if > 100 in 5 minutes.

## Diagnose
1. Check `payment_attempt` count for the beneficiary in the last 30 min.
2. Check Service Bus DLQ depth on `payments-out`.
3. Check the `RetryPolicy` config (`payments.retry.max-attempts`).

## Mitigate
- For one beneficiary: re-enqueue from `payment_attempt` after fixing the cause.
- For > 100: pause new disbursements, drain DLQ, replay.

## Verify
- `payment` rows transition to `SETTLED` state.
- DLQ depth returns to 0.

## Escalate
- @alex (engineering lead) for code-level issues.
- @jordan (DevOps) for queue or infra issues.
- @morgan (tech lead) for SEV-1 declaration.
```

## Worked example

**Input:** Generate a README for the new `audit` backend module.

**Expected reply:** README populated with the audit endpoints, the `audit_log` table, the legacy lineage to `BATCHCON.NSN`, and links to its tests and the spec section `REQ-AUDIT-*`.

## Anti-patterns

- Marketing language ("blazing fast," "world-class"). State facts.
- Aspirational claims ("supports multi-region failover" when it does not yet). State current reality; document plans separately.
- Copy-pasting the OpenAPI spec into the README. Link it.
- "Run the tests" without the exact command. Always paste the command.
- Skipping `last_reviewed`. Drift starts immediately.
- ADR without a date and a status. Useless.
- Runbook that does not name the alert. Useless at 03:00.
- Mixing English and Portuguese inconsistently. Domain terms can stay in PT-BR; explanations are English.

## Success criteria

- [ ] Frontmatter is complete (`title`, `audience`, `last_reviewed`, `owner`, `linked_reqs`).
- [ ] Every command in the doc is copy-pasteable.
- [ ] Length within budget (README ≤ 80 lines, ADR ≤ 2 pages).
- [ ] At least two cross-links to related docs.
- [ ] Legacy lineage named for SIFAP modules.
- [ ] No marketing language, no aspirational claims.
- [ ] Doc lives in the canonical path for its type.
