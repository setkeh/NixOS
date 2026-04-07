{ config, lib, pkgs, ... }:

{
  home.file.".config/nixpkgs/config.nix".source = ../config.nix;
}
