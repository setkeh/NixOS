{ config, pkgs, lib, inputs, ... }:

{
  pkgs = import inputs.nixpkgs {
    overlays = [
      /* My Custom Package Channel */
      (import ./nixpkgs-channel.nix { inherit inputs; })

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