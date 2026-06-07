---
name: "codebase-onboarding"
description: "Analyze a codebase and generate onboarding documentation for engineers, tech leads, and contractors. Fast fact-gathering and repeatable onboarding outputs. Use when onboarding a new engineer, writing architecture-overview docs for a new project, or producing tech-lead briefings for unfamiliar repos."
---

# Codebase Onboarding

**Tier:** POWERFUL  
**Category:** Engineering  
**Domain:** Documentation / Developer Experience

---

## Overview

Analyze a codebase and generate onboarding documentation for engineers, tech leads, and contractors. This skill is optimized for fast fact-gathering and repeatable onboarding outputs.

## Core Capabilities

- Architecture and stack discovery from repository signals
- Key file and config inventory for new contributors
- Local setup and common-task guidance generation
- Audience-aware documentation framing
- Debugging and contribution checklist scaffolding

---

## When to Use

- Onboarding a new team member or contractor
- Rebuilding stale project docs after large refactors
- Preparing internal handoff documentation
- Creating a standardized onboarding packet for services

---

## Quick Start

Gather facts with your own tools (Glob/Grep/Read) — no bundled script required:

1. Structure: top-level dirs + entry points (Glob `**/{package.json,*.csproj,go.mod,pyproject.toml}`).
2. Stack: read manifests/lockfiles for languages, frameworks, package managers.
3. Commands: extract the real `install` / `dev` / `test` / `build` from `scripts`, `Makefile`, or CI.
4. Config surface: `.env.example`, config files, infra manifests.
5. Draft the doc from the inline template below.

---

## Recommended Workflow

1. Inspect the repo with Glob/Grep/Read (structure, manifests, CI).
2. Capture key signals: detected languages, frameworks, config files, top-level structure.
3. Fill the inline onboarding template below.
4. Tailor output depth by audience:
   - Junior: setup + guardrails
   - Senior: architecture + operational concerns
   - Contractor: scoped ownership + integration boundaries

---

## Onboarding Document Template

```markdown
# <Project> — Onboarding

## 1. What it does (one paragraph)
## 2. Stack & architecture (languages, frameworks, services, data stores)
## 3. Repo map (top-level dirs → responsibility)
## 4. Local setup (prereqs → install → env → run) with copy-paste commands
## 5. Common tasks (run tests, add a feature, run a migration)
## 6. Key decisions & gotchas (the "why" behind non-obvious choices)
## 7. Troubleshooting & where to get help
```

Audience depth: Junior → setup + guardrails · Senior → architecture + ops · Contractor → scoped ownership + integration boundaries.

---

## Common Pitfalls

- Writing docs without validating setup commands on a clean environment
- Mixing architecture deep-dives into contractor-oriented docs
- Omitting troubleshooting and verification steps
- Letting onboarding docs drift from current repo state

## Best Practices

1. Keep setup instructions executable and time-bounded.
2. Document the "why" for key architectural decisions.
3. Update docs in the same PR as behavior changes.
4. Treat onboarding docs as living operational assets, not one-time deliverables.
