---
title: "Template: Bounded Contexts"
description: "Skeleton for bounded context definitions via /carve-bounded-contexts"
author: "Paula Silva, AI-Native Software Engineer, Americas Global Black Belt at Microsoft"
date: "2026-04-29"
version: "1.0.0"
status: "approved"
tags: ["template", "bounded-contexts", "architect", "stage-2"]
---
<!-- How to use: Run /carve-bounded-contexts. Clone the context block for each. -->
# Bounded Context Map

## Hypothesis Evaluations
### <!-- placeholder: Name --> — <!-- placeholder: ACCEPTED/REJECTED -->
| Criterion | Rating | Evidence |
|---|---|---|
| Cohesion | <!-- placeholder --> | <!-- placeholder --> |
| Coupling | <!-- placeholder --> | <!-- placeholder --> |
| Change frequency | <!-- placeholder --> | <!-- placeholder --> |

## Final Bounded Contexts
### <!-- placeholder: Context Name -->
- **Responsibility:** <!-- placeholder -->
- **Owned data:** <!-- placeholder -->
- **Public interface:** <!-- placeholder -->
- **Why its own context:** <!-- placeholder -->

## Inter-Context Communication
| From | To | Mechanism | Data |
|---|---|---|---|

```mermaid
flowchart LR
    CTX1["Context 1"] -->|"calls"| CTX2["Context 2"]
    classDef ctx fill:#0f172a,stroke:#334155,color:#e2e8f0
    class CTX1,CTX2 ctx
```

---
**Definition of Done reminder:** Hypotheses evaluated, rejections documented, 2-5 contexts named, Mermaid renders.
