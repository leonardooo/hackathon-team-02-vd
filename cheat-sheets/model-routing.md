---
title: "Cheat sheet - Claude model routing in Copilot"
description: "One page. When to use Claude Haiku 4.5, Sonnet 4.6, or Opus 4.6 inside GitHub Copilot. Simple rules, common cases."
author: "Paula Silva"
date: "2026-04-18"
version: "1.0.0"
tags: ["cheat-sheet", "copilot", "claude", "model-routing", "workshop"]
---

# Claude model routing - Cheat sheet

## Master rule

> Bigger model = more capable and slower. Use the smallest one that solves your case. Save Opus for decisions, not for batch production.

## The three models

| Model | When to use | Relative cost | Speed |
|---|---|---|---|
| **Haiku 4.5** | Mechanical task, simple transformation, small context | Low | Fast |
| **Sonnet 4.6** | Day-to-day default. Code, tests, refactor, explanation | Medium | Medium |
| **Opus 4.6** | Architectural decision, impact analysis, trade-off discussion | High | Slow |

## Common cases by persona

### Product Owner / Requirements Engineer
- Writing a user story → **Sonnet**.
- Refining EARS that are already written → **Haiku**.
- Discussing whether a requirement should be v1 or v2 → **Opus** (once, decide, move on).

### Architects (Enterprise + Software)
- Drawing C4 with Mermaid → **Sonnet**.
- Choosing between two patterns (hexagonal vs layered) → **Opus**.
- Generating a syntactic variation of an existing diagram → **Haiku**.

### Technical Lead
- Reviewing a medium-sized PR → **Sonnet**.
- Deciding the project-wide standard (transaction style, for example) → **Opus** at the start; **Sonnet** afterward to apply it.
- Answering "does this code compile?" → **Haiku**.

### Developer
- Generating an implementation of a service → **Sonnet**.
- Writing a simple unit test → **Haiku**.
- Debating the structure of a class before writing it → **Opus**.

### DBA
- Translating an Adabas DDM → SQL → **Sonnet** (with Opus for the weirdest case).
- Generating repetitive DDL → **Haiku**.
- Deciding the partitioning strategy for `payment` → **Opus**.

### QA Engineer
- Generating a JUnit 5 skeleton → **Haiku**.
- Writing a non-trivial integration test → **Sonnet**.
- Deciding whether a given scenario is worth Testcontainers vs a mock → **Opus**.

### DevOps Engineer
- Generating a standard GitHub Actions YAML → **Sonnet**.
- Adjusting trivial commands in the workflow → **Haiku**.
- Deciding the Azure topology → **Opus**.

### Tech Writer
- Reviewing the README's style → **Haiku**.
- Drafting an ADR → **Sonnet**.
- Deciding the global documentation structure → **Opus**, once.

## Signs you're on the wrong model

- **You're waiting 30 seconds for a trivial answer** → drop to a smaller model.
- **The answer was shallow on a critical decision** → move up to Opus.
- **The answer is spot on but you wanted a discussion** → move up to Opus.
- **You're stacking prompts to make Opus generate 400 files** → drop to Sonnet or Haiku.

## Paula's tip

Don't treat Opus as "the good one" and Haiku as "the bad one." Opus on a mechanical task is wasteful; Haiku on a decision is risky. The right model is the cheapest one that doesn't let you down.

- Paula
