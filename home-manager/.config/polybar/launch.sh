#!/usr/bin/env bash

monitors=$(xrandr --listactivemonitors | awk 'NR > 1 {print $NF}')
[ -n "$monitors" ] || { echo 'polybar: no active monitors' >&2; exit 1; }
primary=$(xrandr --query | awk '$2 == "connected" && $3 == "primary" {print $1; exit}')
primary=${primary:-${monitors%%$'\n'*}}

# Nix wraps polybar, so its process name isn't "polybar".
bars='/polybar (main|secondary)$'
pkill -u "$(id -u)" -f "$bars" || true
while pgrep -u "$(id -u)" -f "$bars" >/dev/null; do sleep 0.1; done

while IFS= read -r monitor; do
  if [ "$monitor" = "$primary" ]; then
    MONITOR="$monitor" polybar main &
  else
    MONITOR="$monitor" polybar secondary &
  fi
done <<< "$monitors"
