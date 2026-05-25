#!/bin/bash
# scripts/cliphist-watch.sh
while true; do
  wl-paste --type text --watch cliphist store
  wl-paste --type image --watch cliphist store
  sleep 1
done
