#!/usr/bin/env python3
"""Back up managed conflicts before asking Mise to deploy. Python 3.8+ stdlib only."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def mise_json(repo, *args):
    result = subprocess.run(['mise', '-C', str(repo), *args, '--json'],
                            check=True, capture_output=True, text=True)
    return json.loads(result.stdout)


def status(repo):
    return mise_json(repo, 'dotfiles', 'status')


def pending(repo):
    return mise_json(repo, 'dot', 'history', '--pending')


def checked_target(value, home):
    target = Path(os.path.abspath(os.path.expanduser(value)))
    try:
        relative = target.relative_to(home)
    except ValueError:
        raise RuntimeError('Deployment target is outside home: ' + str(target))
    if not relative.parts:
        raise RuntimeError('Refusing to deploy the home directory itself')
    # A legacy directory symlink could redirect a nested mapping into the repo.
    parent = target.parent
    while parent != home:
        if parent.is_symlink():
            raise RuntimeError('Resolve legacy parent symlink before deploying: ' + str(parent))
        parent = parent.parent
    return target, relative


def preflight(repo, force=False):
    if pending(repo):
        raise RuntimeError('Mise has unfinished operations. Inspect `mise dot history --pending`; '
                           'recover only after reviewing their saved state.')
    home = Path.home().absolute()
    entries = status(repo)['files']
    conflicts = []
    for entry in entries:
        target, relative = checked_target(entry['target'], home)
        if entry['state'] == 'source_missing':
            raise RuntimeError('Missing dotfile source for ' + str(target))
        if entry['state'] == 'differs' and (target.exists() or target.is_symlink()):
            conflicts.append((target, relative))
    if conflicts and not force:
        raise RuntimeError('Existing dotfiles conflict. Preview first, then use --force '
                           'to back them up and replace them.')
    return conflicts


def deploy(repo, force=False, check=False):
    conflicts = preflight(repo, force)
    if check:
        return
    if conflicts:
        home = Path.home().absolute()
        base = home / '.dotfiles-backups'
        if base.is_symlink():
            raise RuntimeError('Backup directory must not be a symlink')
        base.mkdir(mode=0o700, exist_ok=True)
        base.chmod(0o700)
        backup = Path(tempfile.mkdtemp(prefix='deployment-', dir=str(base)))
        manifest = []
        # Complete every backup before applying anything; on failure retain partial
        # backups for inspection and leave deployment untouched.
        for target, relative in conflicts:
            destination = backup / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            if target.is_symlink():
                destination.symlink_to(os.readlink(target), target_is_directory=target.is_dir())
            elif target.is_dir():
                shutil.copytree(target, destination, symlinks=True)
            else:
                shutil.copy2(target, destination)
            manifest.append({'target': str(target), 'backup': str(relative)})
        (backup / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        print('Private pre-deployment backups: ' + str(backup), flush=True)
    command = ['mise', '-C', str(repo), 'dotfiles', 'apply', '--yes']
    if force:
        command.append('--force')
    subprocess.run(command, check=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--force', action='store_true')
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    try:
        deploy(Path(__file__).resolve().parents[1], args.force, args.check)
    except (RuntimeError, OSError, subprocess.CalledProcessError) as error:
        parser.exit(1, str(error) + '\n')
