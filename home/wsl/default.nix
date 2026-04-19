{ config, pkgs, ... }: {
  imports = [
    /* Packages */
    ./packages.nix

    /* Common Configs */
    ../../common/git.nix

    /* Fish Imports */
    ../../common/applications/fish/init.nix
    ../../common/applications/fish/plugins.nix
    ../../common/applications/fish/functions.nix

    /* Tmux Config */
    ../../common/applications/tmux/e7250.nix
  ];

  # Basic user info
  home.username = "setkeh";
  home.stateVersion = "25.11";

  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
