{ pkgs, config, ... }:

{
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
    pkgs.neofetch
    pkgs.qutebrowser
    pkgs._1password
    pkgs._1password-gui
    pkgs.rofi
  ];
}
