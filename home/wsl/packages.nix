{ pkgs, config, ... }:

{
   home.packages = with pkgs; [
     git
     vim
     btop
     tmux
     curl
     wget
     age-plugin-yubikey
   ];
}
