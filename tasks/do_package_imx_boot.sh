#!/usr/bin/env bash

do_package_imx_boot_imx8m() {
	local stage="$OUT_DIR/imx-boot-tools"
	PATH="$stage:$PATH" make -C "$stage" -f soc.mak \
		"SOC=$IMX_SOC" "SOC_DIR=$(basename "$stage")" \
		"dtbs=$BOOT_DTBS" "MKIMG=./mkimage_imx8" \
		"PAD_IMAGE=./pad_image.sh" CC=gcc \
		'CFLAGS=-O2 -Wall -std=c99' "OUTIMG=$BOOT_IMAGE" "$IMXBOOT_TARGET"
}

do_package_imx_boot_imx95() {
	local stage="$OUT_DIR/imx-boot-tools"
	local flash_image="$stage/flash.bin"
	local output_image="$stage/$BOOT_IMAGE"
	: "${IMXBOOT_REVISION:?missing i.MX95 silicon revision}"
	: "${IMXBOOT_OEI:?missing OEI setting}"
	: "${LPDDR_TYPE:?missing LPDDR type}"
	: "${LPDDR_FUNCTION:?missing LPDDR training function}"

	make -C "$stage" -f soc.mak \
		"SOC=$IMX_SOC" "MKIMG=./mkimage_imx8" \
		"REV=$IMXBOOT_REVISION" "OEI=$IMXBOOT_OEI" \
		"LPDDR_TYPE=$LPDDR_TYPE" "LPDDR_FUNC=$LPDDR_FUNCTION" \
		"$IMXBOOT_TARGET"

	if [[ ! -s "$flash_image" ]]; then
		echo "buildboot: error: imx-mkimage did not create $flash_image" >&2
		return 2
	fi
	cp -f "$flash_image" "$output_image"
}
