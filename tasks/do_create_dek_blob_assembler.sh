#!/usr/bin/env bash

do_create_dek_blob_assembler_imx8m() {
	local template="$TASKS_DIR/assemble_dek_blob.sh.in"
	local output="$OUT_DIR/encryption/assemble-dek-blob.sh"

	sed \
		-e "s|@ENCRYPTION_DIR@|$OUT_DIR/encryption|" \
		-e "s|@HAB_DATA@|$OUT_DIR/hab-data|" \
		"$template" > "$output"
	chmod 700 "$output"
}
