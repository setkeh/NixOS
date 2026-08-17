{ config, pkgs, lib, ... }:

let
  # ---------------------------------------------------------------------------
  # Nerd Font glyphs
  #
  # Written as JSON \uXXXX escapes so this file stays plain ASCII. Pasting raw
  # private-use characters into Nix source survives badly across editors,
  # terminals and diffs; this round-trips cleanly and self-documents.
  #
  # Only Basic Multilingual Plane glyphs (U+E000..U+F8FF) are used — the
  # Material Design set in Nerd Fonts v3 lives above U+FFFF and would need
  # surrogate pairs here.
  # ---------------------------------------------------------------------------
  glyph = code: builtins.fromJSON ''"\u${code}"'';

  icons = {
    nixos      = glyph "F313";  # nf-linux-nixos
    cpu        = glyph "F4BC";  # nf-oct-cpu
    memory     = glyph "F2DB";  # nf-fa-microchip
    disk       = glyph "F0A0";  # nf-fa-hdd_o
    ethernet   = glyph "EBCA";  # nf-cod-server
    wifi       = glyph "F1EB";  # nf-fa-wifi
    unlinked   = glyph "F127";  # nf-fa-chain_broken
    volHigh    = glyph "F028";  # nf-fa-volume_up
    volLow     = glyph "F027";  # nf-fa-volume_down
    volMute    = glyph "F026";  # nf-fa-volume_off
    headphone  = glyph "F025";  # nf-fa-headphones
    bluetooth  = glyph "F293";  # nf-fa-bluetooth
  };

  # ---------------------------------------------------------------------------
  # Scripts
  #
  # writeShellApplication pins each script's runtime dependencies into its own
  # PATH and runs shellcheck at build time, so a broken module fails the
  # home-manager build instead of silently rendering an empty slot on the bar.
  # ---------------------------------------------------------------------------
  weatherScript = pkgs.writeShellApplication {
    name = "waybar-weather";
    runtimeInputs = with pkgs; [ curl jq coreutils gnused ];
    text = builtins.readFile ./scripts/weather.sh;
  };

  gpuScript = pkgs.writeShellApplication {
    name = "waybar-gpu";
    runtimeInputs = with pkgs; [ jq coreutils ];
    text = builtins.readFile ./scripts/gpu.sh;
  };

  cpuTempScript = pkgs.writeShellApplication {
    name = "waybar-cputemp";
    runtimeInputs = with pkgs; [ jq coreutils ];
    text = builtins.readFile ./scripts/cputemp.sh;
  };

  # Real-time signal used to force a weather refresh on click.
  weatherSignal = 8;

  terminal = "${pkgs.alacritty}/bin/alacritty";
  btop = "${terminal} --class btop -e ${pkgs.btop}/bin/btop";
  ncdu = "${terminal} --class ncdu -e ${pkgs.ncdu}/bin/ncdu /";
in
{
  programs.waybar = {
    enable = true;

    # Waybar is launched by niri (spawn-at-startup in config-machine.kdl), so
    # the home-manager systemd unit stays off to avoid two instances racing.
    systemd.enable = false;

    settings.mainBar = {
      layer = "top";
      position = "top";
      spacing = 0;
      reload_style_on_change = true;

      modules-left = [
        "custom/logo"
        "niri/workspaces"
        "niri/window"
      ];

      modules-center = [
        "clock"
        "custom/weather"
        
      ];

      modules-right = [
        "disk"
        "memory"
        "cpu"
        "custom/cputemp"
        "custom/gpu"
        "pulseaudio"
        "network"
        "tray"
      ];

      # -- left -----------------------------------------------------------

      "custom/logo" = {
        format = icons.nixos;
        tooltip = false;
        on-click = "${pkgs.fuzzel}/bin/fuzzel";
      };

      clock = {
        interval = 1;
        format = "{:%a %d %b  %I:%M:%S %p}";
        format-alt = "{:%Y-%m-%d  %H:%M:%S}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "month";
          mode-mon-col = 3;
          weeks-pos = "right";
          on-scroll = 1;
          format = {
            months = "<span color='#e6e6e6'><b>{}</b></span>";
            days = "<span color='#aeaeae'>{}</span>";
            weeks = "<span color='#89b4fa'><b>W{}</b></span>";
            weekdays = "<span color='#f9e2af'><b>{}</b></span>";
            today = "<span color='#cba6f7'><b><u>{}</u></b></span>";
          };
        };
        actions = {
          on-click-right = "mode";
          on-scroll-up = "shift_up";
          on-scroll-down = "shift_down";
        };
      };

      # Fixed to Umina Beach — see scripts/weather.sh. Left click drops the
      # cache and signals waybar for an immediate refetch.
      "custom/weather" = {
        format = "{}";
        return-type = "json";
        exec = "${weatherScript}/bin/waybar-weather";
        interval = 600;
        signal = weatherSignal;
        on-click =
          "${pkgs.coreutils}/bin/rm -f \"\${XDG_CACHE_HOME:-$HOME/.cache}/waybar/weather.json\"; "
          + "${pkgs.procps}/bin/pkill -RTMIN+${toString weatherSignal} waybar";
      };

      "niri/window" = {
        format = "{title}";
        max-length = 70;
        separate-outputs = true;
        tooltip = false;
        rewrite = {
          "(.*) [-—] Mozilla Firefox" = "$1";
          "(.*) - Visual Studio Code" = "$1";
          "(.*) - Vivaldi" = "$1";
          "^$" = "";
        };
      };

      # -- centre ---------------------------------------------------------

      "niri/workspaces" = {
        # {value} renders the workspace name when it has one (you have
        # "common" and "media" named in config-machine.kdl) and the index
        # otherwise.
        format = "{value}";
        all-outputs = false;
        disable-click = false;
        enable-bar-scroll = true;
      };

      # -- right ----------------------------------------------------------

      disk = {
        interval = 30;
        path = "/";
        format = "${icons.disk}  {percentage_used}%";
        tooltip-format = "{used} used of {total}  ({percentage_used}%)\n{free} free on {path}";
        on-click = ncdu;
      };

      memory = {
        interval = 5;
        format = "${icons.memory}  {percentage}%";
        tooltip-format = "RAM   {used:0.1f} / {total:0.1f} GiB  ({percentage}%)\nSwap  {swapUsed:0.1f} / {swapTotal:0.1f} GiB";
        on-click = btop;
      };

      cpu = {
        interval = 2;
        format = "${icons.cpu}  {usage}%";
        tooltip-format = "CPU   {usage}%\nLoad  {load}";
        on-click = btop;
      };

      "custom/cputemp" = {
        format = "{}";
        return-type = "json";
        exec = "${cpuTempScript}/bin/waybar-cputemp";
        interval = 5;
        on-click = btop;
      };

      "custom/gpu" = {
        format = "{}";
        return-type = "json";
        exec = "${gpuScript}/bin/waybar-gpu";
        interval = 3;
        on-click = btop;
      };

      pulseaudio = {
        format = "{icon}  {volume}%";
        format-bluetooth = "${icons.bluetooth}  {volume}%";
        format-muted = "${icons.volMute}  muted";
        format-icons = {
          headphone = icons.headphone;
          headset = icons.headphone;
          default = [ icons.volMute icons.volLow icons.volHigh ];
        };
        scroll-step = 5;
        tooltip-format = "{desc}\n{volume}%";
        on-click = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "${pkgs.pwvucontrol}/bin/pwvucontrol";
      };

      network = {
        interval = 5;
        format-ethernet = "${icons.ethernet}";
        format-wifi = "${icons.wifi}  {signalStrength}%";
        format-linked = "${icons.ethernet}  no IP";
        format-disconnected = "${icons.unlinked}";
        # Click swaps the glyph for the address — no external dependency, which
        # matters because NetworkManager is not enabled on this host.
        format-alt = "${icons.ethernet}  {ipaddr}";
        tooltip-format = "{ifname}\n{ipaddr}/{cidr}   gw {gwaddr}\n↓ {bandwidthDownBytes}   ↑ {bandwidthUpBytes}";
        tooltip-format-wifi = "{essid}  ({signalStrength}%)\n{ifname}   {ipaddr}/{cidr}\n↓ {bandwidthDownBytes}   ↑ {bandwidthUpBytes}";
        tooltip-format-disconnected = "No network";
      };

      tray = {
        icon-size = 16;
        spacing = 10;
      };
    };

    style = builtins.readFile ./style.css;
  };
}
