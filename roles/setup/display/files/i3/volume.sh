#!/bin/bash

function get_volume {
  pactl get-sink-volume 0 | head -1 | sed -E 's/^.* ([0-9]+)% .*/\1/'
}

function is_mute {
  pactl get-sink-mute 0 | grep yes
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
      for SINK in $(pactl list sinks short | cut -b1)
      do
        pactl set-sink-mute "$SINK" false
        if [ "$(get_volume)" -lt 120 ]
        then
          pactl set-sink-volume "$SINK" $VOLUME
        fi
      done
      send_notification
      ;;
    down)
      VOLUME='-5%'
      for SINK in $(pactl list sinks short | cut -b1)
      do
        pactl set-sink-mute "$SINK" false
        pactl set-sink-volume "$SINK" $VOLUME
      done
      send_notification
      ;;
    toggle)
      for SINK in $(pactl list sinks short | cut -b1)
      do
        pactl set-sink-mute "$SINK" toggle
      done
      if is_mute ; then
        dunstify -i audio-volume-muted -t 1000 -r 4242 -u normal "Mute" -h int:value:0
      else
        send_notification
      fi
      ;;
esac
