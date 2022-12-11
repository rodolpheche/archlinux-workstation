# set default screen resolution
xrandr --output eDP-1 --mode 1920x1080 --scale 1x1 --primary
xrandr --output DP-2-1 --mode 1920x1080 --scale 1x1 --primary
xrandr --output eDP-1 --mode 1920x1080 --scale 1x1 --right-of DP-2-1

# needed by dunst
systemctl --user import-environment DISPLAY

# launch i3
exec i3
