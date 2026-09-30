#!/usr/bin/env bash

do_compile_imx_atf_dek_blob_imx8m() {
	local out="$OUT_DIR/atf"
	: "${CROSS_COMPILE:?enter the arm64 Nix shell so CROSS_COMPILE is set}"

	env -u LDFLAGS make -C "$ATF_DIR" \
		"-j$JOBS" \
		"CROSS_COMPILE=$CROSS_COMPILE" \
		"BUILD_BASE=$out" "PLAT=$ATF_PLATFORM" SPD=opteed bl31
}
