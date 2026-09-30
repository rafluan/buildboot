#!/usr/bin/env bash

do_prepare_dek_blob_artifacts_imx8m() {
	run_task do_read_dek_blob_layout
	run_task do_render_dek_blob_csfs
	run_task do_encrypt_dek_blob_image
	run_task do_create_dek_blob_assembler
}
