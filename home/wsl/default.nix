{ config, pkgs, ... }: {
  imports = [
    ./packages.nix
  ];

  # Basic user info
  home.username = "setkeh";
  home.homeDirectory = "/home/setkeh";
  home.stateVersion = "25.11";

  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
