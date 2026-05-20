---
mode: agent
model: claude-sonnet-4-6
description: "Author or refactor a single Terraform module for SIFAP 2.0 Azure infrastructure with tags, variables, outputs, and validation."
---

# /iac-module

## Goal

You are the DevOps engineer producing or updating a **single Terraform module** under `05-terraform-azure/modules/` for SIFAP 2.0. Modules are scoped to one Azure service area (networking, compute, database, monitoring, security). The deliverable passes `terraform fmt`, `terraform validate`, `tflint`, and `checkov` cleanly, and ships with an example.

## Inputs

Ask the user for what is missing.

- The module name and Azure service (for example `postgres` for `azurerm_postgresql_flexible_server`).
- The linked `REQ-ID` from `SPECIFICATION.md` (usually a non-functional or operational requirement).
- The target environments (`dev`, `stage`, `prod`) and any environment-specific overrides.
- The existing baseline: are we creating new or modifying `05-terraform-azure/modules/<name>/`?

## Process

1. **Read the constitution and existing modules.** Open `.specs/<NNN>-<feature>/CONSTITUTION.md` for non-negotiables (managed identity, Key Vault for secrets, no public IPs, etc.) and existing modules for patterns to copy.
2. **Pick a Microsoft-supported provider version.** Use `azurerm ~> 4.x` and pin via `required_providers`. Reference [Azure Verified Modules](https://aka.ms/avm) when applicable.
3. **Write the module skeleton.** Five files minimum:
 - `main.tf` — resources only, no `provider` block.
 - `variables.tf` — every input typed and documented, with `validation` blocks where ranges matter.
 - `outputs.tf` — IDs, names, FQDNs that callers need, never secrets.
 - `versions.tf` — `terraform` and `required_providers`.
 - `README.md` — purpose, inputs, outputs, example usage.
4. **Apply the SIFAP standard tags** to every taggable resource:
 ```hcl
 tags = merge(var.tags, {
 project = "sifap"
 environment = var.environment
 owner = var.owner
 module = "<name>"
 managed_by = "terraform"
 })
 ```
5. **Secrets discipline.** No secrets in variables, no secrets in outputs, no secrets in state files we can avoid. Connection strings come from `azurerm_key_vault_secret` data sources or are returned as URIs callers can resolve at runtime.
6. **Identity discipline.** Use `system-assigned` or `user-assigned` managed identities; never service principal credentials in code.
7. **Network discipline.** No `public_network_access_enabled = true` without a CONSTITUTION exception. Private endpoints by default.
8. **Add an `examples/` folder.** A minimal `examples/basic/main.tf` that consumes the module — used by `tflint` and reviewers.
9. **Validate locally.** Run:
 ```
 terraform fmt -check -recursive
 terraform init -backend=false
 terraform validate
 tflint --recursive
 checkov -d . --soft-fail false
 ```
 All must pass.

## Output

Your final reply must include:

- **Module summary** — name, purpose, REQ-ID.
- **All five files** with full content.
- **Example consumer** — `examples/basic/main.tf`.
- **Validation report** — paste output of `fmt`, `validate`, `tflint`, `checkov`.
- **Cost note** — link to [Azure pricing](https://azure.microsoft.com/pricing/) for the SKU(s) chosen and a one-line monthly estimate per environment.

## Worked example

**Input:** New `postgres` module wrapping `azurerm_postgresql_flexible_server`, dev/stage/prod, REQ-OPS-014 ("the system shall persist payment records in PostgreSQL 16 with point-in-time recovery").

**Expected reply skeleton:**

> Module `postgres` — Azure PostgreSQL Flexible Server for SIFAP. Backed by REQ-OPS-014.
>
> `main.tf`: resource with `version = "16"`, `geo_redundant_backup_enabled = var.environment == "prod"`, private endpoint, customer-managed key, system-assigned identity.
>
> `variables.tf`: `name`, `environment`, `sku_name`, `storage_mb`, `subnet_id`, `key_vault_key_id`, `tags` — each with description, type, and validation (`storage_mb >= 32768`).
>
> `outputs.tf`: `id`, `fqdn`, `principal_id` (for RBAC), no passwords.
>
> Example: a 4GB Burstable SKU on `dev`, single zone.
>
> Validation: fmt clean, validate clean, 0 tflint findings, 0 checkov critical findings, 1 informational (long-running snapshot retention default — accepted).

## Anti-patterns

- Hard-coded subscription IDs, resource group names, or region. Pass them as variables.
- `provider` blocks inside modules. Providers belong to root modules.
- `count = var.create ? 1 : 0` to make resources optional. Use separate modules or feature flags.
- Outputs that leak secrets (`administrator_password`, connection strings).
- `public_network_access_enabled = true` without an explicit CONSTITUTION exception.
- Tagging some resources but not others. Tag everything taggable.
- Skipping `validation` blocks on numeric inputs — produces cryptic Azure errors at apply time.
- Mixing module update with a feature change in the same PR. Module changes ship alone.

## Success criteria

- [ ] `terraform fmt -check`, `terraform validate`, `tflint`, and `checkov` all pass.
- [ ] All taggable resources carry the standard tag set.
- [ ] No secrets in variables, outputs, or default values.
- [ ] Public network access disabled unless a CONSTITUTION exception is referenced.
- [ ] Managed identity used; no SP credentials in code.
- [ ] An `examples/basic/` consumer compiles and validates.
- [ ] README documents inputs, outputs, and an example.
- [ ] Linked `REQ-ID` is named in the module README.
