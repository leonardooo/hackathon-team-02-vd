---
title: "Example: Architect Agent in Action"
description: "A realistic session transcript showing how the Architect agent carves bounded contexts from legacy domain analysis"
tags: [example, transcript, architect, hackathon]
author: "Paula Silva, AI-Native Software Engineer, Americas Global Black Belt at Microsoft"
date: 2026-04-29
version: "1.0.0"
---

# Example: Architect Agent in Action

## Scenario

**Participants:** Software Architect (SA), Enterprise Architect (EA)
**Agent command:** `/carve-bounded-contexts`
**Input:** Business rules and entity maps extracted during the Archaeologist phase from XYZPROG1.nat, XYZRATES.nat, and related programs
**Goal:** Identify clean bounded contexts for the modernized system, avoiding both over-splitting and under-splitting.

---

## Setup

1. Open GitHub Copilot Chat in VS Code
2. The Archaeologist phase is complete — the team has a catalogue of 18 business rules, 6 domain entities, and 4 open questions
3. The Architect agent persona is active
4. The extracted artifacts are in `.specs/001-rate-processing/RESEARCH.md`

---

## Opening Prompt

**SA:** `@architect /carve-bounded-contexts based on our extracted rules and entities`

---

## Transcript

**Agent:**
> Starting bounded context analysis. I'll work from the entities and rules you extracted, propose candidate contexts, and evaluate each one against three criteria:
>
> - **Cohesion**: Do the entities and rules within the context belong together semantically?
> - **Coupling**: How many cross-context dependencies would this boundary create?
> - **Change frequency**: Would changes to one context frequently require changes to another?
>
> From your Archaeologist output, I see these domain entities:
> - `EMPL-MASTER` — Employee records (status, grade, department, hire date)
> - `RATE-TABLE` — Rate definitions (base rate, effective date, reason code)
> - `PERIOD-CALENDAR` — Calculation periods (start date, end date, period type)
> - `ACCUM-TOTAL` — Accumulated calculation results per employee
> - `AUDIT-LOG` — Audit trail entries (who, when, what changed)
> - `ERROR-LOG` — Processing errors and rejections
>
> Let me propose **5 candidate bounded contexts** and evaluate each one.

**SA:**
> Go ahead.

**Agent:**
> **Hypothesis 1: "Personnel Management" context**
>
> Would contain: `EMPL-MASTER`, employee status rules (BR-001), grade-based logic (BR-003 grade threshold)
>
> | Criterion | Assessment |
> |-----------|------------|
> | Cohesion | **HIGH** — Employee data and status transitions are tightly related |
> | Coupling | **LOW** — Other contexts need employee ID and status, but not the full record |
> | Change frequency | **INDEPENDENT** — Employee status rules change on HR policy updates, not rate changes |
>
> **Verdict: STRONG CANDIDATE** ✅
>
> This is a natural context. Employee lifecycle (hire, suspend, terminate) is a distinct subdomain with its own change drivers.
>
> ---
>
> **Hypothesis 2: "Rate Calculation" context**
>
> Would contain: `RATE-TABLE`, `ACCUM-TOTAL`, rate application rules (BR-002 date clamping, BR-003 override multiplier, BR-004 accumulation guard)
>
> | Criterion | Assessment |
> |-----------|------------|
> | Cohesion | **HIGH** — All rate computation logic clusters here |
> | Coupling | **MODERATE** — Needs employee grade from Personnel, period dates from Period Management |
> | Change frequency | **INDEPENDENT** — Rate rules change when compensation policy changes |
>
> **Verdict: STRONG CANDIDATE** ✅
>
> The coupling is acceptable because it's read-only — Rate Calculation *reads* employee grade and period dates but never *writes* to those entities.
>
> ---
>
> **Hypothesis 3: "Batch Processing" context**
>
> Would contain: The READ loop structure, ESCAPE TOP/BOTTOM logic, error accumulation, batch job scheduling
>
> | Criterion | Assessment |
> |-----------|------------|
> | Cohesion | **LOW** — This groups things by *how* they execute, not *what* they do |
> | Coupling | **VERY HIGH** — Every business rule runs inside the batch loop |
> | Change frequency | **DEPENDENT** — Changes to any business rule would touch this context |
>
> **Verdict: REJECTED** ❌
>
> **"Batch Processing" is a technical execution mode, not a domain concept.** Batching is an infrastructure concern — it describes *how* work is scheduled and executed, not *what* business problem is being solved. In the modernized system, the same business rules might run in a batch job, a REST API call, or an event handler. The domain logic shouldn't be coupled to the execution mode.
>
> I recommend extracting batch orchestration as an **infrastructure concern** that lives outside the bounded contexts entirely — perhaps as a Spring Batch job that *calls into* the Rate Calculation context.

**EA:**
> Wait — I partially disagree. You're right that batch processing isn't a domain concept, but there IS batch-specific logic in the legacy code. The error accumulation pattern (`#ERROR-COUNT`), the continuation-on-error behavior (ESCAPE TOP instead of ESCAPE BOTTOM), and the summary reporting at the end — those aren't pure infrastructure.

**Agent:**
> That's a valid point. Let me reconsider.
>
> You're distinguishing between two things:
> 1. **Batch scheduling and orchestration** — infrastructure (when to run, how to partition, retry policies)
> 2. **Batch processing semantics** — domain-adjacent (accumulate errors, continue on failure, produce summary)
>
> I'll adjust my analysis. The batch *scheduling* stays as infrastructure, but the batch *processing semantics* — error accumulation, partial-failure handling, summary generation — should be modeled as a **cross-cutting concern** within the Rate Calculation context, not as a separate bounded context.
>
> Specifically:
> - Error accumulation → part of the Rate Calculation context's error handling strategy
> - Continue-on-error → a processing policy that Rate Calculation exposes (configurable per invocation)
> - Summary reporting → a read model / projection that any consumer can request
>
> **Does that separation work for both of you?**

**SA:**
> Yes, that's cleaner. The batch job is just a client of Rate Calculation that happens to call it in a loop.

**EA:**
> Agreed. Moving on.

**Agent:**
> Good. Let me continue with the remaining hypotheses.
>
> ---
>
> **Hypothesis 4: "Period Management" context**
>
> Would contain: `PERIOD-CALENDAR`, period boundary rules, fiscal calendar definitions
>
> | Criterion | Assessment |
> |-----------|------------|
> | Cohesion | **MODERATE** — Period definitions are self-contained, but we only have one entity |
> | Coupling | **LOW** — Rate Calculation reads period dates, but Period Management is independent |
> | Change frequency | **INDEPENDENT** — Calendar changes happen annually, not with rate or personnel changes |
>
> **Verdict: BORDERLINE** ⚠️
>
> A single-entity context is often a smell — it might be too granular. However, period/calendar management is a classic subdomain that tends to grow over time (fiscal years, holiday calendars, pay periods, reporting periods).
>
> **I'd like your input here. Do you see Period Management growing in scope, or is it likely to stay as just a date range lookup?**

**SA:**
> In the legacy system it's just a lookup table. But the business team mentioned they want to support multiple calendar types in the future — fiscal, pay-period, and reporting calendars.

**EA:**
> If it's going to grow, it deserves its own context. Better to have a thin context now that grows naturally than to extract it later from Rate Calculation.

**Agent:**
> Agreed. I'll promote Period Management to a **full bounded context** based on the anticipated growth. Good call.
>
> **Verdict updated: ACCEPTED** ✅ (based on team's domain knowledge of future requirements)
>
> ---
>
> **Hypothesis 5: "Reporting" context**
>
> Would contain: `ERROR-LOG`, summary generation, error reports, audit queries
>
> | Criterion | Assessment |
> |-----------|------------|
> | Cohesion | **LOW** — "Reporting" is a cross-cutting concern, not a domain |
> | Coupling | **VERY HIGH** — Every other context produces data that flows into reports |
> | Change frequency | **DEPENDENT** — Report formats change whenever the source domains change |
>
> **Verdict: REJECTED** ❌
>
> **"Reporting" has the same problem as "Batch Processing" — it's a technical capability, not a business domain.** Reports are *views* over domain data, not a domain themselves. In a well-structured system, each bounded context exposes its own read models, and a reporting infrastructure aggregates them.
>
> However, I notice that `AUDIT-LOG` is different from general reporting. Audit trails have regulatory requirements, retention policies, and immutability constraints that make them a genuine subdomain.
>
> I'd like to propose replacing "Reporting" with...
>
> ---
>
> **Revised Hypothesis 5: "Audit Trail" context**
>
> Would contain: `AUDIT-LOG`, immutable event records, regulatory retention rules, audit query API
>
> | Criterion | Assessment |
> |-----------|------------|
> | Cohesion | **HIGH** — Audit events, retention, and compliance are tightly related |
> | Coupling | **LOW** — Other contexts *publish* events to Audit Trail but don't depend on it |
> | Change frequency | **INDEPENDENT** — Audit requirements change on regulatory cycles, not business cycles |
>
> **Verdict: STRONG CANDIDATE** ✅
>
> The Audit Trail context receives events from other contexts (via domain events or an event bus) but doesn't create bidirectional coupling. It's an autonomous consumer.

**SA:**
> That's much better than lumping it with general reporting. The auditors do have specific requirements about immutability and retention.

**EA:**
> Agreed. And it maps well to a separate data store — audit logs could go to an append-only store while business data stays in PostgreSQL.

**Agent:**
> Good. Let me now present the final bounded context map.
>
> ---
>
> ## Final Bounded Context Map
>
> Based on our evaluation, here are the **4 accepted bounded contexts**:
>
> ```
> ┌─────────────────────┐     ┌─────────────────────┐
> │ Personnel Management│     │  Rate Calculation    │
> │                     │────▶│                      │
> │ • EMPL-MASTER       │ ID  │ • RATE-TABLE         │
> │ • Status lifecycle  │ +   │ • ACCUM-TOTAL        │
> │ • Grade management  │grade│ • Date clamping      │
> │ • BR-001            │     │ • Override multiplier │
> │                     │     │ • Accumulation guard  │
> │                     │     │ • BR-002,003,004      │
> └─────────────────────┘     └──────────┬────────────┘
>                                        │ events
> ┌─────────────────────┐     ┌──────────▼────────────┐
> │ Period Management   │     │    Audit Trail        │
> │                     │────▶│                        │
> │ • PERIOD-CALENDAR   │dates│ • AUDIT-LOG           │
> │ • Calendar types    │     │ • Immutable records   │
> │ • Fiscal periods    │     │ • Retention policies  │
> │ • Pay periods       │     │ • Regulatory queries  │
> └─────────────────────┘     └────────────────────────┘
> ```
>
> **Cross-context communication:**
> - Personnel → Rate Calculation: Employee ID + grade (synchronous query or cached)
> - Period → Rate Calculation: Period dates (synchronous query or cached)
> - Rate Calculation → Audit Trail: Domain events (asynchronous, fire-and-forget)
> - All contexts → Audit Trail: Audit events (asynchronous)
>
> **Rejected candidates:**
> - "Batch Processing" — technical execution mode, not a domain (infra concern)
> - "Reporting" — cross-cutting view layer, not a domain (read models per context)
>
> **Important: I'm presenting this as a recommendation, not a decision.** The final context map should be reviewed by the full team, especially the product owner who understands the business domain boundaries better than the code does.
>
> **Do you want me to proceed with generating the context map artifact for DESIGN.md, or do you want to adjust the boundaries first?**

**SA:**
> Let's review with the full team first. Can you export this as a summary we can present?

**Agent:**
> I'll generate a concise summary with the context map diagram, the evaluation criteria for each hypothesis, and the open items. You can use this in your next team sync.
>
> One last note — I intentionally did not auto-decide on any boundary. **Bounded context boundaries are strategic decisions that affect team structure, API design, and deployment topology.** They should always be a deliberate team choice, not an AI default.

---

## What the Team Got Out of It

| Output | Detail |
|--------|--------|
| **5 hypotheses evaluated** | Each assessed on cohesion, coupling, and change frequency |
| **4 bounded contexts accepted** | Personnel Management, Rate Calculation, Period Management, Audit Trail |
| **2 hypotheses rejected** | "Batch Processing" (technical mode), "Reporting" (cross-cutting view) |
| **1 hypothesis adjusted** | "Reporting" → "Audit Trail" (genuine subdomain with regulatory drivers) |
| **Cross-context communication map** | Sync queries for reference data, async events for audit |
| **Agent-team negotiation** | Batch processing semantics separated from batch infrastructure |
| **Period Management promoted** | Based on team's knowledge of future calendar requirements |

---

## Anti-Patterns Demonstrated

| Anti-Pattern | Where It Almost Happened | How the Agent Prevented It |
|-------------|--------------------------|---------------------------|
| **Technical contexts** | "Batch Processing" proposed as a bounded context | Agent rejected it — execution mode ≠ domain concept |
| **Cross-cutting as context** | "Reporting" proposed as a bounded context | Agent rejected it — views over data ≠ domain |
| **Auto-deciding boundaries** | Agent could have picked 4 contexts and moved on | Agent stated it was presenting recommendations, not decisions |
| **Ignoring team knowledge** | Period Management was borderline on paper | Agent asked team; promoted based on domain insight |
| **Binary thinking** | EA's batch processing pushback could have been dismissed | Agent adjusted — separated batch scheduling (infra) from batch semantics (domain-adjacent) |

---

## What the Team Should Learn

1. **Bounded contexts are domain boundaries, not technical ones** — if your context name describes *how* something works rather than *what* business problem it solves, it's probably not a real context.

2. **Evaluate every hypothesis on the same criteria** — cohesion, coupling, and change frequency give you a consistent framework.

3. **Team knowledge outranks code analysis** — the agent identified Period Management as borderline, but team's future requirements knowledge tipped the decision.

4. **The agent should refuse to auto-decide strategic boundaries** — context boundaries affect team topology, deployment, and API contracts. They need human judgment.

5. **Disagreement is productive** — when the EA pushed back on Batch Processing, the result was a better model. Don't treat the agent's first answer as final.

6. **Rejected hypotheses are valuable** — knowing WHY you didn't create "Reporting" is as important as knowing why you created "Audit Trail."
7. **Cross-context communication patterns matter early** — sync vs async decisions shape the entire integration architecture.
