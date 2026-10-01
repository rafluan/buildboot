#!/usr/bin/env bash

do_read_dek_blob_layout_imx8m() {
	local stage="$OUT_DIR/imx-boot-tools"
	local output="$OUT_DIR/encryption"
	local -a spl_blocks fit_blocks fit_fdt_blocks data_blocks
	local start offset size address block

	mapfile -t spl_blocks < <(grep -oE '0x[0-9A-Fa-f]+ 0x[0-9A-Fa-f]+ 0x[0-9A-Fa-f]+' "$stage/csf_image0.txt")
	mapfile -t fit_blocks < <(grep -oE '0x[0-9A-Fa-f]+ 0x[0-9A-Fa-f]+ 0x[0-9A-Fa-f]+' "$stage/csf_image1.txt")
	mapfile -t fit_fdt_blocks < <(grep -oE '0x[0-9A-Fa-f]+ 0x[0-9A-Fa-f]+ 0x[0-9A-Fa-f]+' "$stage/csf_image2.txt")
	if (( ${#spl_blocks[@]} != 1 || ${#fit_blocks[@]} < 3 || ${#fit_fdt_blocks[@]} < 1 )); then
		echo "buildboot: error: unexpected HAB block layout" >&2
		return 2
	fi

	read -r start offset size <<< "${spl_blocks[0]}"
	printf 'SPL_START=%q\nSPL_OFFSET=%q\nSPL_SIZE=%q\n' "$start" "$offset" "$size" > "$output/layout.env"
	printf 'BOOT_IMAGE=%q\n' "$BOOT_IMAGE" >> "$output/layout.env"
	printf 'SPL_DECRYPT_START=%q\nSPL_DECRYPT_SIZE=%q\n' \
		"$(printf '0x%x' $((start + 0x40)))" "$(printf '0x%x' $((size - 0x40)))" >> "$output/layout.env"
	printf 'SPL_BLOB_ADDRESS=%q\nSPL_CSF_OFFSET=%q\nSPL_BLOB_OFFSET=%q\n' \
		"$(printf '0x%x' $((start + size + 0x2000)))" \
		"$(printf '0x%x' $((offset + size)))" \
		"$(printf '0x%x' $((offset + size + 0x2000)))" >> "$output/layout.env"

	read -r _ offset size <<< "${fit_blocks[0]}"
	printf 'FIT_HEADER_BLOCK=%q\nFIT_CSF_OFFSET=%q\n' "${fit_blocks[0]}" \
		"$(printf '0x%x' $((offset + size)))" >> "$output/layout.env"
	read -r _ offset size <<< "${fit_fdt_blocks[0]}"
	printf 'FIT_FDT_BLOCK=%q\nFIT_FDT_CSF_OFFSET=%q\n' "${fit_fdt_blocks[0]}" \
		"$(printf '0x%x' $((offset + size)))" >> "$output/layout.env"

	: > "$output/fit-decrypt-blocks.txt"
	: > "$output/fit-auth-blocks.txt"
	for block in "${fit_blocks[@]:1}"; do
		read -r address offset size <<< "$block"
		if (( address == 0x40400000 )); then
			printf 'FIT_BLOB_OFFSET=%q\n' "$offset" >> "$output/layout.env"
			continue
		fi
		data_blocks+=("$block")
	done
	write_dek_blob_blocks "$output/fit-decrypt-blocks.txt" "encrypted-fit-$BOOT_IMAGE" "${data_blocks[@]}"
	# The DEK blob is replaced per device after signing and must not be
	# covered by Authenticate Data. Keep the FIT header and every payload.
	write_dek_blob_blocks "$output/fit-auth-blocks.txt" "encrypted-fit-$BOOT_IMAGE" \
		"${fit_blocks[0]}" "${data_blocks[@]}"
}

write_dek_blob_blocks() {
	local file="$1"
	local image="$2"
	shift 2
	local block address offset size
	for block in "$@"; do
		read -r address offset size <<< "$block"
		printf '    Blocks = %s %s %s "%s"\n' "$address" "$offset" "$size" "$image" >> "$file"
	done
}
