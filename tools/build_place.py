"""Export this repository's small Rojo tree as a standalone Roblox XML place.

No Rojo installation required. This is a deliberately limited exporter for the
properties used here, not a general Rojo replacement. Unsupported properties fail.
"""
from pathlib import Path
import argparse
import json
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def build(destination: Path) -> int:
    root = ET.Element('roblox', {'version': '4'})
    for external in ('null', 'nil'):
        ET.SubElement(root, 'External').text = external
    counter = 0
    sources = 0

    def prop(props, kind, name, text=None):
        obj = ET.SubElement(props, kind, {'name': name})
        if text is not None:
            obj.text = str(text)
        return obj

    def item(parent, name, class_name):
        nonlocal counter
        counter += 1
        obj = ET.SubElement(parent, 'Item', {'class': class_name, 'referent': f'RBX{counter}'})
        props = ET.SubElement(obj, 'Properties')
        prop(props, 'string', 'Name', name)
        return obj, props

    def source(parent, name, class_name, path):
        nonlocal sources
        obj, props = item(parent, name, class_name)
        prop(props, 'ProtectedString', 'Source', path.read_text())
        if class_name in ('Script', 'LocalScript'):
            prop(props, 'bool', 'Disabled', 'false')
        sources += 1
        return obj

    def directory(parent, name, path):
        init = path / 'init.lua'
        obj = source(parent, name, 'ModuleScript', init) if init.exists() else item(parent, name, 'Folder')[0]
        for child in sorted(path.iterdir()):
            if child.is_dir():
                directory(obj, child.name, child)
            elif child.suffix == '.lua' and child.name != 'init.lua':
                if child.name.endswith('.server.lua'):
                    source(obj, child.name[:-11], 'Script', child)
                elif child.name.endswith('.client.lua'):
                    source(obj, child.name[:-11], 'LocalScript', child)
                else:
                    source(obj, child.stem, 'ModuleScript', child)
        return obj

    def node(parent, name, data):
        if '$path' in data:
            return directory(parent, name, ROOT / data['$path'])
        # Service and StarterPlayer child class names match their names here.
        obj, props = item(parent, name, data.get('$className', name))
        for key, value in data.get('$properties', {}).items():
            if isinstance(value, bool):
                prop(props, 'bool', key, str(value).lower())
            elif key in ('StreamingTargetRadius',):
                prop(props, 'int', key, value)
            elif key in ('ClockTime', 'Brightness'):
                prop(props, 'float', key, value)
            elif key == 'Size':
                vector = prop(props, 'Vector3', 'size')
                for axis, n in zip(('X', 'Y', 'Z'), value):
                    ET.SubElement(vector, axis).text = str(n)
            elif key == 'Position':
                frame = prop(props, 'CoordinateFrame', 'CFrame')
                for axis, n in zip(('X', 'Y', 'Z'), value):
                    ET.SubElement(frame, axis).text = str(n)
                for row in range(3):
                    for col in range(3):
                        ET.SubElement(frame, f'R{row}{col}').text = '1' if row == col else '0'
            elif key == 'Color':
                r, g, b = (round(n * 255) for n in value)
                prop(props, 'Color3uint8', 'Color3uint8', (r << 16) | (g << 8) | b)
            else:
                raise ValueError(f'Unsupported property: {key}')
        for key, value in data.items():
            if not key.startswith('$'):
                node(obj, key, value)
        return obj

    project = json.loads((ROOT / 'default.project.json').read_text())
    for name, data in project['tree'].items():
        if not name.startswith('$'):
            node(root, name, data)
    destination.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(root)
    ET.ElementTree(root).write(destination, encoding='utf-8', xml_declaration=True)
    return sources


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, default=ROOT / 'build/MysticGarden.rbxlx')
    args = parser.parse_args()
    count = build(args.output)
    print(f'Exported {count} script sources to {args.output} (Studio opening still requires validation).')
