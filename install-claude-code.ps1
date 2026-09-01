# Install Claude Code and a launcher that points it at a local model.
# https://github.com/pddekock/claude_code
#
#   install-claude-code.ps1 <launcher-name> <base-url> <auth-token> <model> <context-tokens>
param([string]$LauncherName, [string]$BaseUrl, [string]$AuthToken, [string]$Model, [string]$ContextTokens)

# -cnotmatch, not -notmatch: PowerShell's normal operators are case-insensitive
# and would accept Ccl / CCL.
if ($LauncherName -cnotmatch '^cc[A-Za-z0-9._-]*$' -or
    $BaseUrl -notmatch '^[A-Za-z0-9:/._~-]+$' -or
    $AuthToken -notmatch '^[A-Za-z0-9._~-]+$' -or
    $Model -notmatch '^[A-Za-z0-9:/._~-]+$' -or
    $ContextTokens -notmatch '^[0-9]+$') {
    Write-Output 'usage: install-claude-code.ps1 <launcher-name> <base-url> <auth-token> <model> <context-tokens>'
    Write-Output '       launcher-name must start with a lowercase cc, e.g. ccl'
    exit 1
}

$bin = "$env:USERPROFILE\.local\bin"
$launcher = "$bin\$LauncherName.cmd"
if ((Test-Path $launcher) -and
    -not (Select-String -Path $launcher -SimpleMatch ':: claude-code local launcher' -Quiet)) {
    Write-Output "$launcher exists and was not created by this installer."
    exit 1
}

$ErrorActionPreference = 'Stop'
try { irm https://claude.ai/install.ps1 | iex } catch {
    Write-Output 'Claude Code installation failed.'
    exit 1
}

if (-not (Test-Path "$bin\claude.exe" -PathType Leaf)) {
    Write-Output 'Claude Code was not installed.'
    exit 1
}

@"
@echo off
:: claude-code local launcher
setlocal
set "ANTHROPIC_BASE_URL=$BaseUrl"
set "ANTHROPIC_AUTH_TOKEN=$AuthToken"
set "ANTHROPIC_MODEL=$Model"
set "ANTHROPIC_DEFAULT_FABLE_MODEL=$Model"
set "ANTHROPIC_DEFAULT_OPUS_MODEL=$Model"
set "ANTHROPIC_DEFAULT_SONNET_MODEL=$Model"
set "ANTHROPIC_DEFAULT_HAIKU_MODEL=$Model"
set "CLAUDE_CODE_SUBAGENT_MODEL=$Model"
set "CLAUDE_CODE_EFFORT_LEVEL=max"
set "ENABLE_TOOL_SEARCH=false"
set "CLAUDE_CODE_AUTO_COMPACT_WINDOW=$ContextTokens"
set "CLAUDE_CODE_MAX_CONTEXT_TOKENS=$ContextTokens"
claude %*
"@ | Set-Content -Path $launcher -Encoding ascii

Write-Output "Installed $launcher - run $LauncherName for the local model; claude still uses the Anthropic API."
