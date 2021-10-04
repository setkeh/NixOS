{ config, lib, pkgs, ... }:

{
  home.file.".doom.d/config.el".source = ../dotfiles/doom-emacs/config.el;
  home.file.".doom.d/init.el".source = ../dotfiles/doom-emacs/init.el;
  home.file.".doom.d/packages.el".source = ../dotfiles/doom-emacs/packages.el;
}
