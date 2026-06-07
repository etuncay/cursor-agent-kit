#!/usr/bin/env bash
# beforeSubmitPrompt: unified intent classify + intake gate + skill router
set -euo pipefail

input="$(cat)"
[ -z "$input" ] && echo '{}' && exit 0

PROMPT="$input" python3 <<'PY'
import json
import os
import re
import sys

raw = os.environ.get("PROMPT", "")
try:
    data = json.loads(raw)
except json.JSONDecodeError:
    print("{}")
    sys.exit(0)

prompt = data.get("prompt") or data.get("user_message") or data.get("text") or ""
if not prompt:
    print("{}")
    sys.exit(0)

lower = prompt.lower()
ctx_parts = []
agent_parts = []

def has(pattern: str) -> bool:
    return re.search(pattern, lower) is not None

# Skip intake entirely
skip_intake = has(
    r"implement the plan|planı uygula|skip intake|intake atla|\bfix\b|bug|refactor|düzelt|todo.*complete"
)

# Highest priority: implement plan
if has(r"implement the plan|planı uygula|planı implement|plana göre|tüm todo|todo.*tamamla|do not edit the plan"):
    ctx_parts.append(
        "[Intent:IMPLEMENT_PLAN] Use existing plan; skip intake. Plan read-only — only todos[].status."
    )
    agent_parts.append(
        "PLAN IMPLEMENT: verify per .cursor/plans/_shared/verification.md. Only todos[].status."
    )
    print(json.dumps({"additional_context": " ".join(ctx_parts), "agent_message": " ".join(agent_parts)}, ensure_ascii=False))
    sys.exit(0)

# Explicit fix — no routing noise
if has(r"\bfix\b|bug|hata|refactor|düzelt"):
    print("{}")
    sys.exit(0)

# Intent classification
if has(r"plan(\s|$|ı|a|l)|uygulama plan|implementation plan|plan oluştur|plan yap") and not has(
    r"implement|uygula|todo.*complete"
):
    ctx_parts.append("[Intent:PLAN_ONLY] implementation-plan skill; intake if brief missing.")
elif has(r"design|mockup|prototype|wireframe|tasarım|tema|ui oluştur|ekran tasar|redesign|güzel yap|visual|style|color palette|renk paleti"):
    ctx_parts.append("[Intent:DESIGN] design-intake skill.")
elif has(r"scaffold|yeni modül|yeni ekran|feature ekle|modül oluştur|ekran oluştur"):
    ctx_parts.append("[Intent:SCAFFOLD] module-scaffolder skill; intake if brief missing.")
elif has(r"greenfield|proje başlat|agent oluştur|yeni proje|from scratch|sıfırdan"):
    ctx_parts.append("[Intent:GREENFIELD] project-intake REQUIRED.")
elif has(r"ekran testi|ekran test|screen test|test dökümanı|test dokumani|test docs|smoke test|user_test|uçtan uca test|e2e ekran"):
    ctx_parts.append("[Intent:SCREEN_TEST] screen-test-protocol skill.")

# Intake gate
needs_intake = has(
    r"greenfield|proje başlat|agent oluştur|yeni proje|plan oluştur|uygulama plan|tasarım|mockup|scaffold|yeni modül|feature ekle|from scratch|sıfırdan"
)
if needs_intake and not skip_intake:
    brief_dir = ".cursor/plans/_briefs"
    has_brief = False
    if os.path.isdir(brief_dir):
        has_brief = any(name.endswith(".brief.md") for name in os.listdir(brief_dir))
    if not has_brief:
        agent_parts.append(
            "INTAKE: read .cursor/skills/project-intake/SKILL.md + .cursor/config/project.defaults.yaml + project.intake-fields.yaml. Save brief."
        )

# Registry skill routing (when no strong agent message yet)
if not agent_parts:
    registry_path = ".cursor/skills/claude-skills-router/registry.json"
    if os.path.isfile(registry_path):
        try:
            with open(registry_path, encoding="utf-8") as f:
                entries = json.load(f)["entries"]
            entries.sort(key=lambda e: e.get("priority", 0), reverse=True)
            for entry in entries:
                pattern = entry.get("match", "")
                skill_path = entry.get("skillPath", "")
                skill_id = entry.get("id", "")
                if not pattern or not os.path.isfile(skill_path):
                    continue
                if re.search(pattern, prompt, re.I):
                    agent_parts.append(
                        f"Skill route: '{skill_id}'. Read '{skill_path}' and follow it."
                    )
                    break
        except (OSError, KeyError, json.JSONDecodeError):
            pass

if not ctx_parts and not agent_parts:
    print("{}")
else:
    out = {}
    if ctx_parts:
        out["additional_context"] = " ".join(ctx_parts)
    if agent_parts:
        out["agent_message"] = " ".join(agent_parts)
    print(json.dumps(out, ensure_ascii=False))
PY

exit 0
