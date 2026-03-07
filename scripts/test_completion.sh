#!/usr/bin/env bash
# Test bash completion for claude CLI
# Runs structural tests always, and functional tests against real
# bash-completion@2 when available.
set -euo pipefail

SCRIPT="completions/claude.bash"
errors=0
tests=0

_pass() { echo "PASS"; ((tests++)) || true; }
_fail() { echo "FAIL${1:+ ($1)}"; ((errors++)) || true; ((tests++)) || true; }

# ==========================================================================
# Structural tests — always run, no dependencies beyond bash + python3
# ==========================================================================
echo "=== Structural Tests ==="
echo

echo -n "  Bash syntax check: "
if bash -n "$SCRIPT" 2>/dev/null; then _pass; else _fail; fi

echo -n "  Script sources with stubs: "
if bash -c '
    _comp_initialize() { return 0; }
    _comp_compgen() { return 0; }
    _comp_compgen_filedir() { return 0; }
    source "'"$SCRIPT"'"
' 2>/dev/null; then _pass; else _fail; fi

for func in _comp_cmd_claude _comp_cmd_claude__has_command \
            _comp_cmd_claude__complete _comp_cmd_claude__flag_values; do
    echo -n "  Contains function $func: "
    if grep -q "^${func}()" "$SCRIPT"; then _pass; else _fail; fi
done

for subcmd in mcp auth plugin doctor install agents setup-token update upgrade; do
    echo -n "  Contains subcommand '$subcmd': "
    if grep -q "$subcmd" "$SCRIPT"; then _pass; else _fail; fi
done

for flag in --model --output-format --continue --print --resume; do
    echo -n "  Contains flag '$flag': "
    if grep -q -- "$flag" "$SCRIPT"; then _pass; else _fail; fi
done

echo -n "  Registers completion for 'claude': "
if grep -q 'complete -F _comp_cmd_claude claude' "$SCRIPT"; then _pass; else _fail; fi

echo -n "  JSON data is valid: "
if python3 -c "import json; json.load(open('data/claude-completion.json'))" 2>/dev/null; then _pass; else _fail; fi

echo -n "  JSON contains version: "
if python3 -c "import json; d=json.load(open('data/claude-completion.json')); assert 'version' in d" 2>/dev/null; then _pass; else _fail; fi

for cmd_path in "claude" "claude mcp" "claude mcp add" "claude auth" "claude plugin"; do
    echo -n "  JSON has command path '$cmd_path': "
    if python3 -c "import json,sys; d=json.load(open('data/claude-completion.json')); sys.exit(0 if '$cmd_path' in d['commands'] else 1)" 2>/dev/null; then
        _pass
    else
        _fail
    fi
done

# ==========================================================================
# Functional tests — require bash-completion@2
# Sources the real framework, simulates COMP_WORDS, calls our completion
# function, and checks COMPREPLY.
# ==========================================================================
echo
BASH_COMPLETION=""
for candidate in \
    /opt/homebrew/opt/bash-completion@2/share/bash-completion/bash_completion \
    /usr/local/opt/bash-completion@2/share/bash-completion/bash_completion \
    /usr/share/bash-completion/bash_completion \
    /etc/bash_completion; do
    if [[ -f "$candidate" ]]; then
        BASH_COMPLETION="$candidate"
        break
    fi
done

if [[ -z "$BASH_COMPLETION" ]]; then
    echo "=== Functional Tests: SKIPPED (bash-completion@2 not found) ==="
    echo
    echo "  Install bash-completion@2 to run functional tests:"
    echo "    macOS:  brew install bash-completion@2"
    echo "    Linux:  apt-get install bash-completion"
else
    echo "=== Functional Tests (using $BASH_COMPLETION) ==="
    echo

    # Run all functional tests inside a single bash process that has the real
    # bash-completion library loaded. This avoids repeated process spawning and
    # ensures we test against the actual framework.
    #
    # The inner script defines get_completions() which sets up COMP_* vars
    # exactly as readline would, then calls our completion function.
    # Each assert_has / assert_not_empty prints a PASS/FAIL line.
    # The final line is "SUMMARY:<tests>:<errors>" which we parse.

    functional_output=$(bash -s "$BASH_COMPLETION" "$SCRIPT" << 'FUNCTIONAL_EOF'
source "$1"
source "$2"

ft_errors=0
ft_tests=0

# Simulate tab completion. Arguments become COMP_WORDS elements.
# The last argument is the word being completed (use "" for empty).
get_completions() {
    COMP_WORDS=("$@")
    COMP_CWORD=$(( $# - 1 ))
    COMP_LINE="${COMP_WORDS[*]}"
    COMP_POINT=${#COMP_LINE}
    COMPREPLY=()
    _comp_cmd_claude \
        "${COMP_WORDS[0]}" \
        "${COMP_WORDS[$COMP_CWORD]}" \
        "${COMP_WORDS[$((COMP_CWORD - 1))]}" 2>/dev/null || true
}

assert_has() {
    local desc="$1" expected="$2"
    shift 2
    get_completions "$@"
    ((ft_tests++))
    local r
    for r in "${COMPREPLY[@]}"; do
        if [[ "$r" == "$expected" ]]; then
            echo "  $desc: PASS"
            return
        fi
    done
    echo "  $desc: FAIL (expected '$expected' in: ${COMPREPLY[*]:-<empty>})"
    ((ft_errors++)) || true
}

assert_not_empty() {
    local desc="$1"
    shift
    get_completions "$@"
    ((ft_tests++))
    if (( ${#COMPREPLY[@]} > 0 )); then
        echo "  $desc: PASS (${#COMPREPLY[@]} completions)"
    else
        echo "  $desc: FAIL (empty)"
        ((ft_errors++)) || true
    fi
}

# --- Top-level subcommand completion ---
assert_has     "claude <TAB> -> mcp"                 "mcp"      claude ""
assert_has     "claude <TAB> -> auth"                "auth"     claude ""
assert_has     "claude <TAB> -> plugin"              "plugin"   claude ""
assert_has     "claude <TAB> -> update"              "update"   claude ""
assert_has     "claude <TAB> -> upgrade"             "upgrade"  claude ""
assert_has     "claude m<TAB> -> mcp"                "mcp"      claude "m"

# --- Top-level flag completion ---
assert_not_empty "claude --<TAB> returns flags"                 claude "--"
assert_has     "claude --<TAB> -> --model"           "--model"          claude "--"
assert_has     "claude --<TAB> -> --output-format"   "--output-format"  claude "--"
assert_has     "claude -<TAB> -> -p"                 "-p"               claude "-"
assert_has     "claude -<TAB> -> -c"                 "-c"               claude "-"

# --- Nested subcommand completion ---
assert_has     "claude mcp <TAB> -> add"             "add"      claude mcp ""
assert_has     "claude mcp <TAB> -> serve"           "serve"    claude mcp ""
assert_has     "claude mcp <TAB> -> remove"          "remove"   claude mcp ""
assert_has     "claude auth <TAB> -> login"          "login"    claude auth ""
assert_has     "claude auth <TAB> -> status"         "status"   claude auth ""

# --- 3-level deep subcommand ---
assert_has     "claude plugin marketplace <TAB> -> add"   "add"   claude plugin marketplace ""
assert_has     "claude plugin marketplace <TAB> -> rm"    "rm"    claude plugin marketplace ""

# --- Subcommand flags ---
assert_has     "claude mcp add --<TAB> -> --scope"       "--scope"     claude mcp add "--"
assert_has     "claude mcp add --<TAB> -> --transport"   "--transport"  claude mcp add "--"
assert_has     "claude mcp add -<TAB> -> -s"             "-s"          claude mcp add "-"
assert_has     "claude mcp add -<TAB> -> -t"             "-t"          claude mcp add "-"

# --- Choice value completion ---
assert_has     "claude --output-format <TAB> -> json"          "json"          claude "--output-format" ""
assert_has     "claude --output-format <TAB> -> text"          "text"          claude "--output-format" ""
assert_has     "claude --output-format <TAB> -> stream-json"   "stream-json"   claude "--output-format" ""
assert_has     "claude --effort <TAB> -> high"                 "high"          claude "--effort" ""
assert_has     "claude --effort <TAB> -> low"                  "low"           claude "--effort" ""
assert_has     "claude --permission-mode <TAB> -> plan"        "plan"          claude "--permission-mode" ""

# --- Scope choices (nested command) ---
assert_has     "claude mcp add --scope <TAB> -> local"     "local"    claude mcp add "--scope" ""
assert_has     "claude mcp add --scope <TAB> -> project"   "project"  claude mcp add "--scope" ""
assert_has     "claude mcp add --scope <TAB> -> user"      "user"     claude mcp add "--scope" ""

# --- Short flag with choices ---
assert_has     "claude mcp add -s <TAB> -> local"          "local"    claude mcp add "-s" ""
assert_has     "claude mcp add -t <TAB> -> stdio"          "stdio"    claude mcp add "-t" ""
assert_has     "claude mcp add -t <TAB> -> http"           "http"     claude mcp add "-t" ""

# --- Alias subcommands work ---
assert_has     "claude plugin <TAB> -> i (alias)"          "i"        claude plugin ""
assert_has     "claude plugin <TAB> -> remove (alias)"     "remove"   claude plugin ""
assert_has     "claude plugin <TAB> -> uninstall"          "uninstall" claude plugin ""

# --- Plugin update scope includes 'managed' ---
assert_has     "claude plugin update --scope <TAB> -> managed"  "managed"  claude plugin update "--scope" ""

echo "SUMMARY:${ft_tests}:${ft_errors}"
FUNCTIONAL_EOF
)

    # Print the test output (everything except the SUMMARY line)
    echo "$functional_output" | grep -v '^SUMMARY:'

    # Parse the summary
    summary_line=$(echo "$functional_output" | grep '^SUMMARY:')
    ft_tests="${summary_line#SUMMARY:}"
    ft_errors="${ft_tests#*:}"
    ft_tests="${ft_tests%%:*}"

    tests=$((tests + ft_tests))
    errors=$((errors + ft_errors))
fi

echo
echo "Results: $tests tests, $errors error(s)"
exit "$errors"
