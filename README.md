# Cursor Agent Kit

Generic **`.cursor`** template for Cursor IDE: project intake, brief → plan → implement flow, hooks, rules, and skills.

Use in any repo by cloning this repository and running the install script.

## Quick start

### macOS / Linux

```bash
# 1. Clone (once)
git clone https://github.com/YOUR_USER/cursor-agent-kit.git
cd cursor-agent-kit

# 2. Install into your project
./install.sh /path/to/your-project

# 3. Configure defaults (locale, stack, architecture)
# Edit: your-project/.cursor/config/project.defaults.yaml
```

### Windows

```cmd
git clone https://github.com/YOUR_USER/cursor-agent-kit.git
cd cursor-agent-kit

install.bat C:\path\to\your-project
REM or: install.bat . --force
```

Then open **your project** in Cursor. Hooks under `.cursor/hooks.json` load automatically.

## Install options

| Command | Effect |
|---------|--------|
| `./install.sh ~/dev/my-app` | Copy `.cursor/` into `my-app/.cursor/` (macOS/Linux) |
| `install.bat C:\dev\my-app` | Same on Windows |
| `./install.sh .` / `install.bat .` | Install into current directory |
| `... --force` | Replace existing `.cursor` (old → `.cursor.bak.<timestamp>`) |

### Without cloning (one-liner)

```bash
git clone --depth 1 https://github.com/YOUR_USER/cursor-agent-kit.git /tmp/cursor-agent-kit
/tmp/cursor-agent-kit/install.sh /path/to/your-project
```

### Git submodule (team pin)

```bash
cd your-project
git submodule add https://github.com/YOUR_USER/cursor-agent-kit.git .cursor-kit
.cursor-kit/install.sh . --force   # or symlink: ln -s .cursor-kit/.cursor .cursor
```

## After install — configure

Edit **`your-project/.cursor/config/project.defaults.yaml`**:

```yaml
locale:
  chat: turkish              # reply language
  plan: turkish
  ask_question_labels: turkish

architecture:
  default: fullstack-separated
  frontend:
    default_language: typescript
    default_framework: react
  backend:
    default_language: csharp-dotnet
    default_framework: aspnet-core
```

Resolution order: **user prompt → repo signals → config defaults → AskQuestion** for missing fields.

## What gets installed

```
your-project/.cursor/
├── config/project.defaults.yaml   ← team standards (edit this)
├── hooks.json + hooks/*.sh
├── rules/*.mdc
├── skills/**/SKILL.md
└── plans/_briefs/                 ← generated briefs (per project)
    plans/features/                ← generated plans (per project)
```

Details: [.cursor/README.md](.cursor/README.md)

## Typical workflow

1. **Greenfield / new feature** → agent runs intake → `plans/_briefs/*.brief.md`
2. **Plan** → `plans/features/*.plan.md`
3. **Implement the plan** → code in your app; only plan `todos[].status` changes

Example prompts:

- `Sıfırdan Next.js admin paneli planla`
- `Planı uygula` (uses existing plan; skips intake)
- `skip intake` (use config defaults only)

## Repository layout (this repo)

| Path | Purpose |
|------|---------|
| `.cursor/` | Template copied to consumer projects |
| `install.sh` | Installer (macOS / Linux) |
| `install.bat` | Installer (Windows) |
| `README.md` | This file |

## Publish to GitHub

```bash
cd cursor-agent-kit
git init
git add .
git commit -m "Initial commit: Cursor agent kit template"
git branch -M main
git remote add origin https://github.com/YOUR_USER/cursor-agent-kit.git
git push -u origin main
```

## Updating an existing project

```bash
cd cursor-agent-kit && git pull
./install.sh /path/to/your-project --force
# Re-apply your project.defaults.yaml changes if overwritten (backup first)
```

Tip: keep project-specific overrides in a separate `project.local.yaml` (future) or document diffs; `--force` replaces the whole `.cursor` tree.

## License

MIT (add LICENSE file if you need one)
