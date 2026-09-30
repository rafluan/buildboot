#!/usr/bin/env bash

do_package_imx8m() {
	run_task do_copy_uboot
	run_task do_copy_imx_atf
	run_task do_copy_dtbs
	run_task do_package_imx_boot
}

# Build the usual image, then replace it with its signed form.
do_package_imx8m_hab() {
	do_package_imx8m
	run_task do_sign_hab_image
}

do_package_imx8m_hab_dek_blob() {
	local stage="$OUT_DIR/imx-boot-tools"
	local generator_image="dek-blob-generator-$BOOT_IMAGE"

	run_task do_copy_uboot
	run_task do_copy_imx_atf_dek_blob
	run_task do_copy_optee
	run_task do_copy_dtbs
	run_task do_create_dek_blob_dummy
	run_task do_package_imx_boot
	run_task do_copy_dek_blob_plain_image
	run_task do_sign_hab_image
	cp -f "$stage/$BOOT_IMAGE" "$stage/$generator_image"
	run_task do_prepare_dek_blob_artifacts
	echo "DEK-blob generator image: $stage/$generator_image"
}

do_package_imx95() {
	run_task do_copy_uboot
	run_task do_copy_imx_atf
	run_task do_copy_oei
	run_task do_copy_system_manager
	run_task do_package_imx_boot
}
