#!/usr/bin/env bash

# The DEK flow compiles a different BL31 (SPD=opteed). Keep its copy step
# separate from the normal HAB path so the standard image cannot accidentally
# consume the OP-TEE dispatcher.
do_copy_imx_atf_dek_blob_imx8m() {
	local file="$OUT_DIR/atf-dek-blob/$ATF_PLATFORM/release/bl31.bin"
	if [[ ! -f "$file" ]]; then
		echo "buildboot: error: missing $file" >&2
		return 2
	fi
	cp -f "$file" "$OUT_DIR/imx-boot-tools/bl31.bin"
}
