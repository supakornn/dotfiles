"""Real Mise deployment into a temporary home; never installs Homebrew packages."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which('mise'), 'Mise is required for deployment integration tests')
class IsolatedDeploymentTests(unittest.TestCase):
    def test_preserves_local_state_and_is_idempotent(self):
        with tempfile.TemporaryDirectory(prefix='dotfiles-integration-') as directory:
            root = Path(directory)
            root.chmod(0o700)
            repo = root / 'repo'
            repo.mkdir()
            shutil.copy2(ROOT / 'mise.toml', repo / 'mise.toml')
            shutil.copytree(ROOT / 'dotfiles', repo / 'dotfiles')
            shutil.copytree(ROOT / 'scripts', repo / 'scripts')
            home = root / 'home'
            home.mkdir()
            env = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(home / '.config'),
                       XDG_CACHE_HOME=str(root / 'cache'), XDG_DATA_HOME=str(root / 'data'),
                       XDG_STATE_HOME=str(root / 'state'), MISE_CONFIG_DIR=str(home / '.config/mise'),
                       MISE_DATA_DIR=str(root / 'mise-data'), MISE_CACHE_DIR=str(root / 'mise-cache'),
                       MISE_STATE_DIR=str(root / 'mise-state'), MISE_TRUSTED_CONFIG_PATHS=str(root))
            # Prevent inherited Mise overrides from loading the real user's config.
            for key in ['MISE_CONFIG_FILE', 'MISE_GLOBAL_CONFIG_FILE']:
                env.pop(key, None)
            local_files = {
                '.pi/agent/auth.json': '{"test-secret":"never-copy-to-repo"}',
                '.pi/agent/mcp-auth.json': '{"test-oauth":"local-only"}',
                '.pi/agent/sessions/test.jsonl': 'local session',
                '.pi/agent/extensions/local.ts': '// local extension',
                '.agents/skills/local-only/SKILL.md': 'local skill',
                '.config/fish/fish_variables': 'SETUVAR local_setting:keep',
                '.config/fish/conf.d/local.fish': '# local startup',
                '.config/mise/local.toml': '# local mise setting',
            }
            for relative, content in local_files.items():
                p = home / relative
                p.parent.mkdir(parents=True, exist_ok=True)
                p.write_text(content)
            # A managed conflict must be backed up, without including auth/state.
            old = home / '.pi/agent/settings.json'
            old.write_text('{"old":"settings"}')

            def run(*command):
                result = subprocess.run(command, cwd=repo, env=env, text=True,
                                        capture_output=True, timeout=30)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                return result.stdout

            run('mise', 'dotfiles', 'apply', '--dry-run', '--force')
            self.assertEqual(old.read_text(), '{"old":"settings"}')
            self.assertFalse((home / '.config/mise/config.toml').exists())
            for relative, content in local_files.items():
                self.assertEqual((home / relative).read_text(), content)
            run(sys.executable, str(repo / 'scripts/deploy.py'), '--force')
            first_status = json.loads(run('mise', 'dotfiles', 'status', '--json'))
            self.assertTrue(first_status['files'])
            self.assertTrue(all(f['state'] == 'applied' for f in first_status['files']), first_status['files'])
            for relative, content in local_files.items():
                self.assertEqual((home / relative).read_text(), content)
            backups = list((home / '.dotfiles-backups').iterdir())
            self.assertEqual(len(backups), 1)
            self.assertEqual((backups[0] / '.pi/agent/settings.json').read_text(), '{"old":"settings"}')
            self.assertFalse((backups[0] / '.pi/agent/auth.json').exists())
            # Mutable config is copied, not linked into tracked source.
            for relative in ['.pi/agent/settings.json', '.config/btop/btop.conf']:
                destination = home / relative
                source = repo / 'dotfiles' / relative
                before = source.read_bytes()
                self.assertFalse(destination.is_symlink())
                destination.write_text('local runtime change')
                self.assertEqual(source.read_bytes(), before)
                destination.write_bytes(before)
            run(sys.executable, str(repo / 'scripts/deploy.py'))
            self.assertEqual(len(list((home / '.dotfiles-backups').iterdir())), 1)
            run('mise', 'dotfiles', 'status', '--missing')


if __name__ == '__main__':
    unittest.main()
