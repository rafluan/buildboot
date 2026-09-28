#!/usr/bin/env bash

do_configure_uboot_imx8m() {
	make -C "$UBOOT_DIR" "O=$OUT_DIR/uboot" "$UBOOT_DEFCONFIG"
}

do_configure_uboot_imx95() {
	make -C "$UBOOT_DIR" "O=$OUT_DIR/uboot" "$UBOOT_DEFCONFIG"
}
