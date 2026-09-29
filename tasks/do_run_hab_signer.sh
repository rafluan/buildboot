#!/usr/bin/env bash

# Run the same Variscite signer used by the Yocto HAB layer.
do_run_hab_signer_imx8m() {
	if ! command -v imx_signer >/dev/null; then
		echo "buildboot: error: imx_signer is unavailable; enter the buildboot Nix shell" >&2
		return 2
	fi

	(
		cd "$OUT_DIR/imx-boot-tools"
		SIG_DATA_PATH="$OUT_DIR/hab-data" \
			imx_signer -d -i "$BOOT_IMAGE" -c "$OUT_DIR/csf_hab4.cfg"
	)
}
