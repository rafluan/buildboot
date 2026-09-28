#!/usr/bin/env bash

run_task() {
	local task="$1"
	local soc="${SOC,,}"
	local candidate
	local -a candidates

	case "$soc" in
		imx8m*) candidates=("${task}_${soc}" "${task}_imx8m" "${task}_imx8" "$task") ;;
		imx8*)  candidates=("${task}_${soc}" "${task}_imx8" "$task") ;;
		imx9*)  candidates=("${task}_${soc}" "${task}_imx9" "$task") ;;
		*)      candidates=("${task}_${soc}" "$task") ;;
	esac

	for candidate in "${candidates[@]}"; do
		if declare -F "$candidate" >/dev/null; then
			echo ">>> $candidate"
			"$candidate"
			return
		fi
	done

	echo "buildboot: error: no implementation for $task (SOC=$soc)" >&2
	return 2
}
