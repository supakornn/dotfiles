#!/usr/bin/env python3
"""Merge OpenCode profile settings into a local config file."""

import json
import os
import sys
import tempfile
from pathlib import Path

if len(sys.argv) < 3:
    raise SystemExit("usage: build-opencode-settings.py OUTPUT INPUT [INPUT ...]")


def merge(base: dict[str, object], update: dict[str, object]) -> None:
    for key, value in update.items():
        if isinstance(value, dict) and isinstance(base.get(key), dict):
            merge(base[key], value)  # type: ignore[arg-type]
        elif key == "plugin" and isinstance(value, list) and isinstance(base.get(key), list):
            for plugin in value:
                if plugin not in base[key]:
                    base[key].append(plugin)
        else:
            base[key] = value


output = Path(sys.argv[1]).expanduser()
merged: dict[str, object] = {}
for source_name in sys.argv[2:]:
    merge(merged, json.loads(Path(source_name).read_text()))

output.parent.mkdir(parents=True, exist_ok=True)
fd, temporary_name = tempfile.mkstemp(dir=output.parent, prefix="opencode.", suffix=".json")
with os.fdopen(fd, "w") as temporary:
    json.dump(merged, temporary, indent=2)
    temporary.write("\n")
os.replace(temporary_name, output)
