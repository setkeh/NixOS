{ config, lib, pkgs, ... }:

{
  # Import the Modules
  imports = [
    ./user/packages.nix
    ./user/non-nix-dots.nix
    ./user/applications/fish/init.nix
    ./user/applications/fish/plugins.nix
    ./user/applications/fish/functions.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "setkeh";
  home.homeDirectory = "/home/setkeh";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";

  programs.git = {
    enable = true;
    userName = "James <SETKEH> Griffis";
    userEmail = "setkeh@gmail.com";
    signing = { 
      signByDefault = true;
      key = "1DE2EE2BD0F84215";
    };
  };

  home.sessionVariables = {
    PATH = "$PATH:/home/setkeh/go/bin";
    GOBIN = "/home/setkeh/go/bin";
    _JAVA_AWT_WM_NONREPARENTING = 1;
  };

#  programs.fish = {
#    enable = true;
#    plugins = [{
#      name = "hydro";
#      src = pkgs.fetchFromGitHub {
#        owner = "setkeh";
#        repo = "hydro";
#        rev = "7068cf4b8e77d638be3e9b5872e916502fbc6bc8";
#        sha256 = "0nwz632cyvc0pvfv9i1ba75cs9yjy2wmfyhxnp53pipc84h9yca8";
#      };
#    }];
#    shellAliases = {
##    };

#    functions = {
#      fish_greeting = {
#        description = "fish greeting";
#        body = "echo Hello Fish";
#      interactiveShellInit = ''

#      '';
# };

  services.kbfs.enable = true;
  services.keybase.enable = true;

  programs.go = {
    enable = true;
    packages = {
      "github.com/sirupsen/logrus" = builtins.fetchGit "https://github.com/sirupsen/logrus";
      "golang.org/x/sys" = builtins.fetchGit "https://go.googlesource.com/sys";
    };
  };

  programs.alacritty = {
    enable = true;
    settings = lib.attrsets.recursiveUpdate (import ./dotfiles/alacritty/default.nix) {
      shell.program = "/home/setkeh/.nix-profile/bin/fish";
    };
  };
}
