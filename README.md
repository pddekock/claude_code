# claude_code

Install Claude Code with a small launcher for an OpenAI-compatible local model.

## Install

**macOS / Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/pddekock/claude_code/main/install-claude-code.sh | bash -s -- http://example.local:12434/engines/v1 your-token
```

**Windows — PowerShell**

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/pddekock/claude_code/main/install-claude-code.ps1))) http://example.local:12434/engines/v1 your-token
```

**Windows — cmd**

```bat
curl -fsSL https://raw.githubusercontent.com/pddekock/claude_code/main/install-claude-code.cmd -o install-claude-code.cmd && install-claude-code.cmd http://example.local:12434/engines/v1 your-token && del install-claude-code.cmd
```

Use `ccl` for the local model. `claude` still uses the Anthropic API.

Both arguments are required. They are restricted to letters, digits and
`: / . _ ~ -` (the token drops `:` and `/`); anything else is rejected and
nothing is installed.

## Configuration reference

```text
ANTHROPIC_BASE_URL               installer argument
ANTHROPIC_AUTH_TOKEN             installer argument
ANTHROPIC_MODEL                  local/qwen3.6-35b-a3b:q4
ANTHROPIC_DEFAULT_FABLE_MODEL    local/qwen3.6-35b-a3b:q4
ANTHROPIC_DEFAULT_OPUS_MODEL     local/qwen3.6-35b-a3b:q4
ANTHROPIC_DEFAULT_SONNET_MODEL   local/qwen3.6-35b-a3b:q4
ANTHROPIC_DEFAULT_HAIKU_MODEL    local/qwen3.6-35b-a3b:q4
CLAUDE_CODE_SUBAGENT_MODEL       local/qwen3.6-35b-a3b:q4
CLAUDE_CODE_EFFORT_LEVEL         max
ENABLE_TOOL_SEARCH               false
CLAUDE_CODE_AUTO_COMPACT_WINDOW  262144
CLAUDE_CODE_MAX_CONTEXT_TOKENS   262144
```

The installer writes `ccl` beside `claude`; it does not edit shell startup files,
the registry, or `PATH`, and never needs administrator rights. Re-running it
replaces the launcher.

## Uninstall

The uninstallers remove Claude Code and `ccl`, but keep `~/.claude`.

```bash
curl -fsSL https://raw.githubusercontent.com/pddekock/claude_code/main/uninstall-claude-code.sh | bash
```

On Windows, run `uninstall-claude-code.ps1` or `uninstall-claude-code.cmd`.
