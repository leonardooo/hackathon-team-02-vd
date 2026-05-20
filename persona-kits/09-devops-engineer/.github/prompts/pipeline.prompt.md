---
mode: agent
model: claude-sonnet-4-6
description: "Author a GitHub Actions CI/CD pipeline for SIFAP 2.0 with build, test, security gates, and environment promotion."
---

# /pipeline

## Goal

You are the DevOps engineer authoring (or refactoring) a **GitHub Actions** workflow for SIFAP 2.0. The pipeline must build, test, scan, and promote artifacts through `develop` → `stage` → `main` (= production) with explicit gates. The deliverable lives in `.github/workflows/` and references reusable workflows in `.github/workflows/_reusable/` where shared.

## Inputs

Ask the user for what is missing.

- Pipeline target — backend Java service, frontend Next.js app, IaC module, or end-to-end orchestration.
- Branching model — `spec/*` → `develop` → `stage` → `main` (default).
- Environments configured in GitHub (`dev`, `stage`, `prod`) with required reviewers.
- Container registry — Azure Container Registry (`acr.azurecr.io`).
- Compliance requirements — SBOM, signed images, attestation (`sigstore`).

## Process

1. **Pick the trigger surface.** `pull_request` for build + test, `push` to protected branches for deploy, `workflow_dispatch` for manual rollback. Avoid `pull_request_target` unless secrets are required from forks (rare in this project).
2. **Use OIDC for Azure auth.** Never store service principal secrets. Use `azure/login@v2` with federated credentials.
3. **Pin actions to a SHA**, not a tag. (Renovate or Dependabot can update.)
4. **Stage the jobs.**
 - `build` — compile and unit test (Java: `./mvnw -B verify`; Node: `pnpm install --frozen-lockfile && pnpm build && pnpm test`).
 - `quality` — lint, type-check, license scan, code-coverage upload.
 - `security` — Trivy on the container image, OWASP Dependency Check, Gitleaks on the diff.
 - `package` — build container, push to ACR with `:sha-<short>` and `:latest` tags, generate SBOM (`syft`), sign with `cosign`.
 - `deploy-dev` — auto on push to `develop`, uses the GitHub `dev` environment.
 - `deploy-stage` — auto on push to `stage`, requires one approval.
 - `deploy-prod` — auto on push to `main`, requires two approvals and a passing change ticket reference.
5. **Cache responsibly.** Maven: `actions/cache@<sha>` keyed on `pom.xml` hash. Node: `pnpm/action-setup@<sha>` with built-in store cache. Buildx layer cache for container builds.
6. **Set timeouts and concurrency.** `timeout-minutes: 30` per job, `concurrency: { group: ${{ github.workflow }}-${{ github.ref }}, cancel-in-progress: true }`.
7. **Gate on branch protection rules.** Required checks: `build`, `quality`, `security`. Stage and prod require deployment review.
8. **Emit traceability.** Tag the deployed image with the merge commit SHA and the related `REQ-ID`s from the PR description; surface them in the GitHub deployment description.

## Output

Your final reply must include:

- **Workflow file path and name** — for example `.github/workflows/backend-payments.yml`.
- **Full YAML** — paste-ready, with comments explaining non-obvious choices.
- **Required GitHub secrets and variables** — listed with their purpose.
- **Branch protection settings** — required checks and reviewer rules.
- **Promotion diagram** — short text or Mermaid sequence from PR to prod.

### Skeleton (Java backend)

```yaml
name: backend-payments
on:
 pull_request:
 paths: ['04-prototipo-sifap-moderno/backend/**']
 push:
 branches: [develop, stage, main]
 paths: ['04-prototipo-sifap-moderno/backend/**']

permissions:
 id-token: write
 contents: read
 packages: write

concurrency:
 group: ${{ github.workflow }}-${{ github.ref }}
 cancel-in-progress: true

jobs:
 build:
 runs-on: ubuntu-latest
 timeout-minutes: 20
 steps:
 - uses: actions/checkout@<sha>
 - uses: actions/setup-java@<sha>
 with: { java-version: '21', distribution: 'temurin', cache: 'maven' }
 - run: ./mvnw -B verify
 # ... coverage, license, test report uploads
 # ... quality, security, package, deploy-* jobs
```

## Worked example

**Input:** New pipeline for the backend `payments` service, deploying to Azure Container Apps via ACR.

**Expected reply skeleton:**

> Workflow `backend-payments.yml` with 7 jobs (`build`, `quality`, `security`, `package`, `deploy-dev`, `deploy-stage`, `deploy-prod`).
>
> OIDC federated to Entra ID app `sp-sifap-cicd`, scoped to subscription `sub-sifap-prod`.
>
> Required secrets: `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `AZURE_CLIENT_ID`, `ACR_NAME`. No passwords.
>
> Branch protection: `build`, `quality`, `security` required on all PRs into `develop`. Stage requires one reviewer. Prod requires two reviewers from the `release-managers` team and a linked change ticket in PR body.
>
> Promotion: PR → develop (auto-deploy `dev`) → cherry-pick to `stage` (1 approver) → cherry-pick to `main` (2 approvers).

## Anti-patterns

- Storing Azure secrets directly in GitHub Secrets when OIDC works. OIDC is the default.
- Pinning to `@v3` instead of a SHA. Tags can be moved.
- A single mega-job that does build + test + deploy. Hard to debug, hard to retry.
- `pull_request_target` without restricting paths. Security risk on forks.
- Caching across branches without invalidation. Stale builds.
- Deploying directly to prod without an approval gate. Sooner or later, a bad PR ships.
- Skipping image signing or SBOM. Required for regulated workloads.
- Hard-coding the registry name in the YAML. Use a repo or environment variable.

## Success criteria

- [ ] OIDC authentication; no Azure secrets stored in GitHub.
- [ ] Each action pinned to a commit SHA with a comment naming the version.
- [ ] `build`, `quality`, and `security` are required checks on PRs.
- [ ] Image is tagged with `sha-<short>` and signed with cosign.
- [ ] Stage and prod deployments require approvals as described.
- [ ] Concurrency group prevents two deploys to the same env at once.
- [ ] `timeout-minutes` set on every job.
- [ ] PR description requirement enforced for prod deploys (linked `REQ-ID`s and change ticket).
