#!/usr/bin/env bash

do_copy_dek_blob_plain_image_imx8m() {
	local image="$OUT_DIR/imx-boot-tools/$BOOT_IMAGE"
	local output="$OUT_DIR/encryption"

	mkdir -p "$output"
	cp -f "$image" "$output/plain-$BOOT_IMAGE"
}
