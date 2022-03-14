{ config, lib, pkgs, ... }:

{
  # Doom Emacs
  home.file.".doom.d/config.el".source = ../dotfiles/doom-emacs/config.el;
  home.file.".doom.d/init.el".source = ../dotfiles/doom-emacs/init.el;
  home.file.".doom.d/packages.el".source = ../dotfiles/doom-emacs/packages.el;

  #QuteBrowser
  home.file.".config/qutebrowser/config.py".source = ../dotfiles/qutebrowser/config.py;
  home.file.".config/qutebrowser/1pass.py".source = ../dotfiles/qutebrowser/1pass.py;

  #TMUX
  home.file.".tmux.conf".source = ../dotfiles/tmux/tmux.conf;
}
