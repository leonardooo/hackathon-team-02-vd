---
mode: ask
model: claude-sonnet-4-6
description: "Detect drift between SIFAP 2.0 docs (README, CODEMAP, ADRs, runbooks) and the current code, surfacing concrete fixes."
---

# /doc-drift

## Goal

You are the technical writer auditing the SIFAP 2.0 documentation for **drift** — places where the docs and the code disagree. The deliverable is a prioritized fix list with the exact line, the contradiction, and a one-line correction. You do not silently rewrite docs; you propose the fix and let the owner approve.

## Inputs

Ask the user for what is missing.

- The doc set in scope: `README.md`, `docs/CODEMAP.md`, `.specs/<NNN>-<feature>/SPECIFICATION.md`, `.specs/<NNN>-<feature>/DESIGN.md`, `docs/runbooks/`, ADRs in `.specs/<NNN>-<feature>/ADRs/`.
- The reference code paths: `04-prototipo-sifap-moderno/backend/`, `04-prototipo-sifap-moderno/frontend/`, `05-terraform-azure/`.
- Time horizon: "drift since last release" or "all current drift."
- A list of recent merges (titles + SHAs) if available — focuses the search.

## Process

1. **Build the inventory of claims.** For each doc, extract claims that can be checked against code:
 - File and folder names — `04-prototipo-sifap-moderno/backend/src/main/java/br/gov/sifap/payments/PaymentService.java`.
 - REST routes and HTTP methods.
 - Database tables, columns, types.
 - Environment variables and configuration keys.
 - Build, run, and deploy commands.
 - Version numbers (Java, Spring Boot, Next.js, Postgres).
 - REQ-ID references.
2. **Verify each claim against the source.** For routes, check controllers. For schema, check migrations in `db/migration/`. For configs, check `application.yml`. For commands, check `Makefile`, `package.json`, `pom.xml`, GitHub Actions.
3. **Classify drift.**
 - **Critical** — instructions that will fail when followed (wrong command, missing file, broken link).
 - **Major** — outdated facts that mislead but don't break (wrong version, renamed module).
 - **Minor** — terminology mismatch, stale examples.
4. **Check legacy mappings.** For any doc claiming "this module replaces `CALCBENF.NSN`," verify the program name exists in `02-cenario-sifap-legado/natural-programs/`.
5. **Cross-check ADRs.** An ADR's "Status: Accepted" with a "Consequences" the code does not reflect is critical drift.
6. **Output the fix list.**

## Output

A markdown report:

```markdown
## Documentation Drift Report — <YYYY-MM-DD>

### Summary
- Files audited: 14
- Critical: 3 — Major: 7 — Minor: 12
- Most-drifted file: `docs/runbooks/disburse-retry.md` (5 findings)

### Critical
| # | File | Line | Claim | Reality | Fix |
|---|------|------|-------|---------|-----|
| 1 | README.md | 42 | "Run `./mvnw spring-boot:run`" | Module is now multi-module; needs `-pl backend/payments` | Replace with `./mvnw -pl backend/payments spring-boot:run` |
| 2 | docs/runbooks/disburse-retry.md | 18 | "POST /retry" | Endpoint is `POST /api/v1/payments/{id}/retry` | Update path and example |
| 3 | .specs/003/ADRs/0007-eventbus.md | 56 | "Consequence: Service Bus topics" | Migrated to Event Grid in PR #482 | Open new ADR superseding 0007 |

### Major
... (table)

### Minor
... (table)

### Cross-cutting issues
- 3 docs reference `BeneficiaryService.findByCpf()` — method renamed to `findByDocument()`; mass-update once.
- Java version in 4 places says `17`; project upgraded to `21` in PR #501.

### Recommended workflow
1. Open one PR per critical fix, naming the doc + line.
2. Bundle major fixes in a single "doc-refresh" PR.
3. Defer minor findings to a backlog issue.
```

## Worked example

**Input:** Audit doc set after the multi-module refactor merged in PR #492.

**Expected reply:** the structure above, populated with the build-command drift, the renamed package paths, and the ADR for service bus → event grid that needs superseding.

## Anti-patterns

- Silently editing docs. Always surface the drift first; ownership matters.
- Reporting "the README is out of date" without line numbers. Reviewers cannot act.
- Treating every minor mismatch as critical. Triage matters.
- Skipping ADRs because they "feel" stable. ADRs drift the most.
- Not checking against migrations for schema claims. Migrations are the source of truth.
- Counting drift in dead docs (`docs/archive/`). Mark archived first, audit live docs only.
- Reporting drift without proposing the fix. Half a job.

## Success criteria

- [ ] Every finding cites file and line.
- [ ] Every finding has a one-line proposed fix.
- [ ] Severity (Critical/Major/Minor) is assigned.
- [ ] Cross-cutting issues are summarized so they can be fixed once.
- [ ] ADRs are explicitly checked, not skipped.
- [ ] Legacy lineage references (Natural programs) are validated.
- [ ] Recommended PR-grouping is included so doc fixes do not balloon.
