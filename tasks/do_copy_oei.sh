#!/usr/bin/env bash

do_copy_oei_imx95() {
	local stage="$OUT_DIR/imx-boot-tools"
	local file
	local -a images=(
		"$OEI_DIR/build/$OEI_BOARD/ddr/oei-m33-ddr.bin"
		"$OEI_DIR/build/$OEI_BOARD/tcm/oei-m33-tcm.bin"
	)
	mkdir -p "$stage"
	for file in "${images[@]}"; do
		if [[ ! -f "$file" ]]; then
			echo "buildboot: error: missing OEI image $file" >&2
			return 2
		fi
		cp -f "$file" "$stage/$(basename "$file")"
	done
}
