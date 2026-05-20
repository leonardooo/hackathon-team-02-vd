---
applyTo: "docs/**/*.md"
---

# Requirements Documentation Conventions

## Format
- EARS notation for formal requirements
- Given/When/Then for acceptance criteria
- Sequential numbering within features
- MUST/SHALL for mandatory, SHOULD for recommended
- **Every requirement carries a `source_legacy:` line** pointing to `legacy/natural-programs/*.NSN`, `legacy/adabas-ddms/*.ddm`, or `[GREENFIELD] + justification`. CI rejects requirements without it.
