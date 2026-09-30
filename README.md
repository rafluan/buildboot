# buildboot

`buildboot` builds Variscite bootloader images from TOML configurations and
small shell tasks. Python reads the configuration, prepares sources, and
exports values to the shell tasks.

## Quick start

```sh
nix develop
./buildboot list
./buildboot sources imx8mn-var-som mx8mn-yocto-scarthgap-6.6.y_2.2.2-v1.1
./buildboot build imx8mn-var-som mx8mn-yocto-scarthgap-6.6.y_2.2.2-v1.1 --jobs 8
./buildboot clean imx8mn-var-som
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
separately with `nix build .#imx-cst`, `nix build .#imx-signer`, or
`nix build .#arm-none-eabi-toolchain`.
The optional `arm-none-eabi-gdb-py` frontend is omitted because the vendor
binary requires a Python 3.8 ABI; the standard GDB and compiler tools remain
available.

## HAB-signed images

HAB signing is optional. Add `--security hab` only when a signed i.MX8M boot
image is required:

```sh
./buildboot sources imx8mn-var-som mx8mn-yocto-scarthgap-6.6.y_2.2.2-v1.1
./buildboot build imx8mn-var-som mx8mn-yocto-scarthgap-6.6.y_2.2.2-v1.1 \
    --security hab --jobs 8
```

The configuration pins the same public test PKI and `imx_signer` revision used
by `meta-variscite-hab`. The signer reads the boot image, creates the CSF data,
calls NXP CST, and writes the signed result to the normal output filename.
These published keys are for development only. Never use them to provision or
close a production device.

The normal build command remains unsigned. The device does not need to be
closed to boot and inspect a HAB-signed image.

### Preparing an i.MX8M DEK-blob generator

DEK-blob support is an optional layer on top of HAB and is currently configured
for the VAR-SOM-MX8MN release above:

```sh
./buildboot sources imx8mn-var-som mx8mn-yocto-scarthgap-6.6.y_2.2.2-v1.1
./buildboot build imx8mn-var-som mx8mn-yocto-scarthgap-6.6.y_2.2.2-v1.1 \
    --security hab --encryption dek-blob --jobs 8
```

This builds U-Boot with the DEK-blob commands, OP-TEE with NXP DEK-blob
encapsulation enabled, and ATF with the OP-TEE dispatcher. It replaces the
prebuilt `tee.bin` from `imx-mkimage` with the newly built OP-TEE image. The
result is the HAB-signed `dek-blob-generator-imx-boot-sd.bin`.

This image is a HAB-signed generator, not the final encrypted image. It can
boot on an open development board for validation, but `dek_blob` can produce
usable blobs only on a closed board. It contains a dummy DEK blob. The NXP procedure
must still encrypt and sign the SPL and FIT, create the per-device DEK blobs,
and insert the resulting CSFs and blobs before flashing. Do not treat this
generator image as the final secure boot image.

The build also creates `out/encryption/`. It contains the encrypted SPL and
FIT image, `dek_spl.bin`, `dek_fit.bin`, their CSFs, and
`assemble-dek-blob.sh`. The offsets are read from the HAB signer output for the
current image; they are not fixed in the build scripts.
The plaintext DEK files are set to owner-only permissions because they are
secret keys.

The generator image can be tested on an open development device. Write it at
the configured boot offset (32 KiB for i.MX8MN), then boot it and run:

```console
=> hab_status
=> help dek_blob
=> help set_priblob_bitfield
```

The boot must complete without HAB events, and both commands must be present.
`hab fuse not enabled` is expected on an open device. Do not run
`set_priblob_bitfield`: it changes CAAM's PRIBLOB setting and prevents creation
of blobs that the encrypted boot image can use.

#### Per-device encrypted boot procedure

The final encrypted image requires two DEKs, one for the SPL and one for the
FIT. CST first encrypts the SPL and FIT on the host and writes their plaintext
DEKs as `dek_spl.bin` and `dek_fit.bin`. These files are inputs to the device,
not the final blobs.

On a closed device that has been closed with the same SRK keys, copy both DEK
files to a FAT partition and boot the generator image. Adjust `mmc 1:1` if the
FAT partition is exposed at another device/partition. Run `dek_blob` once for
each file:

```console
=> fatload mmc 1:1 0x40400000 dek_spl.bin
=> dek_blob 0x40400000 0x40401000 128
=> fatwrite mmc 1:1 0x40401000 dek_spl_blob.bin 0x48
=> reset
=> fatload mmc 1:1 0x40402000 dek_fit.bin
=> dek_blob 0x40402000 0x40403000 128
=> fatwrite mmc 1:1 0x40403000 dek_fit_blob.bin 0x48
```

The command asks OP-TEE to use CAAM and produces
`dek_spl_blob.bin` and `dek_fit_blob.bin`. Each resulting blob is tied to the
device OTPMK and cannot be reused on another SoM.

Finally, on the host, insert the encrypted SPL and FIT CSFs together with the
two device-specific blobs into the encrypted boot image:

```sh
nix develop --command \
    build/imx8mn-var-som/mx8mn-yocto-scarthgap-6.6.y_2.2.2-v1.1/out/encryption/assemble-dek-blob.sh \
    /path/to/dek-blobs
```

The directory must contain exactly the 72-byte `dek_spl_blob.bin` and
`dek_fit_blob.bin` files from that SoM. The script creates
`out/encryption/encrypted-imx-boot-sd.bin`. Only that assembled image is the
final encrypted boot image.

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
`imx8mm-var-dart/mx8mm-yocto-scarthgap-6.6.y_2.2.2-v1.2`. The FIT includes both
board DTBs:

```sh
./buildboot sources imx8mm-var-dart mx8mm-yocto-scarthgap-6.6.y_2.2.2-v1.2
./buildboot build imx8mm-var-dart mx8mm-yocto-scarthgap-6.6.y_2.2.2-v1.2 --jobs 8
```

### DART-MX95

The i.MX95 flow builds U-Boot, ATF, OEI DDR and TCM images, System Manager,
and the ELE container before packaging the `flash_a55` image. The configured
OEI DDR timing must match the module's installed RAM size. The current
configuration targets the 8 GB LPDDR5 DART-MX95. The local Nix shell provides
the required `arm-none-eabi-gcc` toolchain.

```sh
./buildboot sources imx95-var-dart mx95-yocto-wrynose-6.18.20-2.0.0-v1.2
./buildboot build imx95-var-dart mx95-yocto-wrynose-6.18.20-2.0.0-v1.2 --jobs 8
```
