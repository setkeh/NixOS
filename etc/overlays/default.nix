{ config, pkgs, lib, ... }:

{
  pkgs = import inputs.nixpkgs {
    overlays = [
      /* My Custom Package Channel */
      inputs.nixpkgs-channel.overlays.default

      /* Custom Package Configuration */
      (import ./slstatus.nix)
      (import ./dwm.nix)
      (import ./age.nix)
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
}