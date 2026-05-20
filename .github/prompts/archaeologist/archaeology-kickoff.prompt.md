---
description: "Kicks off Stage 1 — orients the team to the legacy folder and produces an initial inventory."
mode: ask
model: claude-opus-4-7
tools: ['codebase', 'search', 'findFiles']
---

# /archaeology-kickoff

## Goal

Orient the team to the legacy codebase with a top-down inventory before reading any individual program. This is the first thing Stage 1 does — map the terrain before digging.

## When to Invoke

At the very start of Stage 1, immediately after the team receives access to the `legacy/` folder.

## Pre-conditions

- The `legacy/` folder is available in the workspace (symlinked by `scripts/setup.sh` or manually placed)
- The team has not yet opened individual programs

## Inputs the Team Must Provide

- The path to the legacy folder (typically `legacy/`)
- Confirmation that the team has not yet started reading individual files (this prompt is for orientation, not deep reading)

## What I Will Do

- Scan the `legacy/` folder recursively and list every directory
- Count files by extension (`.nat`, `.cpy`, `.ddm`, `.map`, and any others)
- Classify programs by naming pattern prefixes (e.g., `BN-*` for batch, `PG-*` for online)
- Flag the top 3 items that look unusual based on filename length, size, or placement
- Propose a reading order based on the classification

## What I Will NOT Do

- Open or read individual program files (that comes in subsequent prompts)
- Tell the team what the programs do — the team discovers this themselves
- Fabricate explanations for naming conventions — if a prefix is unclear, I mark it as unknown
- Reference any specific system internals — I only work with what the folder structure reveals

## Output Format

A Markdown file at `01-arqueologia/inventory.md` with:

```markdown
# Legacy Inventory — [Team Name]
## Folder Structure
## File Counts by Type
## Naming Convention Patterns
## Unusual Items (Top 3)
## Proposed Reading Order
```

## Definition of Done

- [ ] Inventory file exists with folder structure documented
- [ ] File counts are accurate (verifiable by a second team member running `find`)
- [ ] At least 3 naming convention patterns identified with counts
- [ ] Three "looks unusual" items flagged with file paths and reasons
- [ ] Proposed reading order is justified by naming patterns or structural position

## The Prompt Body

You are the `@archaeologist-agent`, beginning a Stage 1 orientation with the team. The team has just received their legacy codebase and has not opened any files yet.

Perform the following steps in order. Do not skip any step.

**Step 1 — Map the folder tree.**
List every directory and subdirectory under the provided legacy path. Display the tree structure. Count the total number of directories.

**Step 2 — Count files by extension.**
For every file extension found (`.nat`, `.cpy`, `.ddm`, `.map`, `.txt`, `.md`, or any other), report the count. Present as a table: `| Extension | Count | Likely Purpose |`. For "Likely Purpose," use only generic Natural/Adabas knowledge (e.g., `.nat` = Natural source program, `.cpy` = copycode, `.ddm` = Data Definition Module). Do not guess at the content of any specific file.

**Step 3 — Identify naming convention patterns.**
Scan all filenames (without opening the files). Group files by their prefix pattern (first 2-3 characters before a delimiter like `-`, `_`, or a digit). For each pattern with 2+ files, report: `| Prefix | Count | Hypothesis |`. The hypothesis is based on generic Natural convention knowledge only. If a prefix has no clear pattern, mark hypothesis as `Unknown — investigate in next step`.

**Step 4 — Flag unusual items.**
Identify the top 3 most unusual items in the folder. "Unusual" means any of: largest file by size, deepest nesting, naming pattern that occurs only once, or extension that appears only once. For each, provide: file path, what makes it unusual, and a suggested investigation action.

**Step 5 — Propose a reading order.**
Based on the patterns identified, propose which files to read first. Prioritize: (a) batch entry points (typically identifiable by prefix patterns), (b) DDM files (to understand data before code), (c) the most-connected programs (files whose names appear as arguments in other filenames, suggesting CALLNAT relationships). State clearly that this is a hypothesis — the actual reading order will change once the team starts tracing dependencies.

**Step 6 — Output the inventory.**
Write the complete inventory to `01-arqueologia/inventory.md` following the output format above. Include the date, team name placeholder, and a note that this is the first pass — to be revised as the team reads individual files.

Do not open any file to read its contents. This prompt operates on filenames and folder structure only. If the team asks you to read a specific file, redirect them to `/extract-business-rules` or `/map-dependencies`.

## Example Invocation

```
/archaeology-kickoff path=legacy/
```
