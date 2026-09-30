#!/usr/bin/env bash

do_encrypt_dek_blob_image_imx8m() {
	local output="$OUT_DIR/encryption"

	if ! command -v cst >/dev/null; then
		echo "buildboot: error: cst is unavailable; enter the buildboot Nix shell" >&2
		return 2
	fi

	(
		cd "$output"
		export SIG_DATA_PATH="$OUT_DIR/hab-data"
		cp "plain-$BOOT_IMAGE" "encrypted-spl-$BOOT_IMAGE"
		cst -i csf_spl_encrypt.txt -o csf_spl_encrypt.bin
		chmod 600 dek_spl.bin
		cp "encrypted-spl-$BOOT_IMAGE" "encrypted-spl-sign-$BOOT_IMAGE"
		cst -i csf_spl_sign.txt -o csf_spl_sign.bin
		copy_dek_blob_nonce_mac csf_spl_encrypt.bin csf_spl_sign.bin

		cp "encrypted-spl-$BOOT_IMAGE" "encrypted-fit-$BOOT_IMAGE"
		cst -i csf_fit_encrypt.txt -o csf_fit_encrypt.bin
		chmod 600 dek_fit.bin
		cp "encrypted-fit-$BOOT_IMAGE" "encrypted-fit-sign-$BOOT_IMAGE"
		cst -i csf_fit_sign.txt -o csf_fit_sign.bin
		copy_dek_blob_nonce_mac csf_fit_encrypt.bin csf_fit_sign.bin
	)
}

copy_dek_blob_nonce_mac() {
	local source="$1"
	local destination="$2"
	local source_size destination_size

	source_size=$(stat --format=%s "$source")
	destination_size=$(stat --format=%s "$destination")
	dd if="$source" of="$destination" bs=1 count=36 \
		skip=$((source_size - 36)) seek=$((destination_size - 36)) \
		conv=notrunc status=none
}
