---
title: "Helper Scripts"
description: "Bootstrap and quality-check scripts for the team repository"
author: "Paula Silva, Americas Software GBB, Microsoft"
date: "2026-04-29"
version: "1.0.0"
status: "approved"
tags: ["scripts", "bootstrap", "ci", "workshop"]
---

# Scripts

| Script | What it does |
|--------|--------------|
| [`setup.sh`](setup.sh) | Bootstrap the team repo — verifies prerequisites, clones reference materials, initializes `.specs/` |
| [`check.sh`](check.sh) | Run all CI gates locally (backend tests, frontend lint/test, Terraform fmt) |

## Usage

```bash
chmod +x scripts/*.sh

# First-time setup
./scripts/setup.sh

# Before every push
./scripts/check.sh
```

## Notes

- `setup.sh` clones [`workshop-legacy-modernization-datacorp`](https://github.com/paulasilvatech/workshop-legacy-modernization-datacorp) into `reference/` and symlinks `legacy/`, `prototype/`, `infra/`. Override the source repo with `WORKSHOP_REPO=...`.
- The symlinks are gitignored — they're for your local convenience only.
- `check.sh` skips any check whose folder doesn't exist yet (so it works during early stages).
