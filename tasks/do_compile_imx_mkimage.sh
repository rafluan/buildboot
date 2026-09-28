#!/usr/bin/env bash

do_compile_imx_mkimage_imx8m() {
	local stage="$OUT_DIR/imx-boot-tools"
	make -C "$stage" -f soc.mak \
		"SOC=$IMX_SOC" "SOC_DIR=$(basename "$stage")" \
		"MKIMG=./mkimage_imx8" CC=gcc \
		'CFLAGS=-O2 -Wall -std=c99' ./mkimage_imx8
}

do_compile_imx_mkimage_imx95() {
	local stage="$OUT_DIR/imx-boot-tools"
	make -C "$MKIMAGE_DIR" "$MKIMAGE_DIR/mkimage_imx8"
	cp -f "$MKIMAGE_DIR/mkimage_imx8" "$stage/mkimage_imx8"
}
