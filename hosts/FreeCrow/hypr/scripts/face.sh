#!/bin/bash

WEATHER_CACHE="/tmp/hyprlock_weather"
BLINK_STATE="/tmp/hyprlock_blink"
SEC=$(date +%s)
HOUR=$(date +%H)

# update weather cache every 10 minutes
if [ ! -f "$WEATHER_CACHE" ] || [ $((SEC % 600)) -eq 0 ]; then
  curl -s "wttr.in/Uberlândia?format=%c+%t+%C" >"$WEATHER_CACHE" 2>/dev/null
fi
WEATHER=$(cat "$WEATHER_CACHE" 2>/dev/null)

# cpu usage
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)

# temperature from weather
TEMP=$(echo "$WEATHER" | grep -oP '\+?\-?\d+' | head -1)

# night: 22:00 - 06:00
is_night() {
  [ "$HOUR" -ge 22 ] || [ "$HOUR" -lt 6 ]
}

# rain check
is_raining() {
  echo "$WEATHER" | grep -qiE "rain|drizzle|storm|thunder"
}

# blink logic — stored state
if [ ! -f "$BLINK_STATE" ]; then
  echo "0 0 1" >"$BLINK_STATE" # phase, count, next_blink_count
fi
read PHASE COUNT NEXT <"$BLINK_STATE"

if [ "$PHASE" -eq 0 ]; then
  # open eyes, check if it's time to blink
  if [ $((SEC % 5)) -eq 0 ]; then
    NEXT=$((RANDOM % 3 + 1))
    echo "1 0 $NEXT" >"$BLINK_STATE"
  fi
else
  # blinking phase
  COUNT=$((COUNT + 1))
  if [ "$COUNT" -ge $((NEXT * 2)) ]; then
    echo "0 0 1" >"$BLINK_STATE"
  else
    echo "$PHASE $COUNT $NEXT" >"$BLINK_STATE"
  fi
fi

# sleeping z cycle
ZS=$(((SEC / 2) % 4))
case $ZS in
0) SLEEPFACE="(＿ ＿*)" ;;
1) SLEEPFACE="‎   (＿ ＿*) z" ;;
2) SLEEPFACE="‎      (＿ ＿*) z z" ;;
3) SLEEPFACE="‎        (＿ ＿*) z z Z" ;;
esac

# cpu wobble
if [ $((SEC % 2)) -eq 0 ]; then
  CPUFACE="Σ(°△°|||)︴"
else
  CPUFACE=" Σ(°△°|||)︴"
fi

# pick face
if [ "${CPU:-0}" -gt 80 ]; then
  echo "$CPUFACE"
elif is_raining; then
  echo "(￣▽￣) ☂"
elif is_night; then
  echo "$SLEEPFACE"
elif [ "${TEMP:-0}" -gt 32 ]; then
  echo "☀(▀U ▀-͠)"
else
  # default with blink
  if [ "$PHASE" -eq 1 ] && [ $((COUNT % 2)) -eq 0 ]; then
    echo "(^‿^)"
  else
    echo "(◕‿◕)"
  fi
fi
