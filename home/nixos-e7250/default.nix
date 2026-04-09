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
  ];

  nixpkgs = {
    overlays = [
      (import ../../etc/overlays/age.nix)
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  # Enable X Compositing
  services.picom.enable = true;

  # Basic user info
  home.stateVersion = "25.11";
}