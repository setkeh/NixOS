{ config, lib, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = lib.attrsets.recursiveUpdate (import ../../../dotfiles/alacritty/default.nix) {
      terminal.shell.program = "/etc/profiles/per-user/setkeh/bin/fish";
    };
  };
}
