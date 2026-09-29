# buildboot

`buildboot` builds Variscite bootloader images from TOML configurations and
small shell tasks. Python reads the configuration, prepares sources, and
exports values to the shell tasks.

## Quick start

```sh
nix develop
./buildboot list
./buildboot sources var-som-mx8mn mx8mn-yocto-scarthgap-6.6.y_2.2.2-v1.1
./buildboot build var-som-mx8mn mx8mn-yocto-scarthgap-6.6.y_2.2.2-v1.1 --jobs 8
./buildboot clean var-som-mx8mn
```

Run `./buildboot` for the command menu. Use `./buildboot list` to find valid
board and release names. `sources` clones missing Git checkouts and downloads
and extracts the firmware declared in the configuration. NXP firmware
installers are run with `--auto-accept`. `clean` removes only `out/`, preserving
source checkouts, downloaded archives, and extracted firmware.

The project flake pins its Nix dependencies in `flake.lock`. Its development
shell provides the native build tools, ARM64 and ARM32 cross-compilers, the
ARM bare-metal toolchain version 15.2.rel1 selected by the NXP Yocto recipe for
i.MX95, Python build utilities, and the NXP CST tools. Build the host tools
separately with `nix build .#imx-cst` or `nix build .#arm-none-eabi-toolchain`.
The optional `arm-none-eabi-gdb-py` frontend is omitted because the vendor
binary requires a Python 3.8 ABI; the standard GDB and compiler tools remain
available.

## Configuration and task layout

Each configuration represents one board and release and lives at
`configs/<board>/<release>.toml`. It declares source repositories and revisions,
firmware packages, board settings, and final image parameters.

The shell flow has three phases: `do_configure`, `do_compile`, and
`do_package`. A SoC-specific phase function calls small operation hooks. Each
hook lives in its own file under `tasks/`, such as `do_compile_uboot.sh` or
`do_copy_ddr_firmware.sh`. Implementations include the SoC override in their
function name, for example `do_compile_uboot_imx8m`.

Overrides come from `board_config.soc`. For `iMX95`, the dispatcher tries
`imx95`, then the `imx9` family, then the generic function. For `iMX8MP`, it
tries `imx8mp`, `imx8m`, `imx8`, then generic.

## Adding a machine with a new build flow

Use this sequence when a machine needs different configuration, build, or
packaging steps. The example uses `iMX93`; replace the names and settings with
those for the target machine.

1. Add `configs/<board>/<release>.toml`. Include the board and release names,
   `board_config.soc`, source repositories and commits, firmware packages, and
   the settings consumed by the build tasks. `buildboot list` discovers the
   configuration from its path and TOML contents.
2. Export any new TOML values in `commands/build.py` so tasks receive them as
   environment variables. Existing shared values such as `UBOOT_DIR`,
   `ATF_DIR`, `MKIMAGE_DIR`, `OUT_DIR`, and `JOBS` are already exported.
3. Add the new flow to `tasks/configure.sh`, `tasks/compile.sh`, and
   `tasks/package.sh`. Keep these functions as readable sequences of hooks:

   ```bash
   do_configure_imx93() {
       run_task do_configure_uboot
       run_task do_copy_imx_mkimage
       run_task do_copy_ddr_firmware
   }

   do_compile_imx93() {
       run_task do_compile_uboot
       run_task do_compile_imx_atf
       run_task do_compile_imx_mkimage
       run_task do_compile_coprocessor_firmware
   }

   do_package_imx93() {
       run_task do_copy_uboot
       run_task do_copy_imx_atf
       run_task do_copy_coprocessor_firmware
       run_task do_package_imx_boot
   }
   ```

4. Implement each required hook in its own `tasks/do_<operation>.sh` file.
   For example, `tasks/do_compile_coprocessor_firmware.sh` would define
   `do_compile_coprocessor_firmware_imx93()`. Hooks called by the phase must
   have an implementation for the new SoC or one of its families.
5. Run `./buildboot plan <board> <release>` to inspect the resolved settings,
   then `sources` and `build` with those names.

Do not add an override list to TOML. For an `iMX93` configuration, task lookup
automatically tries the exact SoC function, `imx9`, and generic implementations.

## Supported flows

### i.MX8MM Mini

DART-MX8M-MINI and VAR-SOM-MX8M-MINI use
`var-mx8mm-mini/mx8mm-yocto-scarthgap-6.6.y_2.2.2-v1.2`. The FIT includes both
board DTBs:

```sh
./buildboot sources var-mx8mm-mini mx8mm-yocto-scarthgap-6.6.y_2.2.2-v1.2
./buildboot build var-mx8mm-mini mx8mm-yocto-scarthgap-6.6.y_2.2.2-v1.2 --jobs 8
```

### DART-MX95

The i.MX95 flow builds U-Boot, ATF, OEI DDR and TCM images, System Manager,
and the ELE container before packaging the `flash_a55` image. The configured
OEI DDR timing must match the module's installed RAM size. The current
configuration targets the 8 GB LPDDR5 DART-MX95. The local Nix shell provides
the required `arm-none-eabi-gcc` toolchain.

```sh
./buildboot sources var-dart-mx95 mx95-yocto-wrynose-6.18.20-2.0.0-v1.2
./buildboot build var-dart-mx95 mx95-yocto-wrynose-6.18.20-2.0.0-v1.2 --jobs 8
```
