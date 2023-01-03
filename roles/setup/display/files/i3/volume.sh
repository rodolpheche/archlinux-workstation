#!/bin/bash

function get_volume {
  pactl get-sink-volume "$(pactl get-default-sink)" | head -1 | sed -E 's/^.* ([0-9]+)% .*/\1/'
}

function is_mute {
  pactl get-sink-mute "$(pactl get-default-sink)" | grep yes
}

function send_notification {
  volume="$(get_volume)"
  if [ "$volume" -eq 0 ]
  then
    icon=audio-volume-muted
  elif [ "$volume" -lt 30 ]
  then
    icon=audio-volume-low
  elif [ "$volume" -lt 30 ]
  then
    icon=audio-volume-low
  elif [ "$volume" -lt 70 ]
  then
    icon=audio-volume-medium
  else
    icon=audio-volume-high
  fi
  dunstify -i $icon -t 1000 -r 4242 -u normal "Volume: $volume" -h int:value:"$volume"
}

case $1 in
    up)
      VOLUME='+5%'
      pactl set-sink-mute "$(pactl get-default-sink)" false
      if [ "$(get_volume)" -lt 120 ]
      then
        pactl set-sink-volume "$(pactl get-default-sink)" $VOLUME
      fi
      send_notification
      ;;
    down)
      VOLUME='-5%'
      pactl set-sink-mute "$(pactl get-default-sink)" false
      pactl set-sink-volume "$(pactl get-default-sink)" $VOLUME
      send_notification
      ;;
    toggle)
      pactl set-sink-mute "$(pactl get-default-sink)" toggle
      if is_mute ; then
        dunstify -i audio-volume-muted -t 1000 -r 4242 -u normal "Mute" -h int:value:0
      else
        send_notification
      fi
      ;;
esac
