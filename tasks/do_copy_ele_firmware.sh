#!/usr/bin/env bash

do_copy_ele_firmware_imx95() {
	local stage="$OUT_DIR/imx-boot-tools"
	if [[ ! -f "$ELE_FIRMWARE_FILE" ]]; then
		echo "buildboot: error: missing ELE container $ELE_FIRMWARE_FILE" >&2
		return 2
	fi
	mkdir -p "$stage"
	cp -f "$ELE_FIRMWARE_FILE" "$stage/$(basename "$ELE_FIRMWARE_FILE")"
}
