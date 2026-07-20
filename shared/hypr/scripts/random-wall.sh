#!/bin/bash

DIRS=(
  "$HOME/dotfiles/shared/wallpapers/rally"
)

# start the daemon
hyprctl dispatch exec awww-daemon
sleep 1

while true; do
  WALL=$(find "${DIRS[@]}" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)
  awww img "$WALL" --transition-type random
  sleep 300
done
