#!/usr/bin/env python3
"""Install agent dependencies not supplied by brew bundle or mise install."""
import json
import os
from pathlib import Path
import re
import subprocess


def install_cua(home):
    binary = home / '.local/bin/cua-driver'
    if not os.access(binary, os.X_OK):
        if binary.exists() or binary.is_symlink():
            raise RuntimeError('Refusing to overwrite existing cua-driver at ' + str(binary))
        print('Installing Cua Driver from its official installer.', flush=True)
        installer = subprocess.run(
            ['curl', '-fsSL', 'https://cua.ai/driver/install.sh'],
            check=True, stdout=subprocess.PIPE, text=True,
        ).stdout
        subprocess.run(
            ['/bin/bash', '-c', installer, 'cua-driver-install',
             '--bin-dir', str(binary.parent), '--no-modify-path'],
            check=True,
        )
        if not os.access(binary, os.X_OK):
            raise RuntimeError('Cua installer did not provide an executable cua-driver.')
    subprocess.run([str(binary), '--version'], check=True)


def install_pi_packages(repo, home):
    settings = json.loads((repo / 'dotfiles/.pi/agent/settings.json').read_text())
    for package in settings.get('packages', []):
        source = package if isinstance(package, str) else package['source']
        # This repo uses npm packages. Fail explicitly if a new source needs support.
        match = re.fullmatch(r'npm:((?:@[a-z0-9][a-z0-9._-]*/)?[a-z0-9][a-z0-9._-]*)(?:@(.+))?', source)
        if not match:
            raise RuntimeError('Unsupported Pi package source: ' + source)
        name, version = match.groups()
        manifest = home / '.pi/agent/npm/node_modules' / name / 'package.json'
        try:
            installed = json.loads(manifest.read_text())
        except (OSError, ValueError):
            installed = {}
        if installed.get('name') == name and (version is None or installed.get('version') == version):
            print('Already installed: ' + source, flush=True)
            continue
        subprocess.run(['pi', 'install', source], check=True)


def prepare_rea(repo):
    servers = json.loads((repo / 'dotfiles/.pi/agent/mcp.json').read_text())['mcpServers']
    source = servers['rea']['args'][1]
    if not re.fullmatch(r'rea-agents@\d+\.\d+\.\d+', source):
        raise RuntimeError('REA must use an explicit release version: ' + source)
    # Install into npx's cache and check the CLI without starting an MCP server.
    subprocess.run(['npx', '--yes', source, '--help'], check=True)


if __name__ == '__main__':
    repo = Path(__file__).resolve().parents[1]
    home = Path.home()
    install_cua(home)
    install_pi_packages(repo, home)
    prepare_rea(repo)
