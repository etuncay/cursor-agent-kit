# Example prompts — cursor-agent-kit

**English** · [Türkçe](example-prompts.tr.md)

Copy-paste prompts for using **hooks**, **commands**, **skills**, **subagents**, **rules**, and **plans** under `.cursor/` effectively.

**Locale:** Chat language follows `locale.chat` in [project.defaults.yaml](../config/project.defaults.yaml); plan/brief body follows `locale.plan` (default English).  
**See also:** [.cursor/README.md](../README.md) · [registry.json](../skills/skills-router/registry.json)

---

## How layers work together

```text
Prompt → hooks (stack + intent + skill route) → skill (main flow) → subagent (parallel explore/validate)
Slash → commands/*.md → same skill + subagent steps (manual, deterministic)
Rules → every turn (core) or file glob (plan, quality)
Plans → brief → plan → implement (plan body read-only)
```

A strong prompt = **goal + scope + constraints + verification** (+ file paths when relevant).

---

## Quality template

```text
[Goal] I want to …
[Scope] In: … / Out: …
[Stack] React + .NET API / match existing repo layout.
[Constraints] Auth required, mock API, English UI.
[Verification] Login → list → create flow must work.
[Mode] skip intake / skip refinement (optional)
```

---

## Quick reference

| You want… | Best entry |
|-----------|------------|
| Clarify an idea | `/refine` or `refine prompt: …` |
| Brief | `/intake` or `greenfield …` |
| Plan | `/plan` or `create implementation plan …` |
| Code (from plan) | `/implement` |
| Module scaffold | `/scaffold` |
| UI/design | `/design` |
| End-to-end repair | `/fix` or `make X work end-to-end` |
| Browser test | `/screen-test` |
| Session handoff | `/handoff` |
| Repo overview | `/onboard` |
| CVE audit | `/audit-deps` |
| SAST/secrets | `/security` |
| OpenAPI review | `/api-review` |
| CI pipeline | `/ci` |
| Kit status | `/status` |
| Skip brief | `skip intake` |
| Skip refinement | `skip refinement` |

---

# 1. Slash commands

## `/refine` — Prompt refinement

```
/refine

I'm thinking about a B2B invoicing panel from scratch. Users should create invoices and download PDFs.
Still at idea stage — clarify stack and module boundaries before intake.
```

```
/refine

We're adding a "reporting" module to an existing monorepo; data source (API vs DB) is undecided.
Constraints: existing shadcn + Tailwind, .NET 8 backend.
After approval, proceed to intake.
```

```
refine prompt: mobile-first onboarding wizard, 3 steps, analytics events on each step
```

## `/intake` — Create brief

```
/intake

Greenfield: SaaS subscription management panel.
Frontend React, backend REST API, start with mocks.
Deliverable: plan first, then code.
```

```
/intake

Full project (not a single screen): internal inventory tracking app.
Role-based access, no barcode scanning, web only.
Save brief aligned with plan locale (English).
```

```
from scratch: contractor onboarding portal, single module, real PostgreSQL
```

## `/plan` — Implementation plan

```
/plan

Approved brief: `.cursor/plans/_briefs/inventory-panel.brief.md`
Run gap analysis; write feature plan matching repo patterns.
Do not present until critical plan-reviewer issues are fixed.
```

```
create implementation plan: auth module — JWT + refresh token, compatible with existing Users table
```

```
implementation plan for slug `billing-admin` — include verification scenarios for invoice CRUD
```

## `/implement` — Execute plan

```
/implement

Apply `.cursor/plans/features/billing-admin.plan.md`.
Update only todos[].status; do not edit plan body.
First todo: API contract + DTOs.
```

```
Implement the plan — start with todo "scaffold-api-routes", skip intake and refinement
```

## `/scaffold` — Module skeleton

```
/scaffold

Brief: `user-management.brief.md`
User list + detail module under `apps/web/src/features/` matching existing patterns.
API client, types, routes, empty pages — business logic later.
```

```
new screen: order history — list + filters + detail drawer, scaffold only
```

```
scaffold notifications preferences module matching `features/reports` layout
```

## `/design` — Design intake

```
/design

Dashboard redesign: dark theme, low motion, shadcn + Tailwind.
Brief aesthetic: minimal; Recharts for charts.
Design brief + design plan first — no app code yet.
```

```
design: modernize login and signup screens, baseline a11y, mobile-first mockup approach
```

```
mockup plan for settings page — tabs: profile, security, notifications
```

## `/fix` — End-to-end module repair

```
/fix

Payments module broken end-to-end: checkout looks successful but orders never hit the DB.
Scope: `src/features/checkout/` + related API handlers.
Follow 3-strike rule; use dependency-tracer output after TRACE.
```

```
make auth work end-to-end — login redirect loop, focus on `apps/web` auth guard + API middleware
```

```
fix the notifications feature — push not sent; inspect webhook + queue paths
```

## `/screen-test` — Screen test + docs

```
/screen-test

Dev server on :3000. Smoke-test all CRUD screens.
Output: per-screen test docs under `user_test/admin-panel/`.
```

```
screen test: login, dashboard, user list — automated browser test + documentation
```

```
screen test for settings flows — include create/edit/delete where applicable
```

## `/handoff` — Session handoff

```
/handoff

Continuing tomorrow on another machine. Compact this session into a handoff doc.
Redact secrets/PII; reference brief and plan paths.
```

```
hand this off — remaining work: plan todos 4–7, no open PR
```

```
pick this up later — summarize auth decisions and open blockers
```

## `/onboard` — Codebase onboarding

```
/onboard

Onboarding doc for a new backend engineer: architecture, folder layout, local setup, test commands.
Audience: senior, ~30 min read.
```

```
codebase overview — focus on event-driven parts and deployment flow
```

```
onboarding for contractors — embed command-validator verified install/test commands
```

## `/audit-deps` — Dependency audit

```
/audit-deps

Full pre-release dependency audit: CVEs, transitive risk, license conflicts.
Priority: upgrade paths for critical/high CVEs.
```

```
dependency audit — npm + pip; summarize audit-runner raw output
```

```
CVE scan — flag GPL conflicts in frontend bundles
```

## `/security` — Security scan

```
/security

App security scan focused on OWASP Top 10. semgrep + gitleaks + secrets.
Report: finding, severity, remediation.
```

```
security scan: auth endpoints, SQL injection, hardcoded secrets
```

```
threat model prep before production — include checkov if infra folders exist
```

## `/api-review` — API design review

```
/api-review

`openapi.yaml` v2 migration review — breaking changes, versioning, error envelope consistency.
Use spectral + oasdiff.
```

```
rest api design review for `/api/v1/orders` — pagination, idempotency, status codes
```

```
openapi lint — compare staging vs production spec for breaking changes
```

## `/ci` — CI/CD pipeline

```
/ci

GitHub Actions: lint, test, build, staging deploy. pnpm monorepo, .NET API separate job.
Validate existing `package.json` scripts with command-validator.
```

```
create pipeline: unit tests on PR + docker image publish on main
```

```
ci/cd for Node frontend + Python worker — parallel jobs, cache strategy
```

## `/skip-intake` and `/skip-refine`

```
/skip-intake

Scope is clear — write `features/notifications.plan.md` directly.
Brief optional; scope in prompt.
```

```
skip intake — implement existing plan at `.cursor/plans/features/auth.plan.md`
```

```
/skip-refine

Urgent hotfix: `UserService.cs` line 142 null reference — minimal diff, no intake/refine.
```

```
skip refinement — not greenfield, only update README
```

## `/status` — Kit status

```
/status

Summarize active briefs, plans, branch, last context report.
```

---

# 2. Skills (natural language — hook registry)

Hooks select skills via [registry.json](../skills/skills-router/registry.json). Phrases below auto-route (English and Turkish supported).

### Greenfield & planning

| Prompt | Expected behavior |
|--------|-------------------|
| `Plan a Next.js admin panel from scratch` | prompt-refinement → project-intake → implementation-plan |
| `from scratch: headless CMS + React editor` | project-intake |
| `greenfield: repo analysis CLI bot` | project-intake |
| `implementation plan: multi-tenant SaaS core` | implementation-plan |

### Module & scaffold

| Prompt | Skill |
|--------|-------|
| `new screen: product catalog list and detail` | module-scaffolder |
| `add feature: webhook management in admin` | module-scaffolder |
| `scaffold notifications preferences module` | module-scaffolder |

### Design

| Prompt | Skill |
|--------|-------|
| `design a landing page with gradient hero, low motion` | design-intake |
| `wireframe-level checkout flow design plan` | design-intake |
| `redesign settings with dark theme` | design-intake |

### Repair (focused-fix vs quick fix)

| Prompt | Behavior |
|--------|----------|
| `Fix login bug — typo in redirect URL` | QUICK_FIX (no skill; core.mdc only) |
| `make billing work end-to-end` | focused-fix + dependency-tracer |
| `debug checkout end-to-end — Excel export broken` | focused-fix |
| `fix the cache invalidation module` | focused-fix |

### Specialist skill examples

```
We're migrating OpenAPI to v3.1 — recommend breaking-change and versioning standards.
→ api-design-reviewer + openapi-linter
```

```
PostgreSQL schema: orders, order_items, payments — normalize and produce ERD.
→ database-schema-designer + schema-reviewer
```

```
Expose GitHub API as MCP server — generate tools from OpenAPI.
→ mcp-server-builder
```

```
Create a skill: auto-generate PR descriptions, include registry triggers.
→ skill-creator
```

```
Create `report.docx`: Q1 summary with tables and headings.
→ docx-tools
```

```
`prices.xlsx` — convert to CSV, drop empty rows.
→ xlsx-tools
```

```
`pitch.pptx`: investor deck, 12 slides, problem-solution-market.
→ pptx-tools
```

```
Merge `contract.pdf` and `appendix.pdf`, add watermark.
→ pdf-tools
```

---

# 3. Subagent-focused prompts

Subagents are usually triggered via skills/commands. Explicit instruction examples:

### `repo-explorer` (readonly)

```
Before writing the plan, run repo-explorer: tabulate feature folder patterns and stack signals.
Scope: `apps/web` and `services/api` only.
```

```
Gap analysis — 3 example module paths + suggested scaffold path; no file creation.
```

### `brief-validator` (readonly)

```
Validate `.cursor/plans/_briefs/crm.brief.md` against `required_before_plan`.
List gaps and suggest brief fixes.
```

### `plan-reviewer` (readonly)

```
Review `.cursor/plans/features/crm.plan.md` — brief alignment, plan-authoring rules, verification section.
Do not suggest implement if critical issues remain.
```

### `dependency-tracer` (readonly)

```
SCOPE done: `src/modules/payments/**`
Run dependency-tracer for inbound/outbound imports; we'll use it in focused-fix DIAGNOSE.
```

### `route-mapper` (readonly)

```
All React routes, auth requirements, CRUD matrix — route-mapper output before screen-test.
```

### `command-validator` (shell)

```
Validate install, dev, test, build commands; report which work and which fail.
```

### `audit-runner` (shell)

```
osv-scanner + npm audit + pip-audit — raw CLI output; I'll triage.
```

### `security-scanner` (shell)

```
semgrep + gitleaks scan — if tool missing, report in "Could not run" format.
```

### `openapi-linter` (shell)

```
spectral lint `docs/openapi.yaml` + oasdiff breaking vs `main` branch spec.
```

### `schema-reviewer` (readonly)

```
Inventory EF Core migrations and entities — schema-reviewer before new loyalty program schema.
```

### `artifact-collector` (readonly)

```
For handoff: all brief/plan paths, git branch, uncommitted summary — artifact-collector format.
```

### Parallel subagents

```
Before /plan, run in parallel:
1) repo-explorer — gap table
2) brief-validator — `inventory.brief.md`
Merge results into the plan.
```

---

# 4. Plans & briefs

### Request a brief

```
Brief slug: `vendor-portal`
Content: B2B vendor portal, single module, REST + React, start with mock API.
UI: shadcn, minimal aesthetic, system theme.
Out of scope: native mobile app.
```

### Write a plan

```
Approved: `.cursor/plans/_briefs/vendor-portal.brief.md`
Write feature plan: YAML frontmatter, Scope in/out, Verification table (UI scenarios).
Template: `plans/_templates/feature-plan.template.md`
Plan language: English (project.defaults.yaml).
```

### Implement mode

```
Plan: `vendor-portal.plan.md`
Rule: plan body read-only; update todo status only.
Order: backend API → frontend list → integration test.
Mark each todo `completed` when done.
```

### Close a plan

```
Plan `vendor-portal` complete — add English closure line to overview; mark all todos completed.
```

---

# 5. Rules

| Rule | When to remind |
|------|----------------|
| [core.mdc](../rules/core.mdc) | Always — minimal diff, no commit unless asked |
| [plan-authoring.mdc](../rules/plan-authoring.mdc) | Editing `.cursor/plans/**/*.plan.md` |
| [quality-standards.mdc](../rules/quality-standards.mdc) | UI/PR quality review |
| [screen-test-docs.mdc](../rules/screen-test-docs.mdc) | `user_test/<app>/` doc format |

Examples:

```
When editing this plan, follow plan-authoring rules:
frontmatter, Brief section, Scope, Verification link required.
```

```
@cursor-guidelines — remember discipline rules this session, then continue /plan flow.
```

---

# 6. Hooks (indirect triggers)

| Hook event | Script | Prompt effect |
|------------|--------|---------------|
| `sessionStart` | session-detect-stack.sh | `[Stack:…]` on new session — don't re-guess stack |
| `beforeSubmitPrompt` | route-work.sh | Intent + skill route + context report |
| `beforeReadFile` | track-context-read.sh | Which rules/skills were actually read |
| `stop` | log-task-end.sh | Task duration log |

```
/status — read last Agent Kit context report: which skills were routed?
```

```
Don't open intake for this prompt — scope is clear, skip intake.
```

---

# 7. End-to-end scenarios

### Scenario A — Greenfield product

```text
1) /refine — B2B inventory, 5 roles, web only
2) [approval]
3) /intake — brief slug: stock-admin
4) /plan — gap + plan-reviewer
5) [plan approval]
6) /implement — todos in order
7) /screen-test — CRUD smoke
8) /handoff — remaining work
```

Single message:

```
Plan inventory admin panel from scratch: React, .NET API, mock MSW.
Roles: admin, warehouse, sales. Brief and plan first; code after approval.
English plan artifacts; chat in project locale.
```

### Scenario B — Module in existing repo

```
skip refinement

Brief exists: `crm-contacts.brief.md`
/scaffold — contacts list + detail, match repo pattern
Then /implement — frontend todos only
```

### Scenario C — Broken module

```
/fix

make sync engine work end-to-end
Scope: `workers/sync/` + `api/webhooks/`
Verify: webhook received → queue → DB row created
```

### Scenario D — Release readiness

```
Parallel security package:
1) /audit-deps
2) /security
3) /api-review — `openapi/production.yaml`
Summary table: blocker / warning / info
```

### Scenario E — Team onboarding

```
/onboard

Audience: frontend dev, day-one setup.
Embed repo-explorer + command-validator output in doc.
Output: `docs/ONBOARDING.md` (technical English)
```

### Scenario F — MCP integration

```
Existing OpenAPI: `specs/internal-api.yaml`
Expose this API as MCP server — Python, forward auth header.
Follow mcp-server-builder skill flow.
```

---

# 8. Weak vs strong prompts

| Weak | Strong |
|------|--------|
| `Make a plan` | `create implementation plan: slug inventory-admin, approved brief, include gap analysis` |
| `Security` | `/security — OWASP, auth routes, secret scan, prioritized report` |
| `Fix it` | `/fix — auth module end-to-end, login redirect loop` |
| `Test it` | `/screen-test — server on :5173, user_test docs required` |
| `Write code` | `/implement — plan path, todo id, plan read-only` |

---

## Related files

- Kit overview: [README.md](../README.md)
- Slash commands: [commands/](../commands/)
- Subagents: [agents/](../agents/)
- Skill router: [registry.json](../skills/skills-router/registry.json)
- Defaults: [project.defaults.yaml](../config/project.defaults.yaml)
