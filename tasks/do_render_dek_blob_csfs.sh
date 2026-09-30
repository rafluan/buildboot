#!/usr/bin/env bash

do_render_dek_blob_csfs_imx8m() {
	local output="$OUT_DIR/encryption"
	local templates="$TASKS_DIR/../configs/hab"

	source "$output/layout.env"
	for name in spl_encrypt spl_sign fit_encrypt fit_sign fit_fdt; do
		render_dek_blob_csf "$templates/csf_${name}.cfg.in" "$output/csf_${name}.txt"
	done
	replace_dek_blob_blocks "$output/csf_fit_encrypt.txt" '@FIT_DECRYPT_BLOCKS@' "$output/fit-decrypt-blocks.txt"
	replace_dek_blob_blocks "$output/csf_fit_sign.txt" '@FIT_AUTH_BLOCKS@' "$output/fit-auth-blocks.txt"
	replace_dek_blob_blocks "$output/csf_fit_sign.txt" '@FIT_DECRYPT_BLOCKS@' "$output/fit-decrypt-blocks.txt"
}

render_dek_blob_csf() {
	local template="$1"
	local output="$2"

	sed \
		-e "s|@SRK_TABLE@|$OUT_DIR/hab-data/crts/SRK_1_2_3_4_table.bin|" \
		-e "s|@CSFK_CERT@|$OUT_DIR/hab-data/crts/CSF1_1_sha256_4096_65537_v3_usr_crt.pem|" \
		-e "s|@IMG_CERT@|$OUT_DIR/hab-data/crts/IMG1_1_sha256_4096_65537_v3_usr_crt.pem|" \
		-e "s|@PLAIN_IMAGE@|plain-$BOOT_IMAGE|g" \
		-e "s|@SPL_ENCRYPTED_IMAGE@|encrypted-spl-$BOOT_IMAGE|g" \
		-e "s|@SPL_SIGN_IMAGE@|encrypted-spl-sign-$BOOT_IMAGE|g" \
		-e "s|@SPL_START@|$SPL_START|g" \
		-e "s|@SPL_OFFSET@|$SPL_OFFSET|g" \
		-e "s|@SPL_SIZE@|$SPL_SIZE|g" \
		-e "s|@SPL_DECRYPT_START@|$SPL_DECRYPT_START|g" \
		-e "s|@SPL_DECRYPT_SIZE@|$SPL_DECRYPT_SIZE|g" \
		-e "s|@SPL_BLOB_ADDRESS@|$SPL_BLOB_ADDRESS|g" \
		-e "s|@FIT_HEADER_BLOCK@|$FIT_HEADER_BLOCK|g" \
		-e "s|@FIT_FDT_BLOCK@|$FIT_FDT_BLOCK|g" \
		-e "s|@FINAL_IMAGE@|encrypted-$BOOT_IMAGE|g" \
		"$template" > "$output"
}

replace_dek_blob_blocks() {
	local output="$1"
	local marker="$2"
	local blocks="$3"

	sed -i "\\|$marker|r $blocks" "$output"
	sed -i "\\|$marker|d" "$output"
}
