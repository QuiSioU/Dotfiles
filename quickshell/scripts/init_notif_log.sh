#!/bin/sh
# quickshell/scripts/init_notif_log.sh


if [ "$#" -ne 1 ]; then
    echo "Usage: ./init_notif_log.sh <log_path>"
    exit 1
fi

LOG="$1"
SESSION_FILE="${LOG%json}session"

mkdir -p "$(dirname "$LOG")"

CURRENT="$XDG_SESSION_ID"
STORED=$(cat "$SESSION_FILE" 2>/dev/null)

if [ "$CURRENT" != "$STORED" ]; then
    printf '[]' > "$LOG"
    printf '%s' "$CURRENT" > "$SESSION_FILE"
fi
