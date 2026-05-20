---
mode: agent
model: claude-opus-4-6
description: "Lead a blameless root-cause analysis for a SIFAP 2.0 incident, producing a timeline, contributing factors, and prioritized actions."
---

# /incident-rca

## Goal

You facilitate a **blameless root-cause analysis** for a SIFAP 2.0 incident. The deliverable is a single document — `docs/incidents/<YYYYMMDD>-<short-slug>.md` — that captures the timeline, what happened, why it happened, what changes prevent it, and how we will know they worked. The output is read by engineering, SRE, the InfoSec officer, and the platform architect.

## Inputs

Ask the user for what is missing.

- Incident ticket ID and severity (`SEV-1` to `SEV-4`).
- Detection time, mitigation time, resolution time (UTC).
- Affected systems and the linked `REQ-ID`s for SLOs they violated.
- Raw timeline data: PagerDuty, Slack channel, Application Insights traces, deployment timestamps.
- Names of responders (for the timeline only — never blame).

## Process

1. **Restate the impact in customer terms.** "Beneficiaries could not check disbursement status for 47 minutes" is correct. "The Redis cluster lost a quorum" is internal.
2. **Reconstruct the timeline minute by minute.** UTC. Source for each entry: log, metric, chat message, or human recall (mark as `[recall]`).
3. **Distinguish detection from mitigation from resolution.**
 - `T0` — first symptom in production.
 - `Td` — first detection by automation or human.
 - `Tm` — mitigation (impact stops).
 - `Tr` — full resolution (system fully recovered).
4. **Find contributing factors, not "the" cause.** Use the "Five Whys," then categorize each factor as: code, configuration, dependency, process, observability, or organizational.
5. **Identify what *almost* worked.** Defenses that fired but were not enough — alarms that paged late, runbooks that were 80% right, fallbacks that activated but timed out. These are gold for prevention.
6. **Propose actions.** For each contributing factor, write at least one action with:
 - Owner (a name, not a team).
 - Target date.
 - Verification criteria (how we will know it worked).
 - Type — `code`, `config`, `monitoring`, `process`, `documentation`, or `architecture`.
7. **Stay blameless.** No personal names tied to mistakes. "The engineer made a typo" is wrong; "The deployment process did not catch the typo" is right.
8. **Add one risk you did not fix.** Be honest. Note what is too expensive to address now and re-evaluate next quarter.

## Output

The deliverable is a markdown file with this structure:

```markdown
# Incident <YYYYMMDD>-<slug>

- **Severity**: SEV-2
- **Customer impact**: Beneficiaries unable to view disbursement status for 47 minutes.
- **SLO breach**: REQ-OPS-031 (availability of `/payments` endpoint, p95 < 99.9%/30d).
- **Total duration**: 47 minutes (T0=14:03 UTC, Tr=14:50 UTC).

## 1. Summary
Two paragraphs. What happened, why, what we did, what changes.

## 2. Timeline (UTC)
| Time | Source | Event |
|-------|---------------|-------|
| 14:03 | App Insights | Latency on `/payments` rises from 80 ms to 3.2 s p95 |
| 14:09 | PagerDuty | First alert: `pay-be-availability-30m` |
| 14:14 | Slack #ops | On-call ack |
| 14:21 | Deploy log | Roll-back triggered for backend image `sha-9c4e2a` |
| 14:38 | Slack #ops | Latency back to baseline |
| 14:50 | App Insights | Steady state confirmed for 12 min |

## 3. Contributing factors
1. **Code** — REST handler called `Beneficiary.findById()` twice in the new `audit-log` middleware (REQ-BEN-007).
2. **Config** — connection pool size unchanged from baseline; doubled DB load saturated the pool.
3. **Observability** — alert fired 6 minutes after impact (T0+6) — runbook target is 2 minutes.
4. **Process** — canary stage skipped because the change was tagged "non-functional."

## 4. What almost worked
- The `pay-be-availability-30m` alert fired correctly.
- The blue-green deployment infrastructure rolled back in 7 minutes once initiated.
- Connection-pool exhaustion metric existed but was not tied to a page.

## 5. Actions
| # | Action | Owner | Type | Due | Verification |
|---|--------|-------|------|-----|--------------|
| 1 | Add memoization to `Beneficiary.findById` in audit middleware | @alex | code | next sprint | Load test shows 1 query per request |
| 2 | Reclassify "non-functional" tag — every change goes through canary | @ops-lead | process | this week | PR template updated, blocked CI without canary |
| 3 | Page on connection-pool > 80% saturation | @sre-rotation | monitoring | this week | Synthetic test triggers page within 90s |
| 4 | Add runbook section for pool-saturation symptoms | @tech-writer | documentation | next sprint | Linked from on-call escalation card |

## 6. Risks accepted (for now)
- Connection pool autoscaling is on the platform roadmap; not addressed in this incident's actions. Risk re-evaluated 2026-Q3.
```

## Worked example

**Input:** SEV-2 latency incident on `/payments` after a deploy of `audit-log` feature.

**Expected reply skeleton:** the structure above, populated, with five timeline entries, four contributing factors, four actions with named owners, one risk accepted.

## Anti-patterns

- Naming individuals next to mistakes. RCAs are about systems, not people.
- "The cause was X." There are always multiple contributing factors.
- Actions without owners or dates. They will not happen.
- Actions without verification criteria. We cannot tell if they worked.
- Hiding contributing factors that are politically uncomfortable. Trust collapses faster than systems do.
- Treating an RCA as a punishment artifact. It is a learning artifact.
- Skipping the timeline because it is tedious. The timeline is the evidence base.

## Success criteria

- [ ] Customer-impact statement is in plain language.
- [ ] Timeline includes at least detection, mitigation, and resolution timestamps with sources.
- [ ] At least three contributing factors across at least two categories.
- [ ] Each action has owner, type, due date, and verification criteria.
- [ ] At least one "what almost worked" item.
- [ ] At least one risk accepted is named honestly.
- [ ] No individual is blamed by name.
- [ ] SLO/REQ-ID references are included for breached requirements.
