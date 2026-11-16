#!/usr/bin/env bash

read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat || exit 1
idle1=$((idle + iowait))
total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
sleep 0.5
read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat || exit 1
total=$((user + nice + system + idle + iowait + irq + softirq + steal - total1))
((total > 0)) || exit 1
usage=$((100 * (total - (idle + iowait - idle1)) / total))

for name in /sys/class/hwmon/hwmon*/name; do
  [[ -r $name && $(<"$name") == k10temp ]] || continue
  input=${name%name}temp1_input
  [[ -r $input ]] || continue
  read -r temp < "$input" || continue
  [[ $temp =~ ^[0-9]+$ ]] || continue
  printf 'CPU %d%% %d°C\n' "$usage" "$((temp / 1000))"
  exit 0
done
