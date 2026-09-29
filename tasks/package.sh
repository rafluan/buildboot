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

do_package_imx95() {
	run_task do_copy_uboot
	run_task do_copy_imx_atf
	run_task do_copy_oei
	run_task do_copy_system_manager
	run_task do_package_imx_boot
}
