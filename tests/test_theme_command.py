#!/usr/bin/env python3
import json
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
COMMAND = ROOT / "common/.local/bin/theme"
STARSHIP = ROOT / "common/.config/starship.toml"


class ThemeCommandTests(unittest.TestCase):
    def test_switches_local_state_and_generated_configs(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            (home / ".config").mkdir()
            (home / ".pi/agent").mkdir(parents=True)
            (home / ".config/starship.toml").write_text(STARSHIP.read_text())
            (home / ".pi/agent/settings.json").write_text("{}")

            subprocess.run([COMMAND, "light"], check=True, env={"HOME": str(home)})

            self.assertEqual((home / ".config/dotfiles/theme").read_text(), "latte\n")
            self.assertIn('palette = "catppuccin_latte"', (home / ".cache/dotfiles/starship.toml").read_text())
            self.assertEqual(json.loads((home / ".pi/agent/settings.json").read_text())["theme"], "catppuccin-latte")


if __name__ == "__main__":
    unittest.main()
