"""Delete generated output while preserving sources and downloaded firmware."""
from pathlib import Path
import shutil


def clean(build_root: Path, board: str, release: str | None) -> None:
    releases = [release] if release else [path.name for path in (build_root / board).glob("*")]
    for name in releases:
        output = build_root / board / name / "out"
        if output.exists():
            print(f"removing {output}")
            shutil.rmtree(output)
        else:
            print(f"already clean: {output}")
