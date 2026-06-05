---
name: project-intake
description: >-
  Generic requirement gathering before plan or greenfield work. Load config defaults,
  infer repo+prompt, AskQuestion for missing required fields, save brief.
---

# Project intake (generic)

Apply when starting work **without** an approved brief in `.cursor/plans/_briefs/`.

**Config (read first):** [project.defaults.yaml](../../config/project.defaults.yaml)  
**Option IDs:** [intake-canonical-options.md](../../plans/_shared/intake-canonical-options.md)  
**Output locale:** from config `locale.*` or [output-locale.md](../../plans/_shared/output-locale.md)

## Triggers

- greenfield, start project, create agent, new project, from scratch
- create plan / new feature — brief missing
- Hook message: `INTAKE REQUIRED`
- **Not:** implement-plan, bugfix with clear scope, skip intake

## Flow

```text
1. Load project.defaults.yaml → apply locale + defaults
2. Infer user prompt + repo (repo_signals in config)
3. Merge: prompt > infer > config defaults
4. AskQuestion — only fields still missing (required_before_plan / conditional fields)
5. Save .cursor/plans/_briefs/{slug}.brief.md
6. Route to design-intake | implementation-plan | module-scaffolder
7. Create plan if deliverable includes plan
```

Max rounds: `intake.max_ask_rounds` from config (default 2). Batch all missing fields per round.

---

## Step 1 — Load config

Read `.cursor/config/project.defaults.yaml`:

| Config path | Use |
|-------------|-----|
| `locale.chat` | User reply language |
| `locale.plan` | Brief/plan language |
| `locale.ask_question_labels` | AskQuestion label language |
| `locale.code` / `code_comments` | Code conventions |
| `architecture.default` | Pre-fill `architecture` |
| `architecture.frontend.*` | Pre-fill frontend.language, framework, platform |
| `architecture.backend.*` | Pre-fill backend.language, framework, api_style |
| `defaults.*` | All other fallback values |
| `intake.required_before_plan` | Must be filled before plan/code |
| `intake.required_before_code` | Must be filled before implementation |

If `intake.ask_when_missing: false`, use defaults silently (greenfield not recommended).

---

## Step 2 — Infer from repo + prompt

Apply `repo_signals` from config plus prompt keyword mapping from [intake-canonical-options.md](../../plans/_shared/intake-canonical-options.md).

**Architecture inference hints:**

| Signal | architecture |
|--------|--------------|
| Only `package.json` + frontend deps | frontend-only |
| Only `*.csproj` / `pyproject.toml` / `go.mod` | backend-only |
| Frontend + backend folders (`apps/web` + `apps/api`) | fullstack-separated |
| Next.js with API routes / server actions | monolith |
| react-native / expo + API client | mobile-bff |

---

## Step 3 — AskQuestion

- **Tool:** `AskQuestion` only
- **Labels:** `locale.ask_question_labels` from config
- **Skip** any field already set (prompt, infer, or config)
- **Conditional fields:** use `fields[].required_when` in config (e.g. ask `backend.language` only when architecture includes backend)

### Round 1

work_type, architecture, scope, data_source, deliverable  
+ frontend.language, frontend.framework, frontend.platform (when frontend enabled)  
+ backend.language, backend.framework, backend.api_style (when backend enabled)

### Round 2 (frontend UI)

ui_approach, component_library, css_stack, aesthetic, theme, interaction, a11y

### Round 3 (ops)

auth, i18n, verification, ci_cd, backend.database (if data_source needs DB), monorepo.tool (if multi-module)

Set `ui_pattern` to `{css_stack}-{component_library}` when useful.

---

## Step 4 — Save brief

Path: `intake.brief_output` from config (default `.cursor/plans/_briefs/{slug}.brief.md`)

Template: [project-brief.template.md](../../plans/_templates/project-brief.template.md)

Source column: `prompt` | `inferred` | `config` | `user-mc`

---

## Step 5 — Route & do not

| brief.work_type | Next skill |
|-----------------|------------|
| design-only | design-intake |
| plan-only, plan-and-implement, new-feature, greenfield | implementation-plan |
| scaffold implied | module-scaffolder |

- Do not write code before `intake.required_before_code` fields are set
- Do not re-ask config defaults unless user contradicts them in prompt
- Do not exceed `intake.max_ask_rounds` without user asking for more detail

---

## Example

Config: fullstack-separated, frontend typescript/react, backend csharp-dotnet/aspnet-core.

User: "Add customer list screen, mock API"

Filled from config + infer: architecture, languages, frameworks, data_source=mock-json, scope=single-screen.

AskQuestion Round 2 only: component_library, css_stack, aesthetic, deliverable (if missing).
