# VSCodium/build_themes.py


from sys import argv
from pathlib import Path
import tomllib
from jinja2 import Environment, FileSystemLoader


def print_usage():
    print("Usage:")
    print("\tpython3 build_themes.py <toml-theme-file>\n")
    print("Example:")
    print("\tpython3 build_themes.py ~/.config/elysian_themes/themes/default/TokyoCarbon.toml")


def parse_toml(toml_path: str) -> dict[str, dict[str, str]]:
    if not Path(toml_path).exists():
        raise FileNotFoundError(f"File {str(toml_path)} does not exist.")

    with open(toml_path, "rb") as f:
        data = tomllib.load(f)

    return data


if __name__ == "__main__":
    argc: int = len(argv)
    if argc != 3:
        print_usage()
        exit(1)

    root_dir: Path = Path(__file__).resolve().parent

    selected_theme: dict[str, dict[str, str]] = parse_toml(argv[1])
    fallback_theme: dict[str, dict[str, str]] = parse_toml(
        Path.home() / ".config" / "elysian_themes" / "themes" / "default" / "TokyoCarbon.toml"
    )

    theme: dict[str, dict[str, str]] = {
        k: fallback_theme.get(k, {}) | selected_theme.get(k, {})
        for k in fallback_theme
    }

    env = Environment(loader=FileSystemLoader(root_dir))
    env.filters["rgba"] = lambda color, a: f"{color}{a}"

    f = Path(argv[2]) / f"{theme['meta']['id']}-color-theme.json"
    f.write_text(env.get_template("template.json").render(colors=theme["colors"], meta=theme["meta"]) + '\n')
