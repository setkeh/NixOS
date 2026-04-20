# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:

{
  imports = [
    ./wsl.nix
    ./services.nix
    ../../common/gpg.nix
    ../../common/cleanup.nix
  ];

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  /* Switch Shell to Fish */
  programs.fish.enable = true;
  users.users.setkeh.shell = pkgs.fish;

  # Allow unfree packages and eperimental features.
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  /* These packages to make yubikey work */
  environment.systemPackages = with pkgs; [
    wget
    socat
    linuxPackages.usbip
    yubikey-manager
    libfido2
    ccid
    age-plugin-yubikey
    age
  ];

  services.openssh = {
    enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
