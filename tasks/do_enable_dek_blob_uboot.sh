#!/usr/bin/env bash

# Enable U-Boot commands and support required by the i.MX8M DEK-blob flow.
do_enable_dek_blob_uboot_imx8m() {
	local config="$OUT_DIR/uboot/.config"
	local option

	for option in FAT_WRITE CMD_DEKBLOB IMX_OPTEE_DEK_ENCAP CMD_PRIBLOB; do
		"$UBOOT_DIR/scripts/config" --file "$config" --enable "$option"
	done

	make -C "$UBOOT_DIR" "O=$OUT_DIR/uboot" olddefconfig

	for option in FAT_WRITE CMD_DEKBLOB IMX_OPTEE_DEK_ENCAP CMD_PRIBLOB; do
		if ! grep -qx "CONFIG_${option}=y" "$config"; then
			echo "buildboot: error: U-Boot does not support CONFIG_${option}" >&2
			return 2
		fi
	done
}
