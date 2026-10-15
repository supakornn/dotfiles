import importlib.util
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]


class AgentToolsTests(unittest.TestCase):
    def setUp(self):
        spec = importlib.util.spec_from_file_location('agent_tools', ROOT / 'scripts/install-agent-tools.py')
        self.tools = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(self.tools)
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.cua = self.home / '.local/bin/cua-driver'

    def installed_cua(self):
        self.cua.parent.mkdir(parents=True)
        self.cua.write_text('existing binary')
        self.cua.chmod(0o755)

    def test_missing_cua_uses_official_installer_without_editing_shell_config(self):
        def run(args, **kwargs):
            if args[0] == '/bin/bash':
                self.installed_cua()
            return subprocess.CompletedProcess(args, 0, stdout='official installer')

        with patch.object(self.tools.subprocess, 'run', side_effect=run) as calls:
            self.tools.install_cua(self.home)
        self.assertEqual(calls.call_args_list[0].args[0],
                         ['curl', '-fsSL', 'https://cua.ai/driver/install.sh'])
        install = calls.call_args_list[1].args[0]
        self.assertIn('--no-modify-path', install)
        self.assertIn(str(self.cua.parent), install)
        self.assertEqual(calls.call_args_list[-1].args[0], [str(self.cua), '--version'])

    def test_existing_cua_is_checked_not_reinstalled(self):
        self.installed_cua()
        with patch.object(self.tools.subprocess, 'run') as run:
            self.tools.install_cua(self.home)
        run.assert_called_once_with([str(self.cua), '--version'], check=True)
        self.assertEqual(self.cua.read_text(), 'existing binary')

    def test_failed_cua_download_does_not_execute_installer(self):
        with patch.object(self.tools.subprocess, 'run', side_effect=subprocess.CalledProcessError(22, 'curl')) as run:
            with self.assertRaises(subprocess.CalledProcessError):
                self.tools.install_cua(self.home)
        self.assertEqual(run.call_count, 1)

    def test_installer_success_without_binary_is_a_failure(self):
        with patch.object(self.tools.subprocess, 'run',
                          return_value=subprocess.CompletedProcess([], 0, stdout='installer')):
            with self.assertRaisesRegex(RuntimeError, 'cua-driver'):
                self.tools.install_cua(self.home)

    def test_existing_nonexecutable_cua_is_not_overwritten(self):
        self.installed_cua()
        self.cua.chmod(0o644)
        with patch.object(self.tools.subprocess, 'run') as run:
            with self.assertRaisesRegex(RuntimeError, 'overwrite'):
                self.tools.install_cua(self.home)
        run.assert_not_called()

    def test_missing_pi_packages_are_installed_from_tracked_settings(self):
        with patch.object(self.tools.subprocess, 'run') as run:
            self.tools.install_pi_packages(ROOT, self.home)
        expected = json.loads((ROOT / 'dotfiles/.pi/agent/settings.json').read_text())['packages']
        self.assertEqual([call.args[0] for call in run.call_args_list],
                         [['pi', 'install', source] for source in expected])

    def test_installed_pi_packages_are_not_upgraded(self):
        expected = json.loads((ROOT / 'dotfiles/.pi/agent/settings.json').read_text())['packages']
        for source in expected:
            name = source[4:]
            manifest = self.home / '.pi/agent/npm/node_modules' / name / 'package.json'
            manifest.parent.mkdir(parents=True)
            manifest.write_text(json.dumps({'name': name, 'version': '1.0.0'}))
        with patch.object(self.tools.subprocess, 'run') as run:
            self.tools.install_pi_packages(ROOT, self.home)
        run.assert_not_called()

    def test_rea_is_prepared_using_the_configured_version_without_starting_mcp(self):
        with patch.object(self.tools.subprocess, 'run') as run:
            self.tools.prepare_rea(ROOT)
        run.assert_called_once_with(['npx', '--yes', 'rea-agents@6.4.0', '--help'], check=True)


if __name__ == '__main__':
    unittest.main()
