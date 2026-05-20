---
name: Azure Boards
type: plugin
description: "Sync SDD work items with Azure DevOps Boards. Create Epics, Features, User Stories, and Tasks with REQ-ID traceability."
audience: persona-kits (all roles)
---

# Azure Boards Plugin

## What it does
Sync SDD work items with Azure DevOps Boards. Create Epics, Features, User Stories, and Tasks with REQ-ID traceability.

## Use this plugin when
- Syncing from TASKS.md to an ADO project with the workshop work items
- Creating Epic -> Feature -> Story hierarchy aligned to SPECIFICATION.md
- Keeping acceptance criteria in sync between markdown and ADO

## Tools provided

### `create_work_item`
Create a single Epic/Feature/User Story/Task with fields mapped from markdown frontmatter.

### `sync_tasks_file`
Parse TASKS.md and upsert work items; existing items matched by REQ-ID in the tag list.

### `link_hierarchy`
Create parent-child links between Epic/Feature/Story/Task from the markdown outline.

### `push_acceptance_criteria`
Copy acceptance criteria from SPECIFICATION.md REQ-NNN into the matching work item's Acceptance Criteria field.

### `comment_on_change`
Post a comment on the work item summarising a git commit that references its REQ-ID.

## Configuration

### Required configuration
- `organization`: ADO organisation name.
- `project`: ADO project name.
- `pat`: Personal Access Token with `Work Items (Read & Write)` scope (env var `AZURE_DEVOPS_PAT`).
- `area_path`: default area path for created items.

### Optional configuration
- `iteration_path`: default sprint iteration.
- `type_map`: override mapping of markdown heading level to work item type. Default:
 - `# Epic` -> Epic
 - `## Feature` -> Feature
 - `### Story` -> User Story
 - `- [ ] Task` -> Task
- `dry_run`: preview without writing (default `true`).

## Usage pattern

```text
@copilot using azure-boards plugin, sync TASKS.md to <target>.
```

Copilot invokes the plugin, the plugin reads the markdown source of truth, and applies changes to the target system.

## Security

- Always read credentials from environment variables. Never inline a PAT in a prompt or config file committed to the repo.
- Default `dry_run` to `true`. Only set to `false` after previewing output.
- Every operation logs the REQ-ID trace it acted on, so you can correlate changes with specification history.

## Anti-patterns

- Using the plugin as the source of truth. The source of truth lives in markdown under `.specs/`; the plugin is a sync mechanism.
- Running with `dry_run: false` before reviewing the preview.
- Committing PATs to the repo.

## Quality gate

Every sync must preserve REQ-ID traceability. If a target system cannot store the REQ-ID (legacy tracker), the plugin refuses to run.
