#!/usr/bin/env bash
# Install Claude Code and a launcher that points it at a local model.
# https://github.com/pddekock/claude_code
#
#   install-claude-code.sh <launcher-name> <base-url> <auth-token> <model> <context-tokens>
set -euo pipefail

name=${1:-}
url=${2:-}
token=${3:-}
model=${4:-}
context=${5:-}
if [[ ! $name =~ ^cc[A-Za-z0-9._-]*$ || ! $url =~ ^[A-Za-z0-9:/._~-]+$ ||
      ! $token =~ ^[A-Za-z0-9._~-]+$ || ! $model =~ ^[A-Za-z0-9:/._~-]+$ ||
      ! $context =~ ^[0-9]+$ ]]; then
    echo "usage: install-claude-code.sh <launcher-name> <base-url> <auth-token> <model> <context-tokens>" >&2
    echo "       launcher-name must start with a lowercase cc, e.g. ccl" >&2
    exit 1
fi

launcher="$HOME/.local/bin/$name"
if [ -e "$launcher" ] && ! grep -q '^# claude-code local launcher' "$launcher"; then
    echo "$launcher exists and was not created by this installer." >&2
    exit 1
fi

curl -fsSL https://claude.ai/install.sh | bash

[ -x "$HOME/.local/bin/claude" ] || { echo "Claude Code was not installed." >&2; exit 1; }

cat > "$launcher" <<EOF
#!/bin/sh
# claude-code local launcher
export ANTHROPIC_BASE_URL="$url"
export ANTHROPIC_AUTH_TOKEN="$token"
export ANTHROPIC_MODEL="$model"
export ANTHROPIC_DEFAULT_FABLE_MODEL="\$ANTHROPIC_MODEL"
export ANTHROPIC_DEFAULT_OPUS_MODEL="\$ANTHROPIC_MODEL"
export ANTHROPIC_DEFAULT_SONNET_MODEL="\$ANTHROPIC_MODEL"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="\$ANTHROPIC_MODEL"
export CLAUDE_CODE_SUBAGENT_MODEL="\$ANTHROPIC_MODEL"
export CLAUDE_CODE_EFFORT_LEVEL="max"
export ENABLE_TOOL_SEARCH="false"
export CLAUDE_CODE_AUTO_COMPACT_WINDOW="$context"
export CLAUDE_CODE_MAX_CONTEXT_TOKENS="$context"
exec "\$HOME/.local/bin/claude" "\$@"
EOF
chmod 700 "$launcher"

echo "Installed $launcher - run $name for the local model; claude still uses the Anthropic API."
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) echo "note: $HOME/.local/bin is not on your PATH, so '$name' will not be found by name yet." ;;
esac
