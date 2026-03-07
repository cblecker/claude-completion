#!/usr/bin/env python3
"""Parse claude CLI --help output recursively and output structured JSON."""

import json
import re
import subprocess
import sys


def run_help(cmd_parts):
    """Run a command with --help and return stdout."""
    try:
        result = subprocess.run(
            cmd_parts + ["--help"],
            capture_output=True,
            text=True,
            stdin=subprocess.DEVNULL,
            timeout=10,
        )
        return result.stdout
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return ""


def get_version():
    """Get claude CLI version."""
    try:
        result = subprocess.run(
            ["claude", "--version"],
            capture_output=True,
            text=True,
            stdin=subprocess.DEVNULL,
            timeout=10,
        )
        # Output like "2.1.70 (Claude Code)"
        return result.stdout.strip().split()[0] if result.stdout.strip() else "unknown"
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return "unknown"


def _parse_choice_list(s):
    """Parse 'a, b, or c' or 'a, b, c' into ['a', 'b', 'c']."""
    s = re.sub(r"\bor\s+", "", s)
    items = [item.strip() for item in s.split(",") if item.strip()]
    return items if len(items) >= 2 else None


def extract_choices(desc):
    """Extract choices from description text."""
    # 1. Commander.js format: (choices: "a", "b", "c")
    m = re.search(r"\(choices:\s*(.+?)\)", desc)
    if m:
        return re.findall(r'"([^"]+)"', m.group(1))

    # Clean description: remove (default: "..."), (default), (default: word) patterns
    clean = re.sub(r"\s*\(default(?::\s*(?:\"[^\"]*\"|[^)]*))?\)", "", desc)
    clean = re.sub(r"\s+", " ", clean).strip()

    # 2. Parenthesized list: (a, b, c) or (a, b, or c)
    m = re.search(
        r"\(([a-zA-Z][-a-zA-Z0-9]*(?:\s*,\s*(?:or\s+)?[a-zA-Z][-a-zA-Z0-9]*)+)\)",
        clean,
    )
    if m:
        return _parse_choice_list(m.group(1))

    # 3. After colon: "...: a, b, or c" or "...: a, b, c"
    m = re.search(
        r":\s+([a-zA-Z][-a-zA-Z0-9]*(?:\s*,\s*(?:or\s+)?[a-zA-Z][-a-zA-Z0-9]*)+)"
        r"(?:\s|$)",
        clean,
    )
    if m:
        return _parse_choice_list(m.group(1))

    return None


def determine_flag_type(long_flags, value_part, desc):
    """Determine the type of a flag based on its value placeholder and description.

    Returns (type_string, choices_list_or_None).
    """
    if not value_part:
        return "bool", None
    if value_part.startswith("["):
        return "optional_value", None

    # Check for choices in description
    choices = extract_choices(desc)
    if choices:
        return "choices", choices

    vp_lower = value_part.lower()

    # Check for directory type
    if "director" in vp_lower:
        return "dir", None
    if any(f.endswith("-dir") for f in long_flags):
        return "dir", None

    # Check for file/path type
    if "path" in vp_lower or "file" in vp_lower:
        return "file", None

    return "value", None


def try_parse_flag(line):
    """Try to parse a single option/flag line from --help output.

    Returns (long_flags, short_flag, value_part, desc) or None.
    """
    # Match option lines that start with spaces and a dash
    # Formats:
    #   -s, --long-name <value>   Description
    #   --long-name <value>       Description
    #   --camelCase, --kebab-case <value>  Description
    m = re.match(
        r"^  +"  # leading spaces
        r"("  # start capture of all flag parts
        r"(?:-[a-zA-Z],\s+)?"  # optional short flag like "-c, "
        r"--[a-zA-Z][-a-zA-Z0-9]*"  # first long flag
        r"(?:,\s+--[a-zA-Z][-a-zA-Z0-9]*)*"  # optional additional long flags
        r")"  # end capture
        r"(\s+<[^>]+>|\s+\[[^\]]+\])?"  # optional value placeholder
        r"\s{2,}"  # gap before description (at least 2 spaces)
        r"(.+)",  # description
        line,
    )
    if not m:
        return None

    flags_part = m.group(1).strip()
    value_part = (m.group(2) or "").strip()
    desc = m.group(3).strip()

    # Parse individual flags
    flag_tokens = [f.strip() for f in flags_part.split(",")]

    short = None
    long_flags = []
    for token in flag_tokens:
        token = token.strip()
        if re.match(r"^-[a-zA-Z]$", token):
            short = token
        elif token.startswith("--"):
            long_flags.append(token)

    if not long_flags:
        return None

    return (long_flags, short, value_part, desc)


def parse_help_output(text):
    """Parse a --help output into flags and subcommands."""
    flags = {}
    subcommands = []

    lines = text.split("\n")
    section = None

    # State for multi-line flag descriptions
    current_long_flags = None
    current_short = None
    current_value_part = None
    current_desc_lines = []

    def finalize_flag():
        nonlocal current_long_flags, current_short, current_value_part, current_desc_lines
        if current_long_flags is None:
            return

        full_desc = " ".join(current_desc_lines)
        flag_type, choices = determine_flag_type(current_long_flags, current_value_part, full_desc)

        info = {"type": flag_type}
        if current_short:
            info["short"] = current_short

        if flag_type == "choices":
            if choices:
                info["choices"] = choices
            else:
                # Fallback: couldn't extract choices, treat as value
                info["type"] = "value"

        repeatable = "..." in (current_value_part or "")
        if repeatable:
            info["repeatable"] = True

        for flag in current_long_flags:
            flags[flag] = dict(info)

        current_long_flags = None
        current_short = None
        current_value_part = None
        current_desc_lines = []

    for line in lines:
        stripped = line.strip()

        # Detect section headers
        if re.match(r"^(Options|Arguments|Commands):", stripped):
            finalize_flag()
            section = stripped.split(":")[0].lower()
            continue

        # Blank line
        if not stripped:
            if section == "options":
                finalize_flag()
            continue

        if section == "options":
            result = try_parse_flag(line)
            if result:
                finalize_flag()
                long_flags, short, value_part, desc = result
                current_long_flags = long_flags
                current_short = short
                current_value_part = value_part
                current_desc_lines = [desc]
            else:
                # Check if this is a continuation line (heavily indented, no leading dash)
                leading_spaces = len(line) - len(line.lstrip())
                if leading_spaces >= 15 and current_long_flags is not None:
                    current_desc_lines.append(stripped)

        elif section == "commands":
            # Match command lines like:
            #   subcommand [options]   Description
            #   update|upgrade         Description
            #   install|i [options]    Description
            cmd_match = re.match(
                r"^\s+"
                r"([a-z][-a-z0-9|]*)"  # command name (possibly with aliases)
                r"(?:\s+\[options\])?"  # optional [options]
                r"(?:\s+(?:\[command\]|<[^>]+>|\[[^\]]+\]))*"  # optional args
                r"\s{2,}"  # gap
                r"(.+)",  # description
                line,
            )
            if cmd_match:
                cmd_names = cmd_match.group(1)
                aliases = cmd_names.split("|")
                for alias in aliases:
                    alias = alias.strip()
                    if alias and alias != "help":
                        subcommands.append(alias)

    finalize_flag()
    return flags, subcommands


def parse_recursive(cmd_parts, commands, max_depth=4):
    """Recursively parse help for a command and its subcommands."""
    cmd_key = " ".join(cmd_parts)

    help_text = run_help(cmd_parts)
    if not help_text:
        return

    flags, subcommands = parse_help_output(help_text)

    commands[cmd_key] = {
        "flags": flags,
        "subcommands": subcommands,
    }

    if len(cmd_parts) < max_depth:
        for subcmd in subcommands:
            parse_recursive(cmd_parts + [subcmd], commands, max_depth)


def main():
    version = get_version()
    commands = {}
    parse_recursive(["claude"], commands, max_depth=4)

    output = {
        "version": version,
        "commands": commands,
    }

    json.dump(output, sys.stdout, indent=2)
    sys.stdout.write("\n")


if __name__ == "__main__":
    main()
