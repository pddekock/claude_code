# claude_code

Install [Claude Code](https://claude.com/claude-code) and generate a small
launcher that points it at a local OpenAI-compatible endpoint.

The launcher sets its environment for that run only. So `ccl` (or whatever you
name it) talks to your local model, while plain `claude` still uses the Anthropic
API. Nothing is written to your shell startup files, and no administrator rights
are needed.

## Usage

```
install-claude-code.{sh,ps1,cmd}    <launcher-name> <base-url> <auth-token> <model> <context-tokens>
uninstall-claude-code.{sh,ps1,cmd}  <launcher-name>
```

All five installer arguments are **required** — no endpoint, token or model is
stored in this repository.

| Argument | Rule | Example |
|---|---|---|
| `launcher-name` | must start with a lowercase `cc`; letters, digits, `.` `_` `-` | `ccl` |
| `base-url` | your OpenAI-compatible endpoint | `http://your-server:12434/engines/v1` |
| `auth-token` | must be non-empty, even if your server ignores it | `your-token` |
| `model` | a model id your server actually serves | `local/qwen3-30b:q4` |
| `context-tokens` | digits only; sets both context variables | `262144` |

The `cc` prefix is a safety rule, not a style choice: it stops the launcher from
being named `claude` (which would overwrite the real binary and then recurse into
itself) or a Windows device name like `CON` or `NUL`.

## Install

Replace the example values with your own.

**macOS / Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/pddekock/claude_code/main/install-claude-code.sh \
  | bash -s -- ccl http://your-server:12434/engines/v1 your-token local/qwen3-30b:q4 262144
```

**Windows — PowerShell**

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/pddekock/claude_code/main/install-claude-code.ps1))) ccl http://your-server:12434/engines/v1 your-token local/qwen3-30b:q4 262144
```

`irm ... | iex` cannot forward arguments, which is why the script is wrapped in a
scriptblock.

**Windows — cmd.exe**

```bat
curl -fsSL https://raw.githubusercontent.com/pddekock/claude_code/main/install-claude-code.cmd -o install-claude-code.cmd && install-claude-code.cmd ccl http://your-server:12434/engines/v1 your-token local/qwen3-30b:q4 262144 && del install-claude-code.cmd
```

This one is **cmd.exe only** — `&&` is not a statement separator in Windows
PowerShell. From a PowerShell prompt, either use the PowerShell command above, or
wrap it: `cmd /c "..."`.

**From a clone**

```bash
git clone https://github.com/pddekock/claude_code.git && cd claude_code
./install-claude-code.sh ccl http://your-server:12434/engines/v1 your-token local/qwen3-30b:q4 262144
```

Then open a new terminal and run `ccl`. It takes the same arguments as `claude`:

```bash
ccl                       # interactive session against the local model
ccl -p "explain this"     # everything is forwarded through
claude                    # unchanged: still the Anthropic API
```

## What the launcher contains

The generated launcher is a dozen lines. It sets these, then execs `claude`:

```text
ANTHROPIC_BASE_URL               <base-url argument>
ANTHROPIC_AUTH_TOKEN             <auth-token argument>
ANTHROPIC_MODEL                  <model argument>
ANTHROPIC_DEFAULT_FABLE_MODEL    <model argument>
ANTHROPIC_DEFAULT_OPUS_MODEL     <model argument>
ANTHROPIC_DEFAULT_SONNET_MODEL   <model argument>
ANTHROPIC_DEFAULT_HAIKU_MODEL    <model argument>
CLAUDE_CODE_SUBAGENT_MODEL       <model argument>
CLAUDE_CODE_EFFORT_LEVEL         max
ENABLE_TOOL_SEARCH               false
CLAUDE_CODE_AUTO_COMPACT_WINDOW  <context-tokens argument>
CLAUDE_CODE_MAX_CONTEXT_TOKENS   <context-tokens argument>
```

Every model alias points at your one local model, so whatever Claude Code asks
for resolves to it. `CLAUDE_CODE_EFFORT_LEVEL=max` and `ENABLE_TOOL_SEARCH=false`
are fixed: a small local model needs the help, and it copes badly with deferred
tool search.

It invokes `claude` by absolute path, so it keeps working even if that directory
is not on your `PATH`.

Written to `~/.local/bin/<name>` (mode 700), or
`%USERPROFILE%\.local\bin\<name>.cmd` on Windows — the same directory the
official installer puts `claude` in.

## PATH

You need `~/.local/bin` on your `PATH` to run the launcher *by name*.

- **Windows**: the official installer does **not** add it, so this installer
  does — prepended to your **user** `PATH` only when it is missing, via
  `[Environment]::SetEnvironmentVariable(..., 'User')`. No admin rights, nothing
  machine-wide. **Restart your terminal** afterwards; an already-open console
  keeps its old environment. (`setx` is deliberately avoided: it silently
  truncates a `PATH` longer than 1024 characters.)
- **macOS / Linux**: the official installer adds it to your shell rc, and these
  scripts do not touch your rc files. If it is somehow absent, the installer
  says so and you add it yourself.

To change the endpoint or model, edit that file, or just re-run the installer:
re-running replaces a launcher it created earlier.

Each generated launcher carries a marker comment, and the scripts refuse to
overwrite or delete a file that lacks it. So naming your launcher `ccache` will
fail safely rather than destroying the real `ccache`.

## Multiple launchers

Nothing stops you installing several against one Claude Code install:

```bash
./install-claude-code.sh ccbig  http://your-server:12434/engines/v1 your-token local/qwen3-235b:q4 262144
./install-claude-code.sh ccfast http://your-server:12434/engines/v1 your-token local/qwen3-8b:q8  131072
```

## Uninstall

Removes **only** the named launcher. Claude Code stays installed, and your
settings in `~/.claude` are untouched.

```bash
./uninstall-claude-code.sh ccl
```
```powershell
.\uninstall-claude-code.ps1 ccl
```
```bat
uninstall-claude-code.cmd ccl
```

To remove Claude Code itself, delete `~/.local/bin/claude` and
`~/.local/share/claude` (`%USERPROFILE%\.local\bin\claude.exe` and
`%USERPROFILE%\.local\share\claude` on Windows).

## Troubleshooting

**`The token '&&' is not a valid statement separator`** — you ran the cmd.exe
command in PowerShell. Use the PowerShell command above.

**`A parameter cannot be found that matches parameter name 'fsSL'`** — in Windows
PowerShell 5.1 `curl` is an alias for `Invoke-WebRequest`. Use `curl.exe`.

**Usage message instead of an install** — an argument failed validation. The
usual causes: the launcher name does not start with `cc`, the context is not
digits, or fewer than five arguments were supplied.

**`<path> exists and was not created by this installer`** — something else owns
that filename. Pick a different launcher name.

**`'ccl' is not recognized as an internal or external command`** — `PATH` changes only reach new
terminals. Open a new one. If it still fails, confirm `~/.local/bin`
(`%USERPROFILE%\.local\bin`) is on your `PATH`; on Windows you can check with
`reg query HKCU\Environment /v PATH`. You can always call the launcher by its
full path in the meantime.

**Claude Code reports `Native installation exists but ... is not in your PATH`** —
that is the condition above. Re-run the installer, or add the directory by hand:
System Properties → Environment Variables → Edit user `PATH` → New.

**Model not found from the server** — `model` must match an id your server
serves:

```bash
curl -s -H "Authorization: Bearer <auth-token>" <base-url>/models | jq -r '.data[].id'
```

**Context overflows or truncated replies** — lower `context-tokens` to match the
context your server was started with.

## Notes

- Arguments are restricted to a conservative character set and rejected before
  anything is installed, which is why no shell escaping is needed anywhere.
- The token is passed on the command line, so it lands in your shell history and
  is briefly visible in the process table. Fine for a local dev token.
- `.ps1` and `.cmd` files must keep CRLF line endings — `cmd.exe` mis-parses
  LF-only batch files. `.gitattributes` enforces this.
