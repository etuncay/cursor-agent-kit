---
name: handoff
description: "Compact the current conversation into a handoff document so a fresh agent can continue. Writes a 5-section markdown doc to the OS temp dir (or a path the user gives), redacts secrets/PII, references existing artifacts instead of duplicating them, and suggests 3-5 skills for the next session. Use when the user says 'hand this off', 'handoff doc', 'summarize this for a new session', 'compact this conversation', 'I'm ending this session', 'pick this up later', or signals switching machines / stopping mid-task."
license: MIT
metadata:
  inspired_by: "https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff"
---

# Handoff

**Output locale:** [`output-locale.md`](../../plans/_shared/output-locale.md) — handoff body follows config `locale.chat`; code paths and identifiers stay English.

Write a handoff document summarising the current conversation so a fresh agent can continue the work. This skill is **agent-driven** — no bundled scripts, slash commands, or hooks. You produce the document yourself with your normal file tools.

Core discipline (Matt Pocock's): **do not duplicate** content that already lives in other artifacts (PRDs, plans, ADRs, issues, commits, diffs) — reference them by path or URL instead. Redact secrets before writing.

## When to use

**Explicit:** "hand this off", "handoff doc", "summarize this for a new session", "compact this conversation", "I'm ending this session", "pick this up later", "wrap this up for tomorrow", "save this for the next session".

**Implicit:** user switches machines or stops for the day mid-task, says "let me come back to this", or context is growing long without a stopping point. On an implicit signal, **propose before running** — *"Want me to write a handoff for the next session?"* — never write it silently.

If the user gave a goal for the next session, tailor the document to it.

## Output path

Default to the OS temp dir so the project folder stays uncluttered:

```bash
mktemp -t handoff-XXXXXX.md
```

If the user names a location (e.g. a project-local `.handoff/` dir), use that instead. Read the file before overwriting it. To continue past an earlier handoff, **edit the most recent file in place** rather than creating a new one.

## Section template

Five sections, exact headers:

- **Goal of next session** — from the user's stated goal, or inferred from the most recent thread.
- **State of play** — what's done, in flight, blocked. Reference artifacts; do not paste them.
- **Open decisions** — what the next agent must decide before continuing.
- **Skills to use** — 3-5 skills the next session should invoke, each with a one-line *why*.
- **Artifacts** — paths/URLs to plans, briefs, issues, branches, PRs, commits. No duplicated contents.

## The agent's job (mandatory checklist)

For **each topic** discussed in the conversation, decide explicitly: *include in State of play* / *log as an Open decision* / *drop with a reason*. Free-handing the summary leads to rosy progress reports and dropped blockers — the explicit pass prevents that.

Then pick the 3-5 next-session skills from the ones available in this kit (e.g. `implementation-plan`, `module-scaffolder`, `focused-fix`, `screen-test-protocol`, `senior-secops`).

## Anti-patterns

- **Do not paste the diff.** Reference the branch or PR.
- **Do not retype the plan/brief.** Link to its path under `.cursor/plans/`.
- **Do not summarise what's already in the commit message.** Link the commit hash.
- **Do not list 20 skills.** Pick the 3-5 the next session actually needs.
- **Do not narrate every message.** Compress to State + Decisions.

## Redaction (before writing)

Scan the draft and remove/redact:

- API keys, OAuth/JWT tokens, passwords, DB connection strings
- `-----BEGIN ... PRIVATE KEY-----` blocks
- `.env`-style `KEY=value` lines containing secrets
- Email addresses, phone numbers, names of unrelated third parties
- Internal URLs containing tokens or session IDs

Regex misses context — also do a manual pass for anything sensitive that isn't a recognisable pattern.

## Example

```
User: hand this off — next session finishes wiring the login flow and opens a draft PR
```

Walk the checklist, draft the 5 sections from the conversation, redact, write to `mktemp` (or the user's path), and reply with the file path plus a one-line summary.

---

**Inspired by:** [Matt Pocock's handoff](https://github.com/mattpocock/skills/tree/main/skills/productivity/handoff) (MIT).
