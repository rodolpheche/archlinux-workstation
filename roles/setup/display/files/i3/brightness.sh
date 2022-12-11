#!/bin/bash

function get_brightness {
  brightnessctl | grep '%' | head -n 1 | cut -d '(' -f 2 | cut -d '%' -f 1
}

function send_notification {
  brightness=$(get_brightness)
  if [ "$brightness" -eq 0 ]
  then
    icon=audio-brightness-muted
  elif [ "$brightness" -lt 30 ]
  then
    icon=audio-brightness-low
  elif [ "$brightness" -lt 30 ]
  then
    icon=audio-brightness-low
  elif [ "$brightness" -lt 70 ]
  then
    icon=audio-brightness-medium
  else
    icon=audio-brightness-high
  fi
  dunstify -i $icon -t 1000 -r 4242 -u normal "Brightness: $brightness%" -h int:value:"$brightness"
}

case $1 in
    up)
      brightnessctl set 5%+
      send_notification
      ;;
    down)
      brightnessctl set 5%-
      send_notification
      ;;
esac
