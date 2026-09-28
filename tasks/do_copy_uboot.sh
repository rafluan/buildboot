#!/usr/bin/env bash

do_copy_uboot_imx8m() {
	local out="$OUT_DIR/uboot"
	local stage="$OUT_DIR/imx-boot-tools"
	local file

	for file in "$out/u-boot.bin" "$out/u-boot-nodtb.bin" \
		"$out/spl/u-boot-spl.bin"; do
		if [[ ! -f "$file" ]]; then
			echo "buildboot: error: missing $file" >&2
			return 2
		fi
		cp -f "$file" "$stage/$(basename "$file")"
	done

	if [[ ! -f "$out/tools/mkimage" ]]; then
		echo "buildboot: error: missing $out/tools/mkimage" >&2
		return 2
	fi
	cp -f "$out/tools/mkimage" "$stage/mkimage_uboot"
	cp -f "$out/tools/mkimage" "$stage/mkimage"
}

do_copy_uboot_imx95() {
	local out="$OUT_DIR/uboot"
	local stage="$OUT_DIR/imx-boot-tools"
	local file

	for file in "$out/u-boot.bin" "$out/spl/u-boot-spl.bin"; do
		if [[ ! -f "$file" ]]; then
			echo "buildboot: error: missing $file" >&2
			return 2
		fi
		cp -f "$file" "$stage/$(basename "$file")"
	done
}
