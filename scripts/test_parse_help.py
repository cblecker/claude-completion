#!/usr/bin/env python3
"""Unit tests for parse_help.parse_help_output().

Fixtures are excerpts of real `claude --help` output (version noted on each)
unless marked synthetic. They cover entries whose term is too wide for the
help column, so the term is printed alone and its description wraps onto the
following, more deeply indented lines.
"""

import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from parse_help import parse_help_output  # noqa: E402

# `claude mcp --help`, Claude Code v2.1.323.
MCP_HELP = """\
Usage: claude mcp [options] [command]

Configure and manage MCP servers

Options:
  -h, --help                            Display help for command

Commands:
  add [options] <name> <commandOrUrl> [args...]
      Add an MCP server
  add-from-claude-desktop [options]     Import MCP servers from Claude Desktop
                                        (Mac and WSL only)
  add-json [options] <name> <json>      Add an MCP server (stdio, SSE, HTTP, or
                                        WebSocket) with a JSON string
  get <name>                            Get details about an MCP server.
                                        Unapproved .mcp.json servers are shown
                                        as ⏸ Pending approval and not connected
                                        to; approved servers are health-checked
                                        unless disabled for this project.
  help [command]                        display help for command
  list                                  List configured MCP servers. Unapproved
                                        .mcp.json servers are shown as ⏸ Pending
                                        approval and not connected to; approved
                                        servers are health-checked unless
                                        disabled for this project.
  login [options] <name>                Authenticate with an MCP server (HTTP,
                                        SSE, or claude.ai connector)
  logout <name>                         Clear stored OAuth credentials for an
                                        MCP server
  remove [options] <name>               Remove an MCP server
  reset-project-choices                 Reset all approved and rejected
                                        project-scoped (.mcp.json) servers
                                        within this project
  serve [options]                       Start the Claude Code MCP server
"""

# Excerpt of `claude --help` Options, Claude Code v2.1.323.
TOP_LEVEL_OPTIONS = """\
Options:
  --allowedTools, --allowed-tools <tools...>
      Comma or space-separated list of tool names to allow (e.g. "Bash(git *)
      Edit")
  --append-system-prompt <prompt>       Append a system prompt to the default
                                        system prompt
  --exclude-dynamic-system-prompt-sections
      Move per-machine sections (cwd, env info, memory paths, git status) from
      the system prompt into the first user message. Improves cross-user
      prompt-cache reuse. Only applies with the default system prompt (ignored
      with --system-prompt). (default: false)
  --fallback-model <model>              Enable automatic fallback to specified
                                        model(s) when the default model is
                                        overloaded or not available. Accepts a
"""

# Excerpt of `claude plugin eval --help` Options, Claude Code v2.1.323.
# "--allow-tools" is the last line of --mocks' description, not a flag.
PLUGIN_EVAL_OPTIONS = """\
Options:
  --mocks <mode>               Mock stand-ins for MCP servers, from <eval
                               dir>/mocks/ (record | off; default: record).
                               record: a plugin server with no mock is NOT
                               started (see --allow-real-servers); off: no
                               stand-ins, every real server starts (as you,
                               outside the OS sandbox), its tools gated by
                               --allow-tools
  --model <model>              Override model for all cases
"""


class TermPrintedAloneTest(unittest.TestCase):
    def test_command(self):
        flags, subcommands = parse_help_output(MCP_HELP)
        self.assertEqual(
            subcommands,
            [
                "add",
                "add-from-claude-desktop",
                "add-json",
                "get",
                "list",
                "login",
                "logout",
                "remove",
                "reset-project-choices",
                "serve",
            ],
        )
        self.assertEqual(flags, {"--help": {"type": "bool", "short": "-h"}})

    def test_wrapped_command_description_is_not_a_command(self):
        # Synthetic: a wrapped description line that is a lone lowercase word.
        _, subcommands = parse_help_output(
            "Commands:\n"
            "  add [options] <name> <commandOrUrl> [args...]\n"
            "      Add an MCP server, then\n"
            "      restart\n"
            "  list                                  List servers\n"
        )
        self.assertEqual(subcommands, ["add", "list"])

    def test_option(self):
        flags, _ = parse_help_output(TOP_LEVEL_OPTIONS)
        self.assertEqual(
            flags,
            {
                "--allowedTools": {"type": "value", "repeatable": True},
                "--allowed-tools": {"type": "value", "repeatable": True},
                "--append-system-prompt": {"type": "value"},
                "--exclude-dynamic-system-prompt-sections": {"type": "bool"},
                "--fallback-model": {"type": "value"},
            },
        )

    def test_option_choices_wrapped_across_lines(self):
        # Synthetic: the choices list is split over two description lines.
        flags, _ = parse_help_output(
            "Options:\n"
            "  -s, --scope <scope>\n"
            "      Configuration scope (local, user,\n"
            '      or project) (default: "local")\n'
            "  -h, --help                   Display help for command\n"
        )
        self.assertEqual(
            flags,
            {
                "--scope": {
                    "type": "choices",
                    "short": "-s",
                    "choices": ["local", "user", "project"],
                },
                "--help": {"type": "bool", "short": "-h"},
            },
        )

    def test_continuation_line_starting_with_dashes_is_not_a_flag(self):
        flags, _ = parse_help_output(PLUGIN_EVAL_OPTIONS)
        self.assertEqual(sorted(flags), ["--mocks", "--model"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
