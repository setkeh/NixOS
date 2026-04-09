{ config, pkgs, ... }:

{
  programs.fish.shellAliases = {
    nswitch = builtins.readFile config.sops.secrets.fish-alias.fish.nswitch.path;
  };
  #programs.fish.shellAliases = {
  #    builtins.readFile config.age.secrets.fish-alias.path
  #};
}
