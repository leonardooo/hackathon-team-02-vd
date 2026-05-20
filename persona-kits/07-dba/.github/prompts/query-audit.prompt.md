---
mode: ask
model: claude-sonnet-4-6
description: "Audit a SQL query for performance, security, and SIFAP coding standards. Output a fixed query plus an EXPLAIN-backed rationale."
---

# /query-audit

## Goal

You are the DBA reviewing a SQL query (or JPA/JPQL query) heading to PostgreSQL 16. Your audit catches injection risk, sequential-scan traps, N+1 patterns, and violations of SIFAP coding standards. The deliverable is a verdict (Pass / Fix required / Reject), a rewritten query, and an `EXPLAIN ANALYZE` reading.

## Inputs

Ask the user for what is missing.

- The query, in its original form (raw SQL, JPQL, Criteria API, or QueryDSL).
- The schema of the involved tables, or a pointer to migrations in `db/migration/`.
- Existing indexes (`\d table_name` output) on those tables.
- Production-realistic row counts and selectivity estimates.
- The calling code path — is this a hot endpoint (per-request) or a batch job (nightly)?

## Process

1. **Static scan first.**
 - Any string concatenation of user input → reject as SQL injection.
 - `SELECT *` on a wide table → reject.
 - Implicit casts (`varchar = bigint`) that disable indexes → fix.
 - Functions on indexed columns (`lower(cpf) = ?` when only `cpf` is indexed) → fix or add expression index.
2. **Dynamic scan.** Run `EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) ...` on a stage snapshot. Read the plan top-down.
 - Flag any `Seq Scan` on tables larger than 10k rows where a filter exists.
 - Flag any `Sort` step that could be index-supported.
 - Flag any `Nested Loop` over more than ~1k outer rows where a `Hash Join` would be cheaper.
 - Flag `rows estimated` vs `rows actual` mismatch ratio above 10× — stats are stale or query shape is unfriendly.
3. **Check for N+1.** If the query is invoked from JPA, look for missing `JOIN FETCH` or batch-size hints. List the parent loop in the application code.
4. **Verify locks and isolation.** `SELECT ... FOR UPDATE` on hot tables requires care. Default isolation should be `READ COMMITTED`; flag `SERIALIZABLE` without justification.
5. **Confirm parameterization.** All user-facing values must be bound parameters, never string-interpolated. Even from "trusted" code paths.
6. **Compare against SIFAP standards.**
 - All public schemas use `snake_case`.
 - Timestamps are `TIMESTAMPTZ`.
 - Money is `NUMERIC(15,2)`, never `FLOAT`.
 - PII columns must have a `COMMENT` flagging them.
7. **Write the fix.** Rewrite the query with index hints if needed, add a missing index migration if justified.
8. **Rate the verdict.**

## Output

A markdown report with this structure:

```markdown
## Query Audit — <short identifier>

### Verdict
**Fix required** — sequential scan on `payment` (1.8M rows), and CPF compared with implicit cast.

### Findings
| # | Severity | Finding | Evidence |
|---|----------|---------|----------|
| 1 | Critical | SQL injection risk: CPF concatenated into query string | line 42, `PaymentRepository.java` |
| 2 | High | Seq Scan on `payment` | EXPLAIN: `Seq Scan on payment (cost=0..38291) rows=1810233` |
| 3 | Medium | `lower(cpf) = ?` defeats `idx_payment_cpf` | EXPLAIN: filter on lower(cpf) |
| 4 | Low | `SELECT *` returns 23 columns when 4 are used | code review |

### Rewritten query
```sql
SELECT id, beneficiary_id, amount, paid_at
FROM payment
WHERE beneficiary_id = :beneficiaryId
 AND paid_at >= :since
ORDER BY paid_at DESC
LIMIT 100;
```

### Index recommendation
```sql
-- if not already present
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_payment_beneficiary_paid_at
 ON payment (beneficiary_id, paid_at DESC);
```

### EXPLAIN ANALYZE before / after
- Before: 412 ms, Seq Scan, 1.8M rows scanned, 100 returned.
- After: 0.8 ms, Index Scan, 100 rows scanned, 100 returned.

### Application change required
- Replace string concatenation with named parameter `:beneficiaryId`.
- Bind `:since` as `Instant` (mapped to `TIMESTAMPTZ`).
```

## Worked example

**Input:** Query returning recent payments for one beneficiary, called from `PaymentRepository.findRecent()`, hot endpoint (~150 RPS).

**Expected verdict:** Fix required. The audit follows the template above and ends with a one-paragraph note that the migration `db/migration/V202604300945__idx_payment_beneficiary_paid_at.sql` must ship with the application change.

## Anti-patterns

- Approving a query because "it's fast on dev" — dev has 1k rows, prod has millions.
- Approving a `SELECT *` because "the ORM strips unused columns" — it does not.
- Adding indexes for every query without considering write amplification.
- Trusting `EXPLAIN` without `ANALYZE` — estimates lie when stats are stale.
- Approving `FOR UPDATE` on a hot row without a queue or backoff strategy.
- Reading PII without a `COMMENT` on the column flagging it as PII.
- Writing a query that works but disagrees with the JPA entity mapping — leads to silent N+1 fixes that re-introduce the bug.

## Success criteria

- [ ] Verdict given: Pass / Fix required / Reject.
- [ ] Findings have severity, evidence (file/line or EXPLAIN snippet), and recommendation.
- [ ] Rewritten query is paste-ready.
- [ ] EXPLAIN ANALYZE pasted before and after, with measured times.
- [ ] Index migrations are versioned and online-safe (`CONCURRENTLY`).
- [ ] All parameters are bound, no string concatenation remains.
- [ ] PII access is flagged and column comments confirmed.
