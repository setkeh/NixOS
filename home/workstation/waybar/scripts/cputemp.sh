# shellcheck shell=bash
#
# Waybar CPU temperature module.
#
# Waybar's built-in `temperature` module needs a hardcoded hwmon index or
# thermal zone, both of which move around between boots and kernel bumps.
# This resolves the sensor by driver name + label instead, so it keeps working.
#
# Wrapped by pkgs.writeShellApplication (supplies shebang + set -euo pipefail),
# so this file deliberately has no shebang line.
#
# Override with CPUTEMP_DRIVER (default: prefer k10temp, then coretemp,
# then zenpower) and CPUTEMP_LABEL (default: Tctl).

# Nerd Font glyph is emitted by jq (which always understands \uXXXX) rather
# than by bash's $'\uXXXX', whose output depends on the active locale.
ICON_JSON='\uF2C9'   # nf-fa-thermometer_half

read -ra PREFERRED_DRIVERS <<<"${CPUTEMP_DRIVER:-k10temp coretemp zenpower}"
PREFERRED_LABEL="${CPUTEMP_LABEL:-Tctl}"

HWMON_ROOT="${CPUTEMP_HWMON_ROOT:-/sys/class/hwmon}"

WARN="${CPUTEMP_WARN:-75}"
CRIT="${CPUTEMP_CRIT:-90}"

rd() {
    if [ -r "$1" ]; then
        cat "$1" 2>/dev/null || true
    fi
}

rdiv() {
    echo $(( ($1 + $2 / 2) / $2 ))
}

pos() {
    case "${1:-}" in
        '' | *[!0-9]* ) return 1 ;;
        * ) [ "$1" -gt 0 ] ;;
    esac
}

fail() {
    jq -cn --arg tooltip "$1" \
        "{ text: \"$ICON_JSON --\", tooltip: \$tooltip, class: [\"cputemp\", \"cputemp-error\"] }"
    exit 0
}

# --- find the hwmon belonging to the CPU driver -----------------------------

HWMON=""
DRIVER=""
for want in "${PREFERRED_DRIVERS[@]}"; do
    for candidate in "$HWMON_ROOT"/hwmon[0-9]*; do
        [ -d "$candidate" ] || continue
        if [ "$(rd "$candidate/name")" = "$want" ]; then
            HWMON="$candidate"
            DRIVER="$want"
            break 2
        fi
    done
done

if [ -z "$HWMON" ]; then
    fail "No CPU temperature sensor found (looked for: ${PREFERRED_DRIVERS[*]})"
fi

# --- read every labelled temperature ----------------------------------------

primary=""
lines=("<b>CPU temperature</b>  ($DRIVER)")

for inp in "$HWMON"/temp[0-9]*_input; do
    [ -r "$inp" ] || continue
    raw="$(rd "$inp")"
    pos "$raw" || continue

    label="$(rd "${inp%_input}_label")"
    if [ -z "$label" ]; then
        label="$(basename "${inp%_input}")"
    fi

    celsius="$(rdiv "$raw" 1000)"
    lines+=("$(printf '%-8s %s°C' "$label" "$celsius")")

    if [ "$label" = "$PREFERRED_LABEL" ]; then
        primary="$celsius"
    elif [ -z "$primary" ]; then
        primary="$celsius"
    fi
done

if [ -z "$primary" ]; then
    fail "$DRIVER exposed no readable temperature inputs"
fi

class="cputemp"
if [ "$primary" -ge "$CRIT" ]; then
    class="cputemp cputemp-critical"
elif [ "$primary" -ge "$WARN" ]; then
    class="cputemp cputemp-warning"
fi

printf '%s\n' "${lines[@]}" |
    jq -Rs --arg temp "$primary" --arg class "$class" \
        "{ text: \"$ICON_JSON \\(\$temp)°C\",
           tooltip: rtrimstr(\"\\n\"),
           class: (\$class | split(\" \")) }"
