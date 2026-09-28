"""Export values from one configuration and invoke its shell tasks."""
from pathlib import Path
import os
import subprocess


def build(config: dict, work: Path, output: Path, jobs: int, root: Path) -> None:
    board = config["board_config"]
    sources = config["sources"]
    package = config["packaging"]
    firmware = config.get("firmware", {})
    oei = config.get("oei", {})
    system_manager = config.get("system_manager", {})
    if jobs < 1:
        raise ValueError("--jobs must be greater than zero")

    env = os.environ.copy()
    env.update({
        "BUILDBOOT_BOARD": config["board"],
        "BUILDBOOT_RELEASE": config["release"],
        "SOC": board["soc"],
        "MEMORY": board.get("memory", ""),
        "JOBS": str(jobs),
        "OUT_DIR": str(output),
        "UBOOT_DIR": str(work / sources["uboot"]["directory"]),
        "UBOOT_DEFCONFIG": sources["uboot"]["defconfig"],
        "ATF_DIR": str(work / sources["atf"]["directory"]),
        "MKIMAGE_DIR": str(work / sources["mkimage"]["directory"]),
        "DDR_FIRMWARE_DIR": firmware_path(work, firmware.get("ddr"), "firmware/ddr/synopsys"),
        "ELE_FIRMWARE_FILE": firmware_path(work, firmware.get("ele"), package.get("ele_container", "")),
        "OEI_DIR": source_path(work, sources.get("oei")),
        "OEI_BOARD": oei.get("board", ""),
        "OEI_DDR_CONFIG": oei.get("ddr_config", ""),
        "OEI_REVISION": oei.get("revision", ""),
        "SYSTEM_MANAGER_DIR": source_path(work, sources.get("system_manager")),
        "SYSTEM_MANAGER_CONFIG": system_manager.get("config", ""),
        "IMX_SOC": package["soc"],
        "ATF_PLATFORM": package["atf_platform"],
        "BOOT_DTBS": " ".join(package.get("dtbs", [package.get("dtb", "")])),
        "IMXBOOT_TARGET": package["target"],
        "IMXBOOT_REVISION": package.get("revision", ""),
        "IMXBOOT_OEI": package.get("oei", ""),
        "LPDDR_TYPE": package.get("lpddr_type", ""),
        "LPDDR_FUNCTION": package.get("lpddr_function", ""),
        "BOOT_IMAGE": package["output"],
        "DD_SEEK_KIB": str(package["dd_seek_kib"]),
    })

    task_runner = root / "tasks" / "run.sh"
    for task in ("do_configure", "do_compile", "do_package"):
        subprocess.run(["bash", str(task_runner), task], cwd=root, env=env, check=True)


def source_path(work: Path, source: dict | None) -> str:
    return str(work / source["directory"]) if source else ""


def firmware_path(work: Path, firmware: dict | None, relative: str) -> str:
    return str(work / firmware["directory"] / relative) if firmware else ""
