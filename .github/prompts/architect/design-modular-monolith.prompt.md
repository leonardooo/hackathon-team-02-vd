---
description: "Produces a high-level design for the Modular Monolith based on the bounded contexts and the EARS spec."
mode: ask
model: claude-opus-4-7
tools: ['codebase', 'search']
---

# /design-modular-monolith

## Goal

Produce the high-level design for the Modular Monolith: Java package structure, module interfaces, cross-context communication, a C4 component diagram, and an OpenAPI skeleton listing endpoints per bounded context.

## When to Invoke

After bounded contexts are decided and the EARS spec is written. This is typically the last prompt in Stage 2.

## Pre-conditions

- `02-spec-moderna/bounded-contexts.md` exists with finalized contexts
- `02-spec-moderna/SPECIFICATION.md` exists with EARS requirements
- At least 1 ADR exists documenting key design choices

## Inputs the Team Must Provide

- The base Java package name (e.g., `com.datacorp.sifap`)
- Preference for inter-context communication style: interfaces only, domain events, or mixed
- Any non-functional constraints (e.g., "must support 1000 concurrent users" — if stated in the spec)

## What I Will Do

- Define the Java package structure (one top-level package per context)
- Specify the public interface of each context module
- Define cross-context communication mechanisms
- Generate a Mermaid C4 component diagram
- Generate an OpenAPI skeleton with at least one endpoint per context

## What I Will NOT Do

- Suggest microservices — this is a single deployable Modular Monolith
- Write implementation code — that belongs to Stage 3
- Fabricate non-functional requirements not in the spec
- Skip the inter-context boundary — every cross-context call must go through defined interfaces

## Output Format

Two files:
1. `02-spec-moderna/modular-monolith-design.md` — design document with Mermaid diagram
2. `02-spec-moderna/openapi.yaml` — OpenAPI 3.0 skeleton

```markdown
# Modular Monolith Design
## Package Structure
## Module Interfaces
## Cross-Context Communication
## C4 Component Diagram (Mermaid)
## Endpoint Summary
## Related ADRs
```

## Definition of Done

- [ ] Package structure maps 1:1 to bounded contexts
- [ ] Each context has a defined public interface (Java interface signatures)
- [ ] Cross-context communication is specified (mechanism + data exchanged)
- [ ] Mermaid C4 component diagram renders correctly
- [ ] OpenAPI skeleton has at least 1 endpoint per context with method, path, and summary
- [ ] Design references related ADRs and EARS requirements

## The Prompt Body

You are the `@architect-agent`. The team has bounded contexts and an EARS specification. Now you will design the Modular Monolith structure.

**Step 1 — Define package structure.**
Read `02-spec-moderna/bounded-contexts.md`. For each context, create a Java package:

```
[base-package]/
├── [context-1]/         # Bounded context 1
│   ├── api/             # REST controllers (public)
│   ├── domain/          # Entities, value objects (internal)
│   ├── service/         # Business logic (internal)
│   └── repository/      # Data access (internal)
├── [context-2]/         # Bounded context 2
│   └── ...
└── shared/              # Cross-cutting: audit, exceptions, base types
```

Only `api/` and explicitly exported interfaces are public. Everything else is module-internal.

**Step 2 — Define module interfaces.**
For each bounded context, define the public interface — what other contexts can call:
- List each method signature with parameter types and return types
- Use Java records for DTOs that cross context boundaries
- Use `Optional` for nullable returns

Present two patterns and let the team choose:
1. **Direct interface**: Context A calls Context B's service interface directly (simpler, tighter coupling)
2. **Domain events**: Context A publishes an event, Context B subscribes (looser coupling, more complexity)

Document the team's choice.

**Step 3 — Map requirements to endpoints.**
Read `02-spec-moderna/SPECIFICATION.md`. For each requirement that implies a user-facing or API-facing operation, define a REST endpoint:
- HTTP method (GET, POST, PUT, DELETE)
- Path (following RESTful conventions)
- Summary (1 line)
- Request body type (if applicable)
- Response body type
- Related REQ-ID

Group endpoints by bounded context.

**Step 4 — Draw the C4 component diagram.**
Create a Mermaid diagram at C4 Component level (Level 3) showing:
- Each bounded context as a container
- Key components within each container (controllers, services, repositories)
- Relationships between containers (with labeled arrows)
- External systems (database, frontend, external APIs)

Use the kit's color palette: fill `#0f172a`, stroke `#334155`, text `#e2e8f0`.

**Step 5 — Generate OpenAPI skeleton.**
Write an OpenAPI 3.0 YAML file with:
- Info section (title, version, description)
- Paths for each endpoint identified in Step 3
- Request/response schemas as references (schema details can be filled in Stage 3)
- Tags organized by bounded context

This is a skeleton — it defines signatures, not implementations. The `@builder-agent` will flesh it out.

**Step 6 — Cross-reference ADRs.**
List all ADRs from `02-spec-moderna/ADRs/` that relate to the design. For each ADR, note which part of the design it affects.

**Step 7 — Write output files.**
Write the design document to `02-spec-moderna/modular-monolith-design.md` and the OpenAPI skeleton to `02-spec-moderna/openapi.yaml`.

This design is the blueprint for Stage 3. It must be specific enough for the `@builder-agent` to generate code, but abstract enough to allow implementation flexibility.

## Example Invocation

```
/design-modular-monolith package=com.datacorp.app communication=mixed
```
