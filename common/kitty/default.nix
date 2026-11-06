{ config, lib, pkgs, ... }:

# Mirrors the Alacritty look (dotfiles/alacritty) so the two can be compared side by side.
{
  programs.kitty = {
    enable = true;

    font = {
      name = "SpaceMono Nerd Font";
      size = 6.0;
    };

    settings = {
      shell = "/etc/profiles/per-user/setkeh/bin/fish -C fastfetch";

      background_opacity = "0.85";
      window_padding_width = 10;
      hide_window_decorations = "yes";

      cursor_shape = "beam";
      cursor_blink_interval = 0;

      scrollback_lines = 10000;
      enable_audio_bell = "no";

      background = "#1b182c";
      foreground = "#cbe3e7";

      color0 = "#100e23";
      color1 = "#ff8080";
      color2 = "#95ffa4";
      color3 = "#ffe9aa";
      color4 = "#91ddff";
      color5 = "#c991e1";
      color6 = "#aaffe4";
      color7 = "#cbe3e7";

      color8 = "#565575";
      color9 = "#ff5458";
      color10 = "#62d196";
      color11 = "#ffb378";
      color12 = "#65b2ff";
      color13 = "#906cff";
      color14 = "#63f2f1";
      color15 = "#a6b3cc";
    };
  };
}
