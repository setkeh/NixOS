{ config, pkgs, lib, ... }:

{
  nixpkgs = {
    overlays = [
      (import ./slstatus.nix)
      (import ./dwm.nix)
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
}