#!/usr/bin/env bash
# beforeSubmitPrompt: remind agent when brief is missing
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
[ -z "$prompt" ] && echo '{}' && exit 0

lower="$(echo "$prompt" | tr '[:upper:]' '[:lower:]')"

# Skip intake
if echo "$lower" | grep -qE 'implement the plan|planı uygula|skip intake|intake atla|\bfix\b|bug|refactor|düzelt|todo.*complete'; then
  echo '{}'
  exit 0
fi

needs_intake=0
if echo "$lower" | grep -qE 'greenfield|proje başlat|agent oluştur|yeni proje|plan oluştur|uygulama plan|tasarım|mockup|scaffold|yeni modül|feature ekle|from scratch|sıfırdan'; then
  needs_intake=1
fi

[ "$needs_intake" -eq 0 ] && echo '{}' && exit 0

BRIEF_DIR=".cursor/plans/_briefs"
if [ -d "$BRIEF_DIR" ] && find "$BRIEF_DIR" -maxdepth 1 -name '*.brief.md' 2>/dev/null | grep -q .; then
  echo '{}'
  exit 0
fi

cat <<'EOF'
{"agent_message": "INTAKE REQUIRED. Read .cursor/config/project.defaults.yaml then .cursor/skills/project-intake/SKILL.md. Order: config defaults → repo+prompt infer → AskQuestion for missing required fields. Save brief: .cursor/plans/_briefs/{slug}.brief.md. Options: .cursor/plans/_shared/intake-canonical-options.md"}
EOF
exit 0
