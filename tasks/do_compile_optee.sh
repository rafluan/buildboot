#!/usr/bin/env bash

# Build OP-TEE into OUT_DIR so its source checkout stays unchanged.
do_compile_optee_imx8m() {
	: "${CROSS_COMPILE:?enter the arm64 Nix shell so CROSS_COMPILE is set}"
	: "${CROSS_COMPILE_ARM32:?enter the buildboot Nix shell}"
	: "${OPTEE_BOARD:?missing OP-TEE board from TOML}"

	(
		cd "$OPTEE_DIR"
		unset ARCH LDFLAGS
		make "-j$JOBS" \
			"CROSS_COMPILE=$CROSS_COMPILE_ARM32" \
			"CROSS_COMPILE64=$CROSS_COMPILE" \
			CFG_NXPCRYPT=y CFG_GEN_DEK_BLOB=y CFG_WERROR=n \
			"PLATFORM=$OPTEE_BOARD" \
			"O=$OUT_DIR/optee/build.$OPTEE_BOARD" all
	)
}
