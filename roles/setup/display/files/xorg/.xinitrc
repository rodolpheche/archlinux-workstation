# set screen resolution
autorandr --change

# needed by dunst
systemctl --user import-environment DISPLAY

# launch i3
exec i3
