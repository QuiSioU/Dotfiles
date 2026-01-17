#!/bin/bash

# Clean up on exit (SIGTERM or SIGINT)
cleanup() {
	# ...
	exit 0
}
trap cleanup SIGINT SIGTERM


# Actual logic

print_json() {
	# DAY
	DAY=$(date +"%d")

	# WEEKDAY
	WEEKDAY=$(date +"%a")

	# MONTH NUMBER
	MONTH_NUM=$(date +"%m")

	# MONTH
	MONTH=$(date +"%b")

	# YEAR
	YEAR=$(date +"%Y")

	# TIME = 15:50
	TIME=$(date +"%H:%M")

	# Output as a single JSON line
	printf '{"day": "%s", "weekday": "%s", "month_num": "%s", "month": "%s", "year": "%s", "time": "%s"}\n'\
		"$DAY" "$WEEKDAY" "$MONTH_NUM" "$MONTH" "$YEAR" "$TIME"
}

# Initial print
print_json

while true; do
    sleep $((60 - $(date +%-S)))
    print_json
done

