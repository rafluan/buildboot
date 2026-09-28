#!/usr/bin/env bash

do_compile_system_manager_imx95() {
	local toolchain="${ARM_NONE_EABI_PREFIX}gcc"
	: "${SYSTEM_MANAGER_CONFIG:?missing System Manager configuration}"
	if ! command -v "$toolchain" >/dev/null 2>&1; then
		echo "buildboot: error: required compiler not found: $toolchain" >&2
		return 2
	fi

	make -C "$SYSTEM_MANAGER_DIR" \
		"config=$SYSTEM_MANAGER_CONFIG" \
		"SM_CROSS_COMPILE=$ARM_NONE_EABI_PREFIX" cfg
	make -C "$SYSTEM_MANAGER_DIR" "-j$JOBS" \
		"config=$SYSTEM_MANAGER_CONFIG" \
		"SM_CROSS_COMPILE=$ARM_NONE_EABI_PREFIX" img
}
