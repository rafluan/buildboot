#!/usr/bin/env bash

do_copy_system_manager_imx95() {
	local stage="$OUT_DIR/imx-boot-tools"
	local file="$SYSTEM_MANAGER_DIR/build/$SYSTEM_MANAGER_CONFIG/m33_image.bin"
	if [[ ! -f "$file" ]]; then
		echo "buildboot: error: missing System Manager image $file" >&2
		return 2
	fi
	mkdir -p "$stage"
	cp -f "$file" "$stage/m33_image.bin"
}
