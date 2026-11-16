#!/usr/bin/env bash

coords=$(xdotool getmouselocation --shell) || exit 1
x=$(awk -F= '$1 == "X" {print $2}' <<< "$coords")
y=$(awk -F= '$1 == "Y" {print $2}' <<< "$coords")
[[ $x =~ ^[0-9]+$ && $y =~ ^[0-9]+$ ]] || exit 1

read -r left top width height < <(
  xrandr --listactivemonitors | awk -v x="$x" -v y="$y" '
    NR > 1 {
      split($3, g, "[/x+]")
      if (x >= g[5] && x < g[5] + g[1] && y >= g[6] && y < g[6] + g[3]) {
        print g[5], g[6], g[1], g[3]
        exit
      }
    }'
)
[[ $left =~ ^[0-9]+$ && $top =~ ^[0-9]+$ && $width =~ ^[0-9]+$ && $height =~ ^[0-9]+$ ]] || exit 1

# shortcut: Polybar exposes no module bounds; center on the click, revisit if it exposes geometry.
posx=$((x - 130))
((posx < left)) && posx=$left
((posx > left + width - 260)) && posx=$((left + width - 260))

export GTK_THEME=Adwaita:dark
# i3 places YAD's floating window 2px right and 12px below the requested position.
exec yad --calendar --title=polybar-calendar --undecorated --fixed --no-buttons \
  --close-on-unfocus --width=260 --height=230 \
  --posx="$((posx - 2))" --posy="$((top + height - 30 - 230 - 12))"
