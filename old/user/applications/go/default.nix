{ config, pkgs, ... }:

{
  programs.go = {
    enable = true;
    packages = {
      "github.com/sirupsen/logrus" = builtins.fetchGit "https://github.com/sirupsen/logrus";
      "golang.org/x/sys" = builtins.fetchGit "https://go.googlesource.com/sys";
    };
  };
}
