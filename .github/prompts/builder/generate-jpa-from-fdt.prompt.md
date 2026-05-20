---
description: "Generates JPA entity classes from Adabas FDT definitions, with JSONB for MU/PE fields."
mode: agent
model: claude-sonnet-4-6
tools: ['codebase', 'search', 'editFiles']
---

# /generate-jpa-from-fdt

## Goal

Parse an Adabas DDM file and generate a JPA entity class with proper type mappings, JSONB for MU/PE fields, and a corresponding Flyway migration script.

## When to Invoke

Early in Stage 3, when the team is setting up the data layer for a bounded context.

## Pre-conditions

- `02-spec-moderna/bounded-contexts.md` exists (to know which context owns this DDM)
- The DDM file is accessible in `legacy/ddms/`
- The team has decided on the target package from the modular monolith design

## Inputs the Team Must Provide

- The DDM file path (e.g., `legacy/ddms/DDMXXXXX.ddm`)
- The target bounded context and Java package
- Date format used in the legacy system (e.g., `YYYYMMDD` packed, or `YYYY-MM-DD` alpha)

## What I Will Do

- Parse the FDT structure from the DDM file
- Map each field to the appropriate Java/JPA type
- Handle MU fields as JSONB-mapped collections or @ElementCollection
- Handle PE groups as @OneToMany embedded entities
- Generate the Flyway migration creating the PostgreSQL table
- Flag cryptic field names with FIXME markers

## What I Will NOT Do

- Invent business meaning for cryptic field names — I add FIXME markers
- Assume date formats — the team must confirm
- Create stored procedures — all business logic stays in Java
- Skip MU/PE fields — these are the hardest part and must be handled explicitly

## Output Format

Two files:
1. JPA entity at `src/main/java/[package]/domain/[EntityName].java`
2. Flyway migration at `db/migration/V[NNN]__create_[table_name].sql`

## Definition of Done

- [ ] Entity compiles without errors
- [ ] Every FDT field has a corresponding Java field with correct type
- [ ] MU fields use JSONB (`@JdbcTypeCode(SqlTypes.JSON)`) or `@ElementCollection`
- [ ] PE groups use `@OneToMany` with a separate entity class
- [ ] Flyway migration is valid PostgreSQL 16 DDL
- [ ] Cryptic field names have `// FIXME: confirm semantics` comments
- [ ] Cryptic fields are added to the mystery catalog if not already there

## The Prompt Body

You are the `@builder-agent`. The team needs to create a JPA entity from an Adabas DDM.

**Step 1 — Parse the FDT.**
Open the specified DDM file. Extract every field definition:
- Level number (01 = top-level, 02+ = children)
- Short name (2-character Adabas name)
- Long name (if present in comments or documentation)
- Format: A (alpha), N (numeric), P (packed), B (binary), D (date), T (time)
- Length
- Descriptor type: DE (searchable), MU (multi-value), PE (periodic group), SU (super-descriptor)

Present the parsed FDT as a table for the team to review before generating code.

**Step 2 — Map types.**
Apply these mapping rules:

| Adabas | Java | JPA | Notes |
|--------|------|-----|-------|
| A(n) | `String` | `@Column(length = n)` | |
| N(n) no decimal | `Long` or `Integer` | `@Column` | Use `Long` for IDs |
| N(n.m) | `BigDecimal` | `@Column(precision=n, scale=m)` | Always for money |
| P(n.m) | `BigDecimal` | `@Column(precision=n, scale=m)` | Packed decimal |
| D | `LocalDate` | `@Column` | Ask team for source format |
| T | `LocalDateTime` | `@Column` | |
| B(n) | `byte[]` | `@Lob` | Rare |
| MU field | `List<T>` | JSONB or `@ElementCollection` | Team chooses |
| PE group | `List<EmbeddedEntity>` | `@OneToMany` | Separate entity class |

For MU fields, present both options:
1. **JSONB**: Simpler, less queryable → `@JdbcTypeCode(SqlTypes.JSON) private List<String> fieldName;`
2. **@ElementCollection**: More queryable, separate table → `@ElementCollection @CollectionTable(...)`

Let the team choose per field.

**Step 3 — Handle PE groups.**
For each PE group, create a separate `@Entity` class with:
- Its own table
- A `@ManyToOne` back-reference to the parent entity
- All fields within the PE group mapped as in Step 2
- An index field tracking the occurrence number

**Step 4 — Handle super-descriptors.**
For each super-descriptor, add a composite `@Index` annotation on the parent entity:
```java
@Table(indexes = @Index(columnList = "field_a, field_b"))
```

**Step 5 — Flag cryptic names.**
For any field where the 2-character Adabas name has no clear English equivalent:
```java
/** FIXME: confirm semantics with team for Adabas field XX */
@Column(name = "xx_value", length = 20)
private String xxValue;
```

If the field is not already in `01-arqueologia/mysteries-found.md`, note it for the team to add.

**Step 6 — Generate Flyway migration.**
Write a PostgreSQL 16 DDL script:
- Table name derived from the entity name (snake_case)
- Column types matching JPA mappings
- JSONB columns for MU fields (if JSONB was chosen)
- Separate table for PE groups with foreign key
- Primary key, indexes for descriptors
- `CHECK` constraints where obvious from the FDT (e.g., NOT NULL for required fields)

Number the migration: `V[NNN]__create_[table_name].sql`.

**Step 7 — Verify compilation.**
Ensure the entity class compiles. Report any issues.

## Example Invocation

```
/generate-jpa-from-fdt ddm=legacy/ddms/DDM001.ddm context=payment package=com.datacorp.app.payment dateformat=YYYYMMDD
```
