#!/usr/bin/env bash

# Copy Variscite's published test PKI into the build output. The source
# checkout stays unchanged; generated password files stay out of the source tree.
do_prepare_hab_signing_data_imx8m() {
	local signing_data="$OUT_DIR/hab-data"

	if [[ ! -d "$HAB_CERTS_DIR/crts" || ! -d "$HAB_CERTS_DIR/keys" ]]; then
		echo "buildboot: error: HAB PKI tree is incomplete; run buildboot sources first" >&2
		return 2
	fi

	if [[ ! -f "$HAB_CERTS_DIR/crts/SRK_1_2_3_4_table.bin" ]]; then
		echo "buildboot: error: Variscite HAB SRK table is missing" >&2
		return 2
	fi

	mkdir -p "$signing_data"
	cp -R "$HAB_CERTS_DIR/crts" "$HAB_CERTS_DIR/keys" "$signing_data/"
	printf '%s\n' "$HAB_CST_SERIAL" > "$signing_data/keys/serial"
	printf '%s\n' "$HAB_CST_KEYPASS" > "$signing_data/keys/key_pass.txt"
	printf '%s\n' "$HAB_CST_KEYPASS" >> "$signing_data/keys/key_pass.txt"
	chmod 700 "$signing_data/keys"
	chmod 600 "$signing_data/keys"/*
	cp "$HAB_CSF_TEMPLATE" "$OUT_DIR/csf_hab4.cfg"
}
