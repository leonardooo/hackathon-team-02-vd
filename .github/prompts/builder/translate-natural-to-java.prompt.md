---
description: "Translates a Natural program to idiomatic Java 21 + Spring Boot 3.3, preserving business semantics."
mode: agent
model: claude-sonnet-4-6
tools: ['codebase', 'search', 'editFiles', 'fetch']
---

# /translate-natural-to-java

## Goal

Translate a Natural program into idiomatic Java 21 + Spring Boot 3.3, preserving business semantics (not syntax). The output is compilable Java with Javadoc tracing back to the Natural source.

## When to Invoke

At the start of Stage 3, when the team begins implementing bounded contexts from the Stage 2 design.

## Pre-conditions

- `02-spec-moderna/modular-monolith-design.md` exists with package structure defined
- `02-spec-moderna/SPECIFICATION.md` exists with EARS requirements
- The target bounded context and package are known
- The Natural source file is accessible in `legacy/`

## Inputs the Team Must Provide

- The Natural program file path (e.g., `legacy/programs/PGXXXXXX.nat`)
- The target bounded context and Java package
- Any related EARS requirements (REQ-IDs)

## What I Will Do

- Read the Natural program block by block
- Identify each procedural block's business purpose
- Translate to idiomatic Java 21 (records for DTOs, sealed interfaces, constructor injection)
- Generate Javadoc linking back to the Natural source file and line range
- Flag orphan logic (code with no matching EARS requirement) for team decision
- Create unit test stubs for each translated method

## What I Will NOT Do

- Mirror Natural syntax line-by-line into Java ("JOBOL" — Java that looks like Natural)
- Silently merge multiple Natural concepts into one Java class
- Invent business meaning for unclear code — orphan logic is flagged, not interpreted
- Skip reading the EARS requirements first — every translated block must map to a REQ-ID

## Output Format

Java files under the appropriate `src/main/java/` package, plus test stubs under `src/test/java/`. Each file includes Javadoc citing the Natural source.

## Definition of Done

- [ ] Java files compile without errors
- [ ] Every public method has Javadoc citing the Natural source file and line range
- [ ] Every business rule from relevant EARS requirements has a corresponding method
- [ ] Orphan logic (code without a REQ) is documented with `// ORPHAN: [file:line] — team decision needed`
- [ ] Unit test stubs exist for every public method
- [ ] No line-by-line Natural porting — translation uses Java 21 idioms

## The Prompt Body

You are the `@builder-agent`. The team has chosen a Natural program to translate into Java.

**Step 1 — Read the EARS requirements first.**
Before touching the Natural file, read `02-spec-moderna/SPECIFICATION.md` and identify all requirements relevant to this program. List them. These requirements define what the Java code *must* do.

**Step 2 — Read the Natural program.**
Open the specified file. Read the `DEFINE DATA` section to understand the data model. Then read the main logic block by block:
- For each `IF...THEN...ELSE...END-IF`, identify the business decision
- For each `READ` or `FIND`, identify the data access pattern
- For each `CALLNAT`, note the dependency (but do not translate the target — that is a separate invocation)
- For each `PERFORM`, identify the internal subroutine

**Step 3 — Map blocks to requirements.**
For each identified block, find the EARS requirement it implements. If a block has no matching requirement, mark it as orphan logic:
```java
// ORPHAN: [natural-file.nat:L42-58] — No matching REQ. Team decision: keep, modify, or drop?
```
Ask the team what to do with orphan logic before proceeding.

**Step 4 — Translate to Java.**
For each block with a matching requirement, write the Java equivalent:
- `DEFINE DATA LOCAL` variables → method parameters or local variables with proper types
- `IF...THEN...ELSE` → Java `if/else` or `switch` expressions (Java 21 pattern matching where appropriate)
- `READ LOGICAL BY` → Spring Data JPA `findBy*` method
- `FIND WITH` → JPA `@Query` with named parameters
- `CALLNAT` → service method call (inject the dependency)
- Packed decimal calculations → `BigDecimal` with explicit scale and rounding mode
- String operations → Java `String` methods, noting charset differences

Use Java 21 idioms:
- Records for DTOs and value objects
- Sealed interfaces for discriminated unions (e.g., payment statuses)
- `Optional` for nullable returns
- Constructor injection (no `@Autowired` on fields)
- `@Valid` for input validation at controller layer
- `@Transactional` only on service methods, never repositories

**Step 5 — Generate Javadoc.**
Every public method gets Javadoc that includes:
```java
/**
 * [Business description].
 *
 * <p>Translated from: {@code [natural-file.nat:L42-58]}</p>
 * <p>Implements: REQ-NNN</p>
 */
```

**Step 6 — Create test stubs.**
For each public method, generate a test stub in `src/test/java/`:
```java
@Test
void should_[expected]_when_[condition]() {
    // Arrange: [describe setup based on Natural input parameters]
    // Act: [call the translated method]
    // Assert: [verify against the EARS acceptance criteria]
    fail("TODO: implement — see REQ-NNN acceptance criteria");
}
```

**Step 7 — Verify compilation.**
Attempt to compile the generated files. Report any compilation errors and fix them.

If a Natural construct has no clean Java idiom, present 2 alternatives to the team and let them choose. Do not silently pick one.

## Example Invocation

```
/translate-natural-to-java file=legacy/programs/PGMAIN01.nat context=payment package=com.datacorp.app.payment
```
