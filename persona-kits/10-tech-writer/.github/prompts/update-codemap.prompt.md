---
mode: agent
model: claude-sonnet-4-6
description: "Generate or refresh CODEMAP.md — a navigable index of the SIFAP 2.0 codebase showing modules, owners, and entry points."
---

# /update-codemap

## Goal

You produce or update `docs/CODEMAP.md`, a one-page navigation aid that a new team member can read in 10 minutes and use to find any module, its owner, its entry points, and its tests. The codemap is **not** auto-generated documentation; it is curated. It complements `DESIGN.md` (architecture) and the spec (requirements).

## Inputs

Ask the user for what is missing.

- The repo root path (this workspace).
- Whether to refresh in place (`update`) or rebuild (`rebuild`).
- The persona owners table — usually defined in `06-kit-repositorio-times/personas/`.
- A previous version of `CODEMAP.md` if one exists.

## Process

1. **List the top-level service folders.** Backend services under `04-prototipo-sifap-moderno/backend/src/main/java/br/gov/sifap/<service>/`, frontend routes under `04-prototipo-sifap-moderno/frontend/app/<route>/`, infra under `05-terraform-azure/modules/<name>/`.
2. **For each module, capture five facts.**
 - Purpose (one sentence).
 - Public entry points (REST endpoints, page routes, CLI commands, IaC inputs).
 - Persistent state (tables, queues, blob containers).
 - Linked `REQ-ID` ranges (for example `REQ-PAY-001..024`).
 - Owner persona (`alex`, `sam`, `jordan`, `morgan`, `casey`).
3. **Find tests.** For each module, find the corresponding test directory and link it.
4. **Find the legacy mapping.** When a module corresponds to a Natural program from `02-cenario-sifap-legado/natural-programs/`, name the program (`CALCBENF.NSN`, etc.). This makes the modernization lineage explicit.
5. **Find non-obvious dependencies.** Cross-module imports, shared libraries (`commons-*`), and external Azure services. Highlight any module that depends on more than three others — that is a smell.
6. **Sort modules by user-visible value.** Critical user paths first (registration, disbursement, audit), supporting modules next, infra last.
7. **Render as a single navigable markdown file.** Keep it under 200 lines. If it grows past that, split sub-codemaps per service area and link them.

## Output

The deliverable is `docs/CODEMAP.md` (or sub-files), with this structure:

```markdown
# SIFAP 2.0 Codemap

> Last updated: <YYYY-MM-DD>. Owners: see `06-kit-repositorio-times/personas/`.

## 1. Reading guide
- Critical paths: payments, beneficiaries, audit.
- See `DESIGN.md` for architecture rationale; see `SPECIFICATION.md` for requirements.

## 2. Backend services

### payments — disbursement orchestration
- **Purpose**: Issue, retry, and reconcile beneficiary disbursements.
- **Path**: `04-prototipo-sifap-moderno/backend/src/main/java/br/gov/sifap/payments/`
- **Tests**: `04-prototipo-sifap-moderno/backend/src/test/java/br/gov/sifap/payments/`
- **Entry points**: `POST /api/v1/payments`, `GET /api/v1/payments/{id}`, `POST /api/v1/payments/{id}/retry`
- **State**: Postgres tables `payment`, `payment_attempt`, `disbursement_lock`. Service Bus queue `payments-out`.
- **REQ-IDs**: REQ-PAY-001..024
- **Owner**: @alex
- **Legacy lineage**: `CALCBENF.NSN`, `CALCDSCT.NSN`, `BATCHPGT.NSN`
- **Cross-module deps**: `beneficiaries` (read), `audit` (write).

### beneficiaries — registry and lifecycle
- ...

## 3. Frontend routes

### /beneficiaries — listing & detail
- **Path**: `04-prototipo-sifap-moderno/frontend/app/beneficiaries/`
- **Tests**: `04-prototipo-sifap-moderno/frontend/app/beneficiaries/__tests__/`
- **REQ-IDs**: REQ-UI-007..014
- **Owner**: @sam
- **API consumer of**: `payments`, `beneficiaries`
- ...

## 4. Infrastructure modules

### postgres
- **Path**: `05-terraform-azure/modules/postgres/`
- **REQ-IDs**: REQ-OPS-014..018
- **Owner**: @jordan
- ...

## 5. Cross-cutting libraries
- `br.gov.sifap.shared.audit` — used by payments, beneficiaries, programs.
- `br.gov.sifap.shared.money` — `BigDecimal` wrappers for ICMS calculations.

## 6. Smells noted
- `beneficiaries` imports from 4 other modules — review for tighter responsibility boundary.

## 7. How to update this file
Run `/update-codemap` after any module add/rename. Do not auto-generate; curate.
```

## Worked example

**Input:** Refresh after adding the new `audit` service and the `audit-log` Postgres migration.

**Expected reply skeleton:** the structure above with the new section for `audit`, updated `payments` cross-module deps, and a new "Smells noted" line if appropriate.

## Anti-patterns

- Generating from `find . -type d` — that is a directory listing, not a map.
- Including every file. The codemap names modules, not lines.
- Listing endpoints as `*` — be specific.
- Forgetting the legacy lineage column for SIFAP — modernization without lineage is invisible.
- Owners as teams. The on-call human is the owner.
- Skipping the "Smells noted" section. The codemap is also a health check.
- Letting it drift > 30 days. Out-of-date codemap is worse than no codemap.

## Success criteria

- [ ] Every backend service, frontend route, and IaC module is listed.
- [ ] Each entry has Purpose, Path, Tests, Entry points, State, REQ-IDs, Owner.
- [ ] Legacy lineage is named for any module that maps to a Natural program.
- [ ] Cross-module dependencies are stated; modules with > 3 deps are flagged.
- [ ] File length stays under 200 lines (or is split with linked sub-files).
- [ ] Last-updated date is set to today.
- [ ] Owner persona names match `06-kit-repositorio-times/personas/`.
