{pkgs, config, lib,  ...}:
with builtins;
with lib;
let
  cfg = config.sys.shell;
in {
  options.sys.shell = {
    fish = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable zsh for use on this system";
      };
    };
  };

  config = mkIf cfg.fish.enable {

    # Enable Home Manager Fish Module
    programs.fish.enable = true;

    # Enable Home Manager Starship Prompt Module
    programs.starship.enable = true;

    imports = [
      ../../dotfiles/fish/init.nix
    ];

  };
}
