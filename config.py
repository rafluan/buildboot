"""Find and read buildboot configurations."""
from pathlib import Path
import tomllib


ROOT = Path(__file__).resolve().parent
CONFIGS_DIR = ROOT / "configs"
BUILD_DIR = ROOT / "build"


def load_config(board: str, release: str) -> dict:
    path = CONFIGS_DIR / board / f"{release}.toml"
    if not path.is_file():
        raise ValueError(f"config not found: {path.relative_to(ROOT)}")

    with path.open("rb") as file:
        return tomllib.load(file)


def available_configs():
    for path in sorted(CONFIGS_DIR.glob("*/*.toml")):
        with path.open("rb") as file:
            yield tomllib.load(file)


def workspace(config: dict) -> Path:
    return BUILD_DIR / config["board"] / config["release"]
