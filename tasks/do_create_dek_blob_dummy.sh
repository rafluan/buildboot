#!/usr/bin/env bash

do_create_dek_blob_dummy_imx8m() {
	dd if=/dev/zero of="$OUT_DIR/imx-boot-tools/dek_blob_fit_dummy.bin" \
		bs=96 count=1 status=none
}
