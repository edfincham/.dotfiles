# to run the script, you need to install imagemagick and scrot
img=/tmp/i3lock.png

scrot -o $img
convert $img -scale 10% -scale 1000% $img

i3lock -u -i $img
