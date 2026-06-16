{ pkgs, config, ... }:

{
   home.packages = [
    pkgs.vim
    pkgs.btop
    pkgs.xclip
    pkgs.feh
    pkgs.nerd-fonts.space-mono
    pkgs.imagemagick
    pkgs.unzip
    pkgs.gnupg
    pkgs.udisks
    pkgs.ncdu
    pkgs.scrot
    pkgs.jq
    pkgs.tmux
    pkgs.smartmontools
    pkgs.dmenu
    pkgs.slstatus
    pkgs.vivaldi
    pkgs.ipmitool
    pkgs.xz
    pkgs.ipmiview
    pkgs.nix-prefetch-scripts
    pkgs.asciinema
    pkgs.arandr
    pkgs.weechat
  ];
}