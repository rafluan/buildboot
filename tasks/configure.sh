#!/usr/bin/env bash

do_configure_imx8m() {
	run_task do_configure_uboot
	run_task do_copy_imx_mkimage
	run_task do_copy_ddr_firmware
}

do_configure_imx95() {
	run_task do_configure_uboot
	run_task do_copy_imx_mkimage
	run_task do_copy_ddr_firmware
	run_task do_copy_ele_firmware
}
