#!/usr/bin/env bash

do_compile_uboot_imx8m() {
	local out="$OUT_DIR/uboot"
	make -C "$UBOOT_DIR" "O=$out" "-j$JOBS"
	make -C "$UBOOT_DIR" "O=$out" "-j$JOBS" dtbs
}

do_compile_uboot_imx95() {
	local out="$OUT_DIR/uboot"
	make -C "$UBOOT_DIR" "O=$out" "-j$JOBS"
	make -C "$UBOOT_DIR" "O=$out" "-j$JOBS" dtbs
}
