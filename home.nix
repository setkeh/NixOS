{ config, lib, pkgs, ... }:

{
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

  programs.fish.enable = true;

  services.kbfs.enable = true;
  services.keybase.enable = true;

  programs.alacritty = {
    enable = true;
    settings = lib.attrsets.recursiveUpdate (import ./dotfiles/alacritty/default.nix) {
      shell.program = "/home/setkeh/.nix-profile/bin/fish";
    };
  };

  home.packages = [
    pkgs.htop
    pkgs.imagemagick
    pkgs.vagrant
    pkgs.gcc
    pkgs.python3
    pkgs.gnumake
    pkgs.obs-studio
    pkgs.zoom-us
    pkgs.slack
    pkgs.teams
    pkgs.kbfs
    pkgs.keybase
    pkgs.keybase-gui
    pkgs.unzip
    pkgs.wget
    pkgs.gnupg
    pkgs.udisks
    pkgs.ncdu
    pkgs.scrot
    pkgs.jq
    pkgs.virt-manager
    pkgs.awscli2
    pkgs.tmux
    pkgs.docker-compose
    pkgs.smartmontools
    pkgs.terminator
    pkgs.xlockmore
    pkgs.dmenu
    pkgs.discord
    pkgs.calc
    pkgs.pavucontrol
    pkgs.arduino
    pkgs.freecad
    pkgs.slic3r
    pkgs.jre8
    pkgs.chromium
    pkgs.gparted
    pkgs.p7zip
    pkgs.ntfs3g
    pkgs.freerdp
    pkgs.kdenlive
    pkgs.spotify
    pkgs.cryptomator
    pkgs.gqrx
    pkgs.vlc
    pkgs.gnome.cheese
    pkgs.terraform
    pkgs.ansible
    pkgs.ansible-lint
    pkgs.hugo
  ];
}
