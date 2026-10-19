"""Static scaffold checks, not a replacement for Studio/Luau runtime tests."""
import json
import pathlib
import re
import tomllib
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


class ScaffoldTests(unittest.TestCase):
    def test_rojo_paths_exist(self):
        project = json.loads((ROOT / 'default.project.json').read_text())

        def walk(node):
            if not isinstance(node, dict):
                return
            if '$path' in node:
                self.assertTrue((ROOT / node['$path']).is_dir())
            for value in node.values():
                walk(value)
        walk(project['tree'])

    def test_dependencies_declared(self):
        config = tomllib.loads((ROOT / 'wally.toml').read_text())
        self.assertEqual(len(config['dependencies']), 4)
        self.assertEqual(len(config['server-dependencies']), 2)

    def test_luau_strict(self):
        for path in (ROOT / 'src').rglob('*.lua'):
            if 'Vendor' in path.parts:
                continue
            self.assertTrue(path.read_text().startswith('--!strict\n'), str(path))

    def test_ten_unique_sample_plants(self):
        source = (ROOT / 'src/shared/Config/PlantConfig.lua').read_text()
        ids = re.findall(r'^define\("([a-z]+)"', source, re.MULTILINE)
        self.assertEqual(len(ids), 10)
        self.assertEqual(len(set(ids)), 10)

    def test_streaming(self):
        project = json.loads((ROOT / 'default.project.json').read_text())
        self.assertTrue(project['tree']['Workspace']['$properties']['StreamingEnabled'])


if __name__ == '__main__':
    unittest.main()
