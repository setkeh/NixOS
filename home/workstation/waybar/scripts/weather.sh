# shellcheck shell=bash
#
# Waybar weather module — Open-Meteo backend.
#
# Wrapped by pkgs.writeShellApplication (which supplies the shebang and
# `set -euo pipefail`), so this file deliberately has no shebang line.
#
# Location is fixed rather than geolocated. Override at runtime with
# WEATHER_LAT / WEATHER_LON / WEATHER_LABEL / WEATHER_TZ if needed.

LAT="${WEATHER_LAT:--33.5231}"
LON="${WEATHER_LON:-151.3133}"
LABEL="${WEATHER_LABEL:-Umina Beach}"
TZNAME="${WEATHER_TZ:-Australia/Sydney}"

# Only hit the network this often (seconds). Waybar may poll more frequently;
# anything inside the window is served from cache.
MAX_AGE="${WEATHER_MAX_AGE:-900}"

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
RAW="$CACHE_DIR/weather.json"

mkdir -p "$CACHE_DIR"

URL="https://api.open-meteo.com/v1/forecast"
URL+="?latitude=$LAT&longitude=$LON"
URL+="&timezone=$(printf '%s' "$TZNAME" | sed 's|/|%2F|g')"
URL+="&wind_speed_unit=kmh&temperature_unit=celsius&precipitation_unit=mm"
URL+="&current=temperature_2m,apparent_temperature,relative_humidity_2m"
URL+=",is_day,precipitation,weather_code,wind_speed_10m,wind_direction_10m"
URL+=",wind_gusts_10m,surface_pressure,cloud_cover"
URL+="&daily=weather_code,temperature_2m_max,temperature_2m_min"
URL+=",precipitation_sum,precipitation_probability_max,uv_index_max,sunrise,sunset"
URL+="&forecast_days=5"

stale=1
if [ -s "$RAW" ]; then
    now="$(date +%s)"
    mtime="$(stat -c %Y "$RAW" 2>/dev/null || echo 0)"
    if [ "$((now - mtime))" -lt "$MAX_AGE" ]; then
        stale=0
    fi
fi

if [ "$stale" -eq 1 ]; then
    tmp="$(mktemp "$CACHE_DIR/weather.XXXXXX")"
    if curl -sf --max-time 12 --compressed "$URL" -o "$tmp" \
        && jq -e '.current.temperature_2m != null' "$tmp" >/dev/null 2>&1; then
        mv -f "$tmp" "$RAW"
    else
        rm -f "$tmp"
    fi
fi

if [ ! -s "$RAW" ]; then
    printf '%s\n' '{"text":"","tooltip":"Weather unavailable — no data and no cache.","class":["weather","weather-error"]}'
    exit 0
fi

# shellcheck disable=SC2016  # the jq program uses jq variables, not shell ones
jq -c --arg label "$LABEL" '
  def desc(c):
      if   c == 0  then "Clear sky"
      elif c == 1  then "Mainly clear"
      elif c == 2  then "Partly cloudy"
      elif c == 3  then "Overcast"
      elif c == 45 then "Fog"
      elif c == 48 then "Rime fog"
      elif c == 51 then "Light drizzle"
      elif c == 53 then "Drizzle"
      elif c == 55 then "Heavy drizzle"
      elif c == 56 or c == 57 then "Freezing drizzle"
      elif c == 61 then "Light rain"
      elif c == 63 then "Rain"
      elif c == 65 then "Heavy rain"
      elif c == 66 or c == 67 then "Freezing rain"
      elif c == 71 then "Light snow"
      elif c == 73 then "Snow"
      elif c == 75 then "Heavy snow"
      elif c == 77 then "Snow grains"
      elif c == 80 then "Light showers"
      elif c == 81 then "Showers"
      elif c == 82 then "Violent showers"
      elif c == 85 then "Light snow showers"
      elif c == 86 then "Snow showers"
      elif c == 95 then "Thunderstorm"
      elif c == 96 then "Thunderstorm, hail"
      elif c == 99 then "Thunderstorm, heavy hail"
      else "Unknown (code \(c))" end;

  # Nerd Font weather glyphs (Weather Icons range).
  def icon(c; day):
      if   c == 0             then (if day then "\ue30d" else "\ue32b" end)
      elif c == 1 or c == 2   then (if day then "\ue302" else "\ue379" end)
      elif c == 3             then "\ue312"
      elif c == 45 or c == 48 then "\ue313"
      elif c >= 51 and c <= 57 then (if day then "\ue30b" else "\ue31c" end)
      elif c >= 61 and c <= 67 then (if day then "\ue308" else "\ue318" end)
      elif c >= 71 and c <= 77 then (if day then "\ue30a" else "\ue31a" end)
      elif c >= 80 and c <= 82 then (if day then "\ue309" else "\ue319" end)
      elif c == 85 or c == 86 then "\ue31a"
      elif c >= 95            then (if day then "\ue30f" else "\ue31d" end)
      else "\ue374" end;

  # Coarse bucket used as a CSS class so the stylesheet can tint the module.
  def bucket(c):
      if   c <= 1  then "clear"
      elif c <= 3  then "cloudy"
      elif c <= 48 then "fog"
      elif c <= 67 then "rain"
      elif c <= 77 then "snow"
      elif c <= 86 then "showers"
      else "storm" end;

  def compass(d):
      ["N","NNE","NE","ENE","E","ESE","SE","SSE",
       "S","SSW","SW","WSW","W","WNW","NW","NNW"][ (((d / 22.5) + 0.5) | floor) % 16 ];

  def r0: . + 0.5 | floor;
  def r1: (. * 10 | round) / 10;
  def pad(n): tostring | (" " * (n - length)) + .;
  def hhmm: split("T")[1][0:5];
  def dayname: split("T")[0] | strptime("%Y-%m-%d") | mktime | strftime("%a");

  .current      as $c
| .daily        as $d
| ($c.is_day == 1) as $day
| ($c.weather_code) as $code
| ($c.temperature_2m | r0) as $t

| ([ "<b>\($label)</b>",
     "\(icon($code; $day))  <big>\($t)°C</big>   \(desc($code))",
     "Feels like \($c.apparent_temperature | r0)°C   ·   Humidity \($c.relative_humidity_2m | r0)%",
     "Wind \($c.wind_speed_10m | r0) km/h \(compass($c.wind_direction_10m))   ·   Gusts \($c.wind_gusts_10m | r0) km/h",
     "Cloud \($c.cloud_cover | r0)%   ·   Rain now \($c.precipitation | r1) mm   ·   \($c.surface_pressure | r0) hPa",
     "Sunrise \($d.sunrise[0] | hhmm)   ·   Sunset \($d.sunset[0] | hhmm)",
     "",
     "<b>Forecast</b>"
   ]
   + [ range(0; ($d.time | length)) as $i
       | "\($d.time[$i] | dayname)  \(icon($d.weather_code[$i]; true))  "
         + "\($d.temperature_2m_min[$i] | r0 | pad(3))° / \($d.temperature_2m_max[$i] | r0 | pad(3))°   "
         + "\($d.precipitation_probability_max[$i] // 0 | r0 | pad(3))% rain   "
         + "UV \($d.uv_index_max[$i] // 0 | r0)"
     ]
   | join("\n")) as $tooltip

| {
    text:    "\(icon($code; $day)) \($t)°",
    alt:     desc($code),
    tooltip: $tooltip,
    class:   [ "weather", bucket($code), (if $day then "day" else "night" end) ]
  }
' "$RAW"
