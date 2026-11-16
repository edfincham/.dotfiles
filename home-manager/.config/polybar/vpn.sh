#!/usr/bin/env bash
set -o pipefail

vpn=
if interfaces=$(wg show interfaces 2>/dev/null); then
  for iface in $interfaces; do
    [[ -r /sys/class/net/$iface/flags ]] || continue
    read -r flags < "/sys/class/net/$iface/flags"
    if ((flags & 1)); then
      vpn="${vpn:+$vpn+}WG:$iface"
    fi
  done
else
  unknown=1
fi

if state=$(timeout 3 tailscale status --json 2>/dev/null | jq -er 'if .BackendState == "Running" and .Self.Online == true then "on" else "off" end' 2>/dev/null); then
  [[ $state == on ]] && vpn="${vpn:+$vpn+}TS"
else
  unknown=1
fi

status=${vpn:-off}
[[ -z $vpn && -n ${unknown:-} ]] && status=unavailable
printf 'VPN %s\n' "$status"
