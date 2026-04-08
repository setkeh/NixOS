{ pkgs, config, ... }:

{
   home.packages = [
    pkgs.vim
    pkgs.gemini-cli
    pkgs.btop
    pkgs.xclip
    pkgs.feh
    pkgs.nerd-fonts.space-mono
    pkgs.imagemagick 
    pkgs.obs-studio
    pkgs.slack
    pkgs.kbfs
    pkgs.keybase
    pkgs.keybase-gui
    pkgs.unzip
    pkgs.gnupg
    pkgs.udisks
    pkgs.ncdu
    pkgs.scrot
    pkgs.jq
    /* pkgs.virt-manager */
    /* pkgs.awscli2 */
    pkgs.tmux
    pkgs.smartmontools
    pkgs.terminator
    pkgs.xlockmore
    pkgs.dmenu
    pkgs.slstatus
    pkgs.discord
    pkgs.calc
    pkgs.chromium
    pkgs.gparted
    pkgs.p7zip
    pkgs.ntfs3g
    pkgs.freerdp
    pkgs.spotify
    pkgs.cryptomator
    pkgs.gqrx
    pkgs.neofetch
    pkgs._1password-cli
    pkgs._1password-gui
    pkgs.rofi
    /* pkgs.rnix-lsp RIP @jD91mZM2 */
    pkgs.vivaldi
    pkgs.ipmitool
    pkgs.xz
    pkgs.perl
    pkgs.ipmiview
    pkgs.file
    pkgs.appimage-run
    pkgs.nix-prefetch-scripts
    pkgs.asciinema
    pkgs.dbeaver-bin
    pkgs.ripgrep
    pkgs.websocat
    pkgs.mcrcon
    pkgs.filezilla
    pkgs.arandr
    pkgs.weechat
    pkgs.openssl
    pkgs.xclip
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.postman
    /* pkgs.s3cmd */
    pkgs.vscode
    pkgs.mc
    pkgs.yubikey-manager
    pkgs.age-plugin-yubikey
  ];
}