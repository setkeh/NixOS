{ config, lib, pkgs, ... }:

{
  # Import the Modules
  imports = [
    ./user/packages.nix
    ./user/non-nix-dots.nix
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
  home.stateVersion = "21.05";

  programs.git = {
    enable = true;
    userName = "James <SETKEH> Griffis";
    userEmail = "setkeh@gmail.com";
    signing = { 
      signByDefault = true;
      key = "1DE2EE2BD0F84215";
    };
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      opl = "eval (op signin griffis)";
    };
  };

  services.kbfs.enable = true;
  services.keybase.enable = true;

  programs.go.enable = true;

  programs.alacritty = {
    enable = true;
    settings = lib.attrsets.recursiveUpdate (import ./dotfiles/alacritty/default.nix) {
      shell.program = "/home/setkeh/.nix-profile/bin/fish";
    };
  };
}
