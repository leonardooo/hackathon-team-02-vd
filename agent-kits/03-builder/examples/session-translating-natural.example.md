---
title: "Example: Builder Agent in Action"
description: "A realistic session transcript showing how the Builder agent translates Natural/Adabas code to Java 21 + Spring Boot"
tags: [example, transcript, builder, hackathon]
author: "Paula Silva, AI-Native Software Engineer, Americas Global Black Belt at Microsoft"
date: 2026-04-29
version: "1.0.0"
---

# Example: Builder Agent in Action

## Scenario

**Participants:** Developer (DEV), Tech Lead (TL)
**Agent command:** `/translate-natural-to-java`
**Target program:** `XYZRATES.nat`
**Goal:** Translate a Natural program that manages rate history (with a PE group of 12 monthly occurrences) into idiomatic Java 21 + Spring Boot code.

---

## Setup

1. Open GitHub Copilot Chat in VS Code
2. The Archaeologist and Architect phases are complete
3. The bounded context map identifies this as part of the "Rate Calculation" context
4. The Builder agent persona is active
5. `XYZRATES.nat` is open — it contains a PE (periodic) group with 12 occurrences, each holding a date, rate value, and reason code

---

## Opening Prompt

**DEV:** `@builder /translate-natural-to-java XYZRATES.nat — focus on the PE group and the FOR loop that processes it`

---

## Transcript

**Agent:**
> Starting translation analysis for `XYZRATES.nat`. Let me first understand the data structure before writing any Java code.
>
> **Step 1 — Analyzing the PE Group**
>
> I see this periodic group definition in the Adabas DDM:
>
> ```
> 01 RATE-HISTORY (PE/12)
>   02 RATE-DATE      (D)      /* Effective date     */
>   02 RATE-VALUE     (P7.2)   /* Rate amount        */
>   02 RATE-REASON    (A3)     /* Reason code        */
> ```
>
> This is a classic Adabas PE group — a fixed-size array of 12 occurrences (one per month). Not all slots may be filled — empty ones have zero dates.
>
> For Java, I see **two viable approaches**:
>
> ---
>
> **Option A: JSONB Column (PostgreSQL)**
>
> Store the rate history as a JSON array in a single column:
>
> ```java
> @Entity
> @Table(name = "rate_table")
> public class RateTable {
>     @Id
>     private Long id;
>
>     @JdbcTypeCode(SqlTypes.JSON)
>     @Column(name = "rate_history", columnDefinition = "jsonb")
>     private List<RateHistoryEntry> rateHistory;
> }
>
> public record RateHistoryEntry(
>     LocalDate rateDate,
>     BigDecimal rateValue,
>     String rateReason
> ) {}
> ```
>
> **Pros**: Simple, preserves "embedded collection" semantics, no join overhead.
> **Cons**: No referential integrity on individual entries, harder to index.
>
> ---
>
> **Option B: @OneToMany with Separate Table**
>
> Standard JPA `@OneToMany` with `@OrderColumn` preserving occurrence index. Separate `rate_history_entry` table with its own PK.
>
> **Pros**: Full relational integrity, standard JPA, entries independently queryable.
> **Cons**: Join overhead, N+1 risk, more complex mapping.
>
> **Which approach does the team prefer?**

**DEV:**
> I'm leaning toward JSONB. We always read/write the rate history as a whole.

**TL:**
> Agreed. JSONB maps more naturally to PE group semantics.

**Agent:**
> JSONB it is. Let me translate the FOR loop.
>
> **Step 2 — Translating the FOR Loop**
>
> Here's the Natural FOR loop that processes the PE group:
>
> ```natural
> FOR #I = 1 TO 12
>   IF RATE-HISTORY.RATE-DATE(#I) NE ' '
>     IF RATE-HISTORY.RATE-DATE(#I) <= #EFF-DATE
>       COMPUTE #APPLICABLE-RATE = RATE-HISTORY.RATE-VALUE(#I)
>     END-IF
>   END-IF
> END-FOR
> ```
>
> This loop finds the most recent rate on or before the effective date. It iterates all 12 slots, skips empty ones, keeps overwriting `#APPLICABLE-RATE`. Since PE groups are chronological, the last qualifying entry wins.
>
> Idiomatic Java 21 translation:
>
> ```java
> public BigDecimal findApplicableRate(List<RateHistoryEntry> rateHistory,
>                                      LocalDate effectiveDate) {
>     return rateHistory.stream()
>         .filter(entry -> entry.rateDate() != null)
>         .filter(entry -> !entry.rateDate().isAfter(effectiveDate))
>         .reduce((first, second) -> second)  // take the last qualifying entry
>         .map(RateHistoryEntry::rateValue)
>         .orElseThrow(() -> new NoApplicableRateException(
>             "No rate found on or before " + effectiveDate));
> }
> ```
>
> Key translation decisions:
> - `RATE-DATE NE ' '` → `entry.rateDate() != null` (Natural blank date = Java null)
> - `RATE-DATE <= #EFF-DATE` → `!entry.rateDate().isAfter(effectiveDate)` (inclusive comparison)
> - Last-wins semantics → `reduce((first, second) -> second)` (keeps the last match)
> - No matching rate → explicit exception instead of Natural's implicit zero

**TL:**
> Hold on — I see a potential edge case. What happens if two entries have the **same** date? In the Natural code, the one with the higher occurrence index wins because the FOR loop overwrites. In your stream, `.reduce((first, second) -> second)` also takes the last one, so the behavior matches. But what if the JSONB list isn't guaranteed to be in order?

**Agent:**
> Excellent catch. You're right — **the stream approach depends on the list being ordered chronologically**, which the PE group guarantees by occurrence index but JSONB does not guarantee by default.
>
> I need to add an explicit sort:
>
> ```java
> public BigDecimal findApplicableRate(List<RateHistoryEntry> rateHistory,
>                                      LocalDate effectiveDate) {
>     return rateHistory.stream()
>         .filter(entry -> entry.rateDate() != null)
>         .sorted(Comparator.comparing(RateHistoryEntry::rateDate))
>         .filter(entry -> !entry.rateDate().isAfter(effectiveDate))
>         .reduce((first, second) -> second)
>         .map(RateHistoryEntry::rateValue)
>         .orElseThrow(() -> new NoApplicableRateException(
>             "No rate found on or before " + effectiveDate));
> }
> ```
>
> The `.sorted(Comparator.comparing(RateHistoryEntry::rateDate))` ensures chronological order regardless of JSONB storage order. Good catch — this is exactly the kind of implicit assumption that causes subtle bugs in modernization.

**DEV:**
> Nice. What about the same-date case though? Should we sort by date and then by some tiebreaker?

**Agent:**
> In the legacy system, the tiebreaker is the occurrence index (position in the PE group). Since we're using a `List` which preserves insertion order, we can use a **stable sort** — Java's `List.sort()` and `Stream.sorted()` are both stable, meaning elements with equal keys retain their original order.
>
> So if two entries have the same date, the one that appears later in the list (higher original index) will still be the last match after sorting. This preserves the legacy behavior.
>
> I'll add a comment documenting this assumption:
>
> ```java
> // Stable sort preserves insertion order for same-date entries,
> // matching the legacy PE group occurrence-index tiebreaker behavior.
> .sorted(Comparator.comparing(RateHistoryEntry::rateDate))
> ```

**TL:**
> Good. Continue.

**Agent:**
> **Step 3 — Identifying Orphan Dependencies**
>
> While scanning `XYZRATES.nat`, I found a CALLNAT that doesn't belong to the Rate Calculation bounded context:
>
> ```natural
> CALLNAT 'XYZAUDIT' #EMPL-ID #ACTION-CODE #OLD-RATE #NEW-RATE #TIMESTAMP
> ```
>
> This is a call to an **audit logging program** (`XYZAUDIT`). In the legacy system, it's a direct synchronous call — the rate processing program pauses, writes an audit record, and resumes.
>
> In our bounded context map, audit logging belongs to the **Audit Trail** context, not Rate Calculation. We need to decide how to handle this cross-context communication.
>
> I see three options:
>
> 1. **Direct service call** — `rateService.update()` calls `auditService.log()` synchronously. Simple but creates tight coupling.
> 2. **Domain events** — `rateService.update()` publishes a `RateChangedEvent`, and the Audit Trail context subscribes. Loose coupling, matches the bounded context boundary.
> 3. **Spring ApplicationEvent** — Lightweight in-process events via `ApplicationEventPublisher`. Moderate coupling, no external messaging infrastructure needed.
>
> **I'm not going to silently merge these concepts.** The legacy code treats audit logging as an inline call, but our architecture says it's a separate context. We should be explicit about the boundary crossing.
>
> **Which approach do you want to take?**

**DEV:**
> I like domain events. It keeps the contexts clean.

**TL:**
> Agreed, but let's use Spring's `ApplicationEventPublisher` for now. We don't need Kafka or RabbitMQ at this stage — we can upgrade later if needed.

**Agent:**
> Good pragmatic choice. Here's the translation:
>
> ```java
> // Domain event record (shared kernel package)
> public record RateChangedEvent(
>     String employeeId, String actionCode,
>     BigDecimal oldRate, BigDecimal newRate, Instant timestamp) {}
>
> // In Rate Calculation service — publishes event
> @Service
> public class RateCalculationService {
>     private final ApplicationEventPublisher eventPublisher;
>     // ... constructor injection ...
>     public void updateRate(String employeeId, BigDecimal newRate) {
>         BigDecimal oldRate = findCurrentRate(employeeId);
>         // ... perform update ...
>         eventPublisher.publishEvent(new RateChangedEvent(
>             employeeId, "UPDATE", oldRate, newRate, Instant.now()));
>     }
> }
>
> // In Audit Trail context — listens AFTER_COMMIT only
> @Component
> public class AuditTrailListener {
>     @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
>     public void onRateChanged(RateChangedEvent event) { /* write audit log */ }
> }
> ```
>
> Key: `@TransactionalEventListener(AFTER_COMMIT)` prevents phantom audit records for rolled-back transactions.
>
> **Should I continue with the rest of XYZRATES, or review and adjust first?**

**DEV:**
> Let's review with the full team first. The event approach changes our package structure.

**TL:**
> Agreed. The CALLNAT-to-event mapping is exactly the pattern we should document for other teams.

---

## What the Team Got Out of It

| Output | Detail |
|--------|--------|
| **PE group → JSONB mapping** | Team chose JSONB over @OneToMany based on access pattern analysis |
| **FOR loop → Stream translation** | Idiomatic Java 21 with explicit sort and stable-sort tiebreaker |
| **Edge case caught** | Tech Lead identified the ordering assumption; agent added explicit sort |
| **CALLNAT → Domain event** | Orphan audit dependency identified and translated to event-driven pattern |
| **4 translation decisions documented** | Each with legacy pattern, modern pattern, and rationale |
| **Shared kernel identified** | `RateChangedEvent` placed in shared package between contexts |

---

## Anti-Patterns Demonstrated

| Anti-Pattern | Where It Almost Happened | How the Agent/Team Prevented It |
|-------------|--------------------------|-------------------------------|
| **Silently merging concepts** | CALLNAT to XYZAUDIT could have been inlined as a direct service call | Agent flagged the bounded context violation and presented options |
| **Implicit ordering assumption** | Stream processing assumed chronological order without sort | Tech Lead caught it; agent added explicit sort with documentation |
| **Over-engineering** | Domain events could have led to Kafka discussion | TL chose pragmatic `ApplicationEventPublisher` |
| **Literal translation** | FOR loop could have been a Java for-loop with index | Agent used idiomatic streams, preserving semantics not syntax |

---

## What the Team Should Learn

1. **Present options, don't prescribe** — the agent offered both JSONB and @OneToMany with clear trade-offs. The team's access pattern knowledge ("always read as a whole") drove the right choice.

2. **Edge cases live in the translation gap** — the legacy FOR loop had an implicit ordering guarantee from the PE group structure. The Java stream didn't. The Tech Lead's catch prevented a subtle bug that would only appear with same-date entries.

3. **Orphan dependencies reveal architecture** — when the agent found a CALLNAT to an audit program, it didn't silently inline it. It recognized a bounded context boundary and asked the team to decide how to cross it.

4. **Pragmatism over purity** — Spring's `ApplicationEventPublisher` is simpler than a full event bus but still respects the context boundary. The team can upgrade to Kafka later without changing the domain code.

5. **Stable sort is your friend** — Java's stable sort preserves insertion order for equal keys, matching legacy PE group occurrence-index tiebreaker behavior.

6. **`@TransactionalEventListener(AFTER_COMMIT)` prevents phantom records** — always use AFTER_COMMIT for side effects that should only happen if the transaction succeeds.
