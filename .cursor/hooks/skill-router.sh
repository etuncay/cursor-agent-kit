#!/usr/bin/env bash
# beforeSubmitPrompt: registry-based skill routing
set -euo pipefail

input="$(cat)"
prompt=""

extract_prompt() {
  if command -v python3 >/dev/null 2>&1; then
    printf '%s' "$input" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('prompt') or d.get('user_message') or d.get('text') or '', end='')
except Exception:
    pass
" 2>/dev/null || true
  fi
}

prompt="$(extract_prompt)"
[ -z "$prompt" ] && exit 0

# Implement plan — highest priority
if echo "$prompt" | grep -iE 'implement the plan|planı uygula|planı implement|plana göre|tüm todo|todo.*tamamla' >/dev/null 2>&1; then
  cat <<'EOF'
{"agent_message": "PLAN IMPLEMENT mode. After code: test/build + verification (.cursor/plans/_shared/verification.md). Do not edit plan body — only todos[].status. Reply in English; ## Verification results table when UI applies."}
EOF
  exit 0
fi

registry_path=".cursor/skills/claude-skills-router/registry.json"
[ ! -f "$registry_path" ] && exit 0

PROMPT="$prompt" REGISTRY="$registry_path" python3 <<'PY'
import json, os, re, sys

prompt = os.environ.get("PROMPT", "")
path = os.environ.get("REGISTRY", "")
try:
    with open(path, encoding="utf-8") as f:
        entries = json.load(f)["entries"]
except OSError:
    sys.exit(1)

entries.sort(key=lambda e: e.get("priority", 0), reverse=True)
for entry in entries:
    pattern = entry.get("match", "")
    skill_path = entry.get("skillPath", "")
    skill_id = entry.get("id", "")
    if not pattern or not os.path.isfile(skill_path):
        continue
    if re.search(pattern, prompt, re.I):
        msg = (
            f"Auto skill route: '{skill_id}'. "
            f"Read '{skill_path}' and follow it. "
            f"Reply to user in ENGLISH (output-locale.md)."
        )
        print(json.dumps({"agent_message": msg}, ensure_ascii=False))
        sys.exit(0)
sys.exit(1)
PY

exit 0
