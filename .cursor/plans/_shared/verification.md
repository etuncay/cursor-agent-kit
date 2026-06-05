# Verification (post-implement)

Checklist after code changes. Apply level from brief `verification` field.

## Levels

| brief.verification | Required actions |
|--------------------|------------------|
| `unit-only` | Run project test command; report exit code |
| `browser-mcp` | Dev server up → `cursor-ide-browser` navigate → snapshot → scenario table |
| `e2e-playwright` | Run project E2E command (e.g. `pnpm exec playwright test`) |
| `manual-user` | Document steps for user; do not mark verify todo completed |
| `skip-for-now` | Report "verification deferred" in English |

## Browser MCP flow (when required)

1. Run tests + build for touched package(s) — exit 0.
2. Start or use running dev server; note URL/port from config or terminal.
3. **cursor-ide-browser:** navigate → snapshot → exercise spec/plan scenarios.
4. Reply with **`## Verification results`** table: Pass / Partial / Fail.

## Plan todo alignment

- Plan todo `*-verify` → test + build
- Mark completed only after pass, or document `Could not run` with reason

## Exceptions

- Pure backend/domain change with no UI → unit/build only
- No dev server available → report `Could not run`; do not mark browser todo completed
