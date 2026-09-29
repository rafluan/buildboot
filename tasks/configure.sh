#!/usr/bin/env bash

do_configure_imx8m() {
	run_task do_configure_uboot
	run_task do_copy_imx_mkimage
	run_task do_copy_ddr_firmware
}

# Keep the standard i.MX8M setup and enable HAB only for the HAB variant.
do_configure_imx8m_hab() {
	do_configure_imx8m
	run_task do_enable_hab_uboot
}

do_configure_imx95() {
	run_task do_configure_uboot
	run_task do_copy_imx_mkimage
	run_task do_copy_ddr_firmware
	run_task do_copy_ele_firmware
}
