@echo off
:: Remove a local-model launcher. Claude Code itself stays installed.
:: https://github.com/pddekock/claude_code
::
::   uninstall-claude-code.cmd <launcher-name>
setlocal
set "NAME=%~1"
setlocal EnableDelayedExpansion
if not defined NAME goto usage
echo(!NAME!| findstr /r /x "cc[A-Za-z0-9._-]*" >nul || goto usage

set "LAUNCHER=%USERPROFILE%\.local\bin\!NAME!.cmd"
if not exist "!LAUNCHER!" (
    echo !LAUNCHER! does not exist.
    exit /b 1
)
findstr /b /c:":: claude-code local launcher" "!LAUNCHER!" >nul || goto notours

del /f /q "!LAUNCHER!"
echo Removed !LAUNCHER!. Claude Code is still installed.
exit /b 0

:notours
echo !LAUNCHER! was not created by this installer - leaving it alone.
exit /b 1

:usage
echo usage: uninstall-claude-code.cmd ^<launcher-name^>   ^(must start with a lowercase cc^)
exit /b 1
