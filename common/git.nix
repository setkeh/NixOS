{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings.user.name = "James <SETKEH> Griffis";
    settings.user.email = config.age.secrets.gpg-email.path;
    signing = {
      signByDefault = true;
      key = "FA929DF32F5BEA3FDBBDA2A86740B732D3507B5E";
    };
  };
}
