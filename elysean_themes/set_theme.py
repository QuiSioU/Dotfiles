# elysean_themes/set_theme.py


from sys import argv
from pathlib import Path
import tomllib
import subprocess


def print_usage():
    print("Usage:")
    print("\tpython set_theme.py <toml-theme-file>\n")
    print("Example:")
    print("\tpython set_theme ~/.config/elysean_themes/default/Oxocarbon.toml")


def parse_toml(toml_path: str) -> dict[str, dict[str, str]]:
    if not Path(toml_path).exists():
        raise FileNotFoundError(f"File {str(toml_path)} does not exist.")

    with open(toml_path, "rb") as f:
        data = tomllib.load(f)

    return data


def hyprland_quickshell(config_dir: Path, theme: dict[str, dict[str, str]]) -> None:
    filepath: Path = config_dir / "theme.lua"

    with open(filepath, "w+") as f:
        f.write(f"-- {filepath.relative_to(config_dir.parent.parent)}\n\n\n")
        f.write("return {\n")
        for k1, v1 in theme.items():
            if k1 == "meta":
                continue

            f.write(f"\n\t{k1} = {{\n")
            for k2, v2 in v1.items():
                f.write(f"\t\t{k2:<20} = \"{v2}\",\n")
            f.write("\t},\n")

        f.write("}\n")


def kitty(config_dir: Path, theme: dict[str, dict[str, str]]) -> None:
    filepath: Path = config_dir / "theme.conf"

    with open(filepath, "w+") as f:
        f.write(f"# {filepath.relative_to(config_dir.parent.parent)}\n\n\n")

        # Set here the main colors directly
        f.write(f"{"background":<25} {theme["colors"]["BG"][0:7]}\n")
        # ...


if __name__ == "__main__":
    argc: int = len(argv)
    if argc != 2:
        print_usage()

    theme: dict[str, dict[str, str]] = parse_toml(argv[1])

    config_dir: Path = Path(__file__).parent / "active_theme"
    config_dir.mkdir(exist_ok=True)

    # Create the template files for all utilities
    hyprland_quickshell(config_dir, theme)
    kitty(config_dir, theme)

    # Reload what needs to be reloaded
    subprocess.run(["hyprctl", "reload"])
