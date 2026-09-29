#!/usr/bin/env bash

do_compile_imx_atf_imx8m() {
	local out="$OUT_DIR/atf"
	: "${CROSS_COMPILE:?enter the arm64 Nix shell so CROSS_COMPILE is set}"

	env -u LDFLAGS make -C "$ATF_DIR" \
		"CROSS_COMPILE=$CROSS_COMPILE" \
		"BUILD_BASE=$out" "PLAT=$ATF_PLATFORM" bl31
}

do_compile_imx_atf_imx95() {
	local out="$OUT_DIR/atf"
	: "${CROSS_COMPILE:?enter the ARM64 cross-compilation environment so CROSS_COMPILE is set}"

	env -u LDFLAGS make -C "$ATF_DIR" \
		"CROSS_COMPILE=$CROSS_COMPILE" \
		"BUILD_BASE=$out" "PLAT=$ATF_PLATFORM" bl31
}
