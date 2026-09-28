#!/usr/bin/env bash

do_compile_oei_imx95() {
	local toolchain="${ARM_NONE_EABI_PREFIX}gcc"
	: "${OEI_BOARD:?missing OEI board}"
	: "${OEI_DDR_CONFIG:?missing OEI DDR configuration}"
	: "${OEI_REVISION:?missing OEI silicon revision}"
	if ! command -v "$toolchain" >/dev/null 2>&1; then
		echo "buildboot: error: required compiler not found: $toolchain" >&2
		return 2
	fi

	make -C "$OEI_DIR" "-j$JOBS" \
		"board=$OEI_BOARD" "DEBUG=1" "DDR_CONFIG=$OEI_DDR_CONFIG" \
		"r=$OEI_REVISION" "OEI_CROSS_COMPILE=$ARM_NONE_EABI_PREFIX" oei=ddr
	make -C "$OEI_DIR" "-j$JOBS" \
		"board=$OEI_BOARD" "DEBUG=0" "DDR_CONFIG=$OEI_DDR_CONFIG" \
		"r=$OEI_REVISION" "OEI_CROSS_COMPILE=$ARM_NONE_EABI_PREFIX" oei=tcm
}
