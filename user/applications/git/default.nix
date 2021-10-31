{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "James <SETKEH> Griffis";
    userEmail = "setkeh@gmail.com";
    signing = {
      signByDefault = true;
      key = "1DE2EE2BD0F84215";
    };
  };
}
