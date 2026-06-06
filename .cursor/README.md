# Cursor — Generic Project Intake

Project-agnostic agent instructions: **infer → AskQuestion → brief → plan → implement** flow for planning, design, scaffold, and greenfield work.

**Instruction language:** English (this tree).  
**Output locale:** [plans/_shared/output-locale.md](plans/_shared/output-locale.md) — chat and plans **English**; code **English**.

## Layout

| Folder | Purpose |
|--------|---------|
| [config/](config/) | **Project defaults** — locale, architecture, frontend/backend stack, intake rules |
| [rules/](rules/) | Intake workflow, guidelines, quality standards |
| [skills/](skills/) | project-intake, design-intake, implementation-plan, module-scaffolder, screen-test-protocol, … |
| [skills/claude-skills-router/registry.json](skills/claude-skills-router/registry.json) | Hook skill priority table |
| [hooks/](hooks/) | Stack detect, intent classify, intake gate, skill router |
| [plans/_briefs/](plans/_briefs/) | Approved brief files (`*.brief.md`) |
| [plans/features/](plans/features/) | Feature implementation plans (created on demand) |
| [plans/_shared/](plans/_shared/) | Intake options, locale, verification |
| [plans/_templates/](plans/_templates/) | Brief, plan, design templates |

## Flow

```text
Prompt → sessionStart (stack signals + config hint)
      → classify-work-intent
      → intake-gate (INTAKE REQUIRED if no brief)
      → skill-router (registry)
      → load config → project-intake → brief.md
      → implementation-plan | design-intake | module-scaffolder
      → *.plan.md → approval → implement (todos[].status only)
```

## User prompt examples

| Request | Expected behavior |
|---------|-------------------|
| "Plan a Next.js admin panel from scratch" | project-intake → brief → implementation-plan |
| "Design a dashboard with Tailwind + shadcn" | design-intake (+ intake UI round) |
| "Scaffold a new module" | module-scaffolder (brief required) |
| "Implement the plan" | Implement mode; intake skipped |
| "skip intake" | Continue without brief (user responsibility) |
| "Ekran testi yap" / "screen test" | screen-test-protocol: auto browser test + per-screen docs under `user_test/<app>/` |

## Hooks

```bash
chmod +x .cursor/hooks/*.sh
```

## File policy

| Mode | Plan / brief |
|------|--------------|
| Intake | New `*.brief.md` under `plans/_briefs/` |
| Create plan | New `*.plan.md` under `plans/features/` or `plans/design-*.plan.md` |
| Implement | Plan body read-only; only `todos[].status` |

## Related files

- **Defaults config:** [config/project.defaults.yaml](config/project.defaults.yaml)
- Question matrix: [intake-canonical-options.md](plans/_shared/intake-canonical-options.md)
- Main workflow: [project-intake-workflow.mdc](rules/project-intake-workflow.mdc)
- Verification: [verification.md](plans/_shared/verification.md)
- Screen testing: [screen-test-protocol/SKILL.md](skills/screen-test-protocol/SKILL.md) · [screen-test-docs.mdc](rules/screen-test-docs.mdc) → output in sibling `user_test/`
