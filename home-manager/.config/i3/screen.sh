#!/bin/bash

# first argument: primary monitor
# second argument: secondary monitor
if  xrandr | grep -q "$2 d"; then
	xrandr --output "$2" --off
else
	xrandr --output "$2" --auto
	xrandr --output "$2" --above "$1"
fi

# restart i3wm
i3-msg restart > /dev/null
