#!/usr/bin/env bash

do_compile_imx8m() {
	run_task do_compile_uboot
	run_task do_compile_imx_atf
	run_task do_compile_imx_mkimage
}

# HAB plus DEK-blob support needs OP-TEE and the OP-TEE dispatcher in ATF.
do_compile_imx8m_hab_dek_blob() {
	run_task do_compile_uboot
	run_task do_compile_optee
	run_task do_compile_imx_atf_dek_blob
	run_task do_compile_imx_mkimage
}

do_compile_imx95() {
	run_task do_compile_uboot
	run_task do_compile_imx_atf
	run_task do_compile_oei
	run_task do_compile_system_manager
	run_task do_compile_imx_mkimage
}
