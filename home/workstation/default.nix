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

    /* Btop */
    ../../common/applications/btop

    /* Wayland / Niri WM Config */
    ./mako.nix
    ./niri.nix
    ./waybar

    /* Lan-Mouse */
    ./lan-mouse

    /* Obsidian */
    ./obsidian

    /* Sandboxes */
    ./sandboxes/ollama.nix

    /* Hermes Desktop */
    ./hermes

    /* Llama-cpp */
    ./llama-cpp
  ];

  xdg.configFile."wallpapers" = {
    source = ../../common/wallpapers;
    recursive = true;
  };

  programs = {
    alacritty = {
      settings = {
        font.size = lib.mkForce 8.0;
      };
    };

    btop = {
      settings = {
        show_battery = lib.mkForce false;
        net_iface = lib.mkForce "bond0";
      };
    };

    mc = {
      enable = true;
    };
  };

  xdg.mimeApps = {
  enable = true;
    defaultApplications = {
      # Registers the custom protocol link used for Lychee cloud logins
      "x-scheme-handler/lycheeslicer" = [ "lycheeslicer.desktop" ];
      
      # Optional: Map standard 3D print file extensions to open in Lychee automatically
      "model/stl" = [ "lycheeslicer.desktop" ];
      "model/3mf" = [ "lycheeslicer.desktop" ];
    };
  };

  # Basic user info
  home.stateVersion = "26.05";
}