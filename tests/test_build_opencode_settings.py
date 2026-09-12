#!/usr/bin/env python3
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
BUILDER = ROOT / "scripts/build-opencode-settings.py"


class BuildOpenCodeSettingsTests(unittest.TestCase):
    def test_replaces_local_settings_with_selected_profiles(self):
        with tempfile.TemporaryDirectory() as directory:
            directory = Path(directory)
            output = directory / "opencode.jsonc"
            output.write_text(json.dumps({"username": "stale-local-user"}))
            common = directory / "common.json"
            common.write_text(json.dumps({
                "mcp": {"context7": {"type": "remote", "url": "https://mcp.context7.com/mcp"}},
            }))
            personal = directory / "personal.json"
            personal.write_text(json.dumps({"model": "openai/gpt-5.6-terra"}))

            subprocess.run(
                [sys.executable, BUILDER, output, common, personal], check=True,
            )

            settings = json.loads(output.read_text())
            self.assertNotIn("username", settings)
            self.assertEqual(
                settings["mcp"],
                {"context7": {"type": "remote", "url": "https://mcp.context7.com/mcp"}},
            )
            self.assertEqual(settings["model"], "openai/gpt-5.6-terra")


if __name__ == "__main__":
    unittest.main()
