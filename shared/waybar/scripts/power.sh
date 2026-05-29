#!/bin/bash
state=$(eww get show-power)
if [ "$state" = "true" ]; then
  eww update show-power=false
else
  eww update show-power=true
fi
