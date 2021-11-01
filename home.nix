{ config, lib, pkgs, ... }:

{
  # Import the Modules
  imports = [
    ./user/packages.nix
    ./user/non-nix-dots.nix
    ./user/applications/fish/init.nix
    #./user/applications/fish/plugins.nix
    ./user/applications/fish/functions.nix
    ./user/applications/alacritty/default.nix
    ./user/applications/git/default.nix
    ./user/applications/go/default.nix
    ./user/applications/keybase/default.nix

  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "setkeh";
  home.homeDirectory = "/home/setkeh";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  #home.stateVersion = "21.05";
}
