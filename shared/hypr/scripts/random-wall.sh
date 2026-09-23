#!/bin/bash

DIRS=(
  "$HOME/dotfiles/shared/wallpapers/photography"
)

# start the daemon if not already running
if ! pgrep -x awww-daemon >/dev/null; then
  awww-daemon &
  # wait until it's actually ready instead of a blind sleep
  for i in {1..20}; do
    awww query &>/dev/null && break
    sleep 0.5
  done
fi

while true; do
  WALL=$(find "${DIRS[@]}" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
  if [[ -z "$WALL" ]]; then
    echo "No wallpapers found in ${DIRS[*]}" >&2
  else
    awww img "$WALL" --transition-type random
  fi
  sleep 300
done
