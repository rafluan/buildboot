#!/usr/bin/env bash

# Prepare signing inputs, sign the image, and keep the usual output filename.
do_sign_hab_image_imx8m() {
	local image_dir="$OUT_DIR/imx-boot-tools"
	local image="$image_dir/$BOOT_IMAGE"
	local signed_image="$image_dir/signed-$BOOT_IMAGE"

	if [[ ! -s "$image" ]]; then
		echo "buildboot: error: boot image is missing: $image" >&2
		return 2
	fi

	rm -f "$signed_image"
	run_task do_prepare_hab_signing_data
	run_task do_run_hab_signer

	if [[ ! -s "$signed_image" ]]; then
		echo "buildboot: error: signer did not create $signed_image" >&2
		return 2
	fi

	mv -f "$signed_image" "$image"
	echo "HAB-signed image: $image"
}
