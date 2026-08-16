# shellcheck shell=bash
#
# Waybar AMD GPU module — reads amdgpu sysfs directly. No root, no daemon.
#
# Wrapped by pkgs.writeShellApplication (supplies shebang + set -euo pipefail),
# so this file deliberately has no shebang line.
#
# Override device discovery with GPU_DEVICE=/sys/class/drm/card1/device

# Nerd Font glyph is emitted by jq (which always understands \uXXXX) rather
# than by bash's $'\uXXXX', whose output depends on the active locale.
ICON_JSON='\uEBA9'   # nf-cod-circuit_board

# --- helpers ----------------------------------------------------------------

# Read a sysfs file, echoing "" when missing or unreadable.
rd() {
    if [ -r "$1" ]; then
        cat "$1" 2>/dev/null || true
    fi
}

# Integer division with rounding.
rdiv() {
    echo $(( ($1 + $2 / 2) / $2 ))
}

# True when the argument is a non-empty positive integer.
pos() {
    case "${1:-}" in
        '' | *[!0-9]* ) return 1 ;;
        * ) [ "$1" -gt 0 ] ;;
    esac
}

fail() {
    jq -cn --arg tooltip "$1" \
        "{ text: \"$ICON_JSON  --\", tooltip: \$tooltip, class: [\"gpu\", \"gpu-error\"] }"
    exit 0
}

# --- locate the GPU and its hwmon -------------------------------------------

DEV="${GPU_DEVICE:-}"

if [ -z "$DEV" ]; then
    for candidate in /sys/class/drm/card[0-9]*/device; do
        [ -d "$candidate" ] || continue
        [ "$(rd "$candidate/vendor")" = "0x1002" ] || continue   # 0x1002 = AMD
        [ -r "$candidate/gpu_busy_percent" ] || continue
        DEV="$candidate"
        break
    done
fi

if [ -z "$DEV" ] || [ ! -d "$DEV" ]; then
    fail "No amdgpu device exposing gpu_busy_percent found under /sys/class/drm"
fi

CARD="$(basename "$(dirname "$DEV")")"

HWMON=""
for candidate in "$DEV"/hwmon/hwmon[0-9]*; do
    if [ -d "$candidate" ]; then
        HWMON="$candidate"
        break
    fi
done

# --- collect ----------------------------------------------------------------

busy="$(rd "$DEV/gpu_busy_percent")"
if ! [ "${busy:-x}" -ge 0 ] 2>/dev/null; then
    fail "gpu_busy_percent unreadable for $CARD"
fi

mem_busy="$(rd "$DEV/mem_busy_percent")"
vram_used="$(rd "$DEV/mem_info_vram_used")"
vram_total="$(rd "$DEV/mem_info_vram_total")"

temp_edge=""
temp_junction=""
temp_mem=""
power_w=""
fan_rpm=""
sclk_mhz=""
mclk_mhz=""

if [ -n "$HWMON" ]; then
    # Resolve temperatures by label so edge/junction/mem stay correct per card.
    for lbl in "$HWMON"/temp[0-9]*_label; do
        [ -r "$lbl" ] || continue
        val="$(rd "${lbl%_label}_input")"
        pos "$val" || continue
        case "$(rd "$lbl")" in
            edge)     temp_edge="$(rdiv "$val" 1000)" ;;
            junction) temp_junction="$(rdiv "$val" 1000)" ;;
            mem)      temp_mem="$(rdiv "$val" 1000)" ;;
        esac
    done

    # Fall back to temp1 when the card exposes no labels at all.
    if [ -z "$temp_edge" ]; then
        raw="$(rd "$HWMON/temp1_input")"
        if pos "$raw"; then
            temp_edge="$(rdiv "$raw" 1000)"
        fi
    fi

    # power1_average is the smoothed board draw; power1_input is instantaneous.
    power_uw="$(rd "$HWMON/power1_average")"
    if ! pos "$power_uw"; then
        power_uw="$(rd "$HWMON/power1_input")"
    fi
    if pos "$power_uw"; then
        power_w="$(rdiv "$power_uw" 1000000)"
    fi

    rpm="$(rd "$HWMON/fan1_input")"
    if pos "$rpm"; then
        fan_rpm="$rpm"
    fi

    f1="$(rd "$HWMON/freq1_input")"   # sclk, Hz
    f2="$(rd "$HWMON/freq2_input")"   # mclk, Hz
    if pos "$f1"; then sclk_mhz="$(rdiv "$f1" 1000000)"; fi
    if pos "$f2"; then mclk_mhz="$(rdiv "$f2" 1000000)"; fi
fi

# --- render -----------------------------------------------------------------

vram_line=""
if pos "$vram_total" && [ -n "$vram_used" ]; then
    used_mib="$(rdiv "$vram_used" 1048576)"
    total_mib="$(rdiv "$vram_total" 1048576)"
    vram_pct="$(( vram_used * 100 / vram_total ))"
    vram_line="VRAM     ${used_mib} / ${total_mib} MiB  (${vram_pct}%)"
fi

hot="${temp_junction:-${temp_edge:-0}}"

class="gpu"
if [ "$hot" -ge 90 ]; then
    class="gpu gpu-critical"
elif [ "$hot" -ge 75 ]; then
    class="gpu gpu-warning"
elif [ "$busy" -ge 80 ]; then
    class="gpu gpu-busy"
fi

lines=("<b>GPU</b>  ${CARD}" "Load     ${busy}%")
if [ -n "$mem_busy" ];      then lines+=("Mem bus  ${mem_busy}%"); fi
if [ -n "$vram_line" ];     then lines+=("$vram_line"); fi
if [ -n "$temp_edge" ];     then lines+=("Edge     ${temp_edge}°C"); fi
if [ -n "$temp_junction" ]; then lines+=("Hotspot  ${temp_junction}°C"); fi
if [ -n "$temp_mem" ];      then lines+=("VRAM T   ${temp_mem}°C"); fi
if [ -n "$power_w" ];       then lines+=("Power    ${power_w} W"); fi
if [ -n "$fan_rpm" ];       then lines+=("Fan      ${fan_rpm} RPM"); fi
if [ -n "$sclk_mhz" ];      then lines+=("Core     ${sclk_mhz} MHz"); fi
if [ -n "$mclk_mhz" ];      then lines+=("Memory   ${mclk_mhz} MHz"); fi

# -c matters: Waybar's json return-type parses exactly one object per line, so
# pretty-printed output fails on the bare "{" of line 1.
printf '%s\n' "${lines[@]}" |
    jq -Rsc --arg busy "$busy" --arg class "$class" \
        "{ text: \"$ICON_JSON \\(\$busy | tostring)%\",
           tooltip: rtrimstr(\"\\n\"),
           class: (\$class | split(\" \")) }"
