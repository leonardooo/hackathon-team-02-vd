---
mode: agent
model: claude-sonnet-4-6
description: "Author a forward-and-rollback PostgreSQL 16 migration with index strategy, data backfill, and zero-downtime steps."
---

# /migration

## Goal

You are the DBA producing a **PostgreSQL 16** migration for SIFAP 2.0. Every migration must be (a) idempotent, (b) reversible, (c) safe to run while the application is online, and (d) traced to a `REQ-ID` from `SPECIFICATION.md`. The deliverable is a versioned Flyway migration plus a rollback script.

## Inputs

Ask the user for what is missing.

- The change requested in plain English (for example "add `suspended_at` timestamp to `beneficiary`").
- The linked `REQ-ID` (and the EARS statement).
- The data scale: row count of affected tables, peak QPS.
- The deployment window: zero-downtime required, or a maintenance window allowed.
- The legacy reference if any — mapping to an Adabas DDM in `02-cenario-sifap-legado/adabas-ddms/`.

## Process

1. **Confirm the change is in `DESIGN.md`.** The migration follows design, not the other way round. If it is not in design, stop and route to `/architecture-review`.
2. **Choose the version number.** Use `Vyyyymmddhhmm__short_description.sql` (Flyway convention).
3. **Design for online migration.** Online-safe patterns:
 - Add nullable column → backfill in batches → add constraint last.
 - Create index `CONCURRENTLY` (no `IF NOT EXISTS` — that requires a separate guard).
 - Avoid `ALTER TABLE` operations that require an `ACCESS EXCLUSIVE` lock on a hot table; if unavoidable, schedule a maintenance window.
4. **Plan the backfill.** For non-trivial data, write a separate idempotent backfill script that processes in batches of 1k–10k rows with `commit` between batches. Never backfill in the migration itself if the table has more than 100k rows.
5. **Constrain after backfill.** Add `NOT NULL`, `CHECK`, foreign keys, and unique indexes only after data is consistent.
6. **Write the rollback.** Every forward migration ships with a `Vyyyymmddhhmm__short_description.undo.sql`. The rollback restores the prior schema even if intermediate state existed.
7. **Document side effects.** Note replication slot drift, vacuum implications, plan-cache invalidation, and any application code that must ship in lockstep.
8. **Test on a snapshot.** Restore the latest stage snapshot, run `flyway migrate`, verify, run the rollback, verify again. Paste the output.

## Output

Your final reply must include:

- **Migration metadata** — version, REQ-ID, online-safe (yes/no), estimated duration on prod-scale.
- **Forward script** — full SQL, paste-ready into `db/migration/Vyyyymmddhhmm__*.sql`.
- **Backfill script** if applicable — separate file with batch loop and progress logging.
- **Rollback script** — full SQL, paste-ready into `db/migration/Vyyyymmddhhmm__*.undo.sql`.
- **Application coordination notes** — what code must deploy before, with, or after the migration.
- **Risk register** — locking risk, replication risk, plan invalidation risk, with mitigations.

### Forward template (zero-downtime add-column)

```sql
-- V202604300930__add_suspended_at_to_beneficiary.sql
-- REQ-BEN-019: while a beneficiary is suspended, the system shall record the timestamp of suspension.
-- Online-safe: nullable column, backfill in separate script, constraint added in V...0945.

ALTER TABLE beneficiary
 ADD COLUMN IF NOT EXISTS suspended_at TIMESTAMPTZ;

COMMENT ON COLUMN beneficiary.suspended_at IS
 'Set when status transitions to SUSPENDED. REQ-BEN-019.';

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_beneficiary_suspended_at
 ON beneficiary (suspended_at)
 WHERE suspended_at IS NOT NULL;
```

### Rollback template

```sql
-- V202604300930__add_suspended_at_to_beneficiary.undo.sql
DROP INDEX CONCURRENTLY IF EXISTS idx_beneficiary_suspended_at;
ALTER TABLE beneficiary DROP COLUMN IF EXISTS suspended_at;
```

## Worked example

**Input:** "Add `suspended_at` to `beneficiary`. Table has 6.2M rows. Zero downtime required. REQ-BEN-019."

**Expected reply skeleton:**

> Metadata: V202604300930, online-safe = yes, estimated duration < 5 s for the schema change; backfill ~12 min for 6.2M rows in 5k batches.
>
> Forward: nullable column + partial index (above).
>
> Backfill: `db/scripts/backfill_suspended_at.sql` — loops over `beneficiary` where `status='SUSPENDED' AND suspended_at IS NULL`, sets `suspended_at = updated_at`, commits every 5,000 rows.
>
> Rollback: drop index then column.
>
> App coordination: `BeneficiaryService` writes to `suspended_at` from release v2.4.0 onward. The migration ships with v2.4.0. Reading the column starts in v2.5.0.
>
> Risks: index creation under load may extend duration; mitigation — schedule during off-peak window. Replication lag — acceptable below 30 s on stage benchmark.

## Anti-patterns

- `ALTER TABLE ... ADD COLUMN ... NOT NULL DEFAULT 'x'` on a hot, large table — rewrites the whole table. Split into nullable add + backfill + constraint.
- Creating an index without `CONCURRENTLY` on a production table — locks writers.
- Combining schema change and large `UPDATE` in the same migration — long transactions and replication lag.
- No rollback script. The DB cannot be restored without one.
- Forgetting to coordinate with application releases — code reads a column that does not exist yet, or vice versa.
- Storing PII in a new column without consulting `25-appsec-engineer` and InfoSec.
- Skipping the test on a stage snapshot. "It worked on my dev DB" is not enough.

## Success criteria

- [ ] Forward and rollback scripts both committed.
- [ ] Forward script is idempotent (`IF NOT EXISTS`, `IF EXISTS`).
- [ ] No `ACCESS EXCLUSIVE` lock on a hot table without an explicit maintenance window note.
- [ ] Backfill handles >100k rows in batches.
- [ ] Linked `REQ-ID` and EARS statement appear as a comment at the top.
- [ ] Tested on a stage snapshot — output of `flyway migrate` and `flyway undo` pasted.
- [ ] Application coordination plan stated explicitly.
