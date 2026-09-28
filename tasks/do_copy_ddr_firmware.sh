#!/usr/bin/env bash

do_copy_ddr_firmware_imx8m() {
	local -a files
	shopt -s nullglob
	files=("$DDR_FIRMWARE_DIR"/*.bin)
	shopt -u nullglob

	if ((${#files[@]} == 0)); then
		echo "buildboot: error: no DDR firmware in $DDR_FIRMWARE_DIR" >&2
		return 2
	fi

	mkdir -p "$OUT_DIR/imx-boot-tools"
	cp -f "${files[@]}" "$OUT_DIR/imx-boot-tools/"
}

do_copy_ddr_firmware_imx95() {
	local -a files
	shopt -s nullglob
	files=("$DDR_FIRMWARE_DIR"/lpddr5*.bin)
	shopt -u nullglob

	if ((${#files[@]} == 0)); then
		echo "buildboot: error: no LPDDR5 firmware in $DDR_FIRMWARE_DIR" >&2
		return 2
	fi

	mkdir -p "$OUT_DIR/imx-boot-tools"
	cp -f "${files[@]}" "$OUT_DIR/imx-boot-tools/"
}
