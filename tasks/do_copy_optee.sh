#!/usr/bin/env bash

do_copy_optee_imx8m() {
	# This FIT loads BL32 directly at its entry address. The OPTE header
	# in core/tee.bin is not executable there, so stage the raw payload.
	local file="$OUT_DIR/optee/build.$OPTEE_BOARD/core/tee-raw.bin"
	if [[ ! -s "$file" ]]; then
		echo "buildboot: error: missing $file" >&2
		return 2
	fi
	cp -f "$file" "$OUT_DIR/imx-boot-tools/tee.bin"
}
