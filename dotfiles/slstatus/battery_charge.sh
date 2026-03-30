#!/bin/sh

BAT_PERC=$(/run/current-system/sw/bin/cat /sys/class/power_supply/BAT0/capacity)
BAT_STATE=$(/run/current-system/sw/bin/cat /sys/class/power_supply/BAT0/status)


if [[ "$BAT_PERC" -lt 10 && "$BAT_STATE" == "Discharging" ]]; then
  # Output in red if less than 10%
  echo "󰁺 ^c#FF0000^ $BAT_PERC%"
elif [[ "$BAT_STATE" == "Charging" || "$BAT_STATE" == "Full" ]]; then
  echo "󰂄 $BAT_PERC%"
elif [[ "$BAT_STATE" == "Not Charging" ]]; then
  echo "󰂃 $BAT_PERC%"
else
  # Output in normal color otherwise
  echo "󰁾 $BAT_PERC%"
fi

