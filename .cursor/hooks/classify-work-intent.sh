#!/usr/bin/env bash
# beforeSubmitPrompt: classify work intent — implement/plan/design/fix
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

if echo "$lower" | grep -qE 'implement the plan|planı uygula|planı implement|plana göre|tüm todo|todo.*tamamla|do not edit the plan'; then
  cat <<'EOF'
{"additional_context": "[Work Intent: IMPLEMENT_PLAN] Use existing plan; skip project-intake. Plan body read-only — only todos[].status. Verification: .cursor/plans/_shared/verification.md"}
EOF
  exit 0
fi

if echo "$lower" | grep -qE 'plan(\s|$|ı|a|l)|uygulama plan|implementation plan|plan oluştur|plan yap'; then
  if ! echo "$lower" | grep -qE 'implement|uygula|todo.*complete'; then
    cat <<'EOF'
{"additional_context": "[Work Intent: PLAN_ONLY] implementation-plan skill. Run project-intake if brief missing, then write plan file. English plan; no code."}
EOF
    exit 0
  fi
fi

if echo "$lower" | grep -qE 'design|mockup|prototype|wireframe|tasarım|tema|ui oluştur|ekran tasar|redesign|güzel yap|visual|style|color palette|renk paleti'; then
  cat <<'EOF'
{"additional_context": "[Work Intent: DESIGN] design-intake skill. Infer + AskQuestion (aesthetic, theme, UI stack). Plan: .cursor/plans/design-*.plan.md"}
EOF
  exit 0
fi

if echo "$lower" | grep -qE 'scaffold|yeni modül|yeni ekran|feature ekle|modül oluştur|ekran oluştur'; then
  cat <<'EOF'
{"additional_context": "[Work Intent: SCAFFOLD] module-scaffolder skill. Run project-intake first if brief missing."}
EOF
  exit 0
fi

if echo "$lower" | grep -qE 'greenfield|proje başlat|agent oluştur|yeni proje|from scratch|sıfırdan'; then
  cat <<'EOF'
{"additional_context": "[Work Intent: GREENFIELD] project-intake skill REQUIRED — full brief matrix."}
EOF
  exit 0
fi

if echo "$lower" | grep -qE '\bfix\b|bug|hata|refactor|düzelt'; then
  echo '{}'
  exit 0
fi

echo '{}'
exit 0
