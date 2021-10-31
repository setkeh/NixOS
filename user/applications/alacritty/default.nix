{ config, lib, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = lib.attrsets.recursiveUpdate (import /home/setkeh/.config/nixpkgs/dotfiles/alacritty/default.nix) {
      shell.program = "/home/setkeh/.nix-profile/bin/fish";
    };
  };
}
