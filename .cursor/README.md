# Cursor — Generic Project Intake

Project-agnostic agent instructions: **infer → AskQuestion → brief → plan → implement** flow for planning, design, scaffold, and greenfield work.

**Instruction language:** English (this tree).  
**Output locale:** config `locale.*` in [config/project.defaults.yaml](config/project.defaults.yaml); inline summary in [rules/core.mdc](rules/core.mdc).

## Token-conscious design

Minimize always-on system prompt cost; load heavy intake only when hooks or user intent require it.

| Load mode | Artifacts | When |
|-----------|-----------|------|
| **Always-on** (~1.5 KB) | [rules/core.mdc](rules/core.mdc) only | Every agent turn |
| **Glob rules** | quality-standards, plan-authoring, screen-test-docs | Matching file paths only |
| **Session hook** | `[Stack:…]` from session-detect-stack | Once per session |
| **Prompt hook** | route-work.sh intent + intake + skill route | Greenfield/plan/design/etc. |
| **On-demand** | project-intake skill, intake-workflow rule, project.defaults.yaml, project.intake-fields.yaml | Intake / greenfield only |

Legacy stubs (`cursor-guidelines.mdc`, `output-locale.mdc`, `project-config.mdc`) point to `core.mdc` — not always-on.

## Layout

| Folder | Purpose |
|--------|---------|
| [config/](config/) | **Project defaults** + [project.intake-fields.yaml](config/project.intake-fields.yaml) (AskQuestion catalog) |
| [rules/](rules/) | core.mdc (always-on), lazy intake workflow, quality standards |
| [skills/](skills/) | project-intake, design-intake, implementation-plan, module-scaffolder, screen-test-protocol, … |
| [skills/claude-skills-router/registry.json](skills/claude-skills-router/registry.json) | Hook skill priority table |
| [hooks/](hooks/) | Stack detect, task logging, unified route-work router |
| [logs/](logs/) | Runtime `agent-activity.log` — task start/end timestamps + duration (gitignored) |
| [plans/_briefs/](plans/_briefs/) | Approved brief files (`*.brief.md`) |
| [plans/features/](plans/features/) | Feature implementation plans (created on demand) |
| [plans/_shared/](plans/_shared/) | Intake options, locale, verification |
| [plans/_templates/](plans/_templates/) | Brief, plan, design templates |

## Flow

```text
Prompt → sessionStart ([Stack:signals])
      → route-work.sh (intent + intake gate + skill route)
      → on demand: project.defaults.yaml + project-intake → brief.md
      → implementation-plan | design-intake | module-scaffolder
      → *.plan.md → approval → implement (todos[].status only)
```

## User prompt examples

| Request | Expected behavior |
|---------|-------------------|
| "Plan a Next.js admin panel from scratch" | route-work → project-intake → brief → implementation-plan |
| "Design a dashboard with Tailwind + shadcn" | design-intake (+ intake UI round) |
| "Scaffold a new module" | module-scaffolder (brief required) |
| "Implement the plan" | Implement mode; intake skipped |
| "Fix login bug" | No intake noise; core.mdc only |
| "skip intake" | Continue without brief (user responsibility) |
| "Ekran testi yap" / "screen test" | screen-test-protocol: auto browser test + per-screen docs under `user_test/<app>/` |

## Hooks

```bash
chmod +x .cursor/hooks/*.sh
```

| Event | Script | Effect |
|-------|--------|--------|
| `sessionStart` | `session-detect-stack.sh` | `[Stack:…]` signals only |
| `beforeSubmitPrompt` | `log-task-start.sh` | Activity log + on-screen note |
| `beforeSubmitPrompt` | `route-work.sh` | Intent classify + intake gate + skill router |
| `stop` | `log-task-end.sh` | Task duration log |

`route-work.sh` is the single prompt router (intent + intake gate + registry skill routing merged into one script).

## File policy

| Mode | Plan / brief |
|------|--------------|
| Intake | New `*.brief.md` under `plans/_briefs/` |
| Create plan | New `*.plan.md` under `plans/features/` or `plans/design-*.plan.md` |
| Implement | Plan body read-only; only `todos[].status` |

## Related files

- **Defaults config:** [config/project.defaults.yaml](config/project.defaults.yaml)
- **Field catalog:** [config/project.intake-fields.yaml](config/project.intake-fields.yaml)
- Question matrix: [intake-canonical-options.md](plans/_shared/intake-canonical-options.md)
- Intake workflow (lazy): [project-intake-workflow.mdc](rules/project-intake-workflow.mdc)
- Always-on rules: [core.mdc](rules/core.mdc)
- Verification: [verification.md](plans/_shared/verification.md)
- Screen testing: [screen-test-protocol/SKILL.md](skills/screen-test-protocol/SKILL.md) · [screen-test-docs.mdc](rules/screen-test-docs.mdc) → output in sibling `user_test/`
