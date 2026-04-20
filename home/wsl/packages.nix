{ pkgs, config, ... }:

{
   home.packages = with pkgs; [
     git
     vim
     btop
     tmux
     curl
     wget
     direnv
     age-plugin-yubikey
   ];
}
