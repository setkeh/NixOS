{ config, pkgs, lib, ... }: {
  imports = [
    ./models.nix
    ./service.nix
  ];

  xdg.enable = true;
}
