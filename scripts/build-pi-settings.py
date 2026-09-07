#!/usr/bin/env python3
"""Merge selected tracked Pi profile settings into one local Pi settings file."""

import json
import os
import sys
import tempfile
from pathlib import Path

if len(sys.argv) < 3:
    raise SystemExit("usage: build-pi-settings.py OUTPUT INPUT [INPUT ...]")

output = Path(sys.argv[1]).expanduser()
merged: dict[str, object] = {}
for source_name in sys.argv[2:]:
    source = Path(source_name)
    data = json.loads(source.read_text())
    for key, value in data.items():
        if key in {"packages", "skills"}:
            values = merged.setdefault(key, [])
            for item in value:
                if item not in values:
                    values.append(item)
        else:
            merged[key] = value

output.parent.mkdir(parents=True, exist_ok=True)
fd, temporary_name = tempfile.mkstemp(dir=output.parent, prefix="settings.", suffix=".json")
with os.fdopen(fd, "w") as temporary:
    json.dump(merged, temporary, indent=2)
    temporary.write("\n")
os.replace(temporary_name, output)
