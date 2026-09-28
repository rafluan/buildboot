#!/usr/bin/env bash

do_copy_imx_atf_imx8m() {
	local file="$OUT_DIR/atf/$ATF_PLATFORM/release/bl31.bin"
	if [[ ! -f "$file" ]]; then
		echo "buildboot: error: missing $file" >&2
		return 2
	fi
	cp -f "$file" "$OUT_DIR/imx-boot-tools/bl31.bin"
}

do_copy_imx_atf_imx95() {
	local file="$OUT_DIR/atf/$ATF_PLATFORM/release/bl31.bin"
	if [[ ! -f "$file" ]]; then
		echo "buildboot: error: missing $file" >&2
		return 2
	fi
	cp -f "$file" "$OUT_DIR/imx-boot-tools/bl31.bin"
}
