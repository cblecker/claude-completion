# claude bash completion                                   -*- shell-script -*-
# Generated from Claude Code v2.1.153
# https://github.com/cblecker/claude-completion
# Requires bash-completion@2

# Compatibility shim for bash-completion 2.11 (Ubuntu 24.04) vs 2.12+
if ! declare -F _comp_initialize >/dev/null 2>&1; then
    _comp_initialize() { _init_completion "$@"; }
    _comp_compgen() { shift; COMPREPLY=($(compgen "$@")); }
    _comp_compgen_filedir() { _filedir "$@"; }
fi

_comp_cmd_claude()
{
    local cur prev words cword was_split
    _comp_initialize -s -- "$@" || return

    # Walk words to find deepest matching subcommand path
    local cmd_path="claude"
    local i
    for ((i = 1; i < cword; i++)); do
        case "${words[i]}" in
            -*) continue ;;
            *)
                local try="${cmd_path} ${words[i]}"
                if _comp_cmd_claude__has_command "$try"; then
                    cmd_path="$try"
                fi
                ;;
        esac
    done

    # Handle flag value completion
    if _comp_cmd_claude__flag_values "$cmd_path"; then
        return
    fi

    # After --flag=value split, don't suggest more completions
    [[ $was_split ]] && return

    _comp_cmd_claude__complete "$cmd_path"
}

_comp_cmd_claude__has_command()
{
    case "$1" in
        "claude agents") return 0 ;;
        "claude auth") return 0 ;;
        "claude auth login") return 0 ;;
        "claude auth logout") return 0 ;;
        "claude auth status") return 0 ;;
        "claude auto-mode") return 0 ;;
        "claude auto-mode config") return 0 ;;
        "claude auto-mode critique") return 0 ;;
        "claude auto-mode defaults") return 0 ;;
        "claude doctor") return 0 ;;
        "claude install") return 0 ;;
        "claude mcp") return 0 ;;
        "claude mcp add") return 0 ;;
        "claude mcp add-from-claude-desktop") return 0 ;;
        "claude mcp add-json") return 0 ;;
        "claude mcp get") return 0 ;;
        "claude mcp list") return 0 ;;
        "claude mcp remove") return 0 ;;
        "claude mcp reset-project-choices") return 0 ;;
        "claude mcp serve") return 0 ;;
        "claude plugin") return 0 ;;
        "claude plugin autoremove") return 0 ;;
        "claude plugin details") return 0 ;;
        "claude plugin disable") return 0 ;;
        "claude plugin enable") return 0 ;;
        "claude plugin i") return 0 ;;
        "claude plugin install") return 0 ;;
        "claude plugin list") return 0 ;;
        "claude plugin marketplace") return 0 ;;
        "claude plugin marketplace add") return 0 ;;
        "claude plugin marketplace list") return 0 ;;
        "claude plugin marketplace remove") return 0 ;;
        "claude plugin marketplace rm") return 0 ;;
        "claude plugin marketplace update") return 0 ;;
        "claude plugin prune") return 0 ;;
        "claude plugin remove") return 0 ;;
        "claude plugin tag") return 0 ;;
        "claude plugin uninstall") return 0 ;;
        "claude plugin update") return 0 ;;
        "claude plugin validate") return 0 ;;
        "claude plugins") return 0 ;;
        "claude plugins autoremove") return 0 ;;
        "claude plugins details") return 0 ;;
        "claude plugins disable") return 0 ;;
        "claude plugins enable") return 0 ;;
        "claude plugins i") return 0 ;;
        "claude plugins install") return 0 ;;
        "claude plugins list") return 0 ;;
        "claude plugins marketplace") return 0 ;;
        "claude plugins marketplace add") return 0 ;;
        "claude plugins marketplace list") return 0 ;;
        "claude plugins marketplace remove") return 0 ;;
        "claude plugins marketplace rm") return 0 ;;
        "claude plugins marketplace update") return 0 ;;
        "claude plugins prune") return 0 ;;
        "claude plugins remove") return 0 ;;
        "claude plugins tag") return 0 ;;
        "claude plugins uninstall") return 0 ;;
        "claude plugins update") return 0 ;;
        "claude plugins validate") return 0 ;;
        "claude project") return 0 ;;
        "claude project purge") return 0 ;;
        "claude setup-token") return 0 ;;
        "claude ultrareview") return 0 ;;
        "claude update") return 0 ;;
        "claude upgrade") return 0 ;;
        *) return 1 ;;
    esac
}

_comp_cmd_claude__complete()
{
    # Stop suggesting flags after -- separator
    local i
    for ((i = 1; i < cword; i++)); do
        if [[ "${words[i]}" == "--" ]]; then
            return
        fi
    done

    case "$1" in
        "claude")
            if [[ "$cur" == -* ]]; then
                _comp_compgen -- -W "--add-dir --agent --agents --allow-dangerously-skip-permissions --append-system-prompt --bare --betas --brief --chrome --continue --dangerously-skip-permissions --debug --debug-file --disable-slash-commands --effort --fallback-model --file --fork-session --from-pr --help --ide --include-hook-events --include-partial-messages --input-format --json-schema --max-budget-usd --mcp-config --mcp-debug --model --name --no-chrome --no-session-persistence --output-format --permission-mode --plugin-dir --plugin-url --print --remote-control --replay-user-messages --resume --session-id --setting-sources --settings --strict-mcp-config --system-prompt --tmux --tools --verbose --version --worktree -c -d -h -n -p -r -v -w"
            else
                _comp_compgen -- -W "agents auth auto-mode doctor install mcp plugin plugins project setup-token ultrareview update upgrade"
            fi
            ;;
        "claude agents")
            _comp_compgen -- -W "--add-dir --allow-dangerously-skip-permissions --cwd --dangerously-skip-permissions --effort --help --json --mcp-config --model --permission-mode --plugin-dir --setting-sources --settings --strict-mcp-config -h"
            ;;
        "claude auth")
            if [[ "$cur" == -* ]]; then
                _comp_compgen -- -W "--help -h"
            else
                _comp_compgen -- -W "login logout status"
            fi
            ;;
        "claude auth login")
            _comp_compgen -- -W "--claudeai --console --email --help --sso -h"
            ;;
        "claude auth logout")
            _comp_compgen -- -W "--help -h"
            ;;
        "claude auth status")
            _comp_compgen -- -W "--help --json --text -h"
            ;;
        "claude auto-mode")
            if [[ "$cur" == -* ]]; then
                _comp_compgen -- -W "--help -h"
            else
                _comp_compgen -- -W "config critique defaults"
            fi
            ;;
        "claude auto-mode config")
            _comp_compgen -- -W "--help -h"
            ;;
        "claude auto-mode critique")
            _comp_compgen -- -W "--help --model -h"
            ;;
        "claude auto-mode defaults")
            _comp_compgen -- -W "--help -h"
            ;;
        "claude doctor")
            _comp_compgen -- -W "--help -h"
            ;;
        "claude install")
            _comp_compgen -- -W "--force --help -h"
            ;;
        "claude mcp")
            if [[ "$cur" == -* ]]; then
                _comp_compgen -- -W "--help -h"
            else
                _comp_compgen -- -W "add add-from-claude-desktop add-json get list remove reset-project-choices serve"
            fi
            ;;
        "claude mcp add")
            _comp_compgen -- -W "--callback-port --client-id --client-secret --env --header --help --scope --transport -H -e -h -s -t"
            ;;
        "claude mcp add-from-claude-desktop")
            _comp_compgen -- -W "--help --scope -h -s"
            ;;
        "claude mcp add-json")
            _comp_compgen -- -W "--client-secret --help --scope -h -s"
            ;;
        "claude mcp get")
            _comp_compgen -- -W "--help -h"
            ;;
        "claude mcp list")
            _comp_compgen -- -W "--help -h"
            ;;
        "claude mcp remove")
            _comp_compgen -- -W "--help --scope -h -s"
            ;;
        "claude mcp reset-project-choices")
            _comp_compgen -- -W "--help -h"
            ;;
        "claude mcp serve")
            _comp_compgen -- -W "--debug --help --verbose -d -h"
            ;;
        "claude plugin")
            if [[ "$cur" == -* ]]; then
                _comp_compgen -- -W "--help -h"
            else
                _comp_compgen -- -W "autoremove details disable enable i install list marketplace prune remove tag uninstall update validate"
            fi
            ;;
        "claude plugin autoremove")
            _comp_compgen -- -W "--dry-run --help --scope --yes -h -s -y"
            ;;
        "claude plugin details")
            _comp_compgen -- -W "--help -h"
            ;;
        "claude plugin disable")
            _comp_compgen -- -W "--all --help --scope -a -h -s"
            ;;
        "claude plugin enable")
            _comp_compgen -- -W "--help --scope -h -s"
            ;;
        "claude plugin i")
            _comp_compgen -- -W "--config --help --scope -h -s"
            ;;
        "claude plugin install")
            _comp_compgen -- -W "--config --help --scope -h -s"
            ;;
        "claude plugin list")
            _comp_compgen -- -W "--available --help --json -h"
            ;;
        "claude plugin marketplace")
            if [[ "$cur" == -* ]]; then
                _comp_compgen -- -W "--help -h"
            else
                _comp_compgen -- -W "add list remove rm update"
            fi
            ;;
        "claude plugin marketplace add")
            _comp_compgen -- -W "--help --scope --sparse -h"
            ;;
        "claude plugin marketplace list")
            _comp_compgen -- -W "--help --json -h"
            ;;
        "claude plugin marketplace remove")
            _comp_compgen -- -W "--help --scope -h"
            ;;
        "claude plugin marketplace rm")
            _comp_compgen -- -W "--help --scope -h"
            ;;
        "claude plugin marketplace update")
            _comp_compgen -- -W "--help -h"
            ;;
        "claude plugin prune")
            _comp_compgen -- -W "--dry-run --help --scope --yes -h -s -y"
            ;;
        "claude plugin remove")
            _comp_compgen -- -W "--help --keep-data --prune --scope --yes -h -s -y"
            ;;
        "claude plugin tag")
            _comp_compgen -- -W "--dry-run --force --help --message --push --remote -f -h -m"
            ;;
        "claude plugin uninstall")
            _comp_compgen -- -W "--help --keep-data --prune --scope --yes -h -s -y"
            ;;
        "claude plugin update")
            _comp_compgen -- -W "--help --scope -h -s"
            ;;
        "claude plugin validate")
            _comp_compgen -- -W "--help --strict -h"
            ;;
        "claude plugins")
            if [[ "$cur" == -* ]]; then
                _comp_compgen -- -W "--help -h"
            else
                _comp_compgen -- -W "autoremove details disable enable i install list marketplace prune remove tag uninstall update validate"
            fi
            ;;
        "claude plugins autoremove")
            _comp_compgen -- -W "--dry-run --help --scope --yes -h -s -y"
            ;;
        "claude plugins details")
            _comp_compgen -- -W "--help -h"
            ;;
        "claude plugins disable")
            _comp_compgen -- -W "--all --help --scope -a -h -s"
            ;;
        "claude plugins enable")
            _comp_compgen -- -W "--help --scope -h -s"
            ;;
        "claude plugins i")
            _comp_compgen -- -W "--config --help --scope -h -s"
            ;;
        "claude plugins install")
            _comp_compgen -- -W "--config --help --scope -h -s"
            ;;
        "claude plugins list")
            _comp_compgen -- -W "--available --help --json -h"
            ;;
        "claude plugins marketplace")
            if [[ "$cur" == -* ]]; then
                _comp_compgen -- -W "--help -h"
            else
                _comp_compgen -- -W "add list remove rm update"
            fi
            ;;
        "claude plugins marketplace add")
            _comp_compgen -- -W "--help --scope --sparse -h"
            ;;
        "claude plugins marketplace list")
            _comp_compgen -- -W "--help --json -h"
            ;;
        "claude plugins marketplace remove")
            _comp_compgen -- -W "--help --scope -h"
            ;;
        "claude plugins marketplace rm")
            _comp_compgen -- -W "--help --scope -h"
            ;;
        "claude plugins marketplace update")
            _comp_compgen -- -W "--help -h"
            ;;
        "claude plugins prune")
            _comp_compgen -- -W "--dry-run --help --scope --yes -h -s -y"
            ;;
        "claude plugins remove")
            _comp_compgen -- -W "--help --keep-data --prune --scope --yes -h -s -y"
            ;;
        "claude plugins tag")
            _comp_compgen -- -W "--dry-run --force --help --message --push --remote -f -h -m"
            ;;
        "claude plugins uninstall")
            _comp_compgen -- -W "--help --keep-data --prune --scope --yes -h -s -y"
            ;;
        "claude plugins update")
            _comp_compgen -- -W "--help --scope -h -s"
            ;;
        "claude plugins validate")
            _comp_compgen -- -W "--help --strict -h"
            ;;
        "claude project")
            if [[ "$cur" == -* ]]; then
                _comp_compgen -- -W "--help -h"
            else
                _comp_compgen -- -W "purge"
            fi
            ;;
        "claude project purge")
            _comp_compgen -- -W "--all --dry-run --help --interactive --yes -h -i -y"
            ;;
        "claude setup-token")
            _comp_compgen -- -W "--help -h"
            ;;
        "claude ultrareview")
            _comp_compgen -- -W "--help --json --timeout -h"
            ;;
        "claude update")
            _comp_compgen -- -W "--help -h"
            ;;
        "claude upgrade")
            _comp_compgen -- -W "--help -h"
            ;;
    esac
}

_comp_cmd_claude__flag_values()
{
    case "$1" in
        "claude")
            case "$prev" in
                --add-dir)
                    _comp_compgen_filedir -d
                    return 0
                    ;;
                --agent)
                    return 0
                    ;;
                --agents)
                    return 0
                    ;;
                --append-system-prompt)
                    return 0
                    ;;
                --betas)
                    return 0
                    ;;
                --debug-file)
                    _comp_compgen_filedir
                    return 0
                    ;;
                --effort)
                    _comp_compgen -- -W "low medium high xhigh max"
                    return 0
                    ;;
                --fallback-model)
                    return 0
                    ;;
                --file)
                    return 0
                    ;;
                --input-format)
                    _comp_compgen -- -W "text stream-json"
                    return 0
                    ;;
                --json-schema)
                    return 0
                    ;;
                --max-budget-usd)
                    return 0
                    ;;
                --mcp-config)
                    return 0
                    ;;
                --model)
                    return 0
                    ;;
                --name|-n)
                    return 0
                    ;;
                --output-format)
                    _comp_compgen -- -W "text json stream-json"
                    return 0
                    ;;
                --permission-mode)
                    _comp_compgen -- -W "acceptEdits auto bypassPermissions default dontAsk plan"
                    return 0
                    ;;
                --plugin-dir)
                    _comp_compgen_filedir -d
                    return 0
                    ;;
                --plugin-url)
                    return 0
                    ;;
                --session-id)
                    return 0
                    ;;
                --setting-sources)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
                --settings)
                    _comp_compgen_filedir
                    return 0
                    ;;
                --system-prompt)
                    return 0
                    ;;
                --tools)
                    return 0
                    ;;
            esac
            ;;
        "claude agents")
            case "$prev" in
                --add-dir)
                    _comp_compgen_filedir -d
                    return 0
                    ;;
                --cwd)
                    _comp_compgen_filedir
                    return 0
                    ;;
                --effort)
                    return 0
                    ;;
                --mcp-config)
                    return 0
                    ;;
                --model)
                    return 0
                    ;;
                --permission-mode)
                    return 0
                    ;;
                --plugin-dir)
                    _comp_compgen_filedir -d
                    return 0
                    ;;
                --setting-sources)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
                --settings)
                    _comp_compgen_filedir
                    return 0
                    ;;
            esac
            ;;
        "claude auth login")
            case "$prev" in
                --email)
                    return 0
                    ;;
            esac
            ;;
        "claude auto-mode critique")
            case "$prev" in
                --model)
                    return 0
                    ;;
            esac
            ;;
        "claude mcp add")
            case "$prev" in
                --callback-port)
                    return 0
                    ;;
                --client-id)
                    return 0
                    ;;
                --env|-e)
                    return 0
                    ;;
                --header|-H)
                    return 0
                    ;;
                --scope|-s)
                    _comp_compgen -- -W "local user project"
                    return 0
                    ;;
                --transport|-t)
                    _comp_compgen -- -W "stdio sse http"
                    return 0
                    ;;
            esac
            ;;
        "claude mcp add-from-claude-desktop")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "local user project"
                    return 0
                    ;;
            esac
            ;;
        "claude mcp add-json")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "local user project"
                    return 0
                    ;;
            esac
            ;;
        "claude mcp remove")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "local user project"
                    return 0
                    ;;
            esac
            ;;
        "claude plugin autoremove")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugin disable")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugin enable")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugin i")
            case "$prev" in
                --config)
                    return 0
                    ;;
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugin install")
            case "$prev" in
                --config)
                    return 0
                    ;;
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugin marketplace add")
            case "$prev" in
                --scope)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
                --sparse)
                    _comp_compgen_filedir
                    return 0
                    ;;
            esac
            ;;
        "claude plugin marketplace remove")
            case "$prev" in
                --scope)
                    _comp_compgen -- -W "user project or"
                    return 0
                    ;;
            esac
            ;;
        "claude plugin marketplace rm")
            case "$prev" in
                --scope)
                    _comp_compgen -- -W "user project or"
                    return 0
                    ;;
            esac
            ;;
        "claude plugin prune")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugin remove")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugin tag")
            case "$prev" in
                --message|-m)
                    return 0
                    ;;
                --remote)
                    return 0
                    ;;
            esac
            ;;
        "claude plugin uninstall")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugin update")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "user project local managed"
                    return 0
                    ;;
            esac
            ;;
        "claude plugins autoremove")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugins disable")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugins enable")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugins i")
            case "$prev" in
                --config)
                    return 0
                    ;;
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugins install")
            case "$prev" in
                --config)
                    return 0
                    ;;
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugins marketplace add")
            case "$prev" in
                --scope)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
                --sparse)
                    _comp_compgen_filedir
                    return 0
                    ;;
            esac
            ;;
        "claude plugins marketplace remove")
            case "$prev" in
                --scope)
                    _comp_compgen -- -W "user project or"
                    return 0
                    ;;
            esac
            ;;
        "claude plugins marketplace rm")
            case "$prev" in
                --scope)
                    _comp_compgen -- -W "user project or"
                    return 0
                    ;;
            esac
            ;;
        "claude plugins prune")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugins remove")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugins tag")
            case "$prev" in
                --message|-m)
                    return 0
                    ;;
                --remote)
                    return 0
                    ;;
            esac
            ;;
        "claude plugins uninstall")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "user project local"
                    return 0
                    ;;
            esac
            ;;
        "claude plugins update")
            case "$prev" in
                --scope|-s)
                    _comp_compgen -- -W "user project local managed"
                    return 0
                    ;;
            esac
            ;;
        "claude ultrareview")
            case "$prev" in
                --timeout)
                    return 0
                    ;;
            esac
            ;;
    esac
    return 1
}

complete -F _comp_cmd_claude claude
