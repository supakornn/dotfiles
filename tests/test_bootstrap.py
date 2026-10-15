import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]


class BootstrapTests(unittest.TestCase):
    def run_bootstrap(self, *args, fail='', missing=(), hopper=False):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            log = root / 'calls'
            hopper_binary = root / 'Hopper Disassembler.app/Contents/MacOS/hopper'
            if hopper:
                hopper_binary.parent.mkdir(parents=True)
                hopper_binary.write_text('#!/bin/sh\nexit 0\n')
                hopper_binary.chmod(0o755)
            for name, body in {
                'uname': 'echo Darwin',
                'dirname': 'exec /usr/bin/dirname "$@"',
                'brew': '''printf "brew %s\\n" "$*" >> "$CALL_LOG"
printf "cask-skip %s\\n" "${HOMEBREW_BUNDLE_CASK_SKIP:-}" >> "$CALL_LOG"
if [ "$TEST_FAIL" = brew ] && [ "$1" = bundle ] && [ "$2" = install ]; then exit 1; fi
if [ "$*" = "install mise" ]; then /bin/mv "$FAKE_BIN/mise.pending" "$FAKE_BIN/mise"; fi''',
                'mise': '''printf "mise %s\\n" "$*" >> "$CALL_LOG"
case "$*" in
  *"install python@latest"*) if [ "$TEST_FAIL" = python ]; then exit 1; fi ;;
  *"run install-agent-tools"*) if [ "$TEST_FAIL" = agents ]; then exit 1; fi ;;
  *"exec python@latest -- python "*)
    case "$*" in *--check*) if [ "$TEST_FAIL" = preflight ]; then exit 1; fi ;; esac ;;
esac''',
                'curl': '''printf "curl %s\\n" "$*" >> "$CALL_LOG"
if [ "$TEST_FAIL" = download ]; then exit 1; fi
printf '%s\\n' '/bin/mv "$FAKE_BIN/brew.pending" "$FAKE_BIN/brew"' ''',
            }.items():
                tool = root / (name + '.pending' if name in missing else name)
                tool.write_text('#!/bin/sh\n' + body + '\n')
                tool.chmod(0o755)
            # No system Python or package managers can leak into this fake Mac.
            env = dict(os.environ, PATH=str(root), CALL_LOG=str(log),
                       TEST_FAIL=fail, FAKE_BIN=str(root), HOMEBREW_BUNDLE_CASK_SKIP='other-app')
            # Keep conventional Homebrew discovery paths inside the test fixture.
            script = root / 'bootstrap.sh'
            script.write_text((ROOT / 'bootstrap.sh').read_text()
                              .replace('/opt/homebrew/bin/brew', str(root / 'brew'))
                              .replace('/usr/local/bin/brew', str(root / 'brew'))
                              .replace('/Applications/Hopper Disassembler.app/Contents/MacOS/hopper',
                                       str(hopper_binary)))
            result = subprocess.run(['/bin/bash', str(script), *args],
                                    env=env, text=True, capture_output=True, timeout=10)
            return result, log.read_text() if log.exists() else ''

    def test_default_is_preview_only(self):
        result, calls = self.run_bootstrap()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('bundle install', calls)
        self.assertNotIn('trust ', calls)
        self.assertNotIn('run install-herdr-plugins', calls)
        self.assertIn('--dry-run', calls)

    def test_fresh_mac_prepares_prerequisites_before_deployment(self):
        result, calls = self.run_bootstrap('--apply', missing=('brew', 'mise'))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('raw.githubusercontent.com/Homebrew/install/HEAD/install.sh', calls)
        self.assertIn('brew install mise', calls)
        self.assertIn('install python@latest', calls)
        self.assertIn('exec python@latest -- python ', calls)
        self.assertLess(calls.index('curl '), calls.index('brew install mise'))
        self.assertLess(calls.index('brew install mise'), calls.index('install python@latest'))
        self.assertLess(calls.index('install python@latest'), calls.index('exec python@latest'))
        self.assertLess(calls.index('deploy.py --check'), calls.index('bundle install'))

    def test_preview_does_not_install_missing_prerequisites(self):
        result, calls = self.run_bootstrap(missing=('brew', 'mise'))
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('curl ', calls)
        self.assertNotIn('install ', calls)

    def test_failed_homebrew_download_stops_before_install(self):
        result, calls = self.run_bootstrap('--apply', missing=('brew', 'mise'), fail='download')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('brew install', calls)
        self.assertNotIn('deploy.py', calls)

    def test_python_failure_prevents_remaining_packages_and_deployment(self):
        result, calls = self.run_bootstrap('--apply', fail='python')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('bundle install', calls)
        self.assertNotIn('deploy.py', calls)
        self.assertNotIn('run build-bat-cache', calls)

    def test_skip_packages_does_not_install_missing_homebrew(self):
        result, calls = self.run_bootstrap('--apply', '--skip-packages', missing=('brew',))
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('curl ', calls)
        self.assertNotIn('brew install', calls)

    def test_unknown_option_is_rejected_without_changes(self):
        result, calls = self.run_bootstrap('--unknown')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, '')

    def test_upgrade_requires_apply(self):
        result, calls = self.run_bootstrap('--upgrade')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, '')

    def test_apply_disables_upgrades_by_default(self):
        result, calls = self.run_bootstrap('--apply')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('bundle install', calls)
        self.assertIn('brew tap anomalyco/tap', calls)
        self.assertIn('brew trust --formula anomalyco/tap/opencode-v2', calls)
        self.assertNotIn('trust --tap', calls)
        self.assertLess(calls.index('deploy.py --check'), calls.index('brew trust'))
        self.assertLess(calls.index('brew trust'), calls.index('bundle install'))
        self.assertIn('--no-upgrade', calls)
        self.assertLess(calls.index('deploy.py --check'), calls.index('bundle install'))
        self.assertIn('run install-agent-tools', calls)
        self.assertLess(calls.index('bundle install'), calls.index('run install-agent-tools'))
        self.assertLess(calls.index('install-agent-tools'), calls.index('run build-bat-cache'))

    def test_existing_hopper_is_preserved_and_other_cask_skips_are_retained(self):
        result, calls = self.run_bootstrap('--apply', hopper=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('cask-skip other-app hopper-disassembler', calls)

    def test_fresh_mac_does_not_skip_hopper(self):
        result, calls = self.run_bootstrap('--apply')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('hopper-disassembler', calls)

    def test_failed_agent_setup_stops_remaining_tasks(self):
        result, calls = self.run_bootstrap('--apply', fail='agents')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('run build-bat-cache', calls)
        self.assertNotIn('run install-herdr-plugins', calls)

    def test_explicit_upgrade_allows_upgrades(self):
        result, calls = self.run_bootstrap('--apply', '--upgrade')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('bundle install', calls)
        self.assertNotIn('--no-upgrade', calls)

    def test_failed_preflight_prevents_package_install(self):
        result, calls = self.run_bootstrap('--apply', fail='preflight')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('brew ', calls)

    def test_failed_packages_prevent_deployment(self):
        result, calls = self.run_bootstrap('--apply', fail='brew')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls.count('deploy.py'), 1)  # preflight only
        self.assertNotIn('run install-herdr-plugins', calls)

    def test_skip_packages_never_calls_brew(self):
        result, calls = self.run_bootstrap('--apply', '--skip-packages')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('brew ', calls)
        self.assertNotIn('run install-agent-tools', calls)


class ConfigurationTests(unittest.TestCase):
    def test_mcp_is_portable_and_uses_local_auth(self):
        text = (ROOT / 'dotfiles/.pi/agent/mcp.json').read_text()
        servers = json.loads(text)['mcpServers']
        self.assertEqual(set(servers), {'alphaxiv', 'huggingface', 'deepwiki', 'github', 'rea', 'cua-driver'})
        self.assertNotIn('/Users/', text)
        self.assertEqual(servers['github']['headers'], {'Authorization': '!echo Bearer $(gh auth token)'})
        self.assertEqual(servers['cua-driver']['command'], '~/.local/bin/cua-driver')
        self.assertIn('rea-agents@6.4.0', servers['rea']['args'])
        self.assertEqual(servers['rea']['env']['HOPPER_LAUNCHER_PATH'],
                         '/Applications/Hopper Disassembler.app/Contents/MacOS/hopper')
        self.assertIn('cask "hopper-disassembler"', (ROOT / 'Brewfile').read_text())


class DeploymentTests(unittest.TestCase):
    def setUp(self):
        spec = importlib.util.spec_from_file_location('deploy', ROOT / 'scripts/deploy.py')
        self.deploy = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.deploy)
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name) / 'home'
        self.home.mkdir()
        self.repo = Path(self.temp.name) / 'repo'
        self.repo.mkdir()
        self.target = self.home / '.pi/agent/settings.json'
        self.target.parent.mkdir(parents=True)
        self.target.write_text('original')
        self.status = {'files': [{'target': str(self.target), 'state': 'differs'}]}

    def run_deploy(self, force=False):
        with patch.object(self.deploy.Path, 'home', return_value=self.home), \
             patch.object(self.deploy, 'status', return_value=self.status), \
             patch.object(self.deploy, 'pending', return_value=[]), \
             patch.object(self.deploy.subprocess, 'run') as run:
            self.deploy.deploy(self.repo, force=force)
            return run

    def test_conflicts_require_explicit_force(self):
        with self.assertRaisesRegex(RuntimeError, 'force'):
            self.run_deploy()
        self.assertEqual(self.target.read_text(), 'original')
        self.assertFalse((self.home / '.dotfiles-backups').exists())

    def test_force_creates_private_backup_before_apply(self):
        run = self.run_deploy(force=True)
        backups = list((self.home / '.dotfiles-backups').iterdir())
        self.assertEqual(len(backups), 1)
        backup = backups[0]
        self.assertEqual(backup.stat().st_mode & 0o777, 0o700)
        self.assertEqual((backup / '.pi/agent/settings.json').read_text(), 'original')
        self.assertTrue((backup / 'manifest.json').exists())
        self.assertIn('--force', run.call_args.args[0])

    def test_backup_failure_prevents_apply(self):
        with patch.object(self.deploy.shutil, 'copy2', side_effect=OSError('disk full')):
            with self.assertRaises(OSError):
                self.run_deploy(force=True)
        self.assertEqual(self.target.read_text(), 'original')

    def test_target_outside_home_is_rejected(self):
        self.status['files'][0]['target'] = str(self.repo / 'external')
        with self.assertRaisesRegex(RuntimeError, 'home'):
            self.run_deploy(force=True)

    def test_symlinked_parent_is_rejected(self):
        outside = self.repo / 'agent'
        outside.mkdir()
        linked = self.home / '.linked'
        linked.symlink_to(outside, target_is_directory=True)
        self.status['files'][0]['target'] = str(linked / 'settings.json')
        with self.assertRaisesRegex(RuntimeError, 'symlink'):
            self.run_deploy(force=True)

    def test_pending_operation_blocks_deployment(self):
        with patch.object(self.deploy, 'pending', return_value=[{'id': 'old'}]), \
             patch.object(self.deploy.Path, 'home', return_value=self.home):
            with self.assertRaisesRegex(RuntimeError, 'unfinished'):
                self.deploy.deploy(self.repo, force=True)
        self.assertEqual(self.target.read_text(), 'original')

    def test_broken_symlink_is_backed_up_as_link(self):
        self.target.unlink()
        self.target.symlink_to('missing')
        self.run_deploy(force=True)
        backup = next((self.home / '.dotfiles-backups').iterdir())
        self.assertEqual(os.readlink(backup / '.pi/agent/settings.json'), 'missing')


if __name__ == '__main__':
    unittest.main()
