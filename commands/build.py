"""Export values from one configuration and invoke its shell tasks."""
from pathlib import Path
import os
import subprocess


def build(
    config: dict,
    work: Path,
    output: Path,
    jobs: int,
    root: Path,
    security: str = "none",
    encryption: str = "none",
) -> None:
    board = config["board_config"]
    sources = config["sources"]
    package = config["packaging"]
    firmware = config.get("firmware", {})
    oei = config.get("oei", {})
    system_manager = config.get("system_manager", {})
    encryption_config = config.get("encryption", {}).get(encryption, {})
    if jobs < 1:
        raise ValueError("--jobs must be greater than zero")
    if encryption != "none" and security != "hab":
        raise ValueError("--encryption dek-blob requires --security hab")
    if encryption != "none" and not board["soc"].startswith("iMX8M"):
        raise ValueError("--encryption dek-blob is supported only on i.MX8M")
    optee = sources.get("optee")
    if encryption != "none" and not encryption_config:
        raise ValueError(f"{config['board']} has no configuration for {encryption}")
    if encryption != "none" and not optee:
        raise ValueError(f"{config['board']} has no OP-TEE source")
    optee_dir = work / optee["directory"] if optee else None
    if encryption != "none" and not optee_dir.is_dir():
        raise ValueError("OP-TEE source is missing; run buildboot sources first")

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
        "OPTEE_DIR": str(optee_dir or ""),
        "OPTEE_BOARD": encryption_config.get("optee_board", ""),
        "OPTEE_UART_BASE": encryption_config.get("optee_uart_base", ""),
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
        "BUILD_SECURITY": security,
        "BUILD_ENCRYPTION": encryption.replace("-", "_"),
    })

    if security == "hab":
        hab = config.get("hab")
        certificates = config.get("sources", {}).get("hab_certs")
        if not hab or not certificates:
            raise ValueError(f"{config['board']} has no HAB configuration")
        certs_dir = (
            work
            / certificates["directory"]
            / hab.get("certificates", "iMX8M")
        )
        if not certs_dir.is_dir():
            raise ValueError("HAB certificate files are missing; run buildboot sources first")
        env.update({
            "HAB_CERTS_DIR": str(certs_dir),
            "HAB_CSF_TEMPLATE": str(root / hab["csf_template"]),
            "HAB_CST_SERIAL": hab["serial"],
            "HAB_CST_KEYPASS": hab["keypass"],
        })

    task_runner = root / "tasks" / "run.sh"
    for task in ("do_configure", "do_compile", "do_package"):
        subprocess.run(["bash", str(task_runner), task], cwd=root, env=env, check=True)


def source_path(work: Path, source: dict | None) -> str:
    return str(work / source["directory"]) if source else ""


def firmware_path(work: Path, firmware: dict | None, relative: str) -> str:
    return str(work / firmware["directory"] / relative) if firmware else ""
