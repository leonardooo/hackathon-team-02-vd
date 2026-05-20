---
title: "Example: Evolution Agent in Action"
description: "A realistic session transcript showing how the Evolution agent writes issues, delegates to Copilot Agent, and reviews the resulting PR"
tags: [example, transcript, evolution, hackathon]
author: "Paula Silva, AI-Native Software Engineer, Americas Global Black Belt at Microsoft"
date: 2026-04-29
version: "1.0.0"
---

# Example: Evolution Agent in Action

## Scenario

**Participants:** Tech Lead (TL), Product Owner (PO)
**Agent commands:** `/write-github-issue`, `/delegate-to-copilot-agent`, `/review-agent-pr`
**Goal:** Create a well-structured GitHub issue for adding input validation to the rate calculation endpoint, delegate implementation to Copilot Agent, then review the resulting PR with a critical eye.

---

## Setup

1. Open GitHub Copilot Chat in VS Code
2. The Builder phase is complete — the rate calculation endpoint exists but lacks input validation
3. The Evolution agent persona is active
4. The team's repository is connected to GitHub with Copilot Agent enabled
5. The bounded context map and specification are in `.specs/001-rate-processing/`

---

## Opening Prompt

**TL:** `@evolution /write-github-issue — we need to add input validation to the rate calculation endpoint. It currently accepts any payload without checking required fields, value ranges, or date formats.`

---

## Transcript

### Part 1: Writing the GitHub Issue

**Agent:**
> I'll draft a structured GitHub issue. Let me pull context from the specification and design artifacts first.
>
> From `SPECIFICATION.md`, I can see these relevant requirements:
> - **REQ-012**: Input validation at controller layer with `@Valid` + Bean Validation
> - **REQ-018**: Rate values must be non-negative and ≤ 9999.99 (from BR-004)
> - **REQ-023**: Effective dates must not be in the future
>
> **Draft issue:**
>
> **Title:** Add input validation to rate calculation endpoint
> **Labels:** `enhancement`, `backend`, `rate-calculation`
>
> **Context:** The `POST /api/v1/rates/calculate` endpoint accepts any JSON payload without validation, violating REQ-012.
>
> **Acceptance Criteria:**
> - [ ] `employeeId` required, non-blank, matches `^[A-Z]{2}\d{6}$`
> - [ ] `effectiveDate` required, valid ISO-8601, not in the future
> - [ ] `rateValue` required, ≥ 0 and ≤ 9999.99 (REQ-018 / BR-004)
> - [ ] `reasonCode` required, one of: `ADJ`, `PRO`, `NEW`, `COR`
> - [ ] HTTP 400 with structured error response listing ALL validation failures
> - [ ] Format: `{ "errors": [{ "field": "...", "message": "..." }] }`
> - [ ] Existing tests pass; new tests cover each rule individually and combined
>
> **Traces:** REQ-012, REQ-018, REQ-023
>
> **Before I post this, I want to confirm a few things:**
>
> 1. Is the employee ID pattern `^[A-Z]{2}\d{6}$` correct? I inferred it from the test data in RESEARCH.md, but I haven't seen it specified explicitly.
> 2. Are `ADJ`, `PRO`, `NEW`, `COR` the complete list of reason codes? The legacy system had these four, but there might be others.
> 3. Should the 9999.99 limit apply to the **input** rate value, or only to the **calculated** result? REQ-018 says "accumulation guard" which suggests it's on the output, but validating input is also sensible.

**PO:**
> Good questions.
> 1. The employee ID pattern is correct — two-letter department code plus six-digit sequence.
> 2. There's a fifth reason code: `TRN` for transfers. Add that.
> 3. Apply the limit to both input AND output. No one should be able to submit a rate above 9999.99 either.

**TL:**
> Agreed on all three. Update the issue and post it.

**Agent:**
> Updated with `TRN` and dual limit. Issue ready to post.
>
> **Issue created: #42 — "Add input validation to rate calculation endpoint"**

---

### Part 2: Delegating to Copilot Agent

**TL:** `@evolution /delegate-to-copilot-agent issue #42`

**Agent:**
> Delegation payload prepared.
>
> **Delegation payload:**
>
> **Target:** GitHub Copilot Agent · **Issue:** #42
>
> **Instructions:**
> 1. **Create** `RateCalculationRequest.java` — record with `@NotBlank`, `@Pattern`, `@PastOrPresent`, `@DecimalMin`/`@DecimalMax` annotations
> 2. **Modify** `RateCalculationController.java` — add `@Valid` to request body parameter
> 3. **Create** `ValidationErrorHandler.java` — `@RestControllerAdvice`, collect ALL field errors (do NOT return on first error), return HTTP 400 list
> 4. **Create** `RateCalculationRequestValidationTest.java` — test each rule, multiple violations, boundary values, all five reason codes
>
> **Constraints:** No new dependencies, no service layer changes, all existing tests must pass.
>
>
> **Ready to delegate. Should I post this to Copilot Agent now?**

**TL:**
> Yes, delegate it.

**Agent:**
> Delegation submitted. Copilot Agent will work on a branch `copilot/issue-42` and open a PR when ready.
>
> I recommend the team reviews the PR within 30 minutes. In my experience, agent-generated PRs benefit from immediate review while the context is fresh.
>
> *(Time passes — approximately 15 minutes)*

---

### Part 3: Reviewing the Agent PR

**TL:** `@evolution /review-agent-pr #43 — Copilot Agent opened PR #43 for issue #42`

**Agent:**
> Starting structured review of PR #43. I'll check against the acceptance criteria in issue #42 and look for common agent-generated code issues.
>
> **Review Structure:**
> 1. Does the PR address all acceptance criteria?
> 2. Are there correctness issues?
> 3. Are there quality issues?
> 4. Are the tests sufficient?
>
> ---
>
> **Acceptance Criteria Check:**
>
> | Criterion | Status |
> |-----------|--------|
> | `employeeId` validation | ✅ `@NotBlank` + `@Pattern("^[A-Z]{2}\\d{6}$")` |
> | `effectiveDate` validation | ✅ `@NotNull` + `@PastOrPresent` |
> | `rateValue` range check | ✅ `@DecimalMin("0")` + `@DecimalMax("9999.99")` |
> | `reasonCode` validation | ✅ Custom `@ValidReasonCode` annotation with `ADJ, PRO, NEW, COR, TRN` |
> | HTTP 400 with all errors | ⚠️ See finding below |
> | Structured error response | ✅ Correct format |
> | Existing tests pass | ✅ CI green |
> | New tests present | ⚠️ See finding below |
>
> ---
>
> **Finding 1 — MUST FIX 🔴**
>
> **File:** `ValidationErrorHandler.java`, line 24
>
> ```java
> @ExceptionHandler(MethodArgumentNotValidException.class)
> public ResponseEntity<Map<String, Object>> handleValidationErrors(
>         MethodArgumentNotValidException ex) {
>     FieldError fieldError = ex.getBindingResult().getFieldErrors().get(0);
>     Map<String, Object> error = Map.of(
>         "field", fieldError.getField(),
>         "message", fieldError.getDefaultMessage()
>     );
>     return ResponseEntity.badRequest().body(Map.of("errors", List.of(error)));
> }
> ```
>
> **Problem:** The handler only returns the **first** field error (`.get(0)`), not all of them. The acceptance criteria require listing ALL validation failures.
>
> **Fix:** Stream all field errors into a list:
>
> ```java
> @ExceptionHandler(MethodArgumentNotValidException.class)
> public ResponseEntity<Map<String, Object>> handleValidationErrors(
>         MethodArgumentNotValidException ex) {
>     List<Map<String, String>> errors = ex.getBindingResult()
>         .getFieldErrors()
>         .stream()
>         .map(fieldError -> Map.of(
>             "field", fieldError.getField(),
>             "message", fieldError.getDefaultMessage()
>         ))
>         .toList();
>     return ResponseEntity.badRequest().body(Map.of("errors", errors));
> }
> ```
>
> ---
>
> **Finding 2 — SHOULD FIX 🟡**
>
> **File:** `RateCalculationRequestValidationTest.java`, line 78
>
> ```java
> @Test
> void shouldRejectMultipleInvalidFields() {
>     RateCalculationRequest request = new RateCalculationRequest(
>         "",           // invalid employeeId
>         LocalDate.now().plusDays(1),  // future date
>         new BigDecimal("10000.00"),   // exceeds max
>         "XXX"         // invalid reason code
>     );
>     Set<ConstraintViolation<RateCalculationRequest>> violations =
>         validator.validate(request);
>     assertThat(violations).isNotEmpty();
> }
> ```
>
> **Problem:** The test uses `.isNotEmpty()` instead of `.hasSize(4)`. With 4 invalid fields, we should assert exactly 4 violations to catch short-circuiting.
>
> **Fix:** `assertThat(violations).hasSize(4);`
>
> ---
>
> **Finding 3 — SHOULD FIX 🟡**
>
> **File:** `RateCalculationRequestValidationTest.java`
>
> **Problem:** The test for invalid reason code checks that a violation exists but doesn't verify the **error message content**. The message should list valid codes (e.g., "must be one of: ADJ, PRO, NEW, COR, TRN") rather than a generic "invalid value."
>
> **Missing assertion:** Add `.contains("ADJ", "PRO", "NEW", "COR", "TRN")` to the reason code test.
>
> ---
>
> **Review Summary:**
>
> | Category | Count | Details |
> |----------|-------|---------|
> | 🔴 Must Fix | 1 | Error handler returns single error instead of collecting all |
> | 🟡 Should Fix | 2 | Incomplete violation count assertion; missing error message assertion |
> | 🟢 Looks Good | 5 | Request record, annotations, controller change, reason code validator, basic tests |
>
> **Recommendation:** Request changes. The must-fix is a functional correctness issue. The should-fixes improve test reliability.
>
> **This is why human-in-the-loop review matters.** The agent correctly implemented 90% of the requirements, but the error handler had a subtle bug that only surfaces with multiple invalid fields.

**TL:**
> Good catch on the error handler. That's exactly the kind of bug that would slip through if we just merged without review.

**PO:**
> The error message assertion is important too. Our frontend team needs predictable error messages to display to users. "Invalid value" is useless.

**TL:**
> Let's request changes. I'll fix the must-fix myself and ask the agent to improve the tests.

**Agent:**
> Sounds good. I'll prepare the review comment with all three findings linked to the specific lines of code.
>
> One note for the team: **this review pattern — delegate, then review critically — is the recommended workflow for agent-generated code.** The agent handles the boilerplate and structure while the human catches the nuanced issues. Neither is sufficient alone.
>
> | Phase | Actor | Strength |
> |-------|-------|----------|
> | Issue writing | Human + Agent | Human provides intent; agent structures and links to specs |
> | Implementation | Agent | Fast boilerplate generation, consistent patterns |
> | Review | Human + Agent | Agent spots structural issues; human spots semantic issues |
> | Fix | Human | Nuanced fixes that require understanding of the "why" |

---

## What the Team Got Out of It

| Output | Detail |
|--------|--------|
| **Structured GitHub issue** | 8 acceptance criteria, 3 REQ-ID traces, technical implementation notes |
| **Agent delegation payload** | Detailed instructions with file-level guidance and constraints |
| **Critical PR review** | 1 must-fix, 2 should-fixes identified in agent-generated code |
| **Human-in-the-loop demonstrated** | Agent generated the code, humans caught the semantic bugs |
| **Confirmation loop** | Agent asked 3 clarifying questions before posting the issue |
| **Team alignment** | PO confirmed business rules; TL confirmed technical approach |

---

## Anti-Patterns Demonstrated

| Anti-Pattern | Where It Almost Happened | How the Agent/Team Prevented It |
|-------------|--------------------------|-------------------------------|
| **Blind merge of agent PR** | Agent-generated code looked correct at first glance | Evolution agent's structured review caught the single-error handler bug |
| **Vague acceptance criteria** | Issue could have said "add validation" without specifics | Agent pulled REQ-IDs from spec and wrote testable criteria |
| **Missing reason codes** | Agent only had 4 codes from legacy analysis | Agent asked for confirmation; PO added the 5th code (TRN) |
| **Assumed input patterns** | Employee ID format was inferred, not confirmed | Agent flagged the inference and asked team to verify |
| **Tests that pass but don't verify** | Multi-field test used `.isNotEmpty()` instead of `.hasSize(4)` | Review caught the weak assertion |
| **Generic error messages** | Agent used default Bean Validation messages | Review flagged the need for actionable, specific messages |

---

## What the Team Should Learn

1. **Write the issue before delegating** — clear acceptance criteria are the single most important factor in agent code quality.

2. **Always confirm business rules before posting** — the agent's 3 questions caught a missing reason code, clarified an ambiguous limit, and confirmed an ID format.

3. **Agent-generated code has a signature failure mode** — agents often handle the first error and return, which passes single-field tests but fails multi-field scenarios.

4. **Review tests as critically as production code** — `.isNotEmpty()` is almost never sufficient for validation tests.

5. **The delegation payload is a contract** — the more specific your instructions, the better the output.

6. **Human-in-the-loop is not optional** — the must-fix bug would have reached production without review.
7. **The three-step chain is the Evolution pattern** — `/write-github-issue` → `/delegate-to-copilot-agent` → `/review-agent-pr`. Skipping any step degrades quality.
