#!/usr/bin/env bash

do_copy_imx_mkimage_imx8m() {
	local stage="$OUT_DIR/imx-boot-tools"
	local helper

	rm -rf -- "$stage"
	mkdir -p "$stage" "$OUT_DIR/scripts"
	cp -a "$MKIMAGE_DIR/iMX8M/." "$stage/"

	for helper in pad_image.sh dtb_check.sh; do
		if [[ -f "$MKIMAGE_DIR/scripts/$helper" ]]; then
			cp -f "$MKIMAGE_DIR/scripts/$helper" "$OUT_DIR/scripts/$helper"
			if [[ "$helper" == pad_image.sh ]]; then
				cp -f "$MKIMAGE_DIR/scripts/$helper" "$stage/$helper"
			fi
		fi
	done
}

do_copy_imx_mkimage_imx95() {
	local stage="$OUT_DIR/imx-boot-tools"
	mkdir -p "$stage" "$OUT_DIR/scripts"
	cp -a "$MKIMAGE_DIR/iMX95/." "$stage/"
	cp -a "$MKIMAGE_DIR/scripts/." "$OUT_DIR/scripts/"
}
