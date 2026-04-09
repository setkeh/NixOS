{ config, pkgs, lib, ... }:

{
  nixpkgs = {
    overlays = [
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