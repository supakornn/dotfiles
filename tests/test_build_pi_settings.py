#!/usr/bin/env python3
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
BUILDER = ROOT / "scripts/build-pi-settings.py"


class BuildPiSettingsTests(unittest.TestCase):
    def test_keeps_machine_local_settings(self):
        with tempfile.TemporaryDirectory() as directory:
            directory = Path(directory)
            output = directory / "settings.json"
            output.write_text(json.dumps({
                "mcpServers": {"work": {"command": "work-mcp"}},
                "lastChangelogVersion": "0.85.1",
                "packages": ["npm:work-only"],
            }))
            shared = directory / "shared.json"
            shared.write_text(json.dumps({
                "theme": "dark",
                "packages": ["npm:shared"],
                "skills": ["skills"],
            }))

            subprocess.run(
                [sys.executable, BUILDER, output, shared], check=True,
            )

            settings = json.loads(output.read_text())
            self.assertEqual(settings["mcpServers"]["work"]["command"], "work-mcp")
            self.assertEqual(settings["lastChangelogVersion"], "0.85.1")
            self.assertEqual(settings["packages"], ["npm:work-only", "npm:shared"])
            self.assertEqual(settings["theme"], "dark")


if __name__ == "__main__":
    unittest.main()
