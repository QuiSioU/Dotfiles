# VSCodium/build_package.py


from pathlib import Path
import json


def get_themes_info(theme_dir: Path, root_dir: Path) -> list[dict[str, str]]:
    themes: list[dict[str, str]] = []

    for t in theme_dir.iterdir():
        with open(t, "r") as f:
            theme_data = json.load(f)

        theme_type = theme_data.get("type", None)

        themes.append({
            "label": theme_data.get("name", "Unknown"),
            "uiTheme": f"vs-{theme_type if theme_type is not None else 'dark'}",
            "path": str(t.resolve().relative_to(root_dir))
        })

    return themes


if __name__ == "__main__":
    root_dir: Path = Path(__file__).resolve().parent

    package_json: dict = {
        "name": "elysian-color-themes",
        "displayName": "Elysian Themes",
        "description": "Color themes for my dotfiles",
        "version": "0.1.0",
        "private": True,
        "engines": {
            "vscode": "^1.50.0"
        },
        "categories": [
            "Themes"
        ],
        "contributes": {
            "themes": get_themes_info(root_dir / "themes", root_dir)
        },
        "repository": {
            "type": "git",
            "url": "https://github.com/QuiSioU/Dotfiles.git",
            "directory": "VSCodium"
        }
    }

    with open(root_dir / "package.json", "w") as f:
        f.write(json.dumps(package_json, indent=4) + '\n')
