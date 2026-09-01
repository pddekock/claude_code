# Remove a local-model launcher. Claude Code itself stays installed.
# https://github.com/pddekock/claude_code
#
#   uninstall-claude-code.ps1 <launcher-name>
param([string]$LauncherName)

if ($LauncherName -cnotmatch '^cc[A-Za-z0-9._-]*$') {
    Write-Output 'usage: uninstall-claude-code.ps1 <launcher-name>   (must start with a lowercase cc)'
    exit 1
}

$launcher = "$env:USERPROFILE\.local\bin\$LauncherName.cmd"
if (-not (Test-Path $launcher)) {
    Write-Output "$launcher does not exist."
    exit 1
}
if (-not (Select-String -Path $launcher -SimpleMatch ':: claude-code local launcher' -Quiet)) {
    Write-Output "$launcher was not created by this installer - leaving it alone."
    exit 1
}

Remove-Item $launcher -Force
Write-Output "Removed $launcher. Claude Code is still installed."
