{ config, pkgs, ... }:

{
  programs.fish.shellAliases = builtins.readFile config.age.secrets.fish-alias.path;
  #programs.fish.shellAliases = {
  #    builtins.readFile config.age.secrets.fish-alias.path
  #};
}
