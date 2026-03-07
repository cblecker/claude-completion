#!/usr/bin/env python3
"""Generate bash completion script from claude-completion.json."""

import json
import os


def generate():
    data_path = os.path.join(os.path.dirname(__file__), "..", "data", "claude-completion.json")
    output_path = os.path.join(os.path.dirname(__file__), "..", "completions", "claude.bash")

    with open(data_path) as f:
        data = json.load(f)

    version = data["version"]
    commands = data["commands"]

    all_paths = sorted(commands.keys())
    subcommand_paths = [p for p in all_paths if p != "claude"]

    lines = []

    # Header
    lines.append("# claude bash completion                                   -*- shell-script -*-")
    lines.append(f"# Generated from Claude Code v{version}")
    lines.append("# https://github.com/cblecker/claude-completion")
    lines.append("# Requires bash-completion@2")
    lines.append("")

    # Main completion function
    lines.append("_comp_cmd_claude()")
    lines.append("{")
    lines.append("    local cur prev words cword was_split")
    lines.append('    _comp_initialize -s -- "$@" || return')
    lines.append("")
    lines.append("    # Walk words to find deepest matching subcommand path")
    lines.append('    local cmd_path="claude"')
    lines.append("    local i")
    lines.append("    for ((i = 1; i < cword; i++)); do")
    lines.append('        case "${words[i]}" in')
    lines.append("            -*) continue ;;")
    lines.append("            *)")
    lines.append('                local try="${cmd_path} ${words[i]}"')
    lines.append('                if _comp_cmd_claude__has_command "$try"; then')
    lines.append('                    cmd_path="$try"')
    lines.append("                fi")
    lines.append("                ;;")
    lines.append("        esac")
    lines.append("    done")
    lines.append("")
    lines.append("    # Handle flag value completion")
    lines.append('    if _comp_cmd_claude__flag_values "$cmd_path"; then')
    lines.append("        return")
    lines.append("    fi")
    lines.append("")
    lines.append("    # After --flag=value split, don't suggest more completions")
    lines.append("    [[ $was_split ]] && return")
    lines.append("")
    lines.append('    _comp_cmd_claude__complete "$cmd_path"')
    lines.append("}")
    lines.append("")

    # has_command function
    lines.append("_comp_cmd_claude__has_command()")
    lines.append("{")
    lines.append('    case "$1" in')
    for path in subcommand_paths:
        lines.append(f'        "{path}") return 0 ;;')
    lines.append("        *) return 1 ;;")
    lines.append("    esac")
    lines.append("}")
    lines.append("")

    # complete function
    lines.append("_comp_cmd_claude__complete()")
    lines.append("{")
    lines.append("    # Stop suggesting flags after -- separator")
    lines.append("    local i")
    lines.append("    for ((i = 1; i < cword; i++)); do")
    lines.append('        if [[ "${words[i]}" == "--" ]]; then')
    lines.append("            return")
    lines.append("        fi")
    lines.append("    done")
    lines.append("")
    lines.append('    case "$1" in')

    for path in all_paths:
        cmd = commands[path]
        flag_info = cmd.get("flags", {})
        subcmds = cmd.get("subcommands", [])

        # Collect all flag names (long + short)
        all_flags = set()
        for flag_name in flag_info:
            all_flags.add(flag_name)
            info = flag_info[flag_name]
            if "short" in info:
                all_flags.add(info["short"])

        flags_str = " ".join(sorted(all_flags))
        subcmds_str = " ".join(sorted(subcmds))

        lines.append(f'        "{path}")')
        if flags_str and subcmds_str:
            lines.append('            if [[ "$cur" == -* ]]; then')
            lines.append(f'                _comp_compgen -- -W "{flags_str}"')
            lines.append("            else")
            lines.append(f'                _comp_compgen -- -W "{subcmds_str}"')
            lines.append("            fi")
        elif flags_str:
            lines.append(f'            _comp_compgen -- -W "{flags_str}"')
        elif subcmds_str:
            lines.append(f'            _comp_compgen -- -W "{subcmds_str}"')
        lines.append("            ;;")

    lines.append("    esac")
    lines.append("}")
    lines.append("")

    # flag_values function
    lines.append("_comp_cmd_claude__flag_values()")
    lines.append("{")
    lines.append('    case "$1" in')

    for path in all_paths:
        cmd = commands[path]
        flag_info = cmd.get("flags", {})

        # Collect flags that take values (not bool, not optional_value)
        value_cases = []
        for flag_name, info in sorted(flag_info.items()):
            if info["type"] in ("bool", "optional_value"):
                continue

            names = [flag_name]
            if "short" in info:
                names.append(info["short"])
            pattern = "|".join(names)

            completion_lines = []
            if info["type"] == "choices" and "choices" in info:
                choices_str = " ".join(info["choices"])
                completion_lines.append(f'                    _comp_compgen -- -W "{choices_str}"')
            elif info["type"] == "dir":
                completion_lines.append("                    _comp_compgen_filedir -d")
            elif info["type"] == "file":
                completion_lines.append("                    _comp_compgen_filedir")
            # For "value" type: no specific completion, but still consume the argument

            completion_lines.append("                    return 0")
            value_cases.append((pattern, completion_lines))

        if not value_cases:
            continue

        lines.append(f'        "{path}")')
        lines.append('            case "$prev" in')
        for pattern, comp_lines in value_cases:
            lines.append(f"                {pattern})")
            for cl in comp_lines:
                lines.append(cl)
            lines.append("                    ;;")
        lines.append("            esac")
        lines.append("            ;;")

    lines.append("    esac")
    lines.append("    return 1")
    lines.append("}")
    lines.append("")

    # Register completion
    lines.append("complete -F _comp_cmd_claude claude")
    lines.append("")

    with open(output_path, "w") as f:
        f.write("\n".join(lines))


if __name__ == "__main__":
    generate()
