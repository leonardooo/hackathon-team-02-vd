# ADR 005: Deployment Strategy

## Status
Accepted

## Context
The SIFAP modernization project requires a robust, secure, and automated deployment strategy for all environments (dev, stage, prod). The team will use GitHub Actions for CI/CD, Docker Compose for local development, and Terraform (Azure provider) for infrastructure provisioning. All secrets will be managed via Azure Key Vault. Deployments must be traceable, repeatable, and follow best practices for security and compliance.

## Decision
- CI/CD pipelines will be managed via GitHub Actions, with separate jobs for backend, frontend, and infrastructure.
- Infrastructure will be provisioned and managed using Terraform, with modules for each Azure service area (network, compute, database, monitoring).
- Docker Compose will be used for local development and integration testing.
- All secrets and sensitive configuration will be stored in Azure Key Vault and never committed to source control.
- Deployments to Azure will use Managed Identity for service-to-service authentication.
- All resources will be tagged with `project`, `environment`, and `owner`.
- CORS will be explicitly configured for each environment (no wildcard in production).

## Consequences
- Enables automated, secure, and auditable deployments.
- Reduces risk of configuration drift and manual errors.
- Ensures compliance with organizational and regulatory requirements.
- Requires team discipline to maintain IaC and secret management practices.

## Alternatives Considered
- Manual deployments (rejected: error-prone, not auditable)
- Using other CI/CD tools (rejected: GitHub Actions is standard for this project)

## References
- [ADR-TEMPLATE.md](ADR-TEMPLATE.md)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
