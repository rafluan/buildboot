"""Create source checkouts without touching existing developer changes."""
from pathlib import Path
import shlex
import shutil
import subprocess
import tempfile


def sources(config: dict, work: Path) -> None:
    work.mkdir(parents=True, exist_ok=True)
    download_git_sources(config, work)
    download_firmware(config.get("firmware", {}), work)


def download_git_sources(config: dict, work: Path) -> None:
    for name, source in config["sources"].items():
        clone_source(name, source, config["release"], work)


def clone_source(name: str, source: dict, release: str, work: Path) -> None:
    path = work / source["directory"]
    if path.exists():
        if not (path / ".git").exists():
            raise ValueError(f"source exists but is not a Git checkout: {path}")
        print(f"reusing {name}: {path}")
        return

    run([
        "git", "clone",
        "--branch", source["branch"],
        "--single-branch",
        source["url"], str(path),
    ], work)

    if commit := source.get("commit"):
        run(["git", "switch", "--create", f"buildboot/{release}", commit], path)


def download_firmware(packages: dict, work: Path) -> None:
    for name, package in packages.items():
        download_firmware_package(name, package, work)


def download_firmware_package(name: str, package: dict, work: Path) -> None:
    extracted = work / package["directory"]
    files_glob = package["files_glob"]
    if has_files(extracted, files_glob):
        print(f"reusing {name} firmware: {extracted}")
        return

    if extracted.exists():
        raise ValueError(f"incomplete {name} firmware directory: {extracted}")

    archive = work / package["package"]
    if not archive.exists():
        run(["wget", "-c", "-O", str(archive), package["url"]], work)

    archive.chmod(archive.stat().st_mode | 0o111)
    run([f"./{archive.name}", "--auto-accept"], work)

    unpacked = work / archive.stem
    if not unpacked.is_dir():
        raise ValueError(f"package did not create {unpacked}")

    with tempfile.TemporaryDirectory(prefix=f"buildboot-{name}-", dir=work) as temporary:
        staged = Path(temporary) / "firmware-package"
        shutil.copytree(unpacked, staged)
        if not has_files(staged, files_glob):
            raise ValueError(f"{name} package contains no files matching {files_glob}")
        staged.rename(extracted)


def has_files(directory: Path, pattern: str) -> bool:
    return any(path.is_file() for path in directory.glob(pattern))


def run(command: list[str], cwd: Path) -> None:
    print("+", shlex.join(command))
    subprocess.run(command, cwd=cwd, check=True)
