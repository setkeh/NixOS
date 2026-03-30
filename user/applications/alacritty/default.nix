{ config, lib, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = lib.attrsets.recursiveUpdate (import ../../../dotfiles/alacritty/default.nix) {
      terminal.shell.program = "/home/setkeh/.nix-profile/bin/fish";
    };
  };
}
