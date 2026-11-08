#!/usr/bin/env bash
# ~/.config/waybar/start-status.sh  (needs pacman-contrib for checkupdates)
n=$(checkupdates 2>/dev/null | wc -l)

if [ "$n" -gt 0 ]; then
  printf '{"text":"%s","alt":"updates","class":"updates","tooltip":"%s updates available"}\n' "$n" "$n"
else
  printf '{"text":"","alt":"default","class":"","tooltip":"Up to date"}\n'
fi
