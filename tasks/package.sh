#!/usr/bin/env bash

do_package_imx8m() {
	run_task do_copy_uboot
	run_task do_copy_imx_atf
	run_task do_copy_dtbs
	run_task do_package_imx_boot
}

do_package_imx95() {
	run_task do_copy_uboot
	run_task do_copy_imx_atf
	run_task do_copy_oei
	run_task do_copy_system_manager
	run_task do_package_imx_boot
}
