#!/bin/bash
iface=$(nmcli -t -f DEVICE,STATE d | awk -F: '$2=="connected"{print $1;exit}')
rx1=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)
tx1=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)
sleep 1
rx2=$(cat /sys/class/net/$iface/statistics/rx_bytes 2>/dev/null || echo 0)
tx2=$(cat /sys/class/net/$iface/statistics/tx_bytes 2>/dev/null || echo 0)

rx=$(((rx2 - rx1) / 1024))
tx=$(((tx2 - tx1) / 1024))

if [[ "$1" == "up" ]]; then
  echo "${tx} KB/s"
else echo "${rx} KB/s"; fi
