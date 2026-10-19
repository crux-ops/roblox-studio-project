"""XML structure checks only; Studio opening is a separate manual gate."""
import importlib.util
from pathlib import Path
import tempfile
import unittest
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('build_place', ROOT / 'tools/build_place.py')
exporter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(exporter)


class PlaceExportTests(unittest.TestCase):
    def test_sources_round_trip(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'test.rbxlx'
            count = exporter.build(output)
            tree = ET.parse(output)
            items = list(tree.iter('Item'))
            source_nodes = [obj for obj in items if obj.attrib['class'] in ('Script', 'LocalScript', 'ModuleScript')]
            expected = list((ROOT / 'src').rglob('*.lua'))
            self.assertEqual(count, len(expected))
            self.assertEqual(len(source_nodes), len(expected))
            actual = {obj.find("Properties/ProtectedString[@name='Source']").text for obj in source_nodes}
            self.assertEqual(actual, {obj.read_text() for obj in expected})
            server = next(obj for obj in items if obj.find("Properties/string[@name='Name']").text == 'ServerMain')
            self.assertEqual(server.attrib['class'], 'Script')
            client = next(obj for obj in items if obj.find("Properties/string[@name='Name']").text == 'ClientMain')
            self.assertEqual(client.attrib['class'], 'LocalScript')
            referents = [obj.attrib['referent'] for obj in items]
            self.assertEqual(len(set(referents)), len(referents))
