@echo off
:: Install Claude Code and a launcher that points it at a local model.
:: https://github.com/pddekock/claude_code
::
::   install-claude-code.cmd <launcher-name> <base-url> <auth-token> <model> <context-tokens>
setlocal

:: Captured before delayed expansion, so a "!" cannot be eaten before validation.
set "NAME=%~1"
set "URL=%~2"
set "TOKEN=%~3"
set "MODEL=%~4"
set "CONTEXT=%~5"
setlocal EnableDelayedExpansion
if not defined NAME goto usage
if not defined URL goto usage
if not defined TOKEN goto usage
if not defined MODEL goto usage
if not defined CONTEXT goto usage
echo(!NAME!| findstr /r /x "cc[A-Za-z0-9._-]*" >nul || goto usage
echo(!URL!| findstr /r /x "[A-Za-z0-9:/._~-][A-Za-z0-9:/._~-]*" >nul || goto usage
echo(!TOKEN!| findstr /r /x "[A-Za-z0-9._~-][A-Za-z0-9._~-]*" >nul || goto usage
echo(!MODEL!| findstr /r /x "[A-Za-z0-9:/._~-][A-Za-z0-9:/._~-]*" >nul || goto usage
echo(!CONTEXT!| findstr /r /x "[0-9][0-9]*" >nul || goto usage

set "BIN=%USERPROFILE%\.local\bin"
set "LAUNCHER=!BIN!\!NAME!.cmd"

:: Never clobber a file this installer did not create - checked before installing.
if exist "!LAUNCHER!" findstr /b /c:":: claude-code local launcher" "!LAUNCHER!" >nul || goto owned

:: Downloaded into %TEMP% so it cannot clobber this script.
pushd "%TEMP%"
curl -fsSL https://claude.ai/install.cmd -o install.cmd || goto fail
call install.cmd
if errorlevel 1 goto fail
if not exist "!BIN!\claude.exe" goto fail
del install.cmd
popd

> "!LAUNCHER!.new" (
    echo @echo off
    echo :: claude-code local launcher
    echo setlocal
    echo set "ANTHROPIC_BASE_URL=!URL!"
    echo set "ANTHROPIC_AUTH_TOKEN=!TOKEN!"
    echo set "ANTHROPIC_MODEL=!MODEL!"
    echo set "ANTHROPIC_DEFAULT_FABLE_MODEL=!MODEL!"
    echo set "ANTHROPIC_DEFAULT_OPUS_MODEL=!MODEL!"
    echo set "ANTHROPIC_DEFAULT_SONNET_MODEL=!MODEL!"
    echo set "ANTHROPIC_DEFAULT_HAIKU_MODEL=!MODEL!"
    echo set "CLAUDE_CODE_SUBAGENT_MODEL=!MODEL!"
    echo set "CLAUDE_CODE_EFFORT_LEVEL=max"
    echo set "ENABLE_TOOL_SEARCH=false"
    echo set "CLAUDE_CODE_AUTO_COMPACT_WINDOW=!CONTEXT!"
    echo set "CLAUDE_CODE_MAX_CONTEXT_TOKENS=!CONTEXT!"
    echo "%%USERPROFILE%%\.local\bin\claude.exe" %%*
)
:: The final line is the proof the whole file landed.
findstr /c:"claude.exe" "!LAUNCHER!.new" >nul || goto writefail
move /y "!LAUNCHER!.new" "!LAUNCHER!" >nul || goto writefail

:: The official Windows installer does not put this on PATH, so do it here.
:: Delegated to PowerShell rather than setx: setx silently truncates a PATH
:: longer than 1024 characters. User scope only - no admin, nothing machine-wide.
powershell -NoProfile -Command "$b = $env:USERPROFILE + '\.local\bin'; $p = [Environment]::GetEnvironmentVariable('PATH','User'); if (($p -split ';') -notcontains $b) { if ($p) { $n = $b + ';' + $p } else { $n = $b }; [Environment]::SetEnvironmentVariable('PATH', $n, 'User'); Write-Output ('Added ' + $b + ' to your user PATH - restart your terminal for it to take effect.') }"
if errorlevel 1 echo Could not update PATH automatically - add !BIN! to your user PATH by hand.

echo Installed !LAUNCHER! - run !NAME! for the local model; claude still uses the Anthropic API.
exit /b 0

:usage
echo usage: install-claude-code.cmd ^<launcher-name^> ^<base-url^> ^<auth-token^> ^<model^> ^<context-tokens^>
echo        launcher-name must start with a lowercase cc, e.g. ccl
exit /b 1

:owned
echo !LAUNCHER! exists and was not created by this installer.
exit /b 1

:fail
del install.cmd >nul 2>&1
popd
echo Claude Code installation failed.
exit /b 1

:writefail
del "!LAUNCHER!.new" >nul 2>&1
echo Failed to write !LAUNCHER! - any existing launcher was left untouched.
exit /b 1
