#!/usr/bin/env bash

run_encrypted_task() {
	local task="$1"
	local soc="${SOC,,}"
	local candidate

	case "$soc" in
		imx8m*) candidate="${task}_imx8m_${BUILD_SECURITY}_${BUILD_ENCRYPTION}" ;;
		*)
			echo "buildboot: error: encryption is not supported on $soc" >&2
			return 2
			;;
	esac

	if ! declare -F "$candidate" >/dev/null; then
		echo "buildboot: error: no encrypted implementation for $task ($soc)" >&2
		return 2
	fi

	echo ">>> $candidate"
	"$candidate"
}
