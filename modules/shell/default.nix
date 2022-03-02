{pkgs, config, lib, ...}:
{
  imports = [
    ./fish.nix
    ./tmux.nix
    ./zsh.nix
  ];
}
