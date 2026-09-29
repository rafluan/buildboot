#!/usr/bin/env bash

# Turn on U-Boot's HAB support before compiling the HAB variant.
do_enable_hab_uboot_imx8m() {
	local config="$OUT_DIR/uboot/.config"

	"$UBOOT_DIR/scripts/config" --file "$config" --enable IMX_HAB
	make -C "$UBOOT_DIR" "O=$OUT_DIR/uboot" olddefconfig

	if ! grep -qx 'CONFIG_IMX_HAB=y' "$config"; then
		echo "buildboot: error: selected U-Boot defconfig does not support CONFIG_IMX_HAB" >&2
		return 2
	fi
}
