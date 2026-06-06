#!/usr/bin/env bash
# Install .cursor agent kit into a target project directory.
# Usage:
#   ./install.sh /path/to/my-project
#   ./install.sh .                    # current directory
#   ./install.sh /path/to/project --force   # overwrite existing .cursor
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="${SCRIPT_DIR}/.cursor"
FORCE=0

usage() {
  cat <<'EOF'
Usage: install.sh <target-project-dir> [--force]

Copies this repository's .cursor/ tree into <target-project-dir>/.cursor/

  --force   Replace existing .cursor ( backs up to .cursor.bak.<timestamp> )

After install:
  1. Edit <project>/.cursor/config/project.defaults.yaml (locale, stack defaults)
  2. chmod +x <project>/.cursor/hooks/*.sh   (done automatically)
  3. Open project in Cursor — hooks load from .cursor/hooks.json

EOF
}

if [[ $# -lt 1 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
  usage
  exit 0
fi

TARGET="$(cd "$1" && pwd)"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ ! -d "$SOURCE" ]]; then
  echo "Error: .cursor source not found at ${SOURCE}" >&2
  exit 1
fi

DEST="${TARGET}/.cursor"

if [[ -d "$DEST" ]]; then
  if [[ "$FORCE" -eq 1 ]]; then
    BACKUP="${TARGET}/.cursor.bak.$(date +%Y%m%d%H%M%S)"
    echo "Backing up existing .cursor → ${BACKUP}"
    mv "$DEST" "$BACKUP"
  else
    echo "Error: ${DEST} already exists. Use --force to replace (creates backup)." >&2
    exit 1
  fi
fi

echo "Installing .cursor → ${DEST}"
mkdir -p "$DEST"
rsync -a --exclude='.DS_Store' "${SOURCE}/" "${DEST}/"

# Ensure runtime folders exist
mkdir -p "${DEST}/plans/_briefs" "${DEST}/plans/features"
touch "${DEST}/plans/_briefs/.gitkeep" "${DEST}/plans/features/.gitkeep" 2>/dev/null || true

# Hooks must be executable
if compgen -G "${DEST}/hooks/"'*.sh' > /dev/null; then
  chmod +x "${DEST}/hooks/"*.sh
fi

# Scaffold user_test seed (screen-test docs). Refresh kit-owned templates;
# never clobber generated per-app docs (README/index only seeded if absent).
USER_TEST_SRC="${SCRIPT_DIR}/user_test"
USER_TEST_DEST="${TARGET}/user_test"
if [[ -d "$USER_TEST_SRC" ]]; then
  mkdir -p "${USER_TEST_DEST}/_templates"
  rsync -a --exclude='.DS_Store' "${USER_TEST_SRC}/_templates/" "${USER_TEST_DEST}/_templates/"
  [[ -f "${USER_TEST_DEST}/README.md" ]] || cp "${USER_TEST_SRC}/README.md" "${USER_TEST_DEST}/README.md"
  [[ -f "${USER_TEST_DEST}/index.md" ]]  || cp "${USER_TEST_SRC}/index.md"  "${USER_TEST_DEST}/index.md"
  echo "Scaffolded user_test/ → ${USER_TEST_DEST} (templates refreshed)"
fi

echo "Done."
echo "Next: edit ${DEST}/config/project.defaults.yaml (locale.chat, architecture, defaults)"
