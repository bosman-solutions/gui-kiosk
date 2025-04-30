#!/bin/bash
set -e

export DISPLAY=:1
XAUTH_FILE="$HOME/.Xauthority"
LOGFILE="./logs/startup.log"
mkdir -p ./logs

APP_BIN="$APP_COMMAND"

log() { echo "$1" | tee -a "$LOGFILE"; }

cleanup_locks() {
  log "[*] Cleaning old X locks"
  rm -rf /tmp/.X*-lock /tmp/.X11-unix/X*
}

start_xvfb() {
  log "[1/5] Starting Xvfb..."
  Xvfb $DISPLAY -screen 0 1280x800x24 >> "$LOGFILE" 2>&1 &
  ./wait-for.sh "$DISPLAY"
}

generate_xauth() {
  if [ ! -f "$XAUTH_FILE" ]; then
    log "[2/5] Generating Xauthority file"
    xauth generate "$DISPLAY" . trusted
  fi
}

start_app() {
  log "[3/5] Launching $APP_LABEL..."
  $APP_BIN $APP_ARGS >> "$LOGFILE" 2>&1 &
  sleep 2

  if pgrep -f "$APP_COMMAND" > /dev/null; then
    pgrep -a -f "$APP_COMMAND" >> "$LOGFILE"
    log "[✓] $APP_LABEL launched successfully."
  else
    log "[✗] $APP_LABEL failed to launch. Process not found."
    exit 1
  fi
}

start_x11vnc() {
  log "[4/5] Starting x11vnc..."
  x11vnc -display $DISPLAY -rfbport 5901 -listen 0.0.0.0 \
    -noxdamage -noshm -forever -shared -nopw \
    -auth "$XAUTH_FILE" >> "$LOGFILE" 2>&1 &
}

start_novnc() {
  log "[5/5] Starting noVNC..."
  /opt/noVNC/utils/novnc_proxy --vnc 127.0.0.1:5901 \
    --listen 0.0.0.0:6080 >> "$LOGFILE" 2>&1 &
}

trap_exit() {
  trap 'log "[-] Shutdown signal received"; kill 0' SIGINT SIGTERM
  wait
}

main() {
  cleanup_locks
  start_xvfb
  generate_xauth
  start_app
  start_x11vnc
  start_novnc
  log "[✓] $APP_LABEL is now browser-accessible."
  trap_exit
}

main