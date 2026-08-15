{ config, pkgs, lib, ... }: {
  imports = [
    /* Packages */
    ./packages.nix

    /* Common Configs */
    ../../common/git.nix
    /*../../common/services.nix*/

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

    /* Lan-Mouse */
    ./lan-mouse

    /* Obsidian */
    ./obsidian
  ];

  xdg.configFile."wallpapers" = {
    source = ../../common/wallpapers;
    recursive = true;
  };

  programs.alacritty.settings = {
    font.size = lib.mkForce 8.0;
  };

  # Basic user info
  home.stateVersion = "26.05";
}