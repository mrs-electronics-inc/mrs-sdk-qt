#!/usr/bin/env bash

set -eu

echo "Checking local env variables..."

REQUIRED_VARS=(
	"MRS_SDK_QT_ROOT"
)

success=0
for var in "${REQUIRED_VARS[@]}"; do
	# Get actual value via indirect expansion
	var_value="${!var}"

	# Check if value is empty or unset
	if [[ -z "$var_value" ]]; then
		echo "$var is not set. Export it in your shell profile (e.g., export $var=<value>)." >&2
		success=1
	fi
done

if [[ $success -eq 0 ]]; then
	echo "Local environment looks OK."
fi

exit $success
