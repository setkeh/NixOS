{ config, pkgs, age, ... }:

{
  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}
