# flake.nix --- the heart of my dotfiles
#
# Author:  James <SETKEH> Griffis <setkeh@gmail.com>
# URL:     https://github.com/setkeh/nixpkgs
# License: MIT
#
# Welcome to ground zero. Where the whole flake gets set up and all its modules
# are loaded.

{
  description = "An Upsettingly Setkeh NixOS configuration";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixos-unstable;

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nixpkgs, home-manager, ... }:
    let
      lib = import ./lib;
    in {
    nixosConfigurations = {
      laptop = lib.mkNixOSConfig {
        name = "laptop";
        system = "x86_64_linux";

        imports = [
          hosts/laptop/laptop.nix
        ];

        sys.users.primaryUser.extraGroups = [ "wheel" "networkmanager" "libvirtd" "docker" ];
        sys.security.username = "wil";
      };
    };
  };
}
