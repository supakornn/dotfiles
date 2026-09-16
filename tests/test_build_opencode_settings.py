#!/usr/bin/env python3
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
BUILDER = ROOT / "chezmoi/support/build-opencode-settings.py"


class BuildOpenCodeSettingsTests(unittest.TestCase):
    def test_keeps_local_settings_and_merges_selected_profiles(self):
        with tempfile.TemporaryDirectory() as directory:
            directory = Path(directory)
            output = directory / "opencode.jsonc"
            output.write_text(json.dumps({
                "username": "local-user",
                "mcp": {"company": {"type": "local", "command": ["company-mcp"]}},
                "plugin": ["company-plugin"],
            }))
            common = directory / "common.json"
            common.write_text(json.dumps({
                "mcp": {"context7": {"type": "remote", "url": "https://mcp.context7.com/mcp"}},
                "plugin": ["@dietrichgebert/ponytail"],
            }))
            personal = directory / "personal.json"
            personal.write_text(json.dumps({
                "model": "openai/gpt-5.6-terra",
                "plugin": ["@slkiser/opencode-quota@latest"],
            }))

            subprocess.run(
                [sys.executable, BUILDER, output, common, personal], check=True,
            )

            settings = json.loads(output.read_text())
            self.assertEqual(settings["username"], "local-user")
            self.assertEqual(
                settings["mcp"],
                {
                    "company": {"type": "local", "command": ["company-mcp"]},
                    "context7": {"type": "remote", "url": "https://mcp.context7.com/mcp"},
                },
            )
            self.assertEqual(settings["model"], "openai/gpt-5.6-terra")
            self.assertEqual(
                settings["plugin"],
                ["company-plugin", "@dietrichgebert/ponytail", "@slkiser/opencode-quota@latest"],
            )


if __name__ == "__main__":
    unittest.main()
