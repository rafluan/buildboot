#!/usr/bin/env bash
set -euo pipefail

TASKS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TASK="${1:?usage: run.sh TASK}"

for file in "$TASKS_DIR"/*.sh; do
	[[ "$file" == "$TASKS_DIR/run.sh" ]] || source "$file"
done

run_task "$TASK"
