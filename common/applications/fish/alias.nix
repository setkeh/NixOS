{ config, pkgs, ... }:

{
  programs.fish.shellAliases = {
    nswitch = builtins.readFile builtins.readFile config.age.secrets.fish-alias.path;
  }
  #programs.fish.shellAliases = {
  #    builtins.readFile config.age.secrets.fish-alias.path
  #};
}
