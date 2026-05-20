---
mode: agent
model: claude-opus-4-6
description: "Author an Architecture Decision Record (ADR) capturing context, options, decision, and consequences for a SIFAP 2.0 architectural choice."
---

# /create-adr

## Goal

You are writing one **Architecture Decision Record** for SIFAP 2.0 in the format used in `.specs/<NNN>-<feature>/ADRs/`. An ADR is the durable answer to "why did we do it this way?" It captures the context at decision time, the options considered, the chosen path, and the consequences. ADRs are immutable once accepted — corrections happen via a *new* ADR that supersedes.

## Inputs

Ask the user for what is missing.

- The decision topic in plain English (for example "How will SIFAP integrate with the legacy Adabas wrapper?").
- The feature folder where the ADR lives (`.specs/<NNN>-<feature>/ADRs/`).
- The next ADR number — look at existing files to avoid clashes.
- The linked `REQ-ID`s the decision affects.
- Stakeholders who must be cited (architect, security, DevOps, product).
- A draft of the chosen direction, even if vague.

## Process

1. **Pick a sharp title.** Use a verb-led, decision-shaped title: "Integrate Adabas legacy via REST adapter" — not "Integration approach" or "Adabas thoughts."
2. **Set status correctly.**
 - `Proposed` — decision drafted, awaiting review.
 - `Accepted` — approved by the architecture forum, dated.
 - `Superseded by NNNN` — replaced by another ADR.
 - `Rejected` — considered and turned down (still recorded — saves future relitigation).
3. **Write the context honestly.** What forces are at play right now? Constraints (Java 21, Postgres 16, Azure-only, regulatory)? Existing decisions (prior ADRs)? Knowns and unknowns?
4. **List at least three options.** Including the status-quo and a "do nothing" if applicable. Each option needs:
 - One-line description.
 - Pros (3 bullets max).
 - Cons (3 bullets max).
 - Cost / risk profile in plain language.
5. **Name the decision and the rationale.** One paragraph each. Reference the option chosen by name.
6. **Capture consequences — positive *and* negative.** What becomes possible? What becomes harder? What new risks appear? What other decisions are now forced or constrained?
7. **Link forward and back.** Cite the REQ-IDs, prior ADRs in the same feature, and CONSTITUTION.md non-negotiables this decision relies on.
8. **Record the date and signatories.** Architecture forum date. Names of approvers (technical lead, software architect, persona owners affected).

## Output

The deliverable is a single file at `.specs/<NNN>-<feature>/ADRs/<NNNN>-<title-slug>.md`:

```markdown
# ADR <NNNN> — Integrate Adabas legacy via REST adapter

- **Status**: Accepted
- **Date**: 2026-04-29
- **Approvers**: @morgan (technical lead), @paula (software architect), @alex (engineering)
- **Linked REQs**: REQ-INT-001, REQ-INT-002, REQ-INT-005
- **Linked ADRs**: ADR 0003 (chose Java 21), ADR 0006 (Postgres 16 as system of record)
- **Supersedes**: —

## 1. Context
SIFAP must continue to read from the legacy Adabas database during the modernization window (estimated 18 months). Legacy code (Natural programs in `02-cenario-sifap-legado/natural-programs/`) is read-only. Direct ODBC bridges are deprecated by the vendor and prohibited by InfoSec for new integrations. The team has Java + REST expertise; nobody on the team writes Natural fluently.

## 2. Options considered

### Option A — Direct ODBC connection from Spring Boot
- Pros: Lowest latency; familiar JDBC mental model.
- Cons: Vendor-deprecated; not approved by InfoSec; couples application directly to legacy schema.
- Cost/risk: Low cost now, high cost on InfoSec exception, very high risk on legacy schema change.

### Option B — REST adapter sidecar (chosen)
- Pros: Hides legacy details; can be replaced or sunset; testable; InfoSec-approved pattern.
- Cons: Extra hop adds ~30 ms p95; requires a separate deployable; new SLO surface.
- Cost/risk: Medium cost (one new service); medium risk; replaceable.

### Option C — Replicate Adabas to Postgres via CDC
- Pros: Unified Postgres surface for the new system; no runtime call to legacy.
- Cons: 18-month modernization is too short to justify CDC tooling; legacy still drives writes.
- Cost/risk: High cost; high risk if CDC tooling does not match Adabas semantics.

## 3. Decision
We will build a thin REST adapter sidecar that exposes a JSON API over the legacy Adabas data. The adapter is owned by the integration squad, deployed to Azure Container Apps, and authenticated via managed identity.

## 4. Rationale
Option B isolates the legacy from new code, satisfies InfoSec, and gives us a clean retirement seam when the legacy system is finally decommissioned. The latency cost is acceptable for the affected REQ-IDs (none of them are in the < 50 ms p95 budget).

## 5. Consequences

### Positive
- New code never imports legacy types.
- The retirement plan becomes "delete the adapter" — clean.
- Adapter can be load-tested and rate-limited independently.

### Negative
- One more deployable to operate (REQ-OPS-014 implications).
- Schema drift between adapter contract and Adabas DDMs must be detected; new contract test suite required.
- Latency budget for affected endpoints rises by ~30 ms p95.

### Risks
- If the adapter becomes a bottleneck under peak load, we must scale it horizontally — capacity-plan now.
- If InfoSec policy changes to prohibit sidecars, we will need a new ADR.

## 6. Validation
- Latency budget verified by k6 scenario `legacy-read-burst`.
- Contract test suite `adapter-pact` runs on every PR.
- A retrospective is scheduled at month 3 to confirm assumptions hold.
```

## Worked example

**Input:** Decision on observability stack — Application Insights vs Grafana Cloud vs in-house Prometheus.

**Expected reply:** an ADR following the template, with three options, a chosen path, a calibrated cost/risk profile, and consequences naming SLO instrumentation, alert routing, and operator training.

## Anti-patterns

- Pre-cooked ADRs that only present the chosen option. Always list rejected options — that is half the value.
- "We chose X because it is best." Not a rationale; describe the forces.
- Missing consequences. ADRs without consequences fool future you.
- Rewriting an accepted ADR. Create a new one with status `Supersedes NNNN`.
- ADRs without dates. Worthless for archaeology.
- Linking nothing. ADRs that do not cite REQ-IDs or prior ADRs are isolated and untrustworthy.
- "Do nothing" never considered. Sometimes the right answer is "later."

## Success criteria

- [ ] Filename follows `<NNNN>-<title-slug>.md`, number does not collide.
- [ ] Status is one of `Proposed`, `Accepted`, `Superseded by NNNN`, `Rejected`.
- [ ] Date and approvers are recorded.
- [ ] At least three options, each with pros, cons, and cost/risk.
- [ ] Decision names the chosen option explicitly.
- [ ] Consequences include positive, negative, and risks.
- [ ] Linked `REQ-ID`s and prior ADRs cited.
- [ ] Validation criteria included so we can check this decision later.
