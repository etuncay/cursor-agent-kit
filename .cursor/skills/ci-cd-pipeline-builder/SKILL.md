---
name: "ci-cd-pipeline-builder"
description: "Generate pragmatic CI/CD pipelines from detected project stack signals — fast baseline generation, repeatable checks, environment-aware deployment stages. Use when setting up CI for a new project, refactoring existing pipelines, or standardizing deployment workflows across multiple repos."
---

# CI/CD Pipeline Builder

**Tier:** POWERFUL  
**Category:** Engineering  
**Domain:** DevOps / Automation

## Overview

Use this skill to generate pragmatic CI/CD pipelines from detected project stack signals, not guesswork. It focuses on fast baseline generation, repeatable checks, and environment-aware deployment stages.

## Core Capabilities

- Detect language/runtime/tooling from repository files
- Recommend CI stages (`lint`, `test`, `build`, `deploy`)
- Generate GitHub Actions or GitLab CI starter pipelines
- Include caching and matrix strategy based on detected stack
- Emit machine-readable detection output for automation
- Keep pipeline logic aligned with project lockfiles and build commands

## When to Use

- Bootstrapping CI for a new repository
- Replacing brittle copied pipeline files
- Migrating between GitHub Actions and GitLab CI
- Auditing whether pipeline steps match actual stack
- Creating a reproducible baseline before custom hardening

## Key Workflows

### 1. Detect Stack

Read the repo directly with your own tools (Glob/Grep/Read) — no bundled script required:

- Lockfiles → package manager: `package-lock.json` / `pnpm-lock.yaml` / `yarn.lock`, `poetry.lock` / `requirements.txt`, `go.sum`, `Cargo.lock`, `*.csproj`.
- Manifests → runtime family + version (`engines`, `python_requires`, Go/.NET version).
- `scripts` / build targets → the **real** `lint` / `test` / `build` commands (never invent them).

### 2. Generate Pipeline From Detection

Write the workflow YAML directly from what you detected:

- GitHub Actions → `.github/workflows/ci.yml`
- GitLab CI → `.gitlab-ci.yml`

Mirror the detected package manager's cache action and the real project commands. Keep deploy jobs gated behind protected branches/environments.

### 3. Validate Before Merge

1. Confirm commands exist in project (`test`, `lint`, `build`).
2. Run generated pipeline locally where possible.
3. Ensure required secrets/env vars are documented.
4. Keep deploy jobs gated by protected branches/environments.

### 4. Add Deployment Stages Safely

- Start with CI-only (`lint/test/build`).
- Add staging deploy with explicit environment context.
- Add production deploy with manual gate/approval.
- Keep rollout/rollback commands explicit and auditable.

## Real tooling (optional)

Prefer the agent's own file inspection. When the user wants an external validator:

- `actionlint` — lint GitHub Actions workflow YAML.
- `act` — run GitHub Actions locally for a smoke check.
- GitLab CI Lint (project CI Lint page / API) — validate `.gitlab-ci.yml`.

## Common Pitfalls

1. Copying a Node pipeline into Python/Go repos
2. Enabling deploy jobs before stable tests
3. Forgetting dependency cache keys
4. Running expensive matrix builds for every trivial branch
5. Missing branch protections around prod deploy jobs
6. Hardcoding secrets in YAML instead of CI secret stores

## Best Practices

1. Detect stack first, then generate pipeline.
2. Keep generated baseline under version control.
3. Add one optimization at a time (cache, matrix, split jobs).
4. Require green CI before deployment jobs.
5. Use protected environments for production credentials.
6. Regenerate pipeline when stack changes significantly.

## References

- GitHub Actions docs: https://docs.github.com/actions
- GitLab CI/CD docs: https://docs.gitlab.com/ee/ci/

## Detection Heuristics

The stack detector prioritizes deterministic file signals over heuristics:

- Lockfiles determine package manager preference
- Language manifests determine runtime families
- Script commands (if present) drive lint/test/build commands
- Missing scripts trigger conservative placeholder commands

## Generation Strategy

Start with a minimal, reliable pipeline:

1. Checkout and setup runtime
2. Install dependencies with cache strategy
3. Run lint, test, build in separate steps
4. Publish artifacts only after passing checks

Then layer advanced behavior (matrix builds, security scans, deploy gates).

## Platform Decision Notes

- GitHub Actions for tight GitHub ecosystem integration
- GitLab CI for integrated SCM + CI in self-hosted environments
- Keep one canonical pipeline source per repo to reduce drift

## Validation Checklist

1. Generated YAML parses successfully.
2. All referenced commands exist in the repo.
3. Cache strategy matches package manager.
4. Required secrets are documented, not embedded.
5. Branch/protected-environment rules match org policy.

## Scaling Guidance

- Split long jobs by stage when runtime exceeds 10 minutes.
- Introduce test matrix only when compatibility truly requires it.
- Separate deploy jobs from CI jobs to keep feedback fast.
- Track pipeline duration and flakiness as first-class metrics.
