#!/bin/bash

LOGFILE="./logs/startup.log"
DISPLAY="$1"
NAME="Xvfb"
MAX_RETRIES=10
RETRY_DELAY=2

echo "[+] Waiting for $NAME on $DISPLAY..." | tee -a "$LOGFILE"

for ((i=1; i<=MAX_RETRIES; i++)); do
    if xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
        echo "[✓] $NAME is ready." | tee -a "$LOGFILE"
        exit 0
    fi
    echo "  [$i/$MAX_RETRIES] $NAME not ready yet..." | tee -a "$LOGFILE"
    sleep "$RETRY_DELAY"
done

echo "[-] Timeout waiting for $NAME." | tee -a "$LOGFILE"
exit 1