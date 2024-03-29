{ pkgs, config, ... }:

{
   home.packages = [
    pkgs.htop
    pkgs.nerdfonts
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
    #pkgs.freecad
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
    pkgs.rnix-lsp
    pkgs.terraform-lsp
    pkgs.python39Packages.pip
    pkgs.vivaldi
    pkgs.cgminer
    pkgs.ipmitool
    #pkgs.giblib
    pkgs.binutils
    pkgs.xz
    pkgs.lzma
    pkgs.perl
    pkgs.ipmiview
    pkgs.file
    pkgs.steam-run
    pkgs.appimage-run
    pkgs.nix-prefetch-scripts
    pkgs.asciinema
    pkgs.dbeaver
    pkgs.ripgrep
    pkgs.websocat
    pkgs.mcrcon
    pkgs.filezilla
    pkgs.arandr
    pkgs.wimlib
    pkgs.weechat
    pkgs.cargo
    pkgs.rustc
    pkgs.rls
    pkgs.pkg-config
    pkgs.openssl
    pkgs.xclip
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.postman
    pkgs.drone-cli
    pkgs.s3cmd
  ];
}
