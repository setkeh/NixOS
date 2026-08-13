{ config, pkgs, lib, ... }: {
  imports = [
    /* Packages */
    ./packages.nix

    /* Common Configs */
    ../../common/git.nix
    ../../common/services.nix

    /* Fish Imports */
    ../../common/applications/fish/init.nix
    ../../common/applications/fish/plugins.nix
    ../../common/applications/fish/functions.nix

    /* Alacritty Terminal */
    ../../common/applications/alacritty/default.nix

    /* Tmux Config */
    ../../common/applications/tmux/e7250.nix

    /* SSH Configuration */
    ../../common/ssh.nix

    /* Wayland / Niri WM Config */
    ./mako.nix
    ./niri.nix
  ];

  # Enable X Compositing
  services.picom.enable = true;

  xdg.configFile."wallpapers" = {
    source = ../../common/wallpapers;
    recursive = true;
  };

  # Basic user info
  home.stateVersion = "25.11";
}