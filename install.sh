#!/usr/bin/env bash
#
# nibble installer (any agent that reads Markdown skills).
#
# Copies the five nibble skills into your Claude Code skills directory
# (~/.claude/skills by default) and makes the scanner executable.
# Read this script before running it. It only copies files; it installs nothing
# system-wide and touches nothing outside the skills directory.
#
# Usage:
#   ./install.sh                 # install to ~/.claude/skills
#   SKILLS_DIR=/path ./install.sh  # install somewhere else

set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/skills"
DEST="${SKILLS_DIR:-$HOME/.claude/skills}"

echo "Installing nibble skills to: $DEST"
mkdir -p "$DEST"

for skill in nibble-map nibble-scan nibble-trace nibble-fix nibble-commit; do
  cp -r "$SRC/$skill" "$DEST/"
  echo "  installed $skill"
done

# Make the deterministic pre-pass runnable.
chmod +x "$DEST/nibble-scan/scan-repo.sh" 2>/dev/null || true

echo "Done. Optional: install ast-grep for higher-precision structural scans."
