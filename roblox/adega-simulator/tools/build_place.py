#!/usr/bin/env python3
"""Gera AdegaSimulator.rbxlx (arquivo de lugar do Roblox Studio) a partir da pasta src/.

Segue as convenções do Rojo:
  pasta/init.server.luau -> Script com os outros arquivos da pasta como filhos
  pasta/init.client.luau -> LocalScript com os outros arquivos como filhos
  arquivo.luau           -> ModuleScript
  pasta comum            -> Folder

Uso: python3 tools/build_place.py
"""

from pathlib import Path
from xml.sax.saxutils import escape

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "src"
OUT = ROOT / "AdegaSimulator.rbxlx"

counter = 0


def referent():
    global counter
    counter += 1
    return f"RBX{counter:08X}"


def cdata(text):
    if "]]>" in text:
        raise ValueError("o código não pode conter ]]>")
    return f"<![CDATA[{text}]]>"


def item(class_name, name, children="", source=None, indent=1):
    pad = "\t" * indent
    props = f'{pad}\t\t<string name="Name">{escape(name)}</string>\n'
    if source is not None:
        props += f'{pad}\t\t<ProtectedString name="Source">{cdata(source)}</ProtectedString>\n'
    return (
        f'{pad}<Item class="{class_name}" referent="{referent()}">\n'
        f"{pad}\t<Properties>\n{props}{pad}\t</Properties>\n"
        f"{children}"
        f"{pad}</Item>\n"
    )


def script_name(path):
    name = path.name
    for suffix in (".server.luau", ".client.luau", ".luau"):
        if name.endswith(suffix):
            return name[: -len(suffix)]
    return name


def build_dir(directory, indent):
    init_server = directory / "init.server.luau"
    init_client = directory / "init.client.luau"
    children = "".join(build_entry(child, indent + 1) for child in sorted(directory.iterdir()) if not child.name.startswith("init."))
    if init_server.exists():
        return item("Script", directory.name, children, init_server.read_text(encoding="utf-8"), indent)
    if init_client.exists():
        return item("LocalScript", directory.name, children, init_client.read_text(encoding="utf-8"), indent)
    return item("Folder", directory.name, children, None, indent)


def build_entry(path, indent):
    if path.is_dir():
        return build_dir(path, indent)
    if not path.name.endswith(".luau"):
        return ""
    source = path.read_text(encoding="utf-8")
    if path.name.endswith(".server.luau"):
        return item("Script", script_name(path), "", source, indent)
    if path.name.endswith(".client.luau"):
        return item("LocalScript", script_name(path), "", source, indent)
    return item("ModuleScript", script_name(path), "", source, indent)


def service(class_name, directory, indent=1):
    children = ""
    if directory.exists():
        children = "".join(build_entry(child, indent + 1) for child in sorted(directory.iterdir()))
    return item(class_name, class_name, children, None, indent)


def main():
    body = ""
    body += service("ReplicatedStorage", SRC / "ReplicatedStorage")
    body += service("ServerScriptService", SRC / "ServerScriptService")
    player_scripts = service("StarterPlayerScripts", SRC / "StarterPlayer" / "StarterPlayerScripts", 2)
    body += item("StarterPlayer", "StarterPlayer", player_scripts, None, 1)
    xml = (
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">\n'
        "\t<External>null</External>\n"
        "\t<External>nil</External>\n"
        f"{body}"
        "</roblox>\n"
    )
    OUT.write_text(xml, encoding="utf-8")
    print(f"Gerado {OUT.relative_to(ROOT)} ({len(xml) // 1024} KB, {counter} objetos)")


if __name__ == "__main__":
    main()
