#!/usr/bin/env bash

do_copy_dtbs_imx8m() {
	local source="$OUT_DIR/uboot/arch/arm/dts"
	local dtb
	local -a dtbs
	read -r -a dtbs <<< "$BOOT_DTBS"

	for dtb in "${dtbs[@]}"; do
		if [[ ! -f "$source/$dtb" ]]; then
			echo "buildboot: error: missing DTB $source/$dtb" >&2
			return 2
		fi
		cp -f "$source/$dtb" "$OUT_DIR/imx-boot-tools/$dtb"
	done
}
