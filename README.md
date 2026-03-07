# claude-completion

Bash completion for the [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI (`claude`).

Requires [bash-completion@2](https://github.com/scop/bash-completion).

## Installation

### Homebrew (recommended)

```bash
brew install cblecker/tap/claude-completion
```

### Manual

Copy `completions/claude.bash` to your bash-completion directory:

```bash
# macOS with Homebrew bash-completion@2
cp completions/claude.bash "$(brew --prefix)/etc/bash_completion.d/claude"

# Linux
sudo cp completions/claude.bash /usr/share/bash-completion/completions/claude
```

Then start a new shell or source the file:

```bash
source "$(brew --prefix)/etc/bash_completion.d/claude"
```

## What it completes

- Subcommands: `claude mcp<TAB>` → `mcp`
- Nested subcommands: `claude mcp <TAB>` → `add`, `list`, `remove`, ...
- Flags: `claude --mo<TAB>` → `--model`
- Flag values with choices: `claude --output-format <TAB>` → `text`, `json`, `stream-json`
- Scope choices: `claude mcp add --scope <TAB>` → `local`, `user`, `project`
- Directory completion: `claude --add-dir <TAB>` → directories
- File completion: `claude --debug-file <TAB>` → files
- Command aliases: `update`/`upgrade`, `install`/`i`, `uninstall`/`remove`, `remove`/`rm`

## How it works

```
claude --help  ──▶  parse_help.py  ──▶  claude-completion.json  ──▶  generate_completion.py  ──▶  claude.bash
```

1. **Parser** (`scripts/parse_help.py`) recursively runs `claude [subcmd...] --help` and extracts flags, subcommands, aliases, and choices into structured JSON
2. **Generator** (`scripts/generate_completion.py`) reads the JSON and produces a bash-completion@2 compatible script
3. **GitHub Actions** runs on a cron schedule, detects new Claude Code releases via npm, and opens PRs with updated completion data

This separation means automated PRs only change the JSON data file, making diffs easy to review.

## Development

```bash
# Parse live CLI help into JSON (requires claude CLI)
make parse

# Generate completion script from JSON
make generate

# Parse + generate
make update

# Validate JSON and bash syntax
make validate

# Run tests
make test

# Verify generated script matches data (catches manual edits)
make verify-generation
```

## License

[MIT](LICENSE)
