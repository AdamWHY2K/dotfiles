#!/bin/bash

pactl set-source-mute @DEFAULT_SOURCE@ toggle

MUTE_STATUS="$(pactl get-source-mute "$(pactl get-default-source)" | awk '{print $2}')"
if [ "${MUTE_STATUS}" == "no" ]; then
  notify-send --icon=mic-ready "Microphone enabled!"
elif [ "${MUTE_STATUS}" == "yes" ]; then
  notify-send --icon=mic-off "Microphone disabled!"
else
  notify-send --icon=dialog-error "! Microphone Error !"
fi
