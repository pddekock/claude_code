#!/usr/bin/env bash
# Remove a local-model launcher. Claude Code itself stays installed.
# https://github.com/pddekock/claude_code
#
#   uninstall-claude-code.sh <launcher-name>
set -euo pipefail

name=${1:-}
if [[ ! $name =~ ^cc[A-Za-z0-9._-]*$ ]]; then
    echo "usage: uninstall-claude-code.sh <launcher-name>   (must start with a lowercase cc)" >&2
    exit 1
fi

launcher="$HOME/.local/bin/$name"
if [ ! -e "$launcher" ]; then
    echo "$launcher does not exist." >&2
    exit 1
fi
if ! grep -q '^# claude-code local launcher' "$launcher"; then
    echo "$launcher was not created by this installer - leaving it alone." >&2
    exit 1
fi

rm -f "$launcher"
echo "Removed $launcher. Claude Code is still installed."
