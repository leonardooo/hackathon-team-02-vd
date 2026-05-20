---
description: "Maps program-to-program (CALLNAT, INCLUDE) and program-to-data (DDM access) dependencies for a chosen scope."
mode: ask
model: claude-opus-4-7
tools: ['codebase', 'search', 'usages']
---

# /map-dependencies

## Goal

Build a dependency graph for a chosen scope of the legacy codebase by tracing CALLNAT calls, INCLUDE directives, and DDM data access patterns. Output a Mermaid diagram with every edge citing its source.

## When to Invoke

After the team has completed the initial inventory and wants to understand how programs relate to each other and to data.

## Pre-conditions

- `01-arqueologia/inventory.md` exists
- The `legacy/` folder is accessible
- The team has chosen a scope: a single program, a batch flow, or a transaction family

## Inputs the Team Must Provide

- The scope to analyze: a specific file path, a directory, or a set of files
- Whether to trace recursively (follow CALLNAT targets to their own CALLNAT calls) or single-level only

## What I Will Do

- Search for every `CALLNAT`, `PERFORM`, and `INCLUDE` statement within the scope
- For each CALLNAT, identify the target subprogram name and verify it exists in the codebase
- Search for data access statements: `READ`, `FIND`, `GET`, `STORE`, `UPDATE`, `DELETE`, `HISTOGRAM` with their target DDM/file references
- Build a Mermaid graph with two types of edges: program-to-program and program-to-data
- List any broken references (CALLNATs to programs that do not exist in the folder)

## What I Will NOT Do

- Invent connections that are not in the source code — every edge must have a file and line number
- Guess what a CALLNAT target does based on its name — I only map the edge, not the target's behavior
- Assume any program structure — I read what is actually there
- Follow references outside the `legacy/` folder

## Output Format

A Mermaid file at `01-arqueologia/dependency-map.mmd` and a companion Markdown at `01-arqueologia/dependency-map.md`:

```markdown
# Dependency Map — [Scope Description]
## Mermaid Diagram
## Program-to-Program Edges
| Source | Target | Type | File | Line |
## Program-to-Data Edges
| Program | DDM/File | Operation | File | Line |
## Broken References
## Observations
```

## Definition of Done

- [ ] Mermaid file exists and renders a valid graph
- [ ] Every node in the graph corresponds to a real file in the codebase
- [ ] Every edge cites a source file and line number
- [ ] Broken references (targets not found) are explicitly listed
- [ ] Data access edges distinguish between READ, FIND, STORE, UPDATE, DELETE operations

## The Prompt Body

You are the `@archaeologist-agent`. The team wants to map dependencies in a portion of the legacy codebase. You will trace every inter-program and program-to-data relationship.

**Step 1 — Identify scope.**
Confirm the scope with the team. Is it a single program (trace its call tree), a directory (all programs in it), or a named set of files? Record the scope boundary — you will not search outside it unless the team explicitly asks for recursive tracing.

**Step 2 — Search for CALLNAT statements.**
Within the scope, search for every occurrence of `CALLNAT`. For each, extract:
- The calling program (file path)
- The target subprogram name (the string argument to CALLNAT)
- The line number
- The parameters passed (list them, do not interpret them)

Verify that each target subprogram exists as a file in the `legacy/` folder. If it does not exist, add it to the broken references list.

**Step 3 — Search for INCLUDE directives.**
Within the scope, search for every `INCLUDE` statement. For each, extract:
- The including program (file path)
- The copycode name
- The line number

Verify the copycode exists in the codebase.

**Step 4 — Search for PERFORM calls.**
Within the scope, search for `PERFORM` statements. These are internal subroutines — note them as intra-program dependencies. They do not create edges in the inter-program graph, but list them in a separate section for completeness.

**Step 5 — Search for data access statements.**
Within the scope, search for: `READ`, `FIND`, `GET`, `STORE`, `UPDATE`, `DELETE`, `HISTOGRAM`. For each, extract:
- The program performing the access
- The DDM or file number referenced
- The type of operation
- The line number
- Any descriptor used in a FIND or READ LOGICAL (the search key)

**Step 6 — Build the Mermaid graph.**
Create a Mermaid flowchart with:
- Program nodes (rectangles)
- DDM/data nodes (cylinders using the `[(name)]` syntax)
- CALLNAT edges (solid arrows with label "CALLNAT")
- INCLUDE edges (dashed arrows with label "INCLUDE")
- Data access edges (arrows to data nodes with the operation as label)

Use the color palette: node fill `#0f172a`, stroke `#334155`, text `#e2e8f0`.

**Step 7 — Document broken references and observations.**
List any CALLNAT targets or INCLUDEs that reference files not found in the codebase. These are important signals — they may indicate missing files, renamed programs, or external system calls.

Add an observations section noting: total programs in scope, total edges found, most-connected program (highest degree), most-accessed DDM, any isolated programs (no incoming or outgoing edges).

**Step 8 — Write output files.**
Write the Mermaid diagram to `01-arqueologia/dependency-map.mmd` and the companion documentation to `01-arqueologia/dependency-map.md`.

Every edge must cite a source file and line number. If you cannot find a source for an edge, do not include it. No fabricated connections.

## Example Invocation

```
/map-dependencies scope=legacy/programs/ recursive=true
```
