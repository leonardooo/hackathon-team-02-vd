---
title: "Example: Archaeologist Agent in Action"
description: "A realistic session transcript showing how the Archaeologist agent extracts business rules from legacy Natural/Adabas code"
tags: [example, transcript, archaeologist, hackathon]
author: "Paula Silva, AI-Native Software Engineer, Americas Global Black Belt at Microsoft"
date: 2026-04-29
version: "1.0.0"
---

# Example: Archaeologist Agent in Action

## Scenario

**Participants:** Requirements Engineer (RE), Tech Writer (TW)
**Agent command:** `/extract-business-rules`
**Target program:** `XYZPROG1.nat`
**Goal:** Extract and catalogue business rules from a legacy Natural program that processes employee rate calculations.

---

## Setup

1. Open GitHub Copilot Chat in VS Code
2. The team has the legacy codebase loaded in the legacy scenario folder
3. The Archaeologist agent persona is active
4. `XYZPROG1.nat` is open — ~280 lines of Natural code with DEFINE DATA, IF/THEN/ELSE blocks, a READ loop over `EMPL-MASTER`, and a CALLNAT to `XYZAUDIT`

---

## Opening Prompt

**RE:** `@archaeologist /extract-business-rules XYZPROG1.nat`

---

## Transcript

**Agent:**
> Starting business rule extraction for `XYZPROG1.nat`. I'll work through this methodically — first the data structures, then the control flow, then the rules themselves.
>
> **Step 1 — Reading DEFINE DATA**
>
> I can see the following data areas referenced:
>
> ```
> DEFINE DATA
> LOCAL USING EMPL-MASTER-L    /* Employee master view    */
> LOCAL USING RATE-TABLE-L      /* Rate table view         */
> LOCAL USING PERIOD-CALENDAR-L /* Period calendar view    */
> LOCAL
>   01 #CALC-RESULT     (P9.2)
>   01 #EFF-DATE        (D)
>   01 #STATUS-FLAG     (A1)
>   01 #ERROR-COUNT     (I4)
>   01 #OVERRIDE-FLAG   (A1)
> END-DEFINE
> ```
>
> This tells me the program works with three domain entities: employees, rates, and periods. The local variables suggest it performs a calculation (`#CALC-RESULT`), checks dates (`#EFF-DATE`), tracks status (`#STATUS-FLAG`), accumulates errors (`#ERROR-COUNT`), and has some kind of manual override capability (`#OVERRIDE-FLAG`).
>
> Before I move to the IF/THEN/ELSE blocks — do you want me to also trace the CALLNAT calls, or focus strictly on the inline business rules first?

**RE:**
> Focus on the inline rules first. We'll trace the CALLNATs in a separate pass.

**Agent:**
> Understood. Proceeding to control flow analysis.
>
> **Step 2 — Scanning IF/THEN/ELSE blocks**
>
> I found **4 conditional blocks** that encode business logic. Let me walk through each one.
>
> ---
>
> **Block 1 (Lines 47–62): Active Employee Gate**
>
> ```natural
> IF EMPL-MASTER.STATUS = 'A'
>   THEN
>     MOVE 'Y' TO #STATUS-FLAG
>     PERFORM CALC-RATE
>   ELSE
>     IF EMPL-MASTER.STATUS = 'S'
>       THEN
>         MOVE 'Y' TO #STATUS-FLAG
>         PERFORM CALC-RATE
>       ELSE
>         MOVE 'N' TO #STATUS-FLAG
>         ADD 1 TO #ERROR-COUNT
>     END-IF
> END-IF
> ```
>
> **Extracted Rule — BR-001: Employee Eligibility Gate**
> *Only employees with status 'A' (Active) or 'S' (Suspended) are eligible for rate calculation. All other statuses are rejected and increment the error counter.*
>
> **Confidence: HIGH** — The logic is explicit and self-contained. Note: Status 'S' being eligible is interesting — might be intentional or a legacy workaround.
>
> **Can you confirm whether 'S' status employees should be eligible in the modernized system?**

**RE:**
> Good catch. In the current business process, suspended employees keep accruing until their suspension is finalized. So yes, 'S' is intentional. Mark it as confirmed.

**TW:**
> I'll note that in the glossary — "Suspended" means "pending finalization, still accruing."

**Agent:**
> Noted. BR-001 marked as **CONFIRMED**.
>
> ---
>
> **Block 2 (Lines 78–95): Rate Effective Date Validation**
>
> ```natural
> IF RATE-TABLE.EFF-DATE > PERIOD-CALENDAR.END-DATE
>   THEN
>     ESCAPE TOP
>   ELSE
>     IF RATE-TABLE.EFF-DATE < PERIOD-CALENDAR.START-DATE
>       THEN
>         MOVE PERIOD-CALENDAR.START-DATE TO #EFF-DATE
>       ELSE
>         MOVE RATE-TABLE.EFF-DATE TO #EFF-DATE
>     END-IF
> END-IF
> ```
>
> **Extracted Rule — BR-002: Rate Effective Date Clamping**
> *If a rate's effective date falls after the current period's end date, the rate is skipped entirely (ESCAPE TOP exits the current loop iteration). If the effective date falls before the period's start date, the system clamps it to the period start date. Otherwise, the actual effective date is used.*
>
> **Confidence: HIGH** — Clear date-boundary logic. The ESCAPE TOP is a Natural idiom for "continue" in the enclosing READ/FOR loop.
>
> This is a classic proration boundary rule. The clamping behavior means partial-period rates are always calculated from the period start, never before it.

**RE:**
> That matches what the business analysts told us. Confirmed.

**Agent:**
> BR-002 marked as **CONFIRMED**.
>
> ---
>
> **Block 3 (Lines 112–138): Override Processing**
>
> ```natural
> IF #OVERRIDE-FLAG = 'Y'
>   THEN
>     IF EMPL-MASTER.GRADE >= 7
>       THEN
>         COMPUTE #CALC-RESULT = RATE-TABLE.BASE-RATE * 1.15
>       ELSE
>         COMPUTE #CALC-RESULT = RATE-TABLE.BASE-RATE * 1.10
>     END-IF
>   ELSE
>     COMPUTE #CALC-RESULT = RATE-TABLE.BASE-RATE * 1.00
> END-IF
> ```
>
> **Extracted Rule — BR-003: Override Multiplier by Grade**
> *When the override flag is set, employees at grade 7 or above receive a 15% multiplier on the base rate. Employees below grade 7 receive a 10% multiplier. When no override is active, the base rate is used as-is (multiplier of 1.00).*
>
> **Confidence: HIGH** — Explicit arithmetic. The grade threshold of 7 and the multiplier values (1.15, 1.10) are hardcoded.

**TW:**
> What triggers the override flag? Can we infer that from the program name?

**Agent:**
> **I'm going to decline that inference.** The program name `XYZPROG1` doesn't tell us anything about what sets `#OVERRIDE-FLAG`. I can see it's declared as a local variable initialized to spaces, but I don't see where it gets set to 'Y' within this program.
>
> There are two possibilities:
> 1. It's set by a preceding program in the batch chain and passed via the parameter area
> 2. It's set by one of the CALLNAT calls we haven't traced yet
>
> **I'd rather leave this as an open question than guess.** We should trace it in the CALLNAT pass.

**RE:**
> Fair enough. Mark BR-003 as confirmed for the calculation logic, but flag the trigger as unknown.

**Agent:**
> BR-003 marked as **CONFIRMED** (calculation logic). Trigger mechanism flagged as **OPEN QUESTION — OQ-001: What sets #OVERRIDE-FLAG to 'Y'?**
>
> ---
>
> **Block 4 (Lines 155–178): Accumulation Guard**
>
> ```natural
> IF #CALC-RESULT > 9999.99
>   THEN
>     COMPRESS 'LIMIT EXCEEDED FOR' EMPL-MASTER.EMPL-ID
>       INTO #ERROR-MSG
>     PERFORM LOG-ERROR
>     ESCAPE TOP
>   ELSE
>     IF #CALC-RESULT < 0
>       THEN
>         COMPRESS 'NEGATIVE RESULT FOR' EMPL-MASTER.EMPL-ID
>           INTO #ERROR-MSG
>         PERFORM LOG-ERROR
>         ESCAPE TOP
>       ELSE
>         ADD #CALC-RESULT TO EMPL-MASTER.ACCUM-TOTAL
>     END-IF
> END-IF
> ```
>
> **Extracted Rule — BR-004: Accumulation Boundary Guard**
> *Calculated results exceeding 9999.99 or falling below zero are rejected with an error log. Only results within the range [0, 9999.99] are accumulated to the employee's total.*
>
> **Confidence: MEDIUM** — The logic is clear, but I have a question. The upper bound of 9999.99 looks like it might be a **field size constraint** from the Adabas DDM (P7.2 = max 99999.99, but P5.2 = max 999.99 — neither matches 9999.99 exactly). It could be:
> - A genuine business rule ("no single calculation should exceed this amount")
> - A legacy field-size guard that's no longer relevant with modern data types
>
> **I cannot determine which interpretation is correct from the code alone. Can you check with the business team?**

**RE:**
> Hmm. Let me think. The old Adabas field for ACCUM-TOTAL is P9.2 which goes up to 9999999.99, so 9999.99 isn't a field constraint. It must be a business rule.

**TW:**
> But is it still relevant? Maybe the limit should be higher in the new system.

**RE:**
> Good point. Let's mark it as a business rule but flag it for review with the product owner. The limit value might need updating.

**Agent:**
> BR-004 marked as **CONFIRMED** (boundary guard is a business rule, not a field constraint). Flagged as **REVIEW ITEM — RI-001: Verify whether the 9999.99 upper limit is still appropriate for the modernized system.**

**RE:**
> Great. Can we skip ahead to the CALLNATs now? I think we've got enough rules.

**Agent:**
> **I'd prefer not to skip ahead yet.** We've covered the 4 main IF/THEN/ELSE blocks, but I haven't finished scanning the rest of the program. There could be implicit business rules embedded in:
>
> 1. The PERFORM subroutines (CALC-RATE, LOG-ERROR) — these may contain additional conditional logic
> 2. The READ loop structure itself — the access sequence on EMPL-MASTER might encode an ordering rule
> 3. The ESCAPE BOTTOM conditions — there may be early-exit rules I haven't catalogued
>
> Skipping ahead risks missing rules that are only visible in the subroutine bodies. I'd recommend we complete the inline scan first — it should only take another 5-10 minutes.
>
> **Should I continue with the subroutine scan, or do you want to override and move to CALLNATs?**

**RE:**
> You're right, let's be thorough. Continue the scan.

**TW:**
> Actually, I disagree — we're running low on time in this stage. Can we at least scan just CALC-RATE and skip LOG-ERROR? The logging subroutine is probably just formatting.

**Agent:**
> That's a reasonable compromise. I'll adjust my approach:
>
> - **CALC-RATE**: Full scan (likely contains business logic)
> - **LOG-ERROR**: Quick skim for any conditional logic, but I won't deep-dive into formatting
>
> Let me proceed with CALC-RATE...
>
> *(Agent continues scanning the CALC-RATE subroutine)*
>
> The CALC-RATE subroutine contains a FOR loop iterating over RATE-TABLE occurrences but no additional IF/THEN/ELSE blocks beyond what we already extracted. The loop body calls the date-clamping logic (BR-002) and the override logic (BR-003) we already documented.
>
> Quick skim of LOG-ERROR: It's purely formatting — COMPRESS statements building an error message, then a WRITE to the print file. No conditional business logic.
>
> **Inline scan complete.**

---

## What the Team Got Out of It

| Output | Detail |
|--------|--------|
| **4 business rules extracted** | BR-001 (eligibility), BR-002 (date clamping), BR-003 (override), BR-004 (accumulation) |
| **3 confirmed, 1 flagged** | BR-004 upper limit needs product owner sign-off |
| **1 open question** | OQ-001: What triggers the override flag? |
| **1 review item** | RI-001: Is 9999.99 still the right limit? |
| **Data entity map** | EMPL-MASTER, RATE-TABLE, PERIOD-CALENDAR identified as core domain entities |
| **Variable trace** | #CALC-RESULT, #EFF-DATE, #STATUS-FLAG, #ERROR-COUNT, #OVERRIDE-FLAG |

---

## Anti-Patterns Demonstrated

| Anti-Pattern | Where It Almost Happened | How the Agent Prevented It |
|-------------|--------------------------|---------------------------|
| **Inferring from program names** | TW asked if the override trigger could be inferred from `XYZPROG1` | Agent explicitly declined — program names are not reliable documentation |
| **Skipping thorough analysis** | RE wanted to jump to CALLNATs | Agent explained risk of missing rules in subroutines |
| **Guessing field constraints** | BR-004's 9999.99 could be a field-size artifact | Agent flagged both interpretations and asked team |
| **Silent assumptions** | Override flag origin was unknown | Agent created an explicit open question (OQ-001) rather than guessing |

---

## What the Team Should Learn

1. **Let the agent read DEFINE DATA first** — it establishes the vocabulary for everything that follows.

2. **Confirm or reject each rule as extracted** — the agent assigns confidence levels, but only humans can truly confirm.

3. **Don't infer business meaning from technical names** — program names and variable prefixes are often misleading. Trace actual data flow.

4. **Respect the agent's refusal to skip steps** — negotiate scope (like TW did with LOG-ERROR) rather than overriding entirely.

5. **Track open questions explicitly** — every unknown becomes an OQ-nnn entry feeding the Clarification phase.
6. **Field constraints ≠ business rules** — legacy systems encode both in the same conditional. Always ask: "technical artifact or business requirement?"
