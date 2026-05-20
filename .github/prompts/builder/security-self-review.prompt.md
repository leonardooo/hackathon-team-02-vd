---
description: "Self-review checklist for security and OWASP Top 10 issues on a freshly built feature."
mode: ask
model: claude-sonnet-4-6
tools: ['codebase', 'search']
---

# /security-self-review

## Goal

Scan a freshly built feature for common security issues aligned with OWASP Top 10. The output is a prioritized report — the agent does not auto-fix, the team decides.

## When to Invoke

After a bounded context has been implemented (entities, services, controllers, tests) and before moving to Stage 4.

## Pre-conditions

- The feature code exists and compiles
- The team specifies which controller(s), service(s), and entity(entities) to review

## Inputs the Team Must Provide

- The feature scope: which controller, service, and entity classes to review
- The bounded context name

## What I Will Do

- Scan for hardcoded secrets (strings that look like keys, passwords, tokens)
- Check for SQL injection vectors (string concatenation in queries)
- Verify authentication/authorization annotations on endpoints
- Check input validation coverage
- Look for sensitive data in logs or error responses
- Identify missing rate limits on write endpoints
- Flag dependency areas where a real security scan should be run

## What I Will NOT Do

- Run an actual security scanner (I do static analysis by reading code)
- Auto-fix issues — the team reviews and decides what to fix
- Fabricate severity ratings — each rating is justified by the finding
- Guarantee completeness — this is a self-review, not a formal audit

## Output Format

A Markdown report at `03-implementacao/security-review-[context].md`:

```markdown
# Security Self-Review — [Bounded Context]
## Summary
Findings: N total | High: N | Medium: N | Low: N
## Findings
| # | Severity | Category | File:Line | Description | Remediation |
## Areas Needing External Scan
## Sign-off
```

## Definition of Done

- [ ] Every controller endpoint has been checked for auth annotations
- [ ] Every query has been checked for SQL injection
- [ ] No hardcoded secrets found (or all are flagged)
- [ ] Input validation coverage is assessed per endpoint
- [ ] Report has severity ratings justified by findings
- [ ] At least one "area needing external scan" is identified

## The Prompt Body

You are the `@builder-agent` performing a security self-review. This is not a formal audit — it is a rapid check before the team moves to Stage 4.

**Step 1 — Scan for hardcoded secrets.**
Search the specified files for patterns that suggest hardcoded secrets:
- Strings containing "password", "secret", "key", "token", "api_key" (case-insensitive)
- Strings that look like Base64-encoded tokens (long alphanumeric strings)
- Properties or environment variable references that are set to literal values instead of `${ENV_VAR}`
- Files named `.env` committed to the repo

For each finding: file path, line number, the suspicious pattern (redacted if it looks like a real secret), severity (High).

**Step 2 — Check for SQL injection.**
Search for:
- String concatenation in SQL queries (`"SELECT..." + variable`)
- `@Query` annotations with string interpolation instead of named parameters
- Any `nativeQuery = true` usage (flag for manual review, not auto-reject)
- `JdbcTemplate` usage with string concatenation

For each finding: file, line, the vulnerable pattern, remediation (use named parameters or derived queries).

**Step 3 — Verify authentication and authorization.**
For each `@RestController` endpoint:
- Check if `@PreAuthorize`, `@Secured`, or method-level security is present
- Check if the controller is under a path covered by Spring Security filter chains
- Flag any endpoint that is publicly accessible without apparent justification

For each unprotected endpoint: file, line, the endpoint method and path, severity (High if it modifies data, Medium if read-only).

**Step 4 — Check input validation.**
For each endpoint that accepts a request body:
- Verify `@Valid` is present on the parameter
- Check that the request DTO has Bean Validation annotations
- Look for any field of type `String` without `@Size` or `@Pattern` constraints

For each gap: file, line, the field missing validation, remediation.

**Step 5 — Check for sensitive data exposure.**
Search for:
- Logging statements that might output sensitive fields (passwords, tokens, personal data)
- Error responses that expose stack traces or internal details
- Response DTOs that include fields like `password`, `token`, `ssn`

**Step 6 — Identify rate limit opportunities.**
Flag any write endpoint (POST, PUT, DELETE) that does not have rate limiting. Note: the team may not implement rate limiting in the hackathon, but it should be documented as a production concern.

**Step 7 — Compile the report.**
Write to `03-implementacao/security-review-[context].md` with all findings sorted by severity (High first). Include a summary count and a section listing areas where a real scanner (SAST/DAST) should be run.

This report does not block Stage 4 — it is informational. The team decides which findings to fix now and which to defer.

## Example Invocation

```
/security-self-review context=payment files=PaymentController.java,PaymentService.java,Payment.java
```
